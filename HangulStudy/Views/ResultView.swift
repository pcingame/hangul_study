import SwiftUI

/// Màn kết quả dùng chung cho bài tập, quiz từ vựng và flashcard: điểm lớn, thanh tỉ lệ, rồi các nút hành động.
struct ResultView<Actions: View>: View {
    let correct: Int
    let total: Int
    @ViewBuilder var actions: Actions

    private var ratio: Double { total == 0 ? 0 : Double(correct) / Double(total) }

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: ratio >= 0.8 ? "star.circle.fill" : ratio >= 0.5 ? "hand.thumbsup.circle.fill" : "arrow.clockwise.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(ratio >= 0.8 ? Color.yellow : Color.accentColor)
                .accessibilityHidden(true)
            Text("\(correct)/\(total)")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .monospacedDigit()
            ProgressView(value: ratio)
                .padding(.horizontal, 40)
            actions
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 24)
    }
}
