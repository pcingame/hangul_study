import SwiftUI

/// Thẻ từ vựng: chạm để lật (Hàn → phiên âm, nghĩa, ví dụ), rồi đánh dấu "đã thuộc" / "chưa thuộc".
/// Mỗi lần đánh dấu cũng ghi lịch ôn (Leitner) để mục "Cần ôn" gom lại các từ tới hạn.
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

    var body: some View {
        VStack(spacing: 16) {
            if deck.isEmpty {
                Text(L.studyEmpty(language)).foregroundStyle(.secondary)
            } else if index >= deck.count {
                Text("\(L.score(language)): \(gotIt)/\(deck.count)").font(.title2)
                Button(L.tryAgain(language), action: restart).buttonStyle(.borderedProminent)
            } else {
                let word = deck[index]
                Text("\(index + 1)/\(deck.count)").font(.caption).foregroundStyle(.secondary)
                Button {
                    flipped.toggle()
                    if flipped { SpeechService.shared.speak(word.word) }
                } label: {
                    card(word)
                }
                .buttonStyle(.plain)

                if flipped {
                    HStack {
                        Button { mark(word, learned: false) } label: { Text(L.flashcardAgain(language)).frame(maxWidth: .infinity) }
                            .buttonStyle(.bordered).tint(.red)
                        Button { mark(word, learned: true) } label: { Text(L.flashcardLearned(language)).frame(maxWidth: .infinity) }
                            .buttonStyle(.borderedProminent).tint(.green)
                    }
                }
            }
            Spacer()
        }
        .padding()
        .onAppear(perform: restart)
        .onChange(of: reloadKey) { restart() }
    }

    private func card(_ word: Vocab) -> some View {
        VStack(spacing: 10) {
            Text(word.word).font(.system(size: 40, weight: .semibold))
            if flipped {
                Text(word.reading).foregroundStyle(.secondary)
                Text(word.meaning).font(.title3)
                Text(word.example).font(.callout)
                Text(word.translation).font(.caption).foregroundStyle(.secondary)
            } else {
                Text(L.flashcardTapToFlip(language)).font(.caption).foregroundStyle(.secondary)
            }
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, minHeight: 260)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    private func restart() {
        deck = words
        index = 0
        flipped = false
        gotIt = 0
    }

    private func mark(_ word: Vocab, learned: Bool) {
        var ids = StudyContent.learnedIDs(learnedRaw)
        if learned { ids.insert(word.id); gotIt += 1 } else { ids.remove(word.id) }
        learnedRaw = StudyContent.learnedRaw(ids)
        ProgressStore.vocab.record(key: word.word, correct: learned)
        index += 1
        flipped = false
    }
}
