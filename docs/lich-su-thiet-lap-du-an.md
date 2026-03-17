# Lịch Sử Thiết Lập Dự Án Date App

## Tổng Quan

Tài liệu này tóm tắt lại các bước thiết lập chính đã thực hiện từ đầu đến nay, những vấn đề đã gặp phải, và cách xử lý tương ứng cho từng vấn đề.

## Các Bước Đã Thực Hiện

### 1. Khởi động lại dự án local

- Khởi động backend local tại `http://localhost:8080`
- Khởi động admin local tại `http://localhost:5173`
- Chạy app Flutter local để test

### 2. Cài toolchain Windows cho Flutter

- Cài `Visual Studio Build Tools 2022`
- Thêm workload C++ desktop
- Đưa `flutter doctor` về trạng thái sạch để có thể build Windows desktop

### 3. Bổ sung dữ liệu user directory

- Thêm các field `birthDate`, `country`, `prefecture`, `datingReason`
- Thêm migration tương ứng cho database
- Cập nhật admin user list để hiển thị đúng các cột theo yêu cầu
- Cập nhật luồng register và update trên app để khớp với dữ liệu mới
- Thêm logic sinh user ID cố định theo format `3 số + 5 chữ`

### 4. Thiết lập PostgreSQL local

- Cài PostgreSQL local
- Tạo database `date_app`
- Kết nối backend local với database local
- Kiểm tra dữ liệu user bằng SQL

### 5. Cài pgAdmin 4

- Cài `pgAdmin 4` để xem database local
- Xác nhận database local đang chạy trên PostgreSQL cài trong máy
- Kiểm tra được các bảng như `users`, `matches`, `refresh_tokens`

### 6. Cải tiến giao diện admin

- Thêm popup `新規登録`
- Ẩn form create và edit cũ khỏi màn user list
- Mở edit bằng modal giống luồng create
- Đổi màu nền admin và màu vùng nội dung bên phải
- Thêm đường kẻ ngang và dọc cho bảng user list
- Thêm phân trang với các lựa chọn `10`, `20`, `50`, `100`

### 7. Thiết lập CI/CD đơn giản

- Thêm GitHub Actions workflow để deploy Render bằng một nút bấm
- Ghi chú các secrets cần thiết cho repo
- Đưa workflow deploy lên `develop` và `main`

### 8. Chuẩn hóa flow branch

- Mỗi lần làm xong đều commit và push ngay
- Khi merge feature vào `develop` thì xóa branch feature ở local và remote

### 9. Làm màn hình login cho app

- Thêm màn `ログイン`
- Validate email và password theo đúng copy tiếng Nhật đã yêu cầu
- Disable button login cho tới khi form hợp lệ
- Thêm show và hide password
- Hỗ trợ Enter để submit
- Thêm loading overlay
- Thêm checkbox ghi nhớ thông tin login

### 10. Refactor cấu trúc app mobile và web

- Tách `LoginScreen`, `AuthShell`, `DiscoverScreen`, `MatchesScreen`, `AccountScreen`
- Tách API client và models ra khỏi `main.dart`
- Giảm trách nhiệm của `main.dart`
- Làm sạch auth flow để sau này thêm chức năng dễ hơn

### 11. Đồng bộ branch mobile với admin và backend mới

- Phát hiện branch mobile có code mobile mới nhưng admin và backend cũ hơn
- Kéo các file admin và backend cần thiết từ `develop` sang branch đang làm
- Build lại và restart local services

### 12. Build và chạy app web local

- Build Flutter web release
- Chạy local server tại `http://localhost:8081`
- Kết nối app web local với backend local tại `http://localhost:8080`

## Các Vấn Đề Đã Gặp Và Cách Xử Lý

### 1. Flutter Windows desktop không build được

- Nguyên nhân: thiếu toolchain desktop của Visual Studio
- Cách xử lý: cài `Visual Studio Build Tools` và workload C++ desktop

### 2. Backend không dùng được database local

- Nguyên nhân: PostgreSQL chưa được cài hoặc chưa chạy
- Cách xử lý: cài PostgreSQL, tạo `date_app`, rồi nối backend vào database này

### 3. Muốn xem database bằng trình duyệt nhưng không biết mở ở đâu

- Nguyên nhân: PostgreSQL không có giao diện web như admin
- Cách xử lý: cài `pgAdmin 4` và connect vào database local

### 4. User tạo từ admin không login được ở app local

- Nguyên nhân: user không được tạo vào cùng backend và database local mà app đang dùng
- Cách xử lý: thêm `admin/.env.local` để admin local luôn trỏ vào `http://localhost:8080`

### 5. Admin local không hiển thị giao diện mới nhất

- Nguyên nhân: branch mobile hiện tại đang chứa code admin cũ
- Cách xử lý: đồng bộ code admin mới từ `develop` sang branch đang làm

### 6. Tạo user ở admin local bị failed

- Nguyên nhân: payload của admin cũ không còn khớp với schema backend mới
- Cách xử lý: đồng bộ lại admin và backend cho cùng version, sau đó build và restart lại

### 7. Flutter web mở lên bị trắng trang hoặc lỗi file resource

- Nguyên nhân: mở sai cách qua file trực tiếp hoặc bị cache/service worker cũ
- Cách xử lý: chạy bằng local HTTP server và mở qua `http://localhost:8081`

### 8. Flutter web báo `Cannot load profiles`

- Nguyên nhân: có lúc backend local không chạy, có lúc bị chặn bởi CORS
- Cách xử lý:
- restart backend local khi cần
- thêm `http://localhost:8081` và `http://127.0.0.1:8081` vào allowed origins của backend

### 9. Refactor auth từng làm vỡ UI login

- Nguyên nhân: login trước đó bị gắn chặt với `AccountScreen` và `main.dart`
- Cách xử lý: tách lại auth theo `LoginScreen` và `AuthShell`

### 10. Một số lệnh build local bị chặn

- Nguyên nhân: giới hạn thực thi hoặc subprocess của môi trường
- Cách xử lý: chạy lại các lệnh cần thiết với quyền phù hợp và kiểm tra output sau khi chạy

## Trạng Thái Local Hiện Tại

- Backend local: `http://localhost:8080`
- Admin local: `http://localhost:5173`
- App web local: `http://localhost:8081`
- Admin local đang trỏ vào backend local
- Backend local đã mở CORS cho app web local trên cổng `8081`
- Auth flow của app đã được tách để dễ mở rộng sau này

## Các Commit Gần Đây Quan Trọng

- `cecd3d7` Refactor mobile auth flow into separate screens
- `c0c834b` Ignore admin local env overrides
- `ab392eb` Sync admin and backend updates into mobile branch
- `cabd074` Allow local web build origin in backend CORS
- `e1f36f4` Add development setup history note
