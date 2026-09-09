# Kiến trúc & Công nghệ — Hangul Study

Ghi chú kỹ thuật cho người mới đọc code lần đầu. Xem `README.md` cho tính năng/cách chạy, `docs/APP_STORE_CHECKLIST.md` cho quy trình nộp App Store.

## Tổng quan

- **Nền tảng**: iOS 17.0+, viết bằng **Swift 5** + **SwiftUI** (không UIKit storyboard, không SceneDelegate — điểm vào là `HangulStudyApp` kiểu `@main App`).
- **Không backend**: app chạy hoàn toàn offline, không gọi mạng, không tài khoản, không SDK bên thứ ba.
- **Quy mô**: ~1865 dòng Swift ở target chính, 77 test (`HangulStudyTests`).
- **Bundle ID**: `com.koreastudy.HangulStudy` · Team `P3MPHWPJ62`.

## Framework dùng (toàn bộ đều của Apple, không có dependency ngoài)

| Framework | Dùng ở đâu | Mục đích |
|---|---|---|
| **SwiftUI** | Toàn bộ UI | Layout, state, navigation (`TabView`, `NavigationStack`) |
| **AVFoundation** | `SpeechService`, `SoundEffects` | `AVSpeechSynthesizer` đọc tiếng Hàn (giọng hệ thống `ko-KR`); `AVAudioPlayer` phát âm báo đúng/sai |
| **PencilKit** | `WritingPracticeView` | `PKCanvasView` cho luyện viết bằng ngón tay/Apple Pencil |
| **CoreText** | `StrokeOrderView` (`StrokeSource`) | Lấy đường viền glyph của font làm nét viết dự phòng cho các chữ không có dữ liệu nét tay thủ công |
| **CoreGraphics** | `HangulStrokes` | Toạ độ `CGPoint`/`CGPath` cho dữ liệu nét viết tay |
| **UIKit** | `QuizView` | `UINotificationFeedbackGenerator` (haptic đúng/sai) |
| **Foundation** | khắp nơi | `UserDefaults`, `JSONEncoder/Decoder`, `Date` |
| **Swift Testing** (`import Testing`, không phải XCTest) | `HangulStudyTests` | `@Test` / `#expect` |

Không có Combine framework rời (dùng `@Published`/`ObservableObject` có sẵn trong Foundation+SwiftUI), không CoreData/SwiftData, không network layer.

## Kiến trúc tổng thể

Không theo MVVM/TCA hình thức — đây là app nhỏ, dùng đúng pattern SwiftUI mặc định:

```
Model (struct/enum thuần)  →  Store/Service (class, nguồn sự thật)  →  View (đọc trực tiếp)
```

- **Model**: struct/enum bất biến, không logic I/O (`HangulLetter`, `HangulCategory`, `LetterProgress`...).
- **Store** (`ProgressStore`): duy nhất 1 class `ObservableObject` giữ state cần persist — đóng vai trò gần giống ViewModel dùng chung toàn app, singleton qua `.shared`.
- **Service** (`SpeechService`, `SoundEffects`): class stateless-ish, singleton, gói API hệ thống (audio) đằng sau interface đơn giản gọi trực tiếp từ View.
- **View**: phần lớn dùng `@State` cục bộ (ví dụ `QuizModel` là `ObservableObject` riêng của `QuizView`, không lưu). Không có Router/Coordinator — điều hướng chỉ là `TabView` 5 tab cố định trong `RootView`.

Không dùng dependency injection framework — inject qua init parameter mặc định (`ProgressStore(defaults: UserDefaults = .standard)`), test override bằng `UserDefaults(suiteName:)` riêng mỗi test.

## Cấu trúc thư mục

```
HangulStudy/
├── HangulStudyApp.swift          @main, chỉ tạo WindowGroup { RootView() }
├── PrivacyInfo.xcprivacy         Privacy manifest (khai UserDefaults required-reason API)
│
├── Models/
│   ├── Localization.swift        Bilingual (vi/en), enum L (toàn bộ chuỗi UI), AppLanguage, AppAppearance
│   ├── HangulLetter.swift        Struct 1 chữ cái + HangulCategory (4 nhóm)
│   ├── HangulData.swift          Dữ liệu tĩnh 40 chữ cái + từ ví dụ (nguồn sự thật duy nhất về nội dung học)
│   ├── HangulSyllable.swift      Ghép jamo → khối âm tiết Unicode (công thức 0xAC00 + ...)
│   ├── HangulStrokes.swift       Toạ độ nét viết tay thủ công (centerline) cho 24 chữ cơ bản
│   └── ProgressStore.swift       ObservableObject, lưu tiến độ học + lịch ôn (Leitner), duy nhất state persist
│
├── Services/
│   ├── SpeechService.swift       Bọc AVSpeechSynthesizer, đọc theo "spoken form" (tên chữ) chứ không đọc jamo rời
│   └── SoundEffects.swift        Tổng hợp sine/square wave thành WAV trong bộ nhớ — không cần file audio đóng gói
│
└── Views/
    ├── RootView.swift            TabView 5 tab + áp appearance + fullScreenCover onboarding lần đầu
    ├── OnboardingView.swift      3 trang giới thiệu, chỉ hiện khi @AppStorage("didOnboard") == false
    ├── LearnView.swift           Lưới 40 chữ theo nhóm, lọc "tất cả / chưa thuộc"
    ├── LetterDetailView.swift    Sheet chi tiết 1 chữ: tên, cách đọc, ví dụ, nút nghe
    ├── SyllableBuilderView.swift Ghép phụ âm đầu + nguyên âm + phụ âm cuối bằng HangulSyllable
    ├── QuizView.swift            QuizModel (ObservableObject riêng) — 2 chế độ, phạm vi lọc, SRS, haptic
    ├── WritingPracticeView.swift PKCanvasView + gọi StrokeOrderView làm overlay hoạt hình mẫu
    ├── StrokeOrderView.swift     Animation .trim vẽ từng nét đúng thứ tự; StrokeSource chọn nguồn nét
    └── SettingsView.swift        Hiển thị/xoá tiến độ, đổi ngôn ngữ + giao diện

HangulStudyTests/                 Swift Testing (không XCTest), 77 @Test
├── HangulDataTests.swift         Toàn vẹn dữ liệu 40 chữ (không trùng, đủ nhóm...)
├── HangulStrokesTests.swift      Toạ độ nét viết hợp lệ (trong ô 0…1)
├── HangulSyllableTests.swift     Công thức ghép âm tiết đúng với bảng Unicode
├── LocalizationTests.swift       Mọi Bilingual có cả vi lẫn en
├── ProgressStoreTests.swift      Leitner box, lịch ôn, learnedCount, dueLetters
├── QuizModelTests.swift          Sinh câu hỏi, chấm điểm, missedLetters
├── SoundEffectsTests.swift       Player tạo thành công, độ dài âm thanh
└── StrokeSourceTests.swift       Fallback contour font khi không có dữ liệu tay
```

