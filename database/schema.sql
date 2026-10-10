-- =========================================================
-- CSDL: electro_shop
-- Website bán đồ điện tử - Bài tập lớn
-- =========================================================

CREATE DATABASE IF NOT EXISTS electro_shop
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE electro_shop;

-- ---------------------------------------------------------
-- Bảng người dùng (khách hàng + quản trị viên)
-- ---------------------------------------------------------
CREATE TABLE users (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  full_name     VARCHAR(100)  NOT NULL,
  email         VARCHAR(150)  NOT NULL UNIQUE,
  password_hash VARCHAR(255)  NOT NULL,
  phone         VARCHAR(20),
  address       VARCHAR(255),
  gender        ENUM('male', 'female', 'other') DEFAULT NULL,
  date_of_birth DATE DEFAULT NULL,
  role          ENUM('user', 'employee', 'admin') NOT NULL DEFAULT 'user',
  position      VARCHAR(100) DEFAULT NULL,
  created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_users_phone (phone)
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- Danh mục sản phẩm (VD: Điện thoại, Laptop, Phụ kiện...)
-- ---------------------------------------------------------
CREATE TABLE categories (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(100) NOT NULL,
  slug        VARCHAR(120) NOT NULL UNIQUE,
  description TEXT
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- Sản phẩm
-- ---------------------------------------------------------
CREATE TABLE products (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  category_id   INT NOT NULL,
  name          VARCHAR(200) NOT NULL,
  brand         VARCHAR(100),
  description   TEXT,
  price         DECIMAL(12,2) NOT NULL DEFAULT 0,
  stock_qty     INT NOT NULL DEFAULT 0,
  image_url     VARCHAR(255),
  is_active     TINYINT(1) NOT NULL DEFAULT 1,
  created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES categories(id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_name ON products(name);

-- ---------------------------------------------------------
-- Giỏ hàng: mỗi user có nhiều dòng cart_items
-- ---------------------------------------------------------
CREATE TABLE cart_items (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  user_id     INT NOT NULL,
  product_id  INT NOT NULL,
  quantity    INT NOT NULL DEFAULT 1,
  added_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  UNIQUE KEY uniq_user_product (user_id, product_id)
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- Đơn hàng
-- ---------------------------------------------------------
CREATE TABLE orders (
  id               INT AUTO_INCREMENT PRIMARY KEY,
  user_id          INT NOT NULL,
  recipient_name   VARCHAR(100) NOT NULL,
  total_amount     DECIMAL(12,2) NOT NULL DEFAULT 0,
  status           ENUM('pending','confirmed','shipping','completed','cancelled')
                     NOT NULL DEFAULT 'pending',
  shipping_address VARCHAR(255) NOT NULL,
  shipping_phone   VARCHAR(20) NOT NULL,
  note             VARCHAR(255),
  created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- Chi tiết đơn hàng (lưu lại giá tại thời điểm mua)
-- ---------------------------------------------------------
CREATE TABLE order_items (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  order_id    INT NOT NULL,
  product_id  INT NOT NULL,
  quantity    INT NOT NULL,
  unit_price  DECIMAL(12,2) NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- Đánh giá sản phẩm (tùy chọn - nâng cao)
-- ---------------------------------------------------------
CREATE TABLE reviews (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  product_id  INT NOT NULL,
  user_id     INT NOT NULL,
  rating      TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment     TEXT,
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_review_user_product (user_id, product_id),
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- Danh sách sản phẩm yêu thích
-- ---------------------------------------------------------
CREATE TABLE wishlist_items (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  user_id     INT NOT NULL,
  product_id  INT NOT NULL,
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_wishlist_user_product (user_id, product_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =========================================================
-- DỮ LIỆU MẪU (seed data)
-- =========================================================

-- Tài khoản admin local (email: admin@electroshop.vn, mật khẩu: ElectroShop@2026!)
INSERT INTO users (full_name, email, password_hash, role) VALUES
('Quản trị viên', 'admin@electroshop.vn', '$2b$12$pAl34yjb0bQBvs98daQhH.z5tB8OhpVdK5AmY45Vs13wYIuqku3LS', 'admin');

INSERT INTO categories (name, slug, description) VALUES
('Điện thoại', 'dien-thoai', 'Smartphone các hãng'),
('Laptop', 'laptop', 'Laptop văn phòng, gaming, đồ họa'),
('Phụ kiện', 'phu-kien', 'Tai nghe, sạc, ốp lưng, chuột, bàn phím'),
('Đồng hồ thông minh', 'dong-ho-thong-minh', 'Smartwatch các loại');

INSERT INTO products (category_id, name, brand, description, price, stock_qty, image_url) VALUES
(1, 'iPhone 18 Pro Max 256GB', 'Apple', 'Super Retina XDR 6.9 inch, chip Apple A20 Pro, camera 48MP.', 41990000, 24, 'https://cdn.tgdd.vn/Products/Images/42/370982/iphone-18-pro-max-den-thumb-600x600.jpg'),
(1, 'iPhone 18 Pro 256GB', 'Apple', 'Super Retina XDR 6.3 inch, chip Apple A20 Pro, pin 34 giờ.', 38990000, 18, 'https://cdn.tgdd.vn/Products/Images/42/370977/iphone-18-pro-do-thumb-600x600.jpg'),
(1, 'iPhone Duo 256GB', 'Apple', 'Điện thoại gập hai màn hình, chip Apple A20 Pro.', 64990000, 7, 'https://cdn.tgdd.vn/Products/Images/42/370987/iphone-duo-white-thumb-600x600.jpg'),
(1, 'iPhone 17 Pro Max 256GB', 'Apple', 'Super Retina XDR 6.9 inch, chip Apple A19 Pro, camera 48MP.', 34590000, 31, 'https://cdn.tgdd.vn/Products/Images/42/342679/iphone-17-pro-max-cam-thumb-600x600.jpg'),
(1, 'iPhone 17 256GB', 'Apple', 'Super Retina XDR 6.3 inch, chip Apple A19, pin 30 giờ.', 28990000, 42, 'https://cdn.tgdd.vn/Products/Images/42/342667/iphone-17-xanh-thumb-600x600.jpg'),
(2, 'Acer Predator Helios 18 AI PH18 Ultra 9 275HX', 'Acer', 'Màn hình 18 inch 4K 120Hz, RTX 5090 24GB, RAM 192GB, SSD 6TB.', 149990000, 3, 'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/44/335963/acer-predator-helios-18-ai-ph18-73-98aq-ultra-9-nhqvwsv001-thumb-638828182518741548-600x600.jpg'),
(2, 'MSI Gaming Raider 16 MAX HX B2WI', 'MSI', 'Màn hình OLED QHD+ 240Hz, RTX 5080 16GB, RAM 64GB, SSD 2TB.', 129590000, 5, 'https://cdn.tgdd.vn/2026/09/timerseo/367865-600x600-2.png'),
(2, 'Asus ROG Zephyrus G14 GU405AW', 'Asus', 'Màn hình OLED 14 inch 3K 120Hz, RTX 5080 16GB, RAM 32GB.', 118590000, 9, 'https://cdn.tgdd.vn/2026/09/timerseo/367889-600x600-2.png'),
(2, 'Asus ROG Flow Z13 GZ302EAC', 'Asus', 'Màn hình WQXGA 13.4 inch 180Hz, AMD Radeon 8060S, RAM 128GB.', 109990000, 4, 'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/44/364389/asus-gaming-rog-flow-z13-gz302eac-ai-max-395-ru184ws-thumb-639094294582783186-600x600.jpg'),
(2, 'Acer Predator Helios 18 AI PH18 93P0', 'Acer', 'Màn hình 18 inch 2.5K 250Hz, RTX 5080 16GB, RAM 64GB.', 99990000, 6, 'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/44/335964/acer-predator-helios-18-ai-ph18-73-93p0-ultra-9-275hx-nhqvysv001-thumb-638828182821796512-600x600.jpg'),
(3, 'Tai nghe Sennheiser IE900', 'Sennheiser', 'Tai nghe có dây cao cấp, âm thanh chi tiết.', 32000000, 11, 'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/54/367952/tai-nghe-co-day-ep-sennheiser-ie900-thumb-639164728894103414-600x600.jpg'),
(3, 'Tai nghe Sennheiser IE600', 'Sennheiser', 'Tai nghe có dây nhỏ gọn, âm thanh cân bằng.', 17000000, 16, 'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/54/367951/tai-nghe-co-day-ep-sennheiser-ie600-thumb-639164725933282173-600x600.jpg'),
(3, 'Sony WH-1000XX', 'Sony', 'Tai nghe chụp tai Bluetooth, chống ồn chủ động.', 16990000, 28, 'https://cdn.tgdd.vn/2026/08/timerseo/367818.jpg'),
(3, 'Bowers & Wilkins Px8', 'Bowers & Wilkins', 'Tai nghe chụp tai Bluetooth cao cấp.', 15695000, 13, 'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/54/337694/tai-nghe-bluetooth-chup-tai-bowers-wilkins-px8-080525-014027-869-600x600.jpg'),
(3, 'AirPods Max 2', 'Apple', 'Tai nghe chụp tai cao cấp, âm thanh sống động.', 14490000, 37, 'https://cdn.tgdd.vn/Products/Images/54/364790/airpods-max-2-vang-thumb-600x600.jpg'),
(4, 'Apple Watch Series 9', 'Apple', 'Đồng hồ thông minh cao cấp, theo dõi sức khỏe.', 9990000, 12, '/images/no-image.svg'),
(4, 'Garmin Forerunner 165 43mm', 'Garmin', 'Đồng hồ chạy bộ GPS, dây silicone, theo dõi sức khỏe.', 3990000, 26, 'https://cdn.tgdd.vn/Products/Images/7077/322848/garmin-forerunner-165-den-tb-600x600.jpg'),
(4, 'imoo Z1 41mm', 'imoo', 'Đồng hồ định vị trẻ em, dây TPU, hỗ trợ gọi và theo dõi vị trí.', 2490000, 34, 'https://cdn.tgdd.vn/Products/Images/7077/316992/dong-ho-dinh-vi-tre-em-imoo-z1-41-mm-xanh-duong-600x600.jpg'),
(4, 'Garmin Forerunner 55 42mm', 'Garmin', 'Đồng hồ chạy bộ GPS, dây silicone, thiết kế nhẹ.', 2590000, 41, 'https://cdn.tgdd.vn/Products/Images/7077/244296/garmin-forerunner-55-day-silicone-den-tn-1-2-600x600.jpg'),
(4, 'Garmin Lily 2 Classic 34mm', 'Garmin', 'Đồng hồ thông minh nhỏ gọn, dây da, theo dõi sức khỏe.', 7840000, 19, 'https://cdn.tgdd.vn/Products/Images/7077/322846/garmin-lily-2-classic-day-da-den-tim-tb-600x600.jpg'),
(4, 'Garmin Forerunner 265 Music 46.1mm', 'Garmin', 'Đồng hồ thể thao GPS, hỗ trợ nghe nhạc, dây silicone.', 9180000, 8, 'https://cdn.tgdd.vn/Products/Images/7077/305882/garmin-forerunner-265-den-tn-2-600x600.jpg');
