# ElectroShop - Hệ thống thương mại điện tử

## 1. Giới thiệu dự án

ElectroShop là một hệ thống thương mại điện tử mô phỏng thực tế, được xây dựng trên nền tảng Node.js và MySQL, phục vụ mục tiêu học tập và nghiên cứu trong lĩnh vực phát triển ứng dụng web. Dự án tập trung vào việc triển khai các chức năng cơ bản của một cửa hàng trực tuyến như đăng ký, đăng nhập, quản lý sản phẩm, giỏ hàng, đặt hàng, theo dõi đơn hàng và quản trị hệ thống.

Mục tiêu của dự án là xây dựng một ứng dụng web có cấu trúc rõ ràng, dễ mở rộng và phù hợp để trình bày trong báo cáo đồ án môn học, đồng thời đáp ứng các yêu cầu nghiệp vụ của một hệ thống bán hàng trực tuyến hiện đại.

---

## 2. Mục tiêu và phạm vi

### 2.1 Mục tiêu chính

- Xây dựng hệ thống bán hàng trực tuyến có giao diện thân thiện
- Hỗ trợ người dùng tìm kiếm, lựa chọn và đặt mua sản phẩm
- Cung cấp chức năng quản lý đơn hàng và người dùng cho admin
- Tạo nền tảng để mở rộng thêm các tính năng như thanh toán online, báo cáo thống kê, email và phân tích dữ liệu

### 2.2 Phạm vi chức năng

- Quản lý tài khoản người dùng
- Đăng ký, đăng nhập, phân quyền người dùng/admin
- Hiển thị sản phẩm theo danh mục
- Tìm kiếm và lọc sản phẩm
- Giỏ hàng và đặt hàng
- Theo dõi trạng thái đơn hàng
- Quản trị sản phẩm, danh mục và đơn hàng
- Đánh giá sản phẩm sau khi hoàn tất đơn hàng
- Wishlist cho người dùng

---

## 3. Công cụ và công nghệ sử dụng

### 3.1 Frontend

- HTML, CSS, JavaScript
- EJS (Embedded JavaScript Templates)
- Bootstrap / CSS tùy chỉnh

### 3.2 Backend

- Node.js
- Express.js
- MVC pattern

### 3.3 Database

- MySQL
- XAMPP / phpMyAdmin để quản lý database cục bộ

### 3.4 Bảo mật và xử lý nghiệp vụ

- bcrypt: mã hóa mật khẩu
- express-session: quản lý session người dùng
- helmet: bảo vệ ứng dụng khỏi các lỗ hổng cơ bản
- csrf: bảo mật form
- express-rate-limit: giới hạn tần suất request
- multer / xử lý hình ảnh nếu có dùng upload sản phẩm

### 3.5 Quản lý dự án và triển khai

- Git + GitHub: quản lý mã nguồn và lưu trữ dự án
- npm: quản lý package và chạy project
- Visual Studio Code: môi trường phát triển
- XAMPP + MySQL: cơ sở dữ liệu local cho phát triển
- Render / Railway: triển khai ứng dụng lên môi trường production

> Các công cụ thực sự đang được sử dụng trong dự án bao gồm: GitHub, VS Code, MySQL, XAMPP, npm và Railway/Render cho triển khai.

---

## 4. Các use case chính của hệ thống

Trạng thái dưới đây phản ánh chức năng hiện có trong mã nguồn; chưa đồng nghĩa với việc mọi luồng đã được kiểm thử trên môi trường triển khai.

- ✅ Đã triển khai
- ⚠️ Đã triển khai một phần (phạm vi còn thiếu được ghi rõ)
- ⬜ Chưa triển khai

### 4.1 Use case người dùng

