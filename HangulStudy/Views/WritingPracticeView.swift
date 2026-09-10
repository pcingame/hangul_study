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

    private var letter: HangulLetter { letters[index] }

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

                    HStack(spacing: 12) {
                        Button {
                            canvasView.drawing = PKDrawing()
                        } label: {
                            Label(L.clear(language), systemImage: "eraser")
                        }
                        .buttonStyle(.bordered)

                        Button {
                            canvasView.drawing = PKDrawing()
                            index = (index + 1) % letters.count
                        } label: {
                            Label(L.nextLetter(language), systemImage: "arrow.right")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(.horizontal)

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