## Luồng dữ liệu & trạng thái persist

Toàn bộ state bền vững nằm trong `UserDefaults.standard`, qua 2 cơ chế:

- **`@AppStorage`** (đơn giá trị, đọc trực tiếp trong View): `appLanguage`, `appAppearance`, `didOnboard`.
- **`ProgressStore`** (đối tượng phức tạp hơn, tự serialize thủ công): key `letterProgress`, giá trị là `[String: LetterProgress]` (`character` → tiến độ) mã hoá bằng `JSONEncoder`/`JSONDecoder`, lưu dạng `Data` trong `UserDefaults`.

```
ProgressStore (⁠ObservableObject, .shared)
  entries: [String: LetterProgress]   ← decode 1 lần khi init
      │
      ├─ entry(for:)      View đọc tiến độ 1 chữ (Learn, Settings)
      ├─ record(_:correct:)  QuizModel ghi kết quả sau mỗi câu → cập nhật box Leitner (0...5)
      │                       + tính nextReview = now + intervalDays[box]
      ├─ dueLetters        QuizScope.due lọc chữ tới hạn ôn (dùng cho Quiz "Cần ôn")
      └─ save()            encode lại toàn bộ dict → ghi UserDefaults mỗi lần record/reset
```

Không có cache lớp trung gian, không migration schema — vì đây là dữ liệu học tập cá nhân, mất là học lại từ đầu (chấp nhận được, không quan trọng).

## Testing

- Framework: **Swift Testing** (Xcode 16+, `import Testing`, cú pháp `@Test func ... { #expect(...) }`), không dùng XCTest.
- Chạy: `xcodebuild -project HangulStudy.xcodeproj -scheme HangulStudy -destination 'platform=iOS Simulator,name=iPhone 17' test`.
- Test thuần logic (model/store), không có UI test — mọi test chạy được trên `@MainActor` struct đơn giản, không cần mock network vì app không có network.
- `ProgressStoreTests` cô lập bằng `UserDefaults(suiteName: "progress-<uuid>")` mỗi test, tránh đụng dữ liệu thật.

## Điểm đáng chú ý khi đọc code

- **Không đọc jamo rời khi phát âm** — `HangulLetter.spoken` lấy phần Hangul trong `name` (ví dụ "기역" cho ㄱ) vì đọc trực tiếp ký tự rời nghe không tự nhiên với `AVSpeechSynthesizer`.
- **Âm báo đúng/sai không dùng file asset** — `SoundEffects` tổng hợp sóng sine/square thành PCM 16-bit rồi tự đóng gói header WAV thủ công trong `wav(samples:sampleRate:)`, nạp thẳng vào `AVAudioPlayer(data:)`.
- **Nét viết có 2 nguồn** — 24 chữ cơ bản có toạ độ tay thủ công trong `HangulStrokes` (đúng thứ tự nét, khớp cách viết thật); các chữ ghép/đôi còn lại fallback sang đường viền glyph font `AppleSDGothicNeo-Bold` qua CoreText (`StrokeSource.contours`), không đúng thứ tự nét nhưng đủ dùng để nhận diện hình chữ.
- **Localization tự chế, không dùng `.xcstrings`/`Localizable.strings`** — mọi chuỗi UI nằm trong `enum L` dạng `Bilingual(vi:en:)`, gọi như hàm: `L.startQuiz(language)`. Đơn giản, dễ audit đủ 2 ngôn ngữ (có hẳn `LocalizationTests` kiểm tra), nhưng không tận dụng được hệ thống String Catalog của Xcode (không cần vì chỉ 2 ngôn ngữ, không cần Xcode Cloud dịch tự động).
- **`TARGETED_DEVICE_FAMILY = 1`** — chỉ build cho iPhone (đã tắt iPad) ở app target; test target vẫn `1,2` (không ảnh hưởng vì test không chạy trên device thật).