- ✅ Đăng ký tài khoản mới
- ✅ Đăng nhập hệ thống
- ✅ Xem danh sách sản phẩm và chi tiết sản phẩm
- ✅ Tìm kiếm và lọc sản phẩm theo tiêu chí
- ✅ Thêm sản phẩm vào giỏ hàng
- ✅ Cập nhật số lượng và xóa sản phẩm trong giỏ hàng
- ⚠️ Checkout và tạo đơn hàng đã có; chưa tích hợp cổng thanh toán trực tuyến.
- ✅ Theo dõi trạng thái đơn hàng
- ✅ Thêm và xóa sản phẩm trong wishlist
- ✅ Viết hoặc cập nhật đánh giá sản phẩm sau khi đơn hàng hoàn tất

### 4.2 Use case quản trị viên

- ✅ Đăng nhập với quyền admin
- ✅ Quản lý danh mục sản phẩm
- ✅ Thêm, sửa, xóa sản phẩm (không cho xóa sản phẩm đã có trong đơn hàng)
- ✅ Quản lý tài khoản nhân viên và khách hàng (thêm, sửa, xóa; không xóa khách hàng đã có đơn hàng).
- ✅ Xem và xử lý đơn hàng
- ✅ Cập nhật trạng thái đơn hàng theo các bước trạng thái hợp lệ
- ⚠️ Dashboard có thống kê số sản phẩm, đơn hàng và tài khoản; chưa có nhật ký hoạt động/audit log.

---

## 5. Cấu trúc dự án

```text
ElectroShop/
├── app.js                  # File khởi động ứng dụng
├── package.json            # Thông tin project và dependency
├── .env.example            # Mẫu biến môi trường
├── config/                 # Cấu hình hệ thống, database, môi trường
├── controllers/            # Xử lý logic nghiệp vụ
├── models/                 # Các model truy vấn dữ liệu
├── routes/                 # Định tuyến request
├── views/                  # Giao diện EJS
├── public/                 # File tĩnh: CSS, JS, hình ảnh
├── middlewares/            # Middleware xác thực và phân quyền
├── database/               # Schema SQL và migration
├── README.md               # Tài liệu dự án
└── ...
```

---

## 6. Yêu cầu môi trường

- Node.js 18+
- MySQL hoặc MariaDB
- XAMPP / Laragon / MySQL Server
- npm
- Git

---

## 7. Hướng dẫn chạy dự án ở local

### Bước 1: Cài đặt dependency

```bash
npm install
```

### Bước 2: Tạo file môi trường

Tạo file `.env` từ `.env.example` ở thư mục gốc. `.env` chỉ dùng local và không đưa lên Git:

```powershell
Copy-Item .env.example .env
```

### Bước 3: Cấu hình database

File `.env` có dạng như sau:

```env
NODE_ENV=development
PORT=3000
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=
DB_NAME=electro_shop
UPLOAD_DIR=public/images/products
SESSION_SECRET=replace-with-a-random-secret-at-least-32-characters
```

Tạo `SESSION_SECRET` riêng bằng lệnh `node -e "console.log(require('crypto').randomBytes(48).toString('hex'))"`; không dùng chuỗi mẫu.

### Bước 4: Tạo database và khởi động MySQL

- Mở XAMPP hoặc MySQL Server và khởi động MySQL.
- Tạo database `electro_shop` với charset `utf8mb4` và collation `utf8mb4_unicode_ci`.
- File schema chỉ tạo bảng và dữ liệu mẫu trong database đang được chọn; nó không tạo hoặc chuyển sang database khác.
- Với database mới, chạy `npm run db:import` để nạp schema và dữ liệu mẫu. Chỉ chạy trên database rỗng; không chạy lại trên database đã có bảng/dữ liệu.

Nếu đang dùng database cũ, chạy thêm các migration cần thiết trong thư mục `database/`. Với thay đổi use case hiện tại, chạy `migration-account-cart.sql`, `migration-employee-position.sql` và `migration-unique-user-phone.sql`; migration số điện thoại yêu cầu xử lý các số trùng trước khi tạo unique index.

### Bước 5: Chạy ứng dụng

```bash
npm run dev
```

Chạy kiểm tra tự động:

```bash
npm test
```

### Bước 6: Truy cập ứng dụng

Mở trình duyệt và truy cập:

```text
http://localhost:3000
```

### Tạo tài khoản admin

