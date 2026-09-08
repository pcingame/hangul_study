# Checklist đưa HangulStudy lên App Store

Thông tin dự án hiện tại (đã đọc từ `HangulStudy.xcodeproj`):

| Mục | Giá trị |
|---|---|
| Bundle ID | `com.koreastudy.HangulStudy` |
| Team ID | `P3MPHWPJ62` (Automatic signing) |
| Marketing version | `1.0` |
| Build number | `1` |
| Deployment target | iOS 17.0 |
| Thiết bị | iPhone-only, chỉ hướng dọc — `TARGETED_DEVICE_FAMILY = 1` |
| Frameworks | SwiftUI, PencilKit, AVFoundation (TTS) — **không có SDK bên thứ ba, không mạng, không tài khoản, không tracking** |

---

## 1. Tài khoản & thiết lập ban đầu

- [x] Đã tham gia **Apple Developer Program**, trạng thái Active (Team ID `P3MPHWPJ62`)
- [x] Đăng nhập được [App Store Connect](https://appstoreconnect.apple.com)
- [x] Agreements, Tax, and Banking: đã submit được app (nếu hợp đồng "Free apps" chưa Active thì App Store Connect đã chặn tạo app — không bị chặn nên coi như OK)
- [x] Tạo **App ID / bản ghi app mới** trong App Store Connect (2026-09-09):
  - Platform: iOS
  - Name: `Hangul Study`
  - Primary language: Vietnamese
  - Bundle ID: `com.koreastudy.HangulStudy` (đăng ký mới trong Certificates, Identifiers & Profiles ▸ Identifiers)
  - SKU: `hangulstudy-001`
  - Apple ID (App Store Connect): `6809894086`

---

## 2. Cấu hình dự án trong Xcode

- [x] **Tên hiển thị**: đã đặt `INFOPLIST_KEY_CFBundleDisplayName = "Hangul Study"`. Sửa trong `project.pbxproj` nếu muốn tên khác.
- [ ] **Version / Build**: `1.0` (1) cho lần nộp đầu là hợp lệ. Mỗi lần upload build mới lên cùng version phải **tăng build number**.
- [ ] **Signing & Capabilities**: Automatic, Team = `P3MPHWPJ62`, không thừa capability nào (app không cần Push, iCloud, v.v.)
- [ ] **Release scheme**: Product ▸ Scheme ▸ Edit Scheme ▸ Archive dùng cấu hình **Release**
- [ ] Build sạch không warning nghiêm trọng:
  ```bash
  xcodebuild -project HangulStudy.xcodeproj -scheme HangulStudy \
    -destination 'generic/platform=iOS' -configuration Release clean build
  ```
- [ ] Chạy toàn bộ test:
  ```bash
  xcodebuild -project HangulStudy.xcodeproj -scheme HangulStudy \
    -destination 'platform=iOS Simulator,name=iPhone 17' test
  ```

---

## 3. Privacy manifest (BẮT BUỘC — app dùng `UserDefaults`)

App lưu tiến độ bằng `UserDefaults` (`ProgressStore`, `@AppStorage`). Từ 2024 Apple yêu cầu khai báo "required reason API" này, nếu không sẽ **bị từ chối khi upload**.

- [x] Đã thêm file `HangulStudy/PrivacyInfo.xcprivacy` với nội dung:

  ```xml
  <?xml version="1.0" encoding="UTF-8"?>
  <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
  <plist version="1.0">
  <dict>
    <key>NSPrivacyTracking</key>
    <false/>
    <key>NSPrivacyTrackingDomains</key>
    <array/>
    <key>NSPrivacyCollectedDataTypes</key>
    <array/>
    <key>NSPrivacyAccessedAPITypes</key>
    <array>
      <dict>
        <key>NSPrivacyAccessedAPIType</key>
        <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
        <key>NSPrivacyAccessedAPITypeReasons</key>
        <array>
          <string>CA92.1</string>
        </array>
      </dict>
    </array>
  </dict>
  </plist>
  ```
  (`CA92.1` = "truy cập dữ liệu của chính app này")

- [x] Dự án dùng file-system-synchronized group nên file tự động được đưa vào target; đã xác minh `PrivacyInfo.xcprivacy` có trong `HangulStudy.app` sau khi build Release.

---

## 4. Export compliance (mã hóa)

App không dùng mã hóa nào ngoài của hệ thống → khai báo sẵn để khỏi bị hỏi mỗi lần upload:

- [x] Đã thêm `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO` (Debug + Release). Info.plist build ra có `ITSAppUsesNonExemptEncryption = false`.

---

## 5. App icon & tài nguyên hình ảnh

- [ ] `AppIcon` hiện chỉ có `icon-1024.png` (một cỡ — Xcode tự sinh các cỡ còn lại, OK)
- [x] Icon đã được làm phẳng (gộp lên nền hồng), `sips -g hasAlpha` trả về `no`. Không còn alpha channel.
- [ ] Launch screen: hiện là màn hình trắng tự sinh (`UILaunchScreen_Generation`). Chấp nhận được; nếu muốn đẹp hơn thì thêm logo/nền.

---

## 6. Metadata cho App Store Connect

- [x] **Tên app**: `Hangul Study`
- [x] **Subtitle**: `Bảng chữ cái & phát âm`
- [x] **Category**: Primary = **Education**; Secondary = **Reference**
- [x] **Description**: đã điền (dựa trên phần "Tính năng" trong `README.md`), ~2941/4000 ký tự.
- [x] **Keywords** (78/100 ký tự): `hangul,tiếng hàn,korean,bảng chữ cái,học tiếng hàn,phát âm,luyện viết,alphabet`
- [ ] **Promotional text** (tuỳ chọn, ≤ 170 ký tự) — bỏ trống, có thể thêm sau
- [x] **Trang Privacy + Support đã tạo**: `docs/index.html`, `docs/privacy.html`, `docs/support.html` (song ngữ VI/EN, email `phuongtdoan2008@gmail.com`).
- [x] **Bật GitHub Pages**: repo ▸ Settings ▸ Pages ▸ Source = "Deploy from a branch" ▸ Branch = `main`, thư mục `/docs` ▸ Save. Đã live, cả 3 URL trả `200 OK` (kiểm tra 2026-09-09).
  - Privacy Policy URL → `https://pcingame.github.io/hangul_study/privacy.html` (điền trong App Store Connect ▸ App Privacy ▸ Edit)
  - Support URL → `https://pcingame.github.io/hangul_study/support.html` (điền trong mục Version 1.0)
- [x] **Marketing URL**: `https://pcingame.github.io/hangul_study/`
- [x] **Copyright**: `2026 Phuong Doan Thanh`
- [ ] **Ngôn ngữ localizations**: hiện chỉ có Vietnamese; thêm English sau nếu muốn metadata song ngữ

### Screenshots (bắt buộc)

- [x] **iPhone 6.9"** (1290×2796 hoặc 1320×2868) — bắt buộc, 3–10 ảnh
- [x] **iPad**: đã tắt (`TARGETED_DEVICE_FAMILY = 1`) → không cần screenshot iPad
- [x] Đã chụp bằng Simulator **iPhone 17 Pro Max**, đúng 1320×2868: `docs/screenshots/{onboarding,learn,build,quiz,write,settings}-{light,dark}.png` (10 ảnh, thiếu build-dark vì không cần thiết). Tiến độ được seed sẵn (22/40 chữ đã thuộc) cho đẹp.
  - *(Tap tự động hoá được trong phiên Claude bằng `cliclick` + toạ độ tính từ khung cửa sổ Simulator — xem lịch sử chat nếu cần lặp lại.)*
- [ ] App preview video: tuỳ chọn

---

## 7. Bảng "App Privacy" (Nutrition Label)

Trong App Store Connect ▸ App Privacy:

- [x] **Data Collection**: đã chọn **"No, we do not collect data from this app"** → hiện "Data Not Collected", đã **Publish** (2026-09-09)
  *(app không có mạng, không analytics, không account — mọi thứ lưu local bằng UserDefaults)*

---

## 8. Age rating

- [x] Điền bảng câu hỏi Age Rating: tất cả chọn **None / No** → kết quả **4+** (172 quốc gia/khu vực; Brazil/Hàn Quốc/Việt Nam ra rating tương đương không giới hạn). Đã Save (2026-09-09).

---

## 9. Build, validate & upload

- [x] Chọn **"Any iOS Device (arm64)"** làm run destination
- [x] **Product ▸ Archive**
- [x] Trong Organizer: **Validate App** → không lỗi
- [x] **Distribute App ▸ App Store Connect ▸ Upload** — upload thành công (2026-09-09)
- [x] Build đã được xử lý và gán vào version 1.0 (build number `1`)

Hoặc bằng dòng lệnh:
```bash
xcodebuild -project HangulStudy.xcodeproj -scheme HangulStudy \
  -configuration Release -archivePath build/HangulStudy.xcarchive archive

xcodebuild -exportArchive -archivePath build/HangulStudy.xcarchive \
  -exportPath build/export -exportOptionsPlist ExportOptions.plist

xcrun altool --upload-app -f build/export/HangulStudy.ipa -t ios \
  --apiKey <KEY_ID> --apiIssuer <ISSUER_ID>
```

---

## 10. Kiểm thử trước khi submit

- [ ] Chạy bản Release trên **máy thật** ít nhất 1 lần
- [ ] Test trên iPhone nhỏ (SE) và iPad — layout không vỡ, nút không bị che
- [ ] Bật **Dynamic Type cỡ lớn nhất** (Settings ▸ Accessibility ▸ Larger Text) — chữ không bị cắt
- [ ] Thử **máy CHƯA cài giọng tiếng Hàn** → app không crash, hiện cảnh báo "Chưa có giọng tiếng Hàn" (đã có sẵn trong `LetterDetailView`)
- [ ] Test cả 2 ngôn ngữ (VI/EN) và 3 chế độ giao diện (Sáng/Tối/Hệ thống)
- [ ] Luyện viết bằng ngón tay + Apple Pencil; nút "Xem cách viết" chạy đúng
- [ ] Hoàn thành 1 lượt quiz → màn hình kết quả + danh sách "Cần ôn lại" hiển thị đúng
- [ ] Xóa tiến độ trong Cài đặt hoạt động
- [ ] Kill app rồi mở lại → tiến độ vẫn còn (UserDefaults)

---

## 11. Submit for Review

- [x] Gán build vào version 1.0
- [x] **App Review Information** (đã điền, Save 2026-09-09):
  - Sign-in required: **No**
  - Contact: Phuong / Doan Thanh, `+84971149326`, `phuongtdoan2008@gmail.com`
  - Notes cho reviewer:
    > App phát âm tiếng Hàn bằng giọng tổng hợp `ko-KR` của hệ thống. Nếu thiết bị review chưa cài giọng tiếng Hàn, phần nghe sẽ im lặng và app hiển thị hướng dẫn cài trong Cài đặt iOS ▸ Trợ năng ▸ Nội dung nói ▸ Giọng nói. Toàn bộ dữ liệu học lưu cục bộ, app không kết nối mạng.
- [x] **Version Release**: để mặc định **Automatically release this version**
- [x] Bấm **Add for Review** → **Submit** — **Đã nộp thành công**, trạng thái **"Waiting for Review"**
  (Submission ID `7de99ae0-b883-48ba-97bf-ca6a1ce55cd5`, nộp lúc Sep 9, 2026, 1:01 AM)

---

## 12. Sau khi được duyệt

- [ ] Nếu để "Manual release": bấm **Release** khi sẵn sàng
- [ ] Kiểm tra app trên App Store thật (mất vài giờ để lan toàn cầu)
- [ ] Tag phiên bản trong git: `git tag v1.0 && git push --tags`

---

## Việc còn thiếu trong repo (cần làm trước lần nộp đầu)

Đã xử lý trong code (build Release + 77 test đã pass):

1. ✅ **`PrivacyInfo.xcprivacy`** — đã thêm `HangulStudy/PrivacyInfo.xcprivacy` (khai `NSPrivacyAccessedAPICategoryUserDefaults` / lý do `CA92.1`, không tracking, không thu thập dữ liệu). Tự động vào bundle nhờ file-system-synchronized group. Đã xác minh có trong `HangulStudy.app`.
2. ✅ **App icon alpha** — đã làm phẳng `icon-1024.png` lên nền hồng, `hasAlpha: no`.
3. ✅ **`ITSAppUsesNonExemptEncryption`** — đã thêm `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO` (Debug + Release). Info.plist build ra có `ITSAppUsesNonExemptEncryption = false`.
4. ✅ **Tên hiển thị** — đã thêm `INFOPLIST_KEY_CFBundleDisplayName = "Hangul Study"`. Đổi lại trong `project.pbxproj` nếu muốn tên khác.

5. ✅ **iPad đã tắt** — `TARGETED_DEVICE_FAMILY = 1`, bỏ luôn key orientation iPad. App giờ iPhone-only, chỉ cần screenshot iPhone 6.9".

Đã xử lý thủ công (ngoài code):

6. ✅ **Bật GitHub Pages** cho thư mục `/docs` trên `main` — live, cả 3 URL trả `200 OK`.
7. ✅ **Bộ screenshot iPhone 6.9"** — chụp bằng Simulator iPhone 17 Pro Max, đúng 1320×2868, đã upload lên App Store Connect.
8. ✅ **Trang App Store Connect** — app record, metadata, Category, App Privacy label (Data Not Collected, Published), Age Rating (4+), App Review Information đều đã điền và lưu.

Còn lại duy nhất — cần Xcode trên máy, không làm qua trình duyệt được:

9. **Archive & upload build** (mục 9) rồi **gán build + Submit** (mục 11).
