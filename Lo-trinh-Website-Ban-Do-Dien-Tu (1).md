# Lộ trình xây dựng ElectroShop

> Tài liệu này mô tả lộ trình và trạng thái dự án theo mã nguồn trong repository. Trạng thái chức năng được đánh dấu theo việc đã có luồng triển khai trong code; điều đó không đồng nghĩa mọi luồng đã được kiểm thử trên production.

## 1. Tổng quan dự án

ElectroShop là website bán đồ điện tử phục vụ đồ án môn học. Ứng dụng render giao diện phía máy chủ, lưu dữ liệu trong MySQL/MariaDB và có ba vai trò `user`, `employee`, `admin`.

### Công nghệ hiện dùng

| Thành phần | Công nghệ |
|---|---|
| Backend | Node.js, Express |
| Giao diện | EJS, HTML, CSS và JavaScript phía trình duyệt |
| Cơ sở dữ liệu | MySQL/MariaDB, truy vấn bằng `mysql2/promise` |
| Đăng nhập | `express-session`, `bcrypt`, `connect-flash` |
| Bảo vệ request | `csurf`, `helmet`, `express-rate-limit` |
| Tải ảnh | `multer`, `sharp`; ảnh được chuyển sang WebP |
| Quản lý mã nguồn | Git, GitHub |
| Triển khai dự kiến/đang hỗ trợ | Railway hoặc Render; cấu hình bằng biến môi trường |

Dự án không dùng Next.js, React, Prisma, PostgreSQL, Bootstrap hay cổng thanh toán trực tuyến trong kiến trúc hiện tại. Các công nghệ này không thuộc phạm vi lộ trình triển khai.

## 2. Phạm vi chức năng

### Đã có luồng triển khai trong mã nguồn

- Duyệt trang chủ, xem danh sách và chi tiết sản phẩm.
- Tìm kiếm theo tên/thương hiệu, lọc theo danh mục/thương hiệu và phân trang.
- Đăng ký, đăng nhập, đăng xuất; mật khẩu được băm bằng bcrypt.
- Cập nhật hồ sơ và đổi mật khẩu riêng biệt; đổi mật khẩu yêu cầu mật khẩu hiện tại.
- Quản lý giỏ hàng theo tài khoản; hỗ trợ luồng mua ngay.
- Checkout, tạo đơn hàng, chụp lại giá tại thời điểm mua và trừ kho trong transaction.
- Xem danh sách đơn hàng, lọc theo trạng thái, xem chi tiết đơn thuộc tài khoản hiện tại.
- Khách hủy đơn `pending`; nhân viên/quản trị viên quản lý trạng thái đơn, hủy đơn phù hợp và hoàn kho.
- Đánh giá sản phẩm sau khi đơn có sản phẩm đó đạt trạng thái `completed`.
- Danh sách yêu thích theo tài khoản.
- Trợ lý gợi ý sản phẩm theo từ khóa, danh mục và ngân sách.
- Admin quản lý sản phẩm, danh mục, nhân viên và xem thống kê.
- Employee quản lý sản phẩm và đơn hàng; chỉ admin quản lý danh mục và tài khoản nhân viên.

### Chưa thuộc phạm vi hoặc chưa triển khai

- Thanh toán trực tuyến qua VNPay, MoMo hoặc cổng khác.
- Gửi email xác nhận đơn hàng.
- Báo cáo doanh thu/biểu đồ chuyên sâu.
- Ứng dụng mobile hoặc SPA tách frontend/backend.
- Thu hồi tự động các phiên đăng nhập khác sau khi đổi mật khẩu.

## 3. Lộ trình và trạng thái

Quy ước: **Đã triển khai** nghĩa là có xử lý trong mã nguồn; **Cần kiểm thử** nghĩa là vẫn cần kiểm tra nghiệp vụ trên môi trường mục tiêu trước khi nghiệm thu.

### Giai đoạn 1 — Phân tích, thiết kế và khởi tạo

