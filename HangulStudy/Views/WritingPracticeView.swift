import SwiftUI
import PencilKit

struct WritingPracticeView: View {
    let language: AppLanguage

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
                    Button {
                        SpeechService.shared.speak(letter)
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.title2)
                    }
                }
                .padding(.horizontal)

                Text(L.writeHint(language))
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))

                    if strokeReplay > 0 {
                        StrokeOrderView(character: letter.character, token: strokeReplay)
                            .padding(24)
                    } else if showGuide {
                        Text(letter.character)
                            .font(.system(size: 240, weight: .medium))
                            .foregroundStyle(.tertiary)
                    }

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
                            strokeReplay = 0
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
