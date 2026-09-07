import SwiftUI

struct RootView: View {
    @AppStorage("appLanguage") private var languageRaw = AppLanguage.vi.rawValue
    @AppStorage("appAppearance") private var appearanceRaw = AppAppearance.system.rawValue
    @AppStorage("didOnboard") private var didOnboard = false

    private var language: AppLanguage {
        AppLanguage(rawValue: languageRaw) ?? .vi
    }

    private var appearance: AppAppearance {
        AppAppearance(rawValue: appearanceRaw) ?? .system
    }

    var body: some View {
        TabView {
            LearnView(language: language)
                .tabItem { Label(L.learnTab(language), systemImage: "textformat.abc") }

            SyllableBuilderView(language: language)
                .tabItem { Label(L.buildTab(language), systemImage: "square.grid.2x2") }

            QuizView(language: language)
                .tabItem { Label(L.quizTab(language), systemImage: "checkmark.circle") }

            WritingPracticeView(language: language)
                .tabItem { Label(L.writeTab(language), systemImage: "pencil.and.scribble") }

            SettingsView()
                .tabItem { Label(L.settingsTab(language), systemImage: "gearshape") }
        }
        .preferredColorScheme(appearance.colorScheme)
        .fullScreenCover(isPresented: .constant(!didOnboard)) {
            OnboardingView(language: language) { didOnboard = true }
        }
    }
}

#Preview {
    RootView()
}
