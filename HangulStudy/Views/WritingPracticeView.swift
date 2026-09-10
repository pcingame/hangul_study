import SwiftUI
import PencilKit

struct WritingPracticeView: View {
    let language: AppLanguage

    @State private var scope: QuizScope = .all
    @State private var letters = HangulData.all.shuffled()
    @State private var index = 0
    @State private var canvasView = PKCanvasView()
    @State private var showGuide = true
    @State private var strokeReplay = 0
    @State private var checkResult: WritingCheckResult?

    private var letter: HangulLetter { letters[index] }

    private enum WritingCheckResult: Equatable {
        case empty
        case scored(Int)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                HStack {
                    Text(letter.character)
                        .font(.system(size: 44, weight: .medium))
                    VStack(alignment: .leading) {
                        Text(letter.romanization)
                            .font(.headline)
                        Text(letter.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("\(index + 1) / \(letters.count)")
                        .font(.footnote)
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                    Button {
                        SpeechService.shared.speak(letter)
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.title2)
                    }
                }
                .padding(.horizontal)

                Picker(L.quizScopeLabel(language), selection: $scope) {
                    ForEach(QuizScope.allChoices) { Text($0.label(language)).tag($0) }
                }
                .pickerStyle(.menu)
                .onChange(of: scope) { _, newScope in applyScope(newScope) }

                if scope.pool().isEmpty {
                    Text(L.quizNothingDue(language))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Text(L.writeHint(language))
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))

                    if showGuide {
                        Text(letter.character)
                            .font(.system(size: 190, weight: .medium))
                            .foregroundStyle(.tertiary)
                    }

                    StrokeOrderView(character: letter.character, token: strokeReplay, strokeWidthScale: 0.6)
                        .padding(40)

                    DrawingCanvas(canvasView: canvasView)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .padding(.horizontal)

                if let checkResult {
                    checkResultBanner(checkResult)
                }

                VStack(spacing: 10) {
                    HStack(spacing: 12) {
                        Toggle(L.showGuide(language), isOn: $showGuide)
                            .toggleStyle(.button)
                            .buttonStyle(.bordered)

                        Button {
                            strokeReplay += 1
                        } label: {
                            Label(L.showStrokes(language), systemImage: "play.circle")
                        }
                        .buttonStyle(.bordered)
                    }

                    Button {
                        checkWriting()
                    } label: {
                        Label(L.checkWriting(language), systemImage: "checkmark.seal")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    HStack(spacing: 12) {
                        Button {
                            canvasView.drawing = PKDrawing()
                            checkResult = nil
                        } label: {
                            Label(L.clear(language), systemImage: "eraser")
                        }
                        .buttonStyle(.bordered)

                        Button {
                            canvasView.drawing = PKDrawing()
                            checkResult = nil
                            index = (index + 1) % letters.count
                        } label: {
                            Label(L.nextLetter(language), systemImage: "arrow.right")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(.horizontal)
                .animation(.default, value: checkResult)

                Spacer()
            }
            .padding(.top)
            .navigationTitle(L.writeTitle(language))
        }
    }

    /// Đổi phạm vi luyện tập; giữ nguyên danh sách cũ nếu phạm vi mới trống (ví dụ "Cần ôn" mà chưa có chữ nào).
    private func applyScope(_ scope: QuizScope) {
        let pool = scope.pool()
        guard !pool.isEmpty else { return }
        letters = pool.shuffled()
        index = 0
        canvasView.drawing = PKDrawing()
        checkResult = nil
    }

    private func checkWriting() {
        guard !canvasView.drawing.strokes.isEmpty else {
            checkResult = .empty
            return
        }
        guard let reference = HangulStrokes.strokes(for: letter.character),
              let score = HandwritingScorer.score(userStrokes: normalizedUserStrokes(), reference: reference) else {
            checkResult = nil
            return
        }
        checkResult = .scored(score)
    }

    /// Toạ độ các nét người dùng vẽ, chuẩn hoá về ô 0…1 (cùng hệ với `HangulStrokes`)
    /// bằng cách chia cho kích thước thật của canvas.
    private func normalizedUserStrokes() -> [[CGPoint]] {
        let size = canvasView.bounds.size
        guard size.width > 0, size.height > 0 else { return [] }
        return canvasView.drawing.strokes.map { stroke in
            stroke.path.map { CGPoint(x: $0.location.x / size.width, y: $0.location.y / size.height) }
        }
    }

    @ViewBuilder
    private func checkResultBanner(_ result: WritingCheckResult) -> some View {
        switch result {
        case .empty:
            Text(L.writingScoreEmpty(language))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        case .scored(let score):
            let message: Bilingual = score >= 80 ? L.writingScoreGreat : (score >= 50 ? L.writingScoreOk : L.writingScoreLow)
            let color: Color = score >= 80 ? .green : (score >= 50 ? .orange : .red)
            Text("\(score)% — \(message(language))")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(color)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

private struct DrawingCanvas: UIViewRepresentable {
    let canvasView: PKCanvasView

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(.pen, color: .label, width: 14)
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}

#Preview {
    WritingPracticeView(language: .vi)
}