- [x] Chốt phạm vi cửa hàng điện tử và nhóm vai trò.
- [x] Chọn Node.js, Express, EJS và MySQL/MariaDB.
- [x] Tổ chức mã nguồn theo `config/`, `controllers/`, `middlewares/`, `models/`, `routes/`, `views/`, `public/`, `database/`.
- [x] Tạo schema và các migration phục vụ cập nhật database hiện hữu.
- [x] Viết tài liệu đặc tả và lộ trình gắn với chức năng thực tế.

### Giai đoạn 2 — Tài khoản và xác thực

- [x] Đăng ký khách hàng với email/số điện thoại duy nhất và mật khẩu tối thiểu 8 ký tự.
- [x] Đăng nhập chung cho khách hàng, employee và admin; đối chiếu mật khẩu với bcrypt hash trong DB.
- [x] Đăng xuất và quản lý session.
- [x] Middleware yêu cầu đăng nhập, nhân viên/quản trị viên và quản trị viên.
- [x] Cập nhật hồ sơ cá nhân và đổi mật khẩu qua form riêng.
- [ ] Kiểm thử đăng nhập lại sau đổi mật khẩu trên database/môi trường triển khai thực tế.

### Giai đoạn 3 — Danh mục và sản phẩm

- [x] CRUD danh mục dành cho admin.
- [x] CRUD sản phẩm dành cho admin/employee.
- [x] Tải ảnh sản phẩm có giới hạn dung lượng/định dạng; resize và chuyển WebP.
- [x] Trang chủ, danh sách, tìm kiếm, lọc, phân trang và chi tiết sản phẩm.
- [x] Ẩn sản phẩm khỏi cửa hàng bằng trạng thái hoạt động; ngăn xóa sản phẩm đã được đặt mua.
- [ ] Kiểm tra hiển thị ảnh sau khi deploy và quy trình lưu trữ bền vững nếu nền tảng dùng filesystem tạm.

### Giai đoạn 4 — Giỏ hàng và đặt hàng

- [x] Lưu giỏ hàng thường theo tài khoản trong `cart_items`.
- [x] Thêm, cập nhật số lượng, xóa dòng giỏ hàng và kiểm tra tồn kho.
- [x] Mua ngay một sản phẩm mà không thay đổi giỏ hàng thường.
- [x] Nhập người nhận, địa chỉ, số điện thoại và ghi chú ở checkout.
- [x] Tạo `orders`/`order_items`, lưu giá tại thời điểm đặt, trừ kho và xóa giỏ hàng trong transaction.
- [ ] Kiểm thử đồng thời nhiều checkout và các tình huống hết hàng trên MySQL mục tiêu.

### Giai đoạn 5 — Theo dõi và vận hành đơn

- [x] Khách xem danh sách đơn, lọc trạng thái, phân trang và mở chi tiết đơn của mình.
- [x] Khách chỉ hủy đơn `pending`; hệ thống khóa đơn, hoàn kho và cập nhật trạng thái trong transaction.
- [x] Employee/admin xem danh sách và chi tiết đơn, cập nhật trạng thái theo luồng hợp lệ.
- [x] Hủy đơn từ giao diện quản trị khi đơn `pending` hoặc `confirmed`, hoàn kho trước khi đổi trạng thái.
- [ ] Kiểm thử lại các chuyển trạng thái và tình huống hai nhân viên thao tác cùng đơn.

### Giai đoạn 6 — Tính năng bổ sung

- [x] Đánh giá sản phẩm: chỉ khách đã có đơn `completed` chứa sản phẩm được đánh giá.
- [x] Wishlist được lưu theo tài khoản.
- [x] Trợ lý gợi ý sản phẩm sử dụng danh mục hiện có, từ khóa và ngân sách.
- [x] Phân quyền: employee không quản lý nhân viên/danh mục; admin có toàn quyền khu vực quản trị.
- [ ] Đánh giá trải nghiệm giao diện trên các kích thước màn hình và trình duyệt mục tiêu.

### Giai đoạn 7 — Kiểm thử, bảo mật và nghiệm thu

