# 📸 Locket Widget Clone (iOS & Android)

Ứng dụng chia sẻ ảnh trực tiếp lên **Widget màn hình chính (Home Screen)** của bạn bè theo phong cách **Locket Widget**, được xây dựng bằng **Flutter**, kết hợp **iOS WidgetKit (SwiftUI)** và **Android AppWidget (Kotlin)**.

---

## 🌟 Điểm nổi bật & Tính năng chính

- 📷 **Giao diện Camera 1:1 chuẩn Locket**:
  - Khung ngắm chụp ảnh bo góc toàn màn hình.
  - Chuyển đổi camera trước/sau, bật/tắt đèn Flash.
  - Chế độ chụp giả lập (Gallery picker) khi test trên máy ảo hoặc thiết bị không có phần cứng camera.
- 👥 **Chọn người nhận (Recipients Selector)**:
  - Gửi ảnh cho "Tất cả bạn bè" (All Friends) hoặc chọn gửi riêng cho từng người.
  - Hiển thị danh sách bạn bè kèm trạng thái Online/Offline.
- 🖼️ **Widget màn hình chính (Core feature)**:
  - **iOS Widget (SwiftUI + WidgetKit)**: Tự động nạp ảnh từ `UserDefaults` (thông qua App Group `group.com.example.locketApp`).
  - **Android AppWidget (Kotlin)**: Tự động cập nhật `RemoteViews` và hiển thị ảnh trên widget Android ngay khi có ảnh mới.
  - Chạm vào widget sẽ kích hoạt Deep link `locket://open` để mở app tức thì.
- 💬 **Ghi chú & Cảm xúc (Reactions & Notes)**:
  - Thêm ghi chú ngắn (caption) trước khi gửi.
  - Thả biểu tượng cảm xúc (❤️, 🔥, 😂, 😮, 🥹, 👏) trực tiếp vào các khoảnh khắc đã nhận.
- 📖 **Lịch sử khoảnh khắc (Moments History)**:
  - Lướt xem lại toàn bộ các ảnh bạn bè đã gửi kèm ngày giờ và biểu cảm.

---

## 📁 Cấu trúc thư mục dự án

```text
locket_app/
├── lib/
│   ├── config/
│   │   └── app_config.dart            # Cấu hình AppGroup, tên widget, cờ bật Firebase
│   ├── models/
│   │   ├── friend_model.dart          # Mô hình dữ liệu bạn bè
│   │   └── moment_model.dart          # Mô hình dữ liệu ảnh chụp Locket
│   ├── services/
│   │   ├── widget_sync_service.dart   # Cầu nối đồng bộ dữ liệu vào iOS & Android Widget
│   │   ├── storage_service.dart       # Quản lý bộ nhớ local, seed dữ liệu mẫu
│   │   └── auth_service.dart          # Quản lý tài khoản người dùng
│   ├── widgets/
│   │   ├── camera_controls.dart       # Nút chụp vàng đặc trưng Locket, lật camera, flash
│   │   ├── friend_badge.dart          # Vòng tròn avatar bạn bè
│   │   └── reaction_overlay.dart      # Thanh thả emoji nổi
│   ├── screens/
│   │   ├── camera_screen.dart         # Màn hình chính kính ngắm camera
│   │   ├── photo_preview_screen.dart  # Xem trước ảnh, viết ghi chú, nút gửi
│   │   ├── history_screen.dart        # Dòng thời gian lướt ảnh cũ
│   │   └── friends_screen.dart        # Danh sách bạn bè & link mời kết bạn
│   └── main.dart                      # Entrypoint khởi tạo app & lắng nghe deep link
├── ios/
│   ├── Runner/
│   │   ├── Info.plist                 # Quyền Camera/Photo & Deep link scheme
│   │   └── Runner.entitlements        # Cấu hình App Group
│   └── LocketWidget/
│       ├── LocketWidget.swift         # WidgetKit SwiftUI render ảnh & info pill
│       ├── LocketWidgetBundle.swift   # Bundle entrypoint cho iOS Widget
│       ├── LocketWidget.entitlements  # App Group cho Extension
│       └── Info.plist
└── android/
    └── app/src/main/
        ├── AndroidManifest.xml        # Khai báo Widget Receiver & Permissions
        ├── kotlin/com/example/locket_app/
        │   ├── MainActivity.kt
        │   └── LocketAppWidgetProvider.kt # Kotlin Widget Provider cập nhật RemoteViews
        └── res/
            ├── layout/locket_widget.xml   # Giao diện widget Android
            └── xml/locket_widget_info.xml # Thông số kích thước widget
```

---

## 🚀 Hướng dẫn cài đặt và chạy thử

### 1. Chuẩn bị môi trường
- Cài đặt **Flutter SDK** (phiên bản `>= 3.0.0`): [flutter.dev](https://flutter.dev)
- Mở thư mục này bằng **VS Code** hoặc **Android Studio**:
  ```bash
  cd "C:\Users\Administrator\.gemini\antigravity\scratch\locket_app"
  flutter pub get
  ```

### 2. Chạy trên Android (Có thể test ngay trên máy Windows)
1. Bật máy ảo Android (hoặc cắm điện thoại Android bật USB Debugging):
   ```bash
   flutter run
   ```
2. **Thêm Widget ra màn hình chính Android**:
   - Nhấn giữ vào chỗ trống trên màn hình chính của điện thoại Android.
   - Chọn mục **Widgets** (Tiện ích).
   - Tìm ứng dụng **Locket** và kéo Widget ra màn hình.
   - Mở app Locket, chụp một bức ảnh và bấm **"Send to Friends’ Widgets"**.
   - Trở lại màn hình chính: Widget sẽ tự động đổi sang ảnh vừa chụp!

### 3. Cấu hình & Chạy trên iOS (Khi đưa sang máy Mac / Xcode)
1. Mở thư mục `ios` bằng Xcode: `open ios/Runner.xcworkspace`.
2. Chọn target **Runner** -> tab **Signing & Capabilities**:
   - Thêm capability **App Groups**.
   - Tích chọn `group.com.example.locketApp`.
3. Thêm target mới **Widget Extension**:
   - File -> New -> Target -> chọn **Widget Extension**.
   - Đặt tên target là `LocketWidget`.
   - Trong target `LocketWidget` -> **Signing & Capabilities**, cũng thêm capability **App Groups** và chọn cùng `group.com.example.locketApp`.
   - File `LocketWidget.swift` đã được chuẩn bị sẵn trong thư mục `ios/LocketWidget/`.
4. Nhấn **Run** trên iPhone hoặc Simulator để tận hưởng WidgetKit iOS.

---

## ☁️ Tích hợp Firebase (Tùy chọn cho Production)

Khi bạn muốn đưa app lên online cho bạn bè ở xa cùng dùng qua Internet:
1. Tạo dự án trên [Firebase Console](https://console.firebase.google.com).
2. Kích hoạt **Authentication**, **Cloud Firestore**, và **Cloud Storage**.
3. Bật **Cloud Messaging (FCM)**: Gửi Silent Notification khi có ảnh mới để kích hoạt hàm reload widget ngầm.
4. Mở file `lib/config/app_config.dart` và chuyển:
   ```dart
   static const bool useFirebase = true;
   ```
