import SwiftUI

struct OnboardingView: View {
    let language: AppLanguage
    var onFinish: () -> Void

    @State private var page = 0

    private struct Page {
        let icon: String
        let title: Bilingual
        let body: Bilingual
    }

    private let pages: [Page] = [
        Page(icon: "textformat.abc", title: L.onboard1Title, body: L.onboard1Body),
        Page(icon: "square.grid.2x2", title: L.onboard2Title, body: L.onboard2Body),
        Page(icon: "speaker.wave.2", title: L.onboard3Title, body: L.onboard3Body),
    ]

    var body: some View {
        VStack {
            TabView(selection: $page) {
                ForEach(pages.indices, id: \.self) { index in
                    VStack(spacing: 24) {
                        Image(systemName: pages[index].icon)
                            .font(.system(size: 76))
                            .foregroundStyle(.tint)
                        Text(pages[index].title(language))
                            .font(.title.bold())
                            .multilineTextAlignment(.center)
                        Text(pages[index].body(language))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }
                    .padding(40)
                    .tag(index)
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            Button {
                if page < pages.count - 1 {
                    withAnimation { page += 1 }
                } else {
                    onFinish()
                }
            } label: {
                Text(page < pages.count - 1 ? L.onboardNext(language) : L.onboardStart(language))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding()
        }
    }
}

#Preview {
    OnboardingView(language: .vi, onFinish: {})
}
