import SwiftUI

/// Thẻ từ vựng: chạm để lật (Hàn → phiên âm, nghĩa, ví dụ); vuốt phải = "đã thuộc", vuốt trái = "chưa thuộc"
/// (hoặc dùng hai nút). Mỗi lần đánh dấu cũng ghi lịch ôn (Leitner) để mục "Cần ôn" gom lại các từ tới hạn.
struct FlashcardView: View {
    let language: AppLanguage
    let words: [Vocab]
    /// Đổi giá trị này (đổi bộ lọc) thì làm lại từ đầu.
    let reloadKey: String

    @AppStorage("learnedVocab") private var learnedRaw = ""
    /// Chụp bộ thẻ lúc bắt đầu, vì bộ "Cần ôn" co lại ngay khi mình đánh dấu từng thẻ.
    @State private var deck: [Vocab] = []
    @State private var index = 0
    @State private var flipped = false
    @State private var gotIt = 0
    @State private var drag: CGFloat = 0

    private static let swipeDistance: CGFloat = 100

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if deck.isEmpty {
                    Text(L.studyEmpty(language)).foregroundStyle(.secondary)
                } else if index >= deck.count {
                    ResultView(correct: gotIt, total: deck.count) {
                        Button(L.tryAgain(language), action: restart).buttonStyle(.borderedProminent)
                    }
                } else {
                    let word = deck[index]
                    Text("\(index + 1)/\(deck.count)").font(.caption).foregroundStyle(.secondary)
                    ProgressView(value: Double(index), total: Double(deck.count))
                    card(word)
                    Text(L.flashcardSwipeHint(language)).font(.caption).foregroundStyle(.secondary)

                    if flipped {
                        HStack {
                            Button { mark(word, learned: false) } label: { Text(L.flashcardAgain(language)).frame(maxWidth: .infinity) }
                                .buttonStyle(.bordered).tint(.red)
                            Button { mark(word, learned: true) } label: { Text(L.flashcardLearned(language)).frame(maxWidth: .infinity) }
                                .buttonStyle(.borderedProminent).tint(.green)
                        }
                    }
                }
            }
            .padding()
        }
        .onAppear(perform: restart)
        .onChange(of: reloadKey) { restart() }
    }

    private func card(_ word: Vocab) -> some View {
        ZStack {
            VStack(spacing: 10) {
                Text(word.word).font(.largeTitle.weight(.semibold))
                Text(L.flashcardTapToFlip(language)).font(.caption).foregroundStyle(.secondary)
            }
            .opacity(flipped ? 0 : 1)

            VStack(spacing: 10) {
                Text(word.word).font(.largeTitle.weight(.semibold))
                Text(word.reading).foregroundStyle(.secondary)
                Text(word.meaning).font(.title3)
                Text(word.example).font(.callout)
                Text(word.translation).font(.caption).foregroundStyle(.secondary)
            }
            .opacity(flipped ? 1 : 0)
            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, minHeight: 260)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(swipeTint.opacity(min(abs(drag) / Self.swipeDistance, 1)), lineWidth: 3))
        .rotation3DEffect(.degrees(flipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .animation(.easeInOut(duration: 0.35), value: flipped)
        .offset(x: drag)
        .rotationEffect(.degrees(Double(drag) / 25))
        .contentShape(RoundedRectangle(cornerRadius: 20))
        .onTapGesture { flip(word) }
        .gesture(
            DragGesture(minimumDistance: 20)
                .onChanged { drag = $0.translation.width }
                .onEnded { value in
                    if value.translation.width > Self.swipeDistance { mark(word, learned: true) }
                    else if value.translation.width < -Self.swipeDistance { mark(word, learned: false) }
                    withAnimation(.spring) { drag = 0 }
                }
        )
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint(L.flashcardTapToFlip(language))
        .accessibilityAction { flip(word) }
    }

    private var swipeTint: Color { drag >= 0 ? .green : .red }

    private func flip(_ word: Vocab) {
        flipped.toggle()
        if flipped { SpeechService.shared.speak(word.word) }
    }

    private func restart() {
        deck = words
        index = 0
        flipped = false
        gotIt = 0
        drag = 0
    }

    private func mark(_ word: Vocab, learned: Bool) {
        var ids = StudyContent.learnedIDs(learnedRaw)
        if learned { ids.insert(word.id); gotIt += 1 } else { ids.remove(word.id) }
        learnedRaw = StudyContent.learnedRaw(ids)
        ProgressStore.vocab.record(key: word.word, correct: learned)
        if learned { SoundEffects.shared.playCorrect() } else { SoundEffects.shared.playWrong() }
        // Sang thẻ kế tiếp không animate để mặt sau của từ mới không lộ ra lúc lật về.
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            index += 1
            flipped = false
        }
    }
}
