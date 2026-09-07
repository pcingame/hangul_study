import SwiftUI
import CoreText

/// Tách đường viền glyph của một ký tự thành các nét (contour) rời,
/// chuẩn hoá vào ô đơn vị 0…1 với trục y hướng xuống (giống toạ độ SwiftUI).
///
/// Kết quả được cache: chỉ có 40 chữ cái và việc trích xuất path bằng CoreText
/// không rẻ, nên mỗi ký tự chỉ tính một lần.
@MainActor
enum GlyphPath {
    private static let font = CTFontCreateWithName("AppleSDGothicNeo-Bold" as CFString, 100, nil)
    private static var cache: [String: [Path]] = [:]

    static func strokes(for character: String) -> [Path] {
        if let cached = cache[character] { return cached }
        let result = extract(character)
        cache[character] = result
        return result
    }

    private static func extract(_ character: String) -> [Path] {
        guard let scalar = character.unicodeScalars.first else { return [] }

        var glyph: CGGlyph = 0
        var unichars = Array(String(scalar).utf16)
        guard CTFontGetGlyphsForCharacters(font, &unichars, &glyph, unichars.count),
              let cgPath = CTFontCreatePathForGlyph(font, glyph, nil) else { return [] }

        // Bao toàn bộ path để chuẩn hoá tỉ lệ.
        let box = cgPath.boundingBoxOfPath
        guard box.width > 0, box.height > 0 else { return [] }
        let scale = 1 / max(box.width, box.height)
        let offsetX = (1 - box.width * scale) / 2
        let offsetY = (1 - box.height * scale) / 2

        func normalize(_ p: CGPoint) -> CGPoint {
            let x = (p.x - box.minX) * scale + offsetX
            let y = (p.y - box.minY) * scale + offsetY
            return CGPoint(x: x, y: 1 - y) // lật trục y
        }

        var strokes: [Path] = []
        var current = Path()

        cgPath.applyWithBlock { elementPtr in
            let element = elementPtr.pointee
            switch element.type {
            case .moveToPoint:
                if !current.isEmpty { strokes.append(current) }
                current = Path()
                current.move(to: normalize(element.points[0]))
            case .addLineToPoint:
                current.addLine(to: normalize(element.points[0]))
            case .addQuadCurveToPoint:
                current.addQuadCurve(to: normalize(element.points[1]),
                                     control: normalize(element.points[0]))
            case .addCurveToPoint:
                current.addCurve(to: normalize(element.points[2]),
                                 control1: normalize(element.points[0]),
                                 control2: normalize(element.points[1]))
            case .closeSubpath:
                current.closeSubpath()
            @unknown default:
                break
            }
        }
        if !current.isEmpty { strokes.append(current) }
        return strokes
    }
}

private struct NormalizedShape: Shape {
    let normalized: Path
    func path(in rect: CGRect) -> Path {
        normalized.applying(CGAffineTransform(scaleX: rect.width, y: rect.height))
    }
}

/// Vẽ từng nét của một chữ cái lần lượt như bút đang viết: nét đang vẽ
/// được "kéo" dọc theo đường viền, vẽ xong thì tô đặc rồi sang nét kế.
/// Tăng `token` (hoặc chạm vào view) để phát lại.
struct StrokeOrderView: View {
    let character: String
    var token: Int = 0

    /// Số nét đã vẽ xong (đang tô đặc).
    @State private var completed = 0
    /// Tiến độ 0…1 của nét đang được vẽ.
    @State private var tracing: CGFloat = 0
    @State private var localReplay = 0

    private var strokes: [Path] { GlyphPath.strokes(for: character) }

    var body: some View {
        ZStack {
            ForEach(strokes.indices, id: \.self) { index in
                if index < completed {
                    NormalizedShape(normalized: strokes[index])
                        .fill(Color.accentColor)
                } else if index == completed {
                    NormalizedShape(normalized: strokes[index])
                        .trim(from: 0, to: tracing)
                        .stroke(Color.accentColor,
                                style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
                } else {
                    NormalizedShape(normalized: strokes[index])
                        .fill(Color.accentColor)
                        .opacity(0.12)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { localReplay += 1 }
        .task(id: "\(character)#\(token)#\(localReplay)") {
            await animate()
        }
    }

    private func animate() async {
        let count = strokes.count
        completed = 0
        tracing = 0
        guard count > 0 else { return }

        let traceDuration = 0.5

        for index in 0..<count {
            tracing = 0
            withAnimation(.easeInOut(duration: traceDuration)) { tracing = 1 }
            try? await Task.sleep(for: .seconds(traceDuration))
            guard !Task.isCancelled else { return }

            completed = index + 1
            tracing = 0
            try? await Task.sleep(for: .seconds(0.12))
            guard !Task.isCancelled else { return }
        }
    }
}

#Preview {
    StrokeOrderView(character: "ㅁ")
        .frame(width: 200, height: 200)
}
