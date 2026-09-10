import CoreGraphics

/// So khớp nét người dùng tự viết với nét mẫu (centerline chuẩn hoá 0…1 trong
/// `HangulStrokes`), cho điểm 0…100 — không dùng ML, chỉ đo khoảng cách hình học.
enum HandwritingScorer {
    /// Khoảng cách trung bình (đơn vị ô 0…1) được coi là "chấp nhận được"; từ đó trở lên điểm giảm dần về 0.
    private static let maxAcceptableDistance: CGFloat = 0.22
    /// Khoảng cách giữa các điểm lấy mẫu dọc theo mỗi nét, cũng đơn vị ô 0…1.
    private static let resampleSpacing: CGFloat = 0.02

    /// - Parameters:
    ///   - userStrokes: các nét người dùng vẽ, đã chuẩn hoá vào ô 0…1 (trục y hướng xuống).
    ///   - reference: nét mẫu tương ứng, cùng hệ toạ độ (từ `HangulStrokes.strokes(for:)`).
    /// - Returns: điểm 0…100, hoặc `nil` nếu không có gì để so (thiếu nét mẫu hoặc chưa viết gì).
    static func score(userStrokes: [[CGPoint]], reference: [[CGPoint]]) -> Int? {
        guard !reference.isEmpty, !userStrokes.isEmpty else { return nil }

        let referencePoints = reference.flatMap { resample($0) }
        let userPoints = userStrokes.flatMap { resample($0) }
        guard !referencePoints.isEmpty, !userPoints.isEmpty else { return nil }

        // "coverage": mỗi điểm trên nét mẫu có được vẽ gần đó không (thiếu nét → điểm thấp).
        let coverage = averageNearestDistance(from: referencePoints, to: userPoints)
        // "precision": mỗi điểm người dùng vẽ có nằm gần nét mẫu không (nguệch ngoạc → điểm thấp).
        let precision = averageNearestDistance(from: userPoints, to: referencePoints)

        let avgDistance = (coverage + precision) / 2
        let raw = 1 - min(avgDistance / maxAcceptableDistance, 1)
        return Int((raw * 100).rounded())
    }

    /// Chia một polyline thành các điểm cách đều nhau theo độ dài cung, để so khớp công bằng
    /// giữa nét dài (nhiều điểm gốc) và nét ngắn (ít điểm gốc).
    private static func resample(_ stroke: [CGPoint]) -> [CGPoint] {
        guard let first = stroke.first else { return [] }
        guard stroke.count > 1 else { return [first] }

        var result: [CGPoint] = [first]
        var carry: CGFloat = 0
        for i in 1..<stroke.count {
            let a = stroke[i - 1]
            let b = stroke[i]
            let segmentLength = hypot(b.x - a.x, b.y - a.y)
            guard segmentLength > 0 else { continue }

            var distanceAlongSegment = resampleSpacing - carry
            while distanceAlongSegment < segmentLength {
                let t = distanceAlongSegment / segmentLength
                result.append(CGPoint(x: a.x + (b.x - a.x) * t, y: a.y + (b.y - a.y) * t))
                distanceAlongSegment += resampleSpacing
            }
            carry = segmentLength - (distanceAlongSegment - resampleSpacing)
        }
        result.append(stroke.last!)
        return result
    }

    /// Với mỗi điểm trong `a`, tìm điểm gần nhất trong `b`; trả về khoảng cách trung bình.
    private static func averageNearestDistance(from a: [CGPoint], to b: [CGPoint]) -> CGFloat {
        guard !a.isEmpty, !b.isEmpty else { return maxAcceptableDistance }
        let total = a.reduce(CGFloat(0)) { sum, p in
            let nearest = b.reduce(CGFloat.greatestFiniteMagnitude) { closest, q in
                min(closest, hypot(q.x - p.x, q.y - p.y))
            }
            return sum + nearest
        }
        return total / CGFloat(a.count)
    }
}
