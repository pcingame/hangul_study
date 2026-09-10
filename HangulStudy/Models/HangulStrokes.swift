import CoreGraphics
import Foundation

/// Dữ liệu nét viết tay (đường trung tâm, đúng thứ tự) cho toàn bộ 40 chữ cái:
/// 24 chữ cơ bản, cộng phụ âm đôi và nguyên âm ghép (ghép từ chữ cơ bản, xem `combine`).
///
/// Toạ độ chuẩn hoá trong ô 0…1, trục y hướng xuống (giống SwiftUI).
/// Mỗi chữ là một mảng nét; mỗi nét là một polyline (đường gấp khúc).
enum HangulStrokes {
    static func strokes(for character: String) -> [[CGPoint]]? {
        table[character]
    }

    private static func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: x, y: y)
    }

    /// Polyline xấp xỉ một vòng tròn, bắt đầu từ đỉnh, đi ngược chiều kim đồng hồ.
    private static func circle(_ cx: CGFloat, _ cy: CGFloat, _ r: CGFloat, steps: Int = 28) -> [CGPoint] {
        (0...steps).map { index in
            let angle = -CGFloat.pi / 2 - (CGFloat(index) / CGFloat(steps)) * 2 * .pi
            return CGPoint(x: cx + r * cos(angle), y: cy + r * sin(angle))
        }
    }

    /// Ghép nhiều chữ cạnh nhau theo chiều ngang, mỗi chữ ép hẹp vào một cột
    /// bằng nhau (dùng cho phụ âm đôi và nguyên âm ghép).
    private static func combine(_ parts: [[[CGPoint]]]) -> [[CGPoint]] {
        let margin: CGFloat = 0.04
        let gap: CGFloat = 0.08
        let n = CGFloat(parts.count)
        let columnWidth = (1 - 2 * margin - (n - 1) * gap) / n
        return parts.enumerated().flatMap { index, strokes -> [[CGPoint]] in
            let lower = margin + CGFloat(index) * (columnWidth + gap)
            let range = lower...(lower + columnWidth)
            return strokes.map { stroke in
                stroke.map { pt(range.lowerBound + $0.x * (range.upperBound - range.lowerBound), $0.y) }
            }
        }
    }

    /// Phụ âm đôi = viết chữ cái gốc hai lần, ép hẹp ngang để nằm cạnh nhau.
    private static func doubled(_ strokes: [[CGPoint]]) -> [[CGPoint]] {
        combine([strokes, strokes])
    }

    private static let table: [String: [[CGPoint]]] = {
        var t: [String: [[CGPoint]]] = [:]

        // MARK: Phụ âm cơ bản

        t["ㄱ"] = [[pt(0.20, 0.28), pt(0.80, 0.28), pt(0.72, 0.82)]]

        t["ㄴ"] = [[pt(0.30, 0.18), pt(0.30, 0.76), pt(0.84, 0.76)]]

        t["ㄷ"] = [
            [pt(0.22, 0.24), pt(0.80, 0.24)],
            [pt(0.22, 0.24), pt(0.22, 0.80), pt(0.80, 0.80)],
        ]

        t["ㄹ"] = [
            [pt(0.22, 0.20), pt(0.80, 0.20), pt(0.80, 0.50)],
            [pt(0.80, 0.50), pt(0.22, 0.50), pt(0.22, 0.80)],
            [pt(0.22, 0.80), pt(0.80, 0.80)],
        ]

        t["ㅁ"] = [
            [pt(0.26, 0.22), pt(0.26, 0.80)],
            [pt(0.26, 0.22), pt(0.78, 0.22), pt(0.78, 0.80)],
            [pt(0.26, 0.80), pt(0.78, 0.80)],
        ]

        t["ㅂ"] = [
            [pt(0.28, 0.18), pt(0.28, 0.84)],
            [pt(0.74, 0.18), pt(0.74, 0.84)],
            [pt(0.28, 0.52), pt(0.74, 0.52)],
            [pt(0.28, 0.84), pt(0.74, 0.84)],
        ]

        t["ㅅ"] = [
            [pt(0.50, 0.20), pt(0.24, 0.84)],
            [pt(0.435, 0.36), pt(0.80, 0.84)],
        ]

        t["ㅇ"] = [circle(0.50, 0.50, 0.30)]

        t["ㅈ"] = [
            [pt(0.20, 0.26), pt(0.80, 0.26)],
            [pt(0.50, 0.26), pt(0.24, 0.82)],
            [pt(0.44, 0.46), pt(0.80, 0.82)],
        ]

        t["ㅊ"] = [
            [pt(0.44, 0.10), pt(0.60, 0.20)],
            [pt(0.20, 0.34), pt(0.80, 0.34)],
            [pt(0.50, 0.34), pt(0.24, 0.85)],
            [pt(0.44, 0.52), pt(0.80, 0.85)],
        ]

        t["ㅋ"] = [
            [pt(0.22, 0.24), pt(0.80, 0.24), pt(0.74, 0.82)],
            [pt(0.20, 0.52), pt(0.72, 0.52)],
        ]

        t["ㅌ"] = [
            [pt(0.22, 0.22), pt(0.80, 0.22)],
            [pt(0.22, 0.50), pt(0.80, 0.50)],
            [pt(0.22, 0.22), pt(0.22, 0.80), pt(0.80, 0.80)],
        ]

        t["ㅍ"] = [
            [pt(0.16, 0.28), pt(0.84, 0.28)],
            [pt(0.32, 0.28), pt(0.32, 0.76)],
            [pt(0.68, 0.28), pt(0.68, 0.76)],
            [pt(0.16, 0.76), pt(0.84, 0.76)],
        ]

        t["ㅎ"] = [
            [pt(0.38, 0.10), pt(0.62, 0.18)],
            [pt(0.20, 0.32), pt(0.80, 0.32)],
            circle(0.50, 0.66, 0.20),
        ]

        // MARK: Phụ âm đôi

        t["ㄲ"] = doubled(t["ㄱ"]!)
        t["ㄸ"] = doubled(t["ㄷ"]!)
        t["ㅃ"] = doubled(t["ㅂ"]!)
        t["ㅆ"] = doubled(t["ㅅ"]!)
        t["ㅉ"] = doubled(t["ㅈ"]!)

        // MARK: Nguyên âm cơ bản

        t["ㅏ"] = [
            [pt(0.45, 0.10), pt(0.45, 0.90)],
            [pt(0.45, 0.50), pt(0.82, 0.50)],
        ]

        t["ㅑ"] = [
            [pt(0.45, 0.10), pt(0.45, 0.90)],
            [pt(0.45, 0.35), pt(0.82, 0.35)],
            [pt(0.45, 0.65), pt(0.82, 0.65)],
        ]

        t["ㅓ"] = [
            [pt(0.18, 0.50), pt(0.55, 0.50)],
            [pt(0.55, 0.10), pt(0.55, 0.90)],
        ]

        t["ㅕ"] = [
            [pt(0.18, 0.35), pt(0.55, 0.35)],
            [pt(0.18, 0.65), pt(0.55, 0.65)],
            [pt(0.55, 0.10), pt(0.55, 0.90)],
        ]

        t["ㅗ"] = [
            [pt(0.50, 0.18), pt(0.50, 0.56)],
            [pt(0.14, 0.56), pt(0.86, 0.56)],
        ]

        t["ㅛ"] = [
            [pt(0.36, 0.18), pt(0.36, 0.54)],
            [pt(0.64, 0.18), pt(0.64, 0.54)],
            [pt(0.14, 0.54), pt(0.86, 0.54)],
        ]

        t["ㅜ"] = [
            [pt(0.14, 0.46), pt(0.86, 0.46)],
            [pt(0.50, 0.46), pt(0.50, 0.84)],
        ]

        t["ㅠ"] = [
            [pt(0.14, 0.44), pt(0.86, 0.44)],
            [pt(0.36, 0.44), pt(0.36, 0.82)],
            [pt(0.64, 0.44), pt(0.64, 0.82)],
        ]

        t["ㅡ"] = [[pt(0.14, 0.50), pt(0.86, 0.50)]]

        t["ㅣ"] = [[pt(0.50, 0.10), pt(0.50, 0.90)]]

        // MARK: Nguyên âm ghép (ghép 2 nguyên âm cơ bản, viết đúng thứ tự từng phần)

        t["ㅘ"] = combine([t["ㅗ"]!, t["ㅏ"]!])
        t["ㅚ"] = combine([t["ㅗ"]!, t["ㅣ"]!])
        t["ㅝ"] = combine([t["ㅜ"]!, t["ㅓ"]!])
        t["ㅟ"] = combine([t["ㅜ"]!, t["ㅣ"]!])
        t["ㅢ"] = combine([t["ㅡ"]!, t["ㅣ"]!])
        t["ㅐ"] = combine([t["ㅏ"]!, t["ㅣ"]!])
        t["ㅒ"] = combine([t["ㅑ"]!, t["ㅣ"]!])
        t["ㅔ"] = combine([t["ㅓ"]!, t["ㅣ"]!])
        t["ㅖ"] = combine([t["ㅕ"]!, t["ㅣ"]!])
        t["ㅙ"] = combine([t["ㅗ"]!, t["ㅏ"]!, t["ㅣ"]!])
        t["ㅞ"] = combine([t["ㅜ"]!, t["ㅓ"]!, t["ㅣ"]!])

        return t
    }()
}
