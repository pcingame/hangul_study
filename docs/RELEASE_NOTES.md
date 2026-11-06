# Release notes — HangulStudy

Bản đang chuẩn bị: **1.3 (build 5)**. Build 5 gồm cả phần dịch bằng giọng nói (đã có ở build 4) lẫn giáo trình Seoul; build number tăng lên 5 để không trùng build 4 (nếu build 4 đã từng upload). IPA đã export tại `build/ipa/HangulStudy.ipa` (không nằm trong git).

## 1.3 (build 5) — Giáo trình Seoul + dịch bằng giọng nói

### Nội dung "What's New" cho App Store

**Tiếng Việt**

```
• Dịch bằng giọng nói: giữ nút ghi âm, nói tiếng Hàn và xem bản dịch sang ngôn ngữ của app.
Tab "Từ vựng" nay bám theo giáo trình Seoul 1A–2B:
• Hơn 980 từ vựng chia theo 33 bài, mỗi bài hiện đủ từ theo đúng thứ tự giáo trình, chia thành nhóm 7 từ.
• Thẻ ghi nhớ (flashcard): chạm để lật, vuốt phải là "đã thuộc", vuốt trái là "chưa thuộc".
• Ôn từ: quiz 10 câu chọn nghĩa đúng. Từ làm sai sẽ được nhắc lại sớm hơn; mục "Cần ôn" gom các từ đến hạn ôn.
• Theo dõi tiến độ từng bài (đã thuộc / tổng số) và làm lại các câu sai ngay sau mỗi lượt.
• Ngữ pháp gọn hơn: danh sách theo bài, bấm vào để xem giải thích và ví dụ. Bài tập ngữ pháp chia thành lượt 10 câu.
• Giao diện: rung nhẹ khi trả lời đúng/sai, hỗ trợ VoiceOver tốt hơn, Cài đặt chuyển vào nút bánh răng ở tab Học.
• Sửa lỗi chữ ở ô đang chọn bị mờ ở màn Ghép chữ.
```

**English**

```
• Speech translation: hold to record, speak Korean and see the translation in the app language.
The Words tab now follows the Seoul 1A–2B textbook:
• 980+ vocabulary words across 33 lessons; each lesson lists its full vocabulary in textbook order, in groups of 7.
• Flashcards: tap to flip, swipe right for "got it", swipe left for "not yet".
• Word quiz: 10 multiple-choice questions. Missed words come back sooner, and the "Due" filter gathers words ready for review.
• Per-lesson progress (learned / total) and a "Retry missed" button after each round.
• Tidier grammar: a list by unit, tap to see the explanation and examples. Grammar exercises now come in rounds of 10.
• Polish: haptic feedback on right/wrong answers, better VoiceOver support, Settings moved behind a gear button on the Learn tab.
• Fixed a faded label on the selected chip in the Syllable Builder.
```

### Thay đổi chi tiết

**Nội dung**
- Từ vựng 408 → **986 từ** (thêm 578), nguồn là danh sách từ theo bài Seoul 1A–2B. `lessons.json` giữ 33 bài với thứ tự từ như giáo trình; một từ ở nhiều bài thì hiện ở cả các bài đó.
- Phần web chỉ có chữ Hàn + nghĩa Việt. **Loại từ, câu ví dụ, bản dịch và phiên âm của 578 từ mới được biên soạn / sinh tự động** (phiên âm theo Romanization chuẩn, chưa xử lý hết các quy tắc biến âm hiếm).

**Tab Giáo trình**
- Thanh chọn 2 tầng: Từ vựng | Ngữ pháp, rồi chế độ (Danh sách / Thẻ / Ôn từ, hoặc Bài học / Bài tập).
- Một menu Bộ lọc (bài Seoul, unit) + dòng tóm tắt bộ lọc kèm "đã thuộc/tổng" và thanh tiến độ.
- Flashcard 3D, vuốt để đánh dấu; Ôn từ dùng lại màn bài tập; màn kết quả dùng chung (`ResultView`).
- Ôn theo lịch Leitner cho từ vựng (`ProgressStore.vocab`, khóa là chữ Hàn), tách riêng khỏi tiến độ chữ cái; mục "Cần ôn" gom các từ đến hạn.
- Bài tập ngữ pháp chia lượt 10 câu, có "Làm lại câu sai".
- Ngữ pháp: danh sách tiêu đề gom theo bài, mở trang chi tiết riêng.

**Chung**
- Nhãn accessibility cho nút chỉ có icon; icon loa trang trí được ẩn khỏi VoiceOver.
- Rung (haptic) kèm âm đúng/sai.
- Cài đặt rời thanh tab (còn 5 tab, không còn "Thêm"), mở bằng nút bánh răng ở tab Học.
- Sửa ô đang chọn bị mờ ở màn Ghép chữ (bỏ `mask` làm mờ hai đầu).

### Ảnh hưởng quyền riêng tư & quyền truy cập
- **Không đổi.** Không thêm quyền mới, không có mạng, không tài khoản. Dữ liệu mới (`learnedVocab`, `vocabProgress`) chỉ nằm trong `UserDefaults` trên máy, nằm trong phạm vi `PrivacyInfo.xcprivacy` hiện có (`CA92.1`).
- Câu trả lời App Privacy giữ nguyên: **Data Not Collected**.

