import SwiftUI
import CoreText

/// Tách đường viền glyph của một ký tự thành các nét (contour) rời,
/// chuẩn hoá vào ô đơn vị 0…1 với trục y hướng xuống (giống toạ độ SwiftUI).
enum GlyphPath {
    static func strokes(for character: String) -> [Path] {
        guard let scalar = character.unicodeScalars.first else { return [] }

        let font = CTFontCreateWithName("AppleSDGothicNeo-Bold" as CFString, 100, nil)
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

/// Hiện các nét của một chữ cái lần lượt để minh hoạ cách viết.
struct StrokeOrderView: View {
    let character: String

    @State private var shown = 0
    private let strokes: [Path]

    init(character: String) {
        self.character = character
        self.strokes = GlyphPath.strokes(for: character)
    }

    var body: some View {
        ZStack {
            ForEach(strokes.indices, id: \.self) { index in
                NormalizedShape(normalized: strokes[index])
                    .fill(Color.accentColor)
                    .opacity(index < shown ? 1 : 0.12)
            }
        }
        .onAppear(perform: play)
        .onTapGesture(perform: play)
    }

    private func play() {
        shown = 0
        guard !strokes.isEmpty else { return }
        for index in 1...strokes.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.4) {
                withAnimation(.easeOut(duration: 0.3)) { shown = index }
            }
        }
    }
}

#Preview {
    StrokeOrderView(character: "ㅁ")
        .frame(width: 200, height: 200)
}
