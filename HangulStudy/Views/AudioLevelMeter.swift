import SwiftUI

/// Thanh hiển thị mức âm lượng đang ghi (0…1) — cho người dùng biết mic có đang bắt được tiếng
/// nói hay không, thay vì nói xong mới biết có ghi được gì hay không.
struct AudioLevelMeter: View {
    let level: Float

    var body: some View {
        GeometryReader { proxy in
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.systemGray5))
                .overlay(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.tint)
                        .frame(width: proxy.size.width * CGFloat(min(max(level, 0), 1)))
                }
        }
        .frame(height: 8)
        .animation(.linear(duration: 0.05), value: level)
    }
}