### Ghi chú gửi App Review (nối thêm vào Notes hiện có)
```
Version 1.3 adds hold-to-record speech translation (existing, on-device recording) and a Seoul 1A–2B vocabulary course to the existing Words tab (flashcards, quiz, spaced-repetition review). All content is bundled in the app; it works offline, needs no account and makes no network requests. Progress is stored locally on the device only. No change to permissions or to the App Privacy answers.
```

### Trạng thái kiểm thử
- 108 unit test (Swift Testing) pass, gồm test mới cho: mỗi bài khớp 100% danh sách từ của giáo trình, quiz luôn có 4 đáp án khác nhau chứa đáp án đúng, lịch ôn từ vựng (`isReviewDue`, kho tiến độ tách riêng).
- Xác nhận bằng ảnh chụp trên simulator (iPhone 17 Pro): thanh 5 tab, nút bánh răng, thanh chọn 2 tầng, dòng tiến độ 0/986, danh sách từ hiển thị đúng.
- **Chưa kiểm tra bằng mắt trên thiết bị / simulator:** vuốt và lật flashcard, menu Bộ lọc, quiz và màn kết quả, trang chi tiết ngữ pháp, nút bánh răng mở Cài đặt, haptic. Cần test tay trước khi nộp.

### Rủi ro / việc cần làm trước khi nộp
1. **Quyền sử dụng nội dung.** Danh sách từ theo giáo trình Seoul lấy từ trang web đã có (`seoultuvung.netlify.app`). Cần chắc chắn có quyền dùng/phân phối nội dung này trong app thương mại (Guideline 5.2, sở hữu trí tuệ).
2. **Rà soát nội dung biên soạn.** Loại từ, câu ví dụ, bản dịch, phiên âm của 578 từ mới chưa có người ngoài duyệt; nên nhờ người biết tiếng Hàn xem một lượt.
3. **Ngữ pháp chưa gắn với bài Seoul.** 70 điểm ngữ pháp chỉ có unit 1–8 (30 điểm chưa có unit); chọn một bài Seoul ở bộ lọc không lọc được ngữ pháp. Cần mục lục giáo trình để làm tiếp.
4. **Thanh chọn / bố cục** ở iPhone màn nhỏ và cỡ chữ lớn (Dynamic Type) chưa được kiểm tra; các tab cũ (ô chữ cái cố định 76pt, viết tay) chưa rà ở cỡ chữ lớn.
5. Thanh tìm kiếm của danh sách từ nằm trên hai thanh chọn nên danh sách bắt đầu khá thấp; xem có cần thu gọn không.

### Các bước phát hành
1. Version trong `project.pbxproj` đã là `MARKETING_VERSION = 1.3`, `CURRENT_PROJECT_VERSION = 5` (mỗi giá trị 4 lần: Debug/Release × hai target). Nếu build 5 đã bị dùng, tăng lên số lớn hơn.
2. Chạy toàn bộ test, rồi archive Release:
   ```
   xcodebuild -project HangulStudy.xcodeproj -scheme HangulStudy -destination 'generic/platform=iOS' \
     -configuration Release -archivePath build/HangulStudy.xcarchive archive
   ```
3. Upload thẳng từ dòng lệnh (`ExportOptions` với `method=app-store-connect`, `destination=upload`, `signingStyle=automatic`, `teamID=<TEAM_ID>`; thư mục `build/` đã nằm trong `.gitignore`):
   ```
   xcodebuild -exportArchive -archivePath build/HangulStudy.xcarchive \
     -exportPath build/upload -exportOptionsPlist build/ExportOptionsUpload.plist
   ```
4. App Store Connect: tạo/chọn version 1.3 → dán "What's New" ở trên → chờ build 5 xử lý xong rồi "Add Build" → nối ghi chú vào App Review Notes → Add for Review → Submit.
5. Sau khi được duyệt: cập nhật mục "Sau khi được duyệt" trong `docs/APP_STORE_CHECKLIST.md` nếu có thay đổi quy trình.

---

## Lịch sử phiên bản

Lấy từ lịch sử git (commit "Bump version").

| Phiên bản | Build | Nội dung chính |
|---|---|---|
| 1.0 | 1 | Bản đầu: bảng chữ cái Hangul, ghép âm tiết, quiz nhiều chế độ có âm đúng/sai, theo dõi tiến độ (Leitner), thứ tự nét và luyện viết, onboarding, hai ngôn ngữ VI/EN |
| 1.1 | 2 | Chấm điểm chữ viết tay, quy tắc phát âm, số đếm, chế độ quiz gõ đáp án |
| 1.2 | 3 | Mẹo phát âm và chấm điểm phát âm (nhận dạng giọng nói trên thiết bị) |
| 1.3 | 4–5 | Dịch bằng giọng nói (giữ để ghi âm, Hàn → ngôn ngữ của app); build 5 thêm giáo trình Seoul: 986 từ theo bài, flashcard, ôn theo lịch, quiz từ vựng, ngữ pháp gọn hơn, nâng cấp giao diện *(đang chuẩn bị)* |