Tạo tài khoản admin riêng sau khi import schema. Đặt các biến môi trường tạm thời rồi chạy:

```powershell
$env:ADMIN_NAME = "Quản trị viên"
$env:ADMIN_EMAIL = "admin@example.com"
$env:ADMIN_PASSWORD = "replace-with-a-unique-password"
npm run admin:create
Remove-Item Env:ADMIN_PASSWORD
```

Lệnh chỉ tạo tài khoản nếu email chưa tồn tại và không in mật khẩu/hash ra log.

---

## 8. Triển khai trên Render

1. Push source code lên GitHub
2. Tạo database MySQL trên Render hoặc sử dụng dịch vụ DB tương thích
3. Tạo Web Service trên Render và kết nối repo GitHub
4. Thêm biến môi trường theo mẫu:

```env
NODE_ENV=production
PORT=10000
DB_HOST=your_db_host
DB_PORT=3306
DB_USER=your_db_user
DB_PASSWORD=your_db_password
DB_NAME=electro_shop
SESSION_SECRET=your_strong_secret
```

5. Import `database/schema.sql` vào database online
6. Khởi động service và kiểm tra các chức năng chính

---

## 9. Triển khai trên Railway

1. Push code lên GitHub, tạo project Railway và deploy repository. `railway.json` dùng `npm start` và health check `/healthz`.
2. Thêm service MySQL trong cùng project. Trong service ứng dụng, thêm các biến từ `.env.railway.example` vào Railway Variables. Đổi `MySQL` trong tham chiếu `${{MySQL.MYSQLHOST}}`... cho đúng tên service nếu khác. Railway tự cấp `PORT`; đặt `SESSION_SECRET` riêng, tối thiểu 32 ký tự.
3. Nếu database Railway chưa có schema, nạp `database/schema.sql` một lần vào database đó. Có thể chạy `railway run npm run db:import` từ máy đã cài và link Railway CLI đúng project/environment/service. Hoặc chạy `npm run db:import` từ local với thông tin **public** MySQL Railway trong biến môi trường. Không dùng host nội bộ Railway khi chạy từ máy local. Chỉ import vào database rỗng; sao lưu trước khi thay đổi database hiện có.
4. Tạo tài khoản admin một lần bằng `npm run admin:create`, với `ADMIN_NAME`, `ADMIN_EMAIL`, `ADMIN_PASSWORD` tạm thời và kết nối tới đúng database. Với Railway CLI, dùng `railway run npm run admin:create`. Script không đổi tài khoản nếu email đó đã tồn tại; không lưu mật khẩu admin trong Git.
5. (Tuỳ chọn) Gắn Railway Volume vào service ứng dụng tại `/app/data` để ảnh upload không mất sau deploy/restart.
6. Ứng dụng lưu session trong MySQL; bảng `sessions` được tạo tự động khi app khởi động, vì vậy user database cần quyền tạo bảng. Đợi deployment healthy rồi kiểm tra đăng nhập, quyền admin và các chức năng chính; `/healthz` chỉ xác nhận server đã khởi động.

---

## 10. Kết luận

ElectroShop là một dự án phát triển web có tính thực tiễn cao, phù hợp để mô phỏng hoạt động của một cửa hàng điện tử trong môi trường học tập. Dự án không chỉ bao gồm các chức năng cơ bản của bán hàng trực tuyến mà còn thể hiện khả năng triển khai hệ thống theo hướng MVC, quản lý cơ sở dữ liệu, xử lý xác thực người dùng và bảo mật ứng dụng. Với cấu trúc rõ ràng và khả năng mở rộng tốt, dự án này đáp ứng yêu cầu của một bài tập lớn hoặc đồ án môn học về phát triển ứng dụng web.

---

## 11. Ghi chú

- Không commit file `.env` lên GitHub
- Nên dùng biến môi trường riêng cho môi trường production
- Trước khi demo, kiểm tra lại kết nối database và trạng thái đơn hàng
- Nếu database chưa được import schema, các chức năng chính sẽ không hoạt động đúng