- [x] Có CSRF cho form, giới hạn tốc độ nhóm route xác thực, Helmet và giới hạn kích thước body.
- [x] Có kiểm tra đầu vào cho các nghiệp vụ chính và xử lý lỗi tập trung.
- [ ] Hoàn thành checklist kiểm thử thủ công cho Guest, Customer, Employee, Admin.
- [ ] Xác minh toàn bộ luồng đặt/hủy đơn và hoàn kho trên bản sao database kiểm thử.
- [ ] Chụp ảnh giao diện, hoàn thiện báo cáo và chuẩn bị kịch bản demo.

### Giai đoạn 8 — Triển khai

- [ ] Cấu hình biến môi trường và database riêng cho staging/production.
- [ ] Chạy schema/migration theo thứ tự, sao lưu trước khi cập nhật database đang có dữ liệu.
- [ ] Deploy lên Railway hoặc Render; kiểm tra URL, HTTPS, cookie secure, upload ảnh và kết nối database.
- [ ] Smoke-test đăng ký/đăng nhập, đổi mật khẩu, mua hàng, theo dõi/hủy đơn và quyền employee/admin trên môi trường đã deploy.

## 4. Cấu trúc mã nguồn hiện tại

```text
.
├── app.js
├── config/                 # Kết nối MySQL
├── controllers/            # Xác thực và xử lý nghiệp vụ
├── middlewares/            # Đăng nhập, phân quyền
├── models/                 # Truy vấn dữ liệu
├── routes/                 # Route theo tính năng
├── views/                  # Giao diện EJS
├── public/                 # CSS, JavaScript, hình ảnh
├── database/
│   ├── schema.sql
│   └── migration-*.sql
├── package.json
└── README.md
```

## 5. Các bảng dữ liệu trọng tâm

- `users`: thông tin tài khoản, `password_hash`, `role` và `position`.
- `categories`, `products`: danh mục, sản phẩm, giá, tồn kho, ảnh và trạng thái hoạt động.
- `cart_items`: giỏ hàng bền vững theo tài khoản.
- `orders`, `order_items`: đơn hàng và các dòng sản phẩm cùng giá tại thời điểm mua.
- `reviews`: đánh giá, duy nhất theo cặp khách hàng/sản phẩm.
- `wishlist_items`: sản phẩm yêu thích, duy nhất theo cặp khách hàng/sản phẩm.

Chi tiết kiểu dữ liệu và khóa ngoại được định nghĩa trong `database/schema.sql`. Khi dùng database cũ, cần xác định migration còn thiếu và xử lý dữ liệu trùng trước migration tạo unique index số điện thoại.

## 6. Chạy dự án local

1. Cài Node.js và MySQL/MariaDB; tạo database `electro_shop`.
2. Import `database/schema.sql` vào database mới. Với database đã tồn tại, đối chiếu các file `database/migration-*.sql` trước khi chạy; không chạy lặp migration nếu chưa kiểm tra.
3. Tạo `.env` từ `.env.example`; điền thông tin DB, `PORT` nếu cần và `SESSION_SECRET` đủ mạnh. Không đưa `.env` lên Git.
4. Cài dependency và chạy:

   ```bash
   npm install
   npm run dev
   ```

5. Mở `http://localhost:3000`. Tài khoản seed nếu được dùng phải lấy từ cấu hình/database local và đổi mật khẩu trước khi triển khai.

## 7. Tiêu chí hoàn thành

- Các chức năng đã triển khai hoạt động đúng theo vai trò.
- Luồng đổi mật khẩu lưu hash mới vào `users.password_hash`; mật khẩu cũ bị từ chối khi đăng nhập mới.
- Tồn kho nhất quán sau đặt hàng/hủy đơn; lỗi giữa transaction không để lại dữ liệu nửa chừng.
- Khách không truy cập được chi tiết đơn của tài khoản khác.
- Employee không truy cập chức năng quản lý danh mục/nhân viên.
- Hướng dẫn cài đặt, schema/migration và báo cáo phản ánh đúng phiên bản được nghiệm thu.
