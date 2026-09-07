import Testing
@testable import HangulStudy

struct LocalizationTests {

    // MARK: Bilingual

    @Test func bilingualReturnsTheRightLanguage() {
        let text = Bilingual(vi: "xin chào", en: "hello")
        #expect(text(.vi) == "xin chào")
        #expect(text(.en) == "hello")
    }

    @Test func bilingualIsValueEqual() {
        #expect(Bilingual(vi: "a", en: "b") == Bilingual(vi: "a", en: "b"))
        #expect(Bilingual(vi: "a", en: "b") != Bilingual(vi: "a", en: "c"))
    }

    // MARK: AppLanguage

    @Test func appLanguageRoundTripsThroughRawValue() {
        for language in AppLanguage.allCases {
            #expect(AppLanguage(rawValue: language.rawValue) == language)
            #expect(!language.label.isEmpty)
            #expect(language.id == language.rawValue)
        }
    }

    @Test func appLanguageHasExactlyViAndEn() {
        #expect(AppLanguage.allCases == [.vi, .en])
    }

    @Test func appLanguageRejectsUnknownRawValue() {
        #expect(AppLanguage(rawValue: "fr") == nil)
    }

    // MARK: AppAppearance

    @Test func appAppearanceMapsToColorScheme() {
        #expect(AppAppearance.system.colorScheme == nil)
        #expect(AppAppearance.light.colorScheme == .light)
        #expect(AppAppearance.dark.colorScheme == .dark)
    }

    @Test func appAppearanceRoundTripsAndIsLabelled() {
        for appearance in AppAppearance.allCases {
            #expect(AppAppearance(rawValue: appearance.rawValue) == appearance)
            #expect(!appearance.label(.vi).isEmpty)
            #expect(!appearance.label(.en).isEmpty)
        }
    }

    // MARK: HangulCategory

    @Test func categoryTitlesExistForBothLanguages() {
        for category in HangulCategory.allCases {
            #expect(!category.title(.vi).isEmpty)
            #expect(!category.title(.en).isEmpty)
            #expect(category.title(.vi) != category.title(.en))
            #expect(category.id == category.rawValue)
        }
    }

    // MARK: Một số chuỗi giao diện

    @Test func keyStringsAreTranslatedInBothLanguages() {
        let strings: [Bilingual] = [
            L.learnTab, L.buildTab, L.quizTab, L.writeTab, L.settingsTab,
            L.quizPrompt, L.quizPromptHear, L.correct, L.wrong,
            L.quizModeSeeLetter, L.quizModeHearSound, L.quizScopeAll, L.quizScopeDue,
            L.buildInitial, L.buildMedial, L.buildFinal,
            L.showStrokes, L.listen, L.resetProgress, L.lettersLearned,
            L.onboard1Title, L.onboard2Title, L.onboard3Title, L.koreanVoiceMissing,
        ]
        for string in strings {
            #expect(!string(.vi).isEmpty)
            #expect(!string(.en).isEmpty)
            #expect(string(.vi) != string(.en), "chưa dịch: \(string(.en))")
        }
    }

    @Test func quizModeAndScopeLabelsAreDistinct() {
        let modeLabels = QuizMode.allCases.map { $0.label(.vi) }
        #expect(Set(modeLabels).count == modeLabels.count)

        let scopeLabels = QuizScope.allChoices.map { $0.label(.vi) }
        #expect(Set(scopeLabels).count == scopeLabels.count)
    }
}
