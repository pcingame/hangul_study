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

- [ ] Đã tham gia **Apple Developer Program** (99 USD/năm), trạng thái Active
- [ ] Đăng nhập được [App Store Connect](https://appstoreconnect.apple.com)
- [ ] Trong App Store Connect ▸ **Agreements, Tax, and Banking**: hợp đồng "Free apps" ở trạng thái Active (bắt buộc kể cả app miễn phí)
- [ ] Tạo **App ID / bản ghi app mới** trong App Store Connect:
  - Platform: iOS
  - Name: *(xem mục 6 — tên hiển thị)*
  - Primary language: Vietnamese (hoặc English — nên chọn ngôn ngữ chính của store)
  - Bundle ID: chọn `com.koreastudy.HangulStudy` (nếu chưa có, tạo trong Certificates, Identifiers & Profiles ▸ Identifiers)
  - SKU: ví dụ `hangulstudy-001`

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

- [ ] **Tên app** (≤ 30 ký tự): ví dụ `Hangul Study — Học tiếng Hàn`
- [ ] **Subtitle** (≤ 30 ký tự): ví dụ `Bảng chữ cái & phát âm`
- [ ] **Category**: Primary = **Education**; Secondary (tuỳ chọn) = Reference
- [ ] **Description**: mô tả tính năng (Học / Ghép chữ / Kiểm tra / Luyện viết / Phát âm / Lặp lại ngắt quãng / Song ngữ). Có thể lấy từ phần "Tính năng" trong `README.md`.
- [ ] **Keywords** (≤ 100 ký tự, phân tách bằng dấu phẩy): ví dụ `hangul,tiếng hàn,korean,bảng chữ cái,học tiếng hàn,phát âm,luyện viết,alphabet`
- [ ] **Promotional text** (tuỳ chọn, ≤ 170 ký tự)
- [ ] **Support URL**: bắt buộc — 1 trang web bất kỳ có thông tin liên hệ (GitHub repo / trang GitHub Pages đều được)
- [ ] **Marketing URL**: tuỳ chọn
- [ ] **Privacy Policy URL**: **bắt buộc** kể cả khi không thu thập dữ liệu. Tự host 1 trang đơn giản (GitHub Pages) ghi rõ "App không thu thập, không truyền dữ liệu cá nhân; tiến độ học chỉ lưu trên máy."
- [ ] **Copyright**: ví dụ `2026 <tên bạn>`
- [ ] **Ngôn ngữ localizations**: thêm cả Vietnamese và English nếu muốn hiển thị metadata song ngữ

### Screenshots (bắt buộc)

- [ ] **iPhone 6.9"** (1290×2796 hoặc 1320×2868) — bắt buộc, 3–10 ảnh
- [x] **iPad**: đã tắt (`TARGETED_DEVICE_FAMILY = 1`) → không cần screenshot iPad
- [ ] Chụp bằng Simulator: `Cmd+S` trong Simulator, hoặc `xcrun simctl io booted screenshot`. Đã có sẵn ảnh trong `docs/screenshots/` để tham khảo.
- [ ] App preview video: tuỳ chọn

---

## 7. Bảng "App Privacy" (Nutrition Label)

Trong App Store Connect ▸ App Privacy:

- [ ] **Data Collection**: chọn **"No, we do not collect data from this app"**
  *(app không có mạng, không analytics, không account — mọi thứ lưu local bằng UserDefaults)*

---

## 8. Age rating

- [ ] Điền bảng câu hỏi Age Rating: tất cả chọn **None / No** → kết quả **4+**

---

## 9. Build, validate & upload

- [ ] Cắm/chọn **"Any iOS Device (arm64)"** làm run destination
- [ ] **Product ▸ Archive**
- [ ] Trong Organizer: **Validate App** → sửa hết lỗi (thường là: thiếu privacy manifest, icon có alpha, build number trùng)
- [ ] **Distribute App ▸ App Store Connect ▸ Upload**
- [ ] Chờ email "processing complete" (5–30 phút), build xuất hiện ở tab **TestFlight**

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

- [ ] Gán build từ TestFlight vào version 1.0
- [ ] **App Review Information**:
  - Sign-in required: **No**
  - Notes cho reviewer (nên có):
    > App phát âm tiếng Hàn bằng giọng tổng hợp `ko-KR` của hệ thống. Nếu thiết bị review chưa cài giọng tiếng Hàn, phần nghe sẽ im lặng và app hiển thị hướng dẫn cài trong Cài đặt iOS ▸ Trợ năng ▸ Nội dung nói ▸ Giọng nói. Toàn bộ dữ liệu học lưu cục bộ, app không kết nối mạng.
- [ ] **Version Release**: Manual hoặc Automatic sau khi được duyệt
- [ ] Bấm **Add for Review** → **Submit**

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

Còn cần bạn làm thủ công (ngoài code):

6. **Privacy Policy URL + Support URL** — cần host (mục 6).
7. **Bộ screenshot iPhone 6.9"** — chụp bằng Simulator.
8. **Trang App Store Connect** — metadata, App Privacy label, age rating, upload build.
