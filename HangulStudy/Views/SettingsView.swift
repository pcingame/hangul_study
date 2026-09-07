import SwiftUI

struct SettingsView: View {
    @AppStorage("appLanguage") private var languageRaw = AppLanguage.vi.rawValue
    @AppStorage("appAppearance") private var appearanceRaw = AppAppearance.system.rawValue

    @ObservedObject private var progress = ProgressStore.shared

    private var language: AppLanguage {
        AppLanguage(rawValue: languageRaw) ?? .vi
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(L.progress(language)) {
                    LabeledContent(L.lettersLearned(language),
                                   value: "\(progress.learnedCount) / \(HangulData.all.count)")
                    Button(L.resetProgress(language), role: .destructive) {
                        progress.reset()
                    }
                }

                Section(L.language(language)) {
                    Picker(L.language(language), selection: $languageRaw) {
                        ForEach(AppLanguage.allCases) { lang in
                            Text(lang.label).tag(lang.rawValue)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                Section(L.appearance(language)) {
                    Picker(L.appearance(language), selection: $appearanceRaw) {
                        ForEach(AppAppearance.allCases) { appearance in
                            Text(appearance.label(language)).tag(appearance.rawValue)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                Section(L.about(language)) {
                    Text(L.aboutText(language))
                        .font(.callout)
                    LabeledContent("Hangul Study", value: "1.0")
                }
            }
            .navigationTitle(L.settingsTitle(language))
        }
    }
}

#Preview {
    SettingsView()
}
