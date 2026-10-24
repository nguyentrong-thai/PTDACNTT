# ElectroShop - Hệ thống thương mại điện tử

## Tổng quan

ElectroShop là ứng dụng cửa hàng trực tuyến dùng **Node.js, Express, EJS và MySQL**.
Có đăng ký/đăng nhập, danh mục và sản phẩm, giỏ hàng, đơn hàng, đánh giá,
wishlist và trang quản trị. Thanh toán trực tuyến chưa được tích hợp.

**Yêu cầu:** Node.js 18 trở lên, npm và MySQL/MariaDB (local) hoặc TiDB Cloud (deploy).

## Cấu trúc chính

```text
app.js                 Khởi động Express
config/                Kết nối database và upload
controllers/           Xử lý đăng nhập
models/                 Truy vấn database
routes/                 Các endpoint
views/                  Giao diện EJS
public/                 CSS, JavaScript, ảnh
database/               Schema, import và migration cũ
tests/                  Kiểm thử
```

## Chạy local (MySQL/XAMPP)

### 1. Cài đặt và cấu hình
```bash
npm install
```

```powershell
Copy-Item .env.example .env
```

Mở `.env` và điền cài đặt MySQL local:

```env
NODE_ENV=development
PORT=3000
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=
DB_NAME=electro_shop
DB_SSL=false
UPLOAD_DIR=public/images/products
SESSION_SECRET=replace-with-a-random-secret-at-least-32-characters
```

Tạo secret riêng bằng lệnh:

```bash
node -e "console.log(require('crypto').randomBytes(48).toString('hex'))"
```

### 2. Tạo database và dữ liệu mẫu

Bật MySQL trong XAMPP rồi chạy **một lần trên database mới/rỗng**:

```bash
npm run db:import:local
```

Lệnh trên dùng `database/schema.local.sql`, tạo bảng và dữ liệu mẫu cùng admin local:

| Email | Mật khẩu |
|---|---|
| `admin@electroshop.vn` | `ElectroShop@2026!` |

Chỉ dùng tài khoản này local, không đưa lên dịch vụ. Không import lại vào database đã có bảng.

### 3. Chạy và kiểm thử
```bash
npm run dev
```

Mở http://localhost:3000. Chạy test bằng:

```bash
npm test
```

## Deploy Render + TiDB Cloud

1. Tạo database `electro_shop` trên TiDB Cloud.
2. Import **`database/schema.sql`** một lần vào database rỗng bằng giao diện quản lý DB hoặc `npm run db:import` khi các biến `DB_*` trỏ tới TiDB. Đây là schema dịch vụ; không có admin mẫu.
3. Tạo Render Web Service từ repository. Build command: `npm install`; Start command: `npm start`.
4. Thêm các biến sau trong Render **Environment**:
```env
NODE_ENV=production
DB_HOST=your_tidb_cloud_host
DB_PORT=4000
DB_USER=your_tidb_cloud_username
DB_PASSWORD=your_tidb_cloud_password
DB_NAME=electro_shop
DB_SSL=true
SESSION_SECRET=your_strong_secret
```

Render tự cấp `PORT`. TiDB Cloud cần port `4000` và `DB_SSL=true`. Không commit `.env` hay mật khẩu lên GitHub.

5. Tạo admin riêng cho production từ PowerShell, dùng đúng thông tin TiDB:

```powershell
$env:DB_HOST = "your_tidb_cloud_host"
$env:DB_PORT = "4000"
$env:DB_USER = "your_tidb_cloud_username"
$env:DB_PASSWORD = "your_tidb_cloud_password"
$env:DB_NAME = "electro_shop"
$env:DB_SSL = "true"
$env:ADMIN_NAME = "Quản trị viên"
$env:ADMIN_EMAIL = "your-admin@example.com"
$env:ADMIN_PASSWORD = "your-unique-password-at-least-8-characters"
npm run admin:create
Remove-Item Env:ADMIN_PASSWORD
```

Không dùng `database/schema.local.sql` trên dịch vụ. Database user cần quyền tạo bảng cho session store. Admin phải tạo riêng cho từng database production.

## Lệnh thường dùng

| Lệnh | Mục đích |
|---|---|
| `npm run dev` | Chạy local |
| `npm start` | Chạy production |
| `npm test` | Chạy test |
| `npm run db:import:local` | Nạp schema và admin demo local |
| `npm run db:import` | Nạp schema dịch vụ |
| `npm run admin:create` | Tạo admin cho database đang cấu hình |

`database/migration-*.sql` dùng để nâng cấp database cũ; không chạy các migration trên database mới đã import schema. Các file `.env` chứa bí mật không được đưa lên GitHub.
