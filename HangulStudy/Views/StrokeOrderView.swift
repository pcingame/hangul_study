import SwiftUI
import CoreText

/// Tập nét của một chữ cái để minh hoạ cách viết, đã chuẩn hoá vào ô 0…1.
struct StrokeGuide {
    let strokes: [Path]
    /// Bề rộng bút, theo tỉ lệ so với cạnh ô vẽ.
    let widthFraction: CGFloat
}

/// Nguồn nét cho `StrokeOrderView`: ưu tiên dữ liệu viết tay (đường trung tâm,
/// đúng thứ tự) cho 24 chữ cơ bản; các chữ khác lấy đường viền glyph của font.
@MainActor
enum StrokeSource {
    private static let font = CTFontCreateWithName("AppleSDGothicNeo-Bold" as CFString, 100, nil)
    private static var cache: [String: StrokeGuide] = [:]

    static func guide(for character: String) -> StrokeGuide {
        if let cached = cache[character] { return cached }
        let guide: StrokeGuide
        if let manual = HangulStrokes.strokes(for: character) {
            guide = StrokeGuide(strokes: manual.map(polyline), widthFraction: 0.11)
        } else {
            guide = StrokeGuide(strokes: contours(of: character), widthFraction: 0.05)
        }
        cache[character] = guide
        return guide
    }

    private static func polyline(_ points: [CGPoint]) -> Path {
        var path = Path()
        guard let first = points.first else { return path }
        path.move(to: first)
        for point in points.dropFirst() { path.addLine(to: point) }
        return path
    }

    /// Tách đường viền glyph thành các contour rời, chuẩn hoá vào ô 0…1 (y hướng xuống).
    private static func contours(of character: String) -> [Path] {
        guard let scalar = character.unicodeScalars.first else { return [] }

        var glyph: CGGlyph = 0
        var unichars = Array(String(scalar).utf16)
        guard CTFontGetGlyphsForCharacters(font, &unichars, &glyph, unichars.count),
              let cgPath = CTFontCreatePathForGlyph(font, glyph, nil) else { return [] }

        let box = cgPath.boundingBoxOfPath
        guard box.width > 0, box.height > 0 else { return [] }
        let scale = 1 / max(box.width, box.height)
        let offsetX = (1 - box.width * scale) / 2
        let offsetY = (1 - box.height * scale) / 2

        func normalize(_ p: CGPoint) -> CGPoint {
            let x = (p.x - box.minX) * scale + offsetX
            let y = (p.y - box.minY) * scale + offsetY
            return CGPoint(x: x, y: 1 - y)
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
                current.addQuadCurve(to: normalize(element.points[1]), control: normalize(element.points[0]))
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
    var normalized: Path
    func path(in rect: CGRect) -> Path {
        normalized.applying(CGAffineTransform(scaleX: rect.width, y: rect.height))
    }
}

/// Vẽ từng nét của một chữ cái lần lượt như bút đang viết: nét đang vẽ được
/// "kéo" dọc theo đường của nó (`.trim`), vẽ xong thì đứng yên và sang nét kế.
/// Tăng `token` (hoặc chạm vào view) để phát lại.
struct StrokeOrderView: View {
    let character: String
    var token: Int = 0

    /// Số nét đã vẽ xong.
    @State private var completed = 0
    /// Tiến độ 0…1 của nét đang vẽ.
    @State private var tracing: CGFloat = 0
    @State private var localReplay = 0

    private var guide: StrokeGuide { StrokeSource.guide(for: character) }

    var body: some View {
        GeometryReader { geo in
            let lineWidth = min(geo.size.width, geo.size.height) * guide.widthFraction
            let style = StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)

            ZStack {
                ForEach(guide.strokes.indices, id: \.self) { index in
                    NormalizedShape(normalized: guide.strokes[index])
                        .stroke(Color.accentColor.opacity(0.12), style: style)
                }
                ForEach(guide.strokes.indices, id: \.self) { index in
                    NormalizedShape(normalized: guide.strokes[index])
                        .trim(from: 0, to: progress(index))
                        .stroke(Color.accentColor, style: style)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .contentShape(Rectangle())
        .onTapGesture { localReplay += 1 }
        .task(id: "\(character)#\(token)#\(localReplay)") { await animate() }
    }

    private func progress(_ index: Int) -> CGFloat {
        if index < completed { return 1 }
        if index == completed { return tracing }
        return 0
    }

    private func animate() async {
        let count = guide.strokes.count
        completed = 0
        tracing = 0
        guard count > 0 else { return }

        for index in 0..<count {
            tracing = 0
            let duration = traceDuration(for: guide.strokes[index])
            withAnimation(.easeInOut(duration: duration)) { tracing = 1 }
            try? await Task.sleep(for: .seconds(duration))
            guard !Task.isCancelled else { return }

            completed = index + 1
            tracing = 0
            try? await Task.sleep(for: .seconds(0.12))
            guard !Task.isCancelled else { return }
        }
    }

    /// Nét nhiều đoạn (vòng tròn) được vẽ chậm hơn nét thẳng.
    private func traceDuration(for path: Path) -> TimeInterval {
        var segments = 0
        path.forEach { _ in segments += 1 }
        return min(0.9, 0.3 + 0.03 * Double(segments))
    }
}

#Preview {
    StrokeOrderView(character: "ㅂ")
        .frame(width: 240, height: 240)
        .padding()
}
