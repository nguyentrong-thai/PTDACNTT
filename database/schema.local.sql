-- LOCAL ONLY: includes a demo administrator account near the seed data.
-- Do not import this file into a public or production database.
-- Create and select the application database before creating its tables.
CREATE DATABASE IF NOT EXISTS electro_shop
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
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

-- Local demo account only. Do not use this account in production.
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
(4, 'Garmin Forerunner 265 Music 46.1mm', 'Garmin', 'Đồng hồ thể thao GPS, hỗ trợ nghe nhạc, dây silicone.', 9180000, 8, 'https://cdn.tgdd.vn/Products/Images/7077/305882/garmin-forerunner-265-den-tn-2-600x600.jpg'),
(1, 'Samsung Galaxy S25 Ultra 256GB', 'Samsung', 'Điện thoại Android cao cấp, màn hình AMOLED lớn, camera đa tiêu cự và bút S Pen.', 33990000, 12, 'https://cdn.tgdd.vn/Products/Images/42/333347/samsung-galaxy-s25-ultra-blue-thumbai.jpg'),
(1, 'Samsung Galaxy S25+ 256GB', 'Samsung', 'Điện thoại màn hình AMOLED, kết nối 5G, camera đa dụng và sạc nhanh.', 26990000, 16, 'https://cdn.tgdd.vn/Products/Images/42/333359/samsung-galaxy-s25-plus-navy-thumbai.jpg'),
(1, 'Samsung Galaxy S25 256GB', 'Samsung', 'Điện thoại nhỏ gọn, màn hình AMOLED, camera độ phân giải cao.', 22990000, 20, 'https://cdn.tgdd.vn/Products/Images/42/333363/samsung-galaxy-s25-blue-thumbai.jpg'),
(1, 'Samsung Galaxy S24 FE 256GB', 'Samsung', 'Điện thoại 5G màn hình AMOLED, camera góc rộng và pin dung lượng lớn.', 15990000, 18, 'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/322789/samsung-galaxy-s24-fe-blue-1-638629861111934098.jpg'),
(1, 'Samsung Galaxy A56 5G 256GB', 'Samsung', 'Điện thoại 5G màn hình Super AMOLED, camera chống rung quang học.', 11990000, 25, 'https://cdn.tgdd.vn/Products/Images/42/335177/samsung-galaxy-a56-5g-green-thumb.jpg'),
(1, 'Samsung Galaxy A36 5G 128GB', 'Samsung', 'Điện thoại 5G màn hình Super AMOLED, pin dùng cả ngày.', 7990000, 32, 'https://cdn.tgdd.vn/Products/Images/42/335174/samsung-galaxy-a36-5g-purple-thumb-1.jpg'),
(1, 'Samsung Galaxy A26 5G 128GB', 'Samsung', 'Điện thoại 5G màn hình AMOLED, camera chính độ phân giải cao.', 6490000, 29, 'https://cdn.tgdd.vn/Products/Images/42/334777/samsung-galaxy-a26-5g-green-thumbn.jpg'),
(1, 'Samsung Galaxy A16 128GB', 'Samsung', 'Điện thoại phổ thông màn hình lớn, pin dung lượng cao.', 4290000, 40, 'https://cdn.tgdd.vn/Products/Images/42/331207/samsung-galaxy-a16-xanh-la-thumb.jpg'),
(1, 'Samsung Galaxy Z Fold6 256GB', 'Samsung', 'Điện thoại gập màn hình lớn, đa nhiệm linh hoạt và hỗ trợ 5G.', 40990000, 5, 'https://cdn.tgdd.vn/Products/Images/42/320721/samsung-galaxy-z-fold6-xam-1-1.jpg'),
(1, 'Samsung Galaxy Z Flip6 256GB', 'Samsung', 'Điện thoại gập nhỏ gọn, màn hình phụ tiện dụng và camera kép.', 25990000, 7, 'https://cdn.tgdd.vn/Products/Images/42/320722/samsung-galaxy-z-flip6-blue-1jpg.jpg'),
(1, 'Xiaomi 15 Ultra 512GB', 'Xiaomi', 'Điện thoại flagship 5G, màn hình AMOLED và hệ thống camera Leica.', 32990000, 8, 'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/334169/xiaomi-15-ultra-bac-1-638773979973547578.jpg'),
(1, 'Xiaomi 15 256GB', 'Xiaomi', 'Điện thoại 5G hiệu năng cao, màn hình AMOLED và camera đa dụng.', 22990000, 14, 'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/320337/xiaomi-15-xanh-1-638774562882706299.jpg'),
(1, 'Xiaomi Redmi Note 14 Pro+ 5G 256GB', 'Xiaomi', 'Điện thoại 5G màn hình AMOLED, camera độ phân giải cao và sạc nhanh.', 10990000, 22, '/images/no-image.svg'),
(1, 'Xiaomi Redmi Note 14 Pro 256GB', 'Xiaomi', 'Điện thoại màn hình AMOLED, camera chống rung và pin dung lượng lớn.', 8990000, 24, '/images/no-image.svg'),
(1, 'Xiaomi Redmi 14C 128GB', 'Xiaomi', 'Điện thoại phổ thông màn hình lớn, pin bền và bộ nhớ mở rộng.', 3290000, 38, '/images/no-image.svg'),
(1, 'POCO X7 Pro 5G 256GB', 'POCO', 'Điện thoại 5G hướng đến hiệu năng, màn hình AMOLED và sạc nhanh.', 9990000, 17, '/images/no-image.svg'),
(1, 'POCO X7 5G 256GB', 'POCO', 'Điện thoại 5G màn hình AMOLED, camera chống rung quang học.', 7490000, 21, '/images/no-image.svg'),
(1, 'OPPO Find X8 Pro 512GB', 'OPPO', 'Điện thoại flagship 5G, màn hình AMOLED và camera Hasselblad.', 29990000, 6, 'https://cdn.tgdd.vn/Products/Images/42/322129/oppo-find-x8-pro-black-thumb.jpg'),
(1, 'OPPO Reno13 Pro 5G 512GB', 'OPPO', 'Điện thoại 5G thiết kế mỏng, camera chân dung và màn hình AMOLED.', 18990000, 13, 'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/332937/oppo-reno13-pro-5g-tim-1-638711719416037010.jpg'),
(1, 'OPPO Reno13 F 5G 256GB', 'OPPO', 'Điện thoại 5G màn hình AMOLED, camera đa dụng và pin lớn.', 9990000, 20, 'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/332936/oppo-reno13-f-5g-blue-1-638708201380084918.jpg'),
(1, 'OPPO A5 Pro 5G 256GB', 'OPPO', 'Điện thoại 5G bền bỉ, màn hình lớn và pin dung lượng cao.', 7990000, 26, 'https://cdn.tgdd.vn/Products/Images/42/334404/oppo-a5-pro-hong-thumb-1.jpg'),
(1, 'Vivo X200 Pro 512GB', 'vivo', 'Điện thoại flagship 5G, camera ZEISS và màn hình AMOLED.', 29990000, 5, '/images/no-image.svg'),
(1, 'Vivo V50 5G 256GB', 'vivo', 'Điện thoại 5G camera chân dung ZEISS, thiết kế mỏng nhẹ.', 13990000, 15, '/images/no-image.svg'),
(1, 'Vivo Y100 5G 128GB', 'vivo', 'Điện thoại 5G màn hình AMOLED, sạc nhanh và pin dung lượng lớn.', 6990000, 23, '/images/no-image.svg'),
(1, 'Google Pixel 9 Pro XL 256GB', 'Google', 'Điện thoại Android 5G, camera computational photography và màn hình OLED.', 26990000, 4, '/images/no-image.svg'),
(2, 'MacBook Air 13 inch M4 16GB 256GB', 'Apple', 'Laptop mỏng nhẹ với chip Apple M4, màn hình Liquid Retina và pin lâu.', 27990000, 10, 'https://cdn.tgdd.vn/Products/Images/44/335362/macbook-air-13-inch-m4-xanh-da-troi.jpg'),
(2, 'MacBook Air 15 inch M4 16GB 256GB', 'Apple', 'Laptop màn hình Liquid Retina 15 inch, chip Apple M4 và thiết kế mỏng nhẹ.', 32990000, 8, 'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/44/335372/macbook-air-15-inch-m4-tgdd-1-638772007305457970.jpg'),
(2, 'MacBook Pro 14 inch M4 16GB 512GB', 'Apple', 'Laptop chuyên nghiệp với chip Apple M4, màn hình Liquid Retina XDR.', 39990000, 7, 'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/44/331564/macbook-pro-14-inch-m4-16gb-512gb-bac-1-638660150192841121.jpg'),
(2, 'MacBook Pro 16 inch M4 Pro 24GB 512GB', 'Apple', 'Laptop hiệu năng cao, chip Apple M4 Pro và màn hình Liquid Retina XDR.', 59990000, 4, 'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/44/331574/macbook-pro-16-inch-m4-tgdd-bac-1-638660173449336788.jpg'),
(2, 'ASUS Zenbook 14 OLED UX3405', 'ASUS', 'Laptop OLED 14 inch, thiết kế mỏng nhẹ, phù hợp làm việc di động.', 27990000, 9, '/images/no-image.svg'),
(2, 'ASUS Vivobook 15 X1504', 'ASUS', 'Laptop 15.6 inch phục vụ học tập và văn phòng, có webcam và bàn phím số.', 13990000, 18, '/images/no-image.svg'),
(2, 'ASUS TUF Gaming A15 FA507', 'ASUS', 'Laptop gaming 15.6 inch, đồ họa rời và hệ thống tản nhiệt chuyên dụng.', 26990000, 8, '/images/no-image.svg'),
(2, 'ASUS ROG Strix G16 G614', 'ASUS', 'Laptop gaming 16 inch tần số quét cao, đồ họa rời và bàn phím RGB.', 42990000, 5, '/images/no-image.svg'),
(2, 'Dell XPS 13 9340', 'Dell', 'Laptop cao cấp 13.4 inch, thiết kế nhôm gọn nhẹ và màn hình sắc nét.', 36990000, 6, '/images/no-image.svg'),
(2, 'Dell Inspiron 14 5440', 'Dell', 'Laptop 14 inch dùng cho học tập, văn phòng và làm việc hàng ngày.', 18990000, 14, '/images/no-image.svg'),
(2, 'Lenovo ThinkPad E14 Gen 6', 'Lenovo', 'Laptop doanh nghiệp 14 inch, bàn phím ThinkPad và nhiều cổng kết nối.', 22990000, 11, '/images/no-image.svg'),
(2, 'Lenovo IdeaPad Slim 5 14IMH9', 'Lenovo', 'Laptop 14 inch mỏng nhẹ, màn hình OLED tùy cấu hình và pin dung lượng lớn.', 19990000, 13, '/images/no-image.svg'),
(2, 'Lenovo LOQ 15IRX9', 'Lenovo', 'Laptop gaming 15.6 inch, card đồ họa rời và màn hình tần số quét cao.', 24990000, 10, '/images/no-image.svg'),
(2, 'HP Pavilion Plus 14', 'HP', 'Laptop 14 inch thiết kế gọn, màn hình độ phân giải cao và webcam tích hợp.', 21990000, 9, '/images/no-image.svg'),
(2, 'HP Envy x360 14', 'HP', 'Laptop cảm ứng xoay gập 360 độ, hỗ trợ thao tác linh hoạt khi làm việc.', 27990000, 6, '/images/no-image.svg'),
(2, 'HP Victus 16', 'HP', 'Laptop gaming 16 inch, card đồ họa rời và hệ thống tản nhiệt kép.', 27990000, 8, '/images/no-image.svg'),
(2, 'Acer Swift Go 14 OLED', 'Acer', 'Laptop OLED 14 inch mỏng nhẹ, webcam độ phân giải cao và sạc USB-C.', 22990000, 12, '/images/no-image.svg'),
(2, 'Acer Aspire 5 A515', 'Acer', 'Laptop 15.6 inch đa dụng, phù hợp học tập, văn phòng và giải trí.', 15990000, 17, '/images/no-image.svg'),
(2, 'Acer Nitro V 15 ANV15', 'Acer', 'Laptop gaming 15.6 inch, đồ họa rời và bàn phím có đèn nền.', 21990000, 11, '/images/no-image.svg'),
(2, 'MSI Modern 14 C13M', 'MSI', 'Laptop 14 inch mỏng nhẹ cho công việc văn phòng và học tập.', 14990000, 16, '/images/no-image.svg'),
(2, 'MSI Cyborg 15 A13V', 'MSI', 'Laptop gaming 15.6 inch thiết kế hiện đại, card đồ họa rời.', 23990000, 9, '/images/no-image.svg'),
(2, 'LG Gram 14 14Z90S', 'LG', 'Laptop 14 inch nhẹ, thân máy gọn và pin phù hợp cho di chuyển.', 32990000, 5, '/images/no-image.svg'),
(2, 'Microsoft Surface Laptop 7 13.8 inch', 'Microsoft', 'Laptop màn hình cảm ứng PixelSense, thiết kế nhôm và camera Windows Hello.', 32990000, 4, '/images/no-image.svg'),
(2, 'Huawei MateBook D 16 2024', 'Huawei', 'Laptop 16 inch phục vụ công việc, màn hình lớn và cảm biến vân tay.', 18990000, 10, '/images/no-image.svg'),
(2, 'Gigabyte G6X 9KG', 'Gigabyte', 'Laptop gaming 16 inch, card đồ họa rời và màn hình tần số quét cao.', 26990000, 6, '/images/no-image.svg'),
(3, 'Apple AirPods 4', 'Apple', 'Tai nghe true wireless, âm thanh không gian và hộp sạc USB-C.', 3490000, 25, '/images/no-image.svg'),
(3, 'Apple AirPods 4 chống ồn chủ động', 'Apple', 'Tai nghe true wireless có chống ồn chủ động và hộp sạc USB-C.', 4990000, 18, '/images/no-image.svg'),
(3, 'Samsung Galaxy Buds3 Pro', 'Samsung', 'Tai nghe true wireless chống ồn, âm thanh Hi-Fi và kháng nước.', 5990000, 14, '/images/no-image.svg'),
(3, 'Sony WF-1000XM5', 'Sony', 'Tai nghe true wireless chống ồn chủ động, hỗ trợ âm thanh độ phân giải cao.', 6990000, 12, '/images/no-image.svg'),
(3, 'JBL Tune 770NC', 'JBL', 'Tai nghe chụp tai Bluetooth có chống ồn chủ động và pin thời lượng dài.', 2490000, 20, '/images/no-image.svg'),
(3, 'JBL Flip 6', 'JBL', 'Loa Bluetooth di động chống nước, âm thanh stereo và dây đeo tiện dụng.', 2990000, 17, '/images/no-image.svg'),
(3, 'Anker Soundcore Motion 300', 'Anker', 'Loa Bluetooth di động, thiết kế nhỏ gọn và hỗ trợ phát nhạc không dây.', 2290000, 15, '/images/no-image.svg'),
(3, 'Anker 737 Power Bank 24000mAh', 'Anker', 'Pin sạc dự phòng dung lượng 24000mAh, màn hình hiển thị và sạc công suất cao.', 3990000, 13, '/images/no-image.svg'),
(3, 'Anker Nano Power Bank 10000mAh', 'Anker', 'Pin sạc dự phòng 10000mAh nhỏ gọn, hỗ trợ sạc nhanh qua USB-C.', 1290000, 28, '/images/no-image.svg'),
(3, 'Ugreen Nexode Charger 100W', 'Ugreen', 'Củ sạc GaN nhiều cổng USB-C và USB-A, hỗ trợ sạc nhanh thiết bị.', 1590000, 22, '/images/no-image.svg'),
(3, 'Apple 20W USB-C Power Adapter', 'Apple', 'Củ sạc USB-C 20W nhỏ gọn, tương thích nhiều thiết bị Apple.', 590000, 35, '/images/no-image.svg'),
(3, 'Logitech MX Master 3S', 'Logitech', 'Chuột không dây công thái học, cảm biến chính xác và cuộn MagSpeed.', 2490000, 11, '/images/no-image.svg'),
(3, 'Logitech MX Anywhere 3S', 'Logitech', 'Chuột không dây nhỏ gọn cho công việc di động, cuộn nhanh và chính xác.', 1990000, 12, '/images/no-image.svg'),
(3, 'Logitech K380s Pebble Keys 2', 'Logitech', 'Bàn phím Bluetooth nhỏ gọn, kết nối nhiều thiết bị và pin lâu.', 890000, 24, '/images/no-image.svg'),
(3, 'Keychron K8 Pro', 'Keychron', 'Bàn phím cơ không dây layout TKL, hỗ trợ kết nối Bluetooth và USB-C.', 2390000, 8, '/images/no-image.svg'),
(3, 'Razer DeathAdder V3', 'Razer', 'Chuột gaming có dây, cảm biến quang học độ chính xác cao.', 1690000, 10, '/images/no-image.svg'),
(3, 'Samsung T7 Shield 1TB', 'Samsung', 'Ổ SSD di động 1TB, giao tiếp USB-C và vỏ chống va đập.', 2990000, 9, '/images/no-image.svg'),
(3, 'SanDisk Extreme Portable SSD 1TB', 'SanDisk', 'Ổ SSD di động 1TB nhỏ gọn, giao tiếp USB-C và vỏ chống nước bụi.', 3190000, 7, '/images/no-image.svg'),
(3, 'TP-Link Archer AX55', 'TP-Link', 'Router Wi-Fi 6 băng tần kép, hỗ trợ kết nối nhiều thiết bị trong nhà.', 1990000, 13, '/images/no-image.svg'),
(3, 'TP-Link Deco X50 2-pack', 'TP-Link', 'Bộ mesh Wi-Fi 6 hai thiết bị, mở rộng vùng phủ sóng cho gia đình.', 3290000, 6, '/images/no-image.svg'),
(3, 'LG UltraGear 27GP850-B', 'LG', 'Màn hình gaming 27 inch QHD, tấm nền IPS và tần số quét cao.', 8990000, 5, '/images/no-image.svg'),
(3, 'Dell UltraSharp U2723QE', 'Dell', 'Màn hình 27 inch 4K IPS Black, hub USB-C phục vụ công việc sáng tạo.', 14990000, 4, '/images/no-image.svg'),
(3, 'Logitech C920s HD Pro Webcam', 'Logitech', 'Webcam Full HD 1080p có nắp che riêng tư, phù hợp họp trực tuyến.', 1690000, 14, '/images/no-image.svg'),
(3, 'Elgato Stream Deck MK.2', 'Elgato', 'Bàn phím điều khiển 15 phím LCD tùy chỉnh cho livestream và công việc.', 3990000, 3, '/images/no-image.svg'),
(3, 'Baseus Bowie MA10', 'Baseus', 'Tai nghe true wireless Bluetooth, hộp sạc dung lượng lớn và chống ồn.', 990000, 30, '/images/no-image.svg'),
(3, 'Sony SRS-XB100', 'Sony', 'Loa Bluetooth siêu gọn, chống nước và hỗ trợ kết nối không dây.', 1290000, 16, '/images/no-image.svg'),
(4, 'Apple Watch Series 10 GPS 42mm', 'Apple', 'Đồng hồ thông minh theo dõi hoạt động, nhịp tim và thông báo trên iPhone.', 10990000, 9, '/images/no-image.svg'),
(4, 'Apple Watch Ultra 2 GPS + Cellular', 'Apple', 'Đồng hồ thể thao bền bỉ, GPS hai tần số và kết nối di động.', 21990000, 4, '/images/no-image.svg'),
(4, 'Samsung Galaxy Watch7 40mm', 'Samsung', 'Đồng hồ thông minh theo dõi sức khỏe, GPS và kết nối điện thoại Android.', 6990000, 13, 'https://cdn.tgdd.vn/Products/Images/7077/327692/samsung-galaxy-watch7-40mm-kem-tn2.jpg'),
(4, 'Samsung Galaxy Watch7 44mm', 'Samsung', 'Đồng hồ thông minh màn hình lớn, theo dõi hoạt động và giấc ngủ.', 7490000, 11, 'https://cdn.tgdd.vn/Products/Images/7077/327692/samsung-galaxy-watch7-40mm-kem-tn2.jpg'),
(4, 'Samsung Galaxy Watch Ultra', 'Samsung', 'Đồng hồ thể thao GPS, thiết kế bền bỉ và hỗ trợ theo dõi luyện tập.', 16990000, 3, 'https://cdn.tgdd.vn/Products/Images/7077/327693/galaxy-watch-ultra-trang-tn.jpg'),
(4, 'Google Pixel Watch 3 41mm', 'Google', 'Đồng hồ thông minh Wear OS, theo dõi vận động và tích hợp Google services.', 8990000, 5, '/images/no-image.svg'),
(4, 'Garmin Venu 3 45mm', 'Garmin', 'Đồng hồ GPS đa môn thể thao, theo dõi sức khỏe và hỗ trợ nghe gọi.', 10990000, 7, '/images/no-image.svg'),
(4, 'Garmin Forerunner 965', 'Garmin', 'Đồng hồ chạy bộ GPS, bản đồ màu và các chỉ số luyện tập chuyên sâu.', 14990000, 5, '/images/no-image.svg'),
(4, 'Garmin Fenix 7 Pro Solar', 'Garmin', 'Đồng hồ outdoor GPS nhiều môn thể thao, sạc năng lượng mặt trời.', 18990000, 3, '/images/no-image.svg'),
(4, 'Garmin Instinct 2X Solar', 'Garmin', 'Đồng hồ GPS bền bỉ cho hoạt động ngoài trời, hỗ trợ sạc năng lượng mặt trời.', 9990000, 6, 'https://cdn.tgdd.vn/Products/Images/7077/324332/garmin-instinct-2x-solar-reu-tn.jpg'),
(4, 'Huawei Watch GT 5 46mm', 'Huawei', 'Đồng hồ thông minh màn hình AMOLED, GPS và theo dõi sức khỏe.', 5990000, 12, '/images/no-image.svg'),
(4, 'Huawei Watch GT 5 Pro 46mm', 'Huawei', 'Đồng hồ thông minh cao cấp, vật liệu bền và chế độ luyện tập đa dạng.', 8990000, 6, '/images/no-image.svg'),
(4, 'Huawei Watch Fit 3', 'Huawei', 'Đồng hồ thông minh màn hình AMOLED vuông, theo dõi vận động hàng ngày.', 2990000, 18, 'https://cdn.tgdd.vn/Products/Images/7077/325375/huawei-watch-fit-3-white-tn.jpg'),
(4, 'Xiaomi Watch 2 Pro', 'Xiaomi', 'Đồng hồ Wear OS, hỗ trợ GPS, theo dõi hoạt động và kết nối điện thoại.', 4990000, 8, 'https://cdn.tgdd.vn/Products/Images/7077/316986/xiaomi-watch-2-pro-tn-600x600.jpg'),
(4, 'Xiaomi Smart Band 9 Pro', 'Xiaomi', 'Vòng đeo tay thông minh màn hình AMOLED, GPS và theo dõi sức khỏe.', 1990000, 22, '/images/no-image.svg'),
(4, 'Amazfit Balance', 'Amazfit', 'Đồng hồ thông minh GPS, theo dõi hoạt động và các chỉ số sức khỏe.', 5490000, 7, 'https://cdn.tgdd.vn/Products/Images/7077/322265/amazfit-balance-day-silicone-tn2-600x600.jpg'),
(4, 'Amazfit Active 2', 'Amazfit', 'Đồng hồ thông minh AMOLED, GPS và nhiều chế độ luyện tập.', 2790000, 14, 'https://cdn.tgdd.vn/Products/Images/7077/335088/amazfit-active-2-tb-600x600.jpg'),
(4, 'Amazfit T-Rex 3', 'Amazfit', 'Đồng hồ outdoor bền bỉ, GPS đa băng tần và hỗ trợ hoạt động ngoài trời.', 5990000, 5, 'https://cdn.tgdd.vn/Products/Images/7077/329945/amazfit-t-rex-3-den-tn-1.jpg'),
(4, 'Fitbit Versa 4', 'Fitbit', 'Đồng hồ thông minh theo dõi vận động, giấc ngủ và nhịp tim.', 4990000, 6, '/images/no-image.svg'),
(4, 'Fitbit Charge 6', 'Fitbit', 'Vòng đeo tay theo dõi sức khỏe, GPS và hoạt động thể chất hàng ngày.', 3990000, 10, '/images/no-image.svg'),
(4, 'Huawei Watch D2', 'Huawei', 'Đồng hồ thông minh theo dõi sức khỏe với tính năng đo huyết áp cổ tay.', 8990000, 4, '/images/no-image.svg'),
(4, 'OnePlus Watch 2', 'OnePlus', 'Đồng hồ Wear OS, GPS hai băng tần và thời lượng pin dài.', 6990000, 5, '/images/no-image.svg'),
(4, 'CMF Watch Pro 2', 'CMF', 'Đồng hồ thông minh màn hình AMOLED, GPS và cuộc gọi Bluetooth.', 1990000, 15, '/images/no-image.svg'),
(4, 'Xiaomi Redmi Watch 5 Lite', 'Xiaomi', 'Đồng hồ thông minh màn hình lớn, GPS và theo dõi hoạt động cơ bản.', 1490000, 20, '/images/no-image.svg'),
(4, 'Garmin Vivosmart 5', 'Garmin', 'Vòng đeo tay theo dõi sức khỏe, giấc ngủ và hoạt động hàng ngày.', 3490000, 8, '/images/no-image.svg'),
(4, 'Amazfit GTR Mini', 'Amazfit', 'Đồng hồ thông minh GPS nhỏ gọn, màn hình AMOLED và pin lâu.', 2490000, 11, 'https://cdn.tgdd.vn/Products/Images/7077/304893/amafit-gtr-mini-xanh-1.jpg');

-- Remove local-only seed products without a usable image.
DELETE FROM products
WHERE image_url IS NULL
   OR TRIM(image_url) = ''
   OR image_url = '/images/no-image.svg'
   OR image_url LIKE 'https://upload.wikimedia.org/%'
   OR name = 'Acer Predator Helios 18 AI PH18 93P0';

INSERT INTO products (category_id, name, brand, description, price, stock_qty, image_url) VALUES
(1, 'Xiaomi Redmi Note 17', 'Xiaomi', 'Điện thoại thông minh phục vụ nhu cầu liên lạc, giải trí và công việc.', 5490000, 5, 'https://cdn2.fptshop.com.vn/unsafe/xiaomi_redmi_note_17_tim_1_857b62ab92.png'),
(1, 'OPPO Reno16 F', 'OPPO', 'Điện thoại thông minh phục vụ nhu cầu liên lạc, giải trí và công việc.', 14990000, 12, 'https://cdn2.fptshop.com.vn/unsafe/oppo_reno_16_f_bac_3741183f3e.png'),
(1, 'Xiaomi Redmi Note 17 Pro Max', 'Xiaomi', 'Điện thoại thông minh phục vụ nhu cầu liên lạc, giải trí và công việc.', 13990000, 19, 'https://cdn2.fptshop.com.vn/unsafe/xiaomi_redmi_note_17_pro_max_trang_1_09bda6764d.png'),
(1, 'Samsung Galaxy S26 Ultra', 'Samsung', 'Điện thoại thông minh phục vụ nhu cầu liên lạc, giải trí và công việc.', 29990000, 26, 'https://cdn2.fptshop.com.vn/unsafe/samsung_galaxy_s26_ultra_tim_d3898ec641.png'),
(1, 'OPPO Find X9 Ultra', 'OPPO', 'Điện thoại thông minh phục vụ nhu cầu liên lạc, giải trí và công việc.', 45990000, 33, 'https://cdn2.fptshop.com.vn/unsafe/oppo_find_x9_ultra_den_1_10ea275163.png'),
(1, 'OPPO Find X9s', 'OPPO', 'Điện thoại thông minh phục vụ nhu cầu liên lạc, giải trí và công việc.', 24990000, 40, 'https://cdn2.fptshop.com.vn/unsafe/oppo_find_x9s_cam_1_020275131c.png'),
(1, 'OPPO Reno15 F', 'OPPO', 'Điện thoại thông minh phục vụ nhu cầu liên lạc, giải trí và công việc.', 10990000, 7, 'https://cdn2.fptshop.com.vn/unsafe/oppo_reno15_f_xanh_den_7715fc8ee7.png'),
(1, 'Xiaomi Redmi Note 15', 'Xiaomi', 'Điện thoại thông minh phục vụ nhu cầu liên lạc, giải trí và công việc.', 4690000, 14, 'https://cdn2.fptshop.com.vn/unsafe/xiaomi_redmi_note_15_xanh_1935de8379.png'),
(1, 'Honor X9d', 'Honor', 'Điện thoại thông minh phục vụ nhu cầu liên lạc, giải trí và công việc.', 10990000, 21, 'https://cdn2.fptshop.com.vn/unsafe/honor_x9d_do_5_5835eff2ec.png'),
(1, 'Samsung Galaxy A17', 'Samsung', 'Điện thoại thông minh phục vụ nhu cầu liên lạc, giải trí và công việc.', 5190000, 28, 'https://cdn2.fptshop.com.vn/unsafe/samsung_galaxy_a17_xanh_884c7d34e7.png'),
(1, 'Honor X7d', 'Honor', 'Điện thoại thông minh phục vụ nhu cầu liên lạc, giải trí và công việc.', 6490000, 35, 'https://cdn2.fptshop.com.vn/unsafe/honor_x7d_vang_5_3023d9c575.png'),
(1, 'iPhone 17 Pro', 'Apple', 'Điện thoại thông minh phục vụ nhu cầu liên lạc, giải trí và công việc.', 38490000, 42, 'https://cdn2.fptshop.com.vn/unsafe/iphone_17_pro_cosmic_orange_1_12e8ea1358.png'),
(1, 'Samsung Galaxy A07', 'Samsung', 'Điện thoại thông minh phục vụ nhu cầu liên lạc, giải trí và công việc.', 4190000, 9, 'https://cdn2.fptshop.com.vn/unsafe/samsung_galaxy_a07_tim_6ddc995eb4.png'),
(1, 'POCO M8 Pro 8GB', 'POCO', 'Điện thoại thông minh phục vụ nhu cầu liên lạc, giải trí và công việc.', 8490000, 16, 'https://cdn2.fptshop.com.vn/unsafe/xiaomi_poco_m8_pro_xam_5_5fc1ed4d51.png'),
(1, 'Samsung Galaxy A08', 'Samsung', 'Điện thoại thông minh phục vụ nhu cầu liên lạc, giải trí và công việc.', 4790000, 23, 'https://cdn2.fptshop.com.vn/unsafe/samsung_galaxy_a08_xanh_la_1_da60c776e3.png'),
(1, 'Honor 600s', 'Honor', 'Điện thoại thông minh phục vụ nhu cầu liên lạc, giải trí và công việc.', 9490000, 30, 'https://cdn2.fptshop.com.vn/unsafe/honor_600s_vang_4_65f8d3bf67.png'),
(1, 'Samsung Galaxy S26 FE', 'Samsung', 'Điện thoại thông minh phục vụ nhu cầu liên lạc, giải trí và công việc.', 15990000, 37, 'https://cdn2.fptshop.com.vn/unsafe/samsung_galaxy_s26_fe_xanh_3d3479feb5.png'),
(1, 'Xiaomi Redmi Note 17 5G', 'Xiaomi', 'Điện thoại thông minh phục vụ nhu cầu liên lạc, giải trí và công việc.', 7490000, 44, 'https://cdn2.fptshop.com.vn/unsafe/xiaomi_redmi_note_17_den_1_665e74c52c.png'),
(1, 'Nubia A76 4GB (NFC)', 'Nubia', 'Điện thoại thông minh phục vụ nhu cầu liên lạc, giải trí và công việc.', 2790000, 11, 'https://cdn2.fptshop.com.vn/unsafe/nubia_a76_xam_5_87aade2a96.jpg'),
(2, 'Acer Aspire Lite 14 AL14-44P-R0SP R7-7730U', 'Acer', 'Laptop phục vụ học tập, công việc và giải trí.', 19490000, 18, 'https://cdn2.fptshop.com.vn/unsafe/00930661_acer_aspire_lite_14_al14_44_01_fb52eeb1fe.png'),
(2, 'HP 250R G10 Core 5-120U (C3SH7AT)', 'HP', 'Laptop phục vụ học tập, công việc và giải trí.', 21990000, 25, 'https://cdn2.fptshop.com.vn/unsafe/hp_250r_g10_silver_no_figer_01_4189a6deca.png'),
(2, 'ASUS Vivobook X1404VA-EB355W Core 7 150U', 'ASUS', 'Laptop phục vụ học tập, công việc và giải trí.', 22490000, 32, 'https://cdn2.fptshop.com.vn/unsafe/asus_vivobook_14_x1404_1_172d6c07b6.png'),
(2, 'Dell 14 DC14250 Core 5 120U (DC4C5386W)', 'Dell', 'Laptop phục vụ học tập, công việc và giải trí.', 26990000, 39, 'https://cdn2.fptshop.com.vn/unsafe/dell_14_dc14250_bac_01_187ecc6453.png'),
(2, 'MacBook Neo 13 8GB/256GB', 'Apple', 'Laptop phục vụ học tập, công việc và giải trí.', 18790000, 6, 'https://cdn2.fptshop.com.vn/unsafe/Mac_Book_13_in_A18_Pro_Citrus_1_f70ec68b06.png'),
(2, 'Lenovo IdeaPad Slim 3 16IWC11 (83RS002KVN)', 'Lenovo', 'Laptop phục vụ học tập, công việc và giải trí.', 18690000, 13, 'https://cdn2.fptshop.com.vn/unsafe/00930377_lenovo_ideapad_slim_3_16iwc11_01_dae1811782.png'),
(2, 'Acer Aspire Lite 15 AL15-36P-30TN C3-N350', 'Acer', 'Laptop phục vụ học tập, công việc và giải trí.', 16990000, 20, 'https://cdn2.fptshop.com.vn/unsafe/00930513_acer_aspire_lite_15_al15_36p_30tn_01_31569a6c93.png'),
(2, 'Colorful Rimbook L1 i5-12450H/CE50016512C-G-E1AC', 'Colorful', 'Laptop phục vụ học tập, công việc và giải trí.', 19490000, 27, 'https://cdn2.fptshop.com.vn/unsafe/colorful_rimbook_l1_xam_1_96ce53228b.png'),
(2, 'MacBook Air 13 M5 2026 10CPU/8GPU/16GB/512GB', 'Apple', 'Laptop phục vụ học tập, công việc và giải trí.', 33490000, 34, 'https://cdn2.fptshop.com.vn/unsafe/macbook_air_13_m5_starlight_1_bfd6f1c5ed.png'),
(2, 'Lenovo IdeaPad Slim 3 14IWC11 (83RQ002PVN)', 'Lenovo', 'Laptop phục vụ học tập, công việc và giải trí.', 18590000, 41, 'https://cdn2.fptshop.com.vn/unsafe/00929657_lenovo_ideapad_slim_3_14iwc11_01_a7054ebbc2.png'),
(2, 'ASUS Vivobook 16 X1607CA-MB387W Ultra 5 225H', 'ASUS', 'Laptop phục vụ học tập, công việc và giải trí.', 24490000, 8, 'https://cdn2.fptshop.com.vn/unsafe/00930030_asus_vivobook_16_x1607ca_bac_logo_ai_17df31a9b3.png'),
(2, 'HP 15-fd1289TU Ultra 7-155H (C2CV8PA)', 'HP', 'Laptop phục vụ học tập, công việc và giải trí.', 24990000, 15, 'https://cdn2.fptshop.com.vn/unsafe/00922844_hp_15_fd1289tu_c2cv8pa_bac_01_216c5b8b09.png'),
(2, 'MacBook Pro 14 M5 2026 10CPU/10GPU/16GB/1TB/96W', 'Apple', 'Laptop phục vụ học tập, công việc và giải trí.', 53990000, 22, 'https://cdn2.fptshop.com.vn/unsafe/macbook_pro_14_m5_2025_den_1_c0818fdf94.jpg'),
(2, 'HP OmniBook 7 14-fr0033TU Ultra 5-225U (C1MN2PA)', 'HP', 'Laptop phục vụ học tập, công việc và giải trí.', 27990000, 29, 'https://cdn2.fptshop.com.vn/unsafe/00921488_hp_omnibook_7_14_fr0033tu_bac_01_fb14b7c88d.png'),
(2, 'HP 14-em0024AU Ryzen 5-7520U (D0BG8PA)', 'HP', 'Laptop phục vụ học tập, công việc và giải trí.', 20990000, 36, 'https://cdn2.fptshop.com.vn/unsafe/hp_14_em_bac_01_f60ff4a623.png'),
(2, 'ASUS Vivobook Go 15 E1504FA-BQ340W R5-40', 'ASUS', 'Laptop phục vụ học tập, công việc và giải trí.', 20490000, 43, 'https://cdn2.fptshop.com.vn/unsafe/asus_vivobook_go_15_oled_e1504f_silver_1_9cdc33fe4d.png'),
(2, 'Acer Aspire Lite 14 AL14-47P-R0TR R5-3500U', 'Acer', 'Laptop phục vụ học tập, công việc và giải trí.', 17990000, 10, 'https://cdn2.fptshop.com.vn/unsafe/00931262_acer_aspire_lite_14_al14_47p_xam_01_177081f228.png'),
(2, 'HP 14-hc0028TU Ultra 5-225U (D72BJPA)', 'HP', 'Laptop phục vụ học tập, công việc và giải trí.', 23590000, 17, 'https://cdn2.fptshop.com.vn/unsafe/hp_14_hc0028tu_bac_logo_ai_3260460d9f.png'),
(2, 'MSI Modern 14 F1MG-432VN Core 5-120U', 'MSI', 'Laptop phục vụ học tập, công việc và giải trí.', 19290000, 24, 'https://cdn2.fptshop.com.vn/unsafe/00928695_laptop_msi_modern_14_f1mg_432vn_silver_01_06659a3978.png'),
(2, 'ASUS ExpertBook P3 G2 PM3406CHA-LY0089W R7-8840HS', 'ASUS', 'Laptop phục vụ học tập, công việc và giải trí.', 25290000, 31, 'https://cdn2.fptshop.com.vn/unsafe/asus_expertbook_p3_g2_pm3406_01_logo_ai_389cba58ec.png'),
(2, 'Dell 15 DC15250 i5-1334U (884116652434-NK)', 'Dell', 'Laptop phục vụ học tập, công việc và giải trí.', 19190000, 38, 'https://cdn2.fptshop.com.vn/unsafe/dell_15_dc15250_black_01_125a41fb5a.png'),
(2, 'HP OmniBook 5 AI 16-af1048TU Ultra 5-225U (BZ7Q9PA)', 'HP', 'Laptop phục vụ học tập, công việc và giải trí.', 25990000, 5, 'https://cdn2.fptshop.com.vn/unsafe/00920700_hp_omnibook_5_ai_16_af10xx_silver_01_0eaec1bdde.png'),
(2, 'Lenovo IdeaPad Slim 3 14IPH11 U5-322 (83UQ003NVN)', 'Lenovo', 'Laptop phục vụ học tập, công việc và giải trí.', 23590000, 12, 'https://cdn2.fptshop.com.vn/unsafe/00929020_lenovo_ideapad_slim_3_14iph11_01_8bc76725d6.png'),
(2, 'Acer Aspire Lite 14 AL14-45P-R7Z3', 'Acer', 'Laptop phục vụ học tập, công việc và giải trí.', 16990000, 19, 'https://cdn2.fptshop.com.vn/unsafe/00928515_acer_aspire_lite_14_al14_45p_01_658e045a69.png'),
(3, 'Bộ sạc Samsung 25W kèm cáp Type-C to Type-C', 'Samsung', 'Phụ kiện điện tử tiện ích cho thiết bị tương thích.', 543000, 26, 'https://cdn2.fptshop.com.vn/unsafe/bo_sac_samsung_25w_kem_cap_type_c_to_type_c_5_1ed3087200.png'),
(3, 'Tai nghe AirPods 5', 'Apple', 'Phụ kiện điện tử tiện ích cho thiết bị tương thích.', 3790000, 33, 'https://cdn2.fptshop.com.vn/unsafe/airpods_5_2_770f2cece6.png'),
(3, 'Ốp lưng MagSafe Mipow iPhone 18 Pro Max/17 Pro Max TPU chống sốc', 'Mipow', 'Phụ kiện điện tử tiện ích cho thiết bị tương thích.', 549000, 40, 'https://cdn2.fptshop.com.vn/unsafe/op_lung_magsafe_mipow_iphone_18_pro_max_17_pro_max_nhua_tpu_chong_soc_2_921725b1db.png'),
(3, 'Miếng dán kính cường lực camera ESR iPhone 18 Pro/18 Pro Max', 'ESR', 'Phụ kiện điện tử tiện ích cho thiết bị tương thích.', 200000, 7, 'https://cdn2.fptshop.com.vn/unsafe/mieng_dan_kinh_cuong_luc_camera_esr_iphone_18_pro_18_pro_max_ee95263dd0.png'),
(3, 'Miếng dán màn hình chống nhìn trộm ESR iPhone 18 Pro', 'ESR', 'Phụ kiện điện tử tiện ích cho thiết bị tương thích.', 250000, 14, 'https://cdn2.fptshop.com.vn/unsafe/mieng_dan_man_hinh_kinh_cuong_luc_chong_nhin_trom_esr_iphone_18_pro_b6e8ed0031.png'),
(3, 'Bộ sạc nhanh Baseus EnerCore CJ11 45W kèm cáp USB-C', 'Baseus', 'Phụ kiện điện tử tiện ích cho thiết bị tương thích.', 799000, 21, 'https://cdn2.fptshop.com.vn/unsafe/bo_sac_nhanh_baseus_enercore_cj11_45w_kem_cap_rut_gon_type_c_usb_c_5_d67fa8bd04.jpg'),
(3, 'Tai nghe Bluetooth Open Ear Trusmi WS18-011', 'Trusmi', 'Phụ kiện điện tử tiện ích cho thiết bị tương thích.', 299000, 28, 'https://cdn2.fptshop.com.vn/unsafe/tai_nghe_bluetooth_open_ear_trusmi_ws18_011_2_75fcd1af5c.jpg'),
(3, 'Miếng dán màn hình MacBook Neo 13 YVS', 'YVS', 'Phụ kiện điện tử tiện ích cho thiết bị tương thích.', 89000, 35, 'https://cdn2.fptshop.com.vn/unsafe/mieng_dan_man_hinh_macbook_neo_13_yvs_77910884bd.jpg'),
(3, 'Bàn phím có dây Havit KB257', 'Havit', 'Phụ kiện điện tử tiện ích cho thiết bị tương thích.', 179000, 42, 'https://cdn2.fptshop.com.vn/unsafe/00926955_Ban_phim_co_day_Havit_KB_257_Den_01_90aa108ff2.png'),
(3, 'Bàn phím không dây Havit HV-KB220BT', 'Havit', 'Phụ kiện điện tử tiện ích cho thiết bị tương thích.', 279000, 9, 'https://cdn2.fptshop.com.vn/unsafe/00926954_Ban_phim_khong_day_Havit_HV_KB_220_BT_Den_xam_01_41565cd413.png'),
(3, 'Chuột gaming không dây Havit MS1020WB', 'Havit', 'Phụ kiện điện tử tiện ích cho thiết bị tương thích.', 579000, 16, 'https://cdn2.fptshop.com.vn/unsafe/00926953_Chuot_gaming_khong_day_Havit_MS_1020_WB_Den_01_e7051c7802.png'),
(3, 'Pin sạc dự phòng 10000mAh Trusmi PB06 22.5W', 'Trusmi', 'Phụ kiện điện tử tiện ích cho thiết bị tương thích.', 399000, 23, 'https://cdn2.fptshop.com.vn/unsafe/pin_sac_du_phong_10000mah_trusmi_pb06_225w_den_3_5581f9b738.jpg'),
(3, 'Bộ dụng cụ vệ sinh đa năng Devia 8in1', 'Devia', 'Phụ kiện điện tử tiện ích cho thiết bị tương thích.', 249000, 30, 'https://cdn2.fptshop.com.vn/unsafe/bo_dung_cu_ve_sinh_da_nang_devia_8in1_3_09a5bbc654.jpg'),
(3, 'Bộ dụng cụ vệ sinh đa năng Coteci 20in1', 'Coteci', 'Phụ kiện điện tử tiện ích cho thiết bị tương thích.', 299000, 37, 'https://cdn2.fptshop.com.vn/unsafe/bo_dung_cu_ve_sinh_da_nang_coteci_20in1_3_87fd409366.jpg'),
(3, 'Tai nghe có dây nhét tai Type-C Havit E336C', 'Havit', 'Phụ kiện điện tử tiện ích cho thiết bị tương thích.', 99000, 44, 'https://cdn2.fptshop.com.vn/unsafe/tai_nghe_co_day_nhet_tai_type_c_havit_e336c_trang_1_0d898e60a0.png'),
(3, 'Tai nghe Bluetooth choàng đầu Havit H618BT', 'Havit', 'Phụ kiện điện tử tiện ích cho thiết bị tương thích.', 269000, 11, 'https://cdn2.fptshop.com.vn/unsafe/tai_nghe_bluetooth_choang_dau_co_mic_havit_h618bt_kem_5_d2a4e7c0ce.png'),
(3, 'Miếng dán màn hình Honor X5c Plus YVS', 'YVS', 'Phụ kiện điện tử tiện ích cho thiết bị tương thích.', 129000, 18, 'https://cdn2.fptshop.com.vn/unsafe/mieng_dan_man_hinh_kinh_cuong_luc_honor_x5c_plus_yvs_2191f76148.png'),
(3, 'USB OTG SanDisk Ultra DDC3 32/64GB', 'SanDisk', 'Phụ kiện điện tử tiện ích cho thiết bị tương thích.', 469000, 25, 'https://cdn2.fptshop.com.vn/unsafe/usb_otg_32_64gb_sandisk_ultra_ddc3_1_be05b79525.jpg'),
(3, 'Chuột gaming có dây Logitech G102 Gen 2', 'Logitech', 'Phụ kiện điện tử tiện ích cho thiết bị tương thích.', 400000, 32, 'https://cdn2.fptshop.com.vn/unsafe/chuot_gaming_co_day_logitech_g102_gen_2_den_1_3e7d45314e.png'),
(3, 'USB Kingston DataTraveler DTX 32/64GB', 'Kingston', 'Phụ kiện điện tử tiện ích cho thiết bị tương thích.', 249000, 39, 'https://cdn2.fptshop.com.vn/unsafe/usb_32_64gb_kingston_dtx_2_b2a5e4f2bf.png'),
(3, 'Miếng dán màn hình Honor X9d 5G YVS', 'YVS', 'Phụ kiện điện tử tiện ích cho thiết bị tương thích.', 129000, 6, 'https://cdn2.fptshop.com.vn/unsafe/mieng_dan_man_hinh_kinh_cuong_luc_honor_x9d_5g_yvs_1c54eb1142.png'),
(3, 'Loa karaoke xách tay Soncamedia CarryOn', 'Soncamedia', 'Phụ kiện điện tử tiện ích cho thiết bị tương thích.', 1490000, 13, 'https://cdn2.fptshop.com.vn/unsafe/loa_karaoke_xach_tay_soncamedia_carryon_1_f3a510d21c.png'),
(3, 'Miếng dán màn hình Honor X7d YVS', 'YVS', 'Phụ kiện điện tử tiện ích cho thiết bị tương thích.', 129000, 20, 'https://cdn2.fptshop.com.vn/unsafe/mieng_dan_man_hinh_kinh_cuong_luc_honor_x7d_yvs_c361767ed3.jpg'),
(3, 'Miếng dán màn hình OPPO A6 Pro YVS', 'YVS', 'Phụ kiện điện tử tiện ích cho thiết bị tương thích.', 129000, 27, 'https://cdn2.fptshop.com.vn/unsafe/mieng_dan_man_hinh_kinh_cuong_luc_oppo_a6_pro_yvs_88e2d23f09.png'),
(3, 'Bộ sạc nhanh Baseus Super Si 20W kèm cáp USB-C to Lightning', 'Baseus', 'Phụ kiện điện tử tiện ích cho thiết bị tương thích.', 299000, 34, 'https://cdn2.fptshop.com.vn/unsafe/bo_sac_nhanh_baseus_super_si_20w_1_cong_kem_cap_type_c_to_lightning_1m_dd_0e19c0de9a.jpg'),
(3, 'Cáp USB-C to USB-C 1m Xiaomi', 'Xiaomi', 'Phụ kiện điện tử tiện ích cho thiết bị tương thích.', 340000, 41, 'https://cdn2.fptshop.com.vn/unsafe/cap_usb_c_to_usb_c_6a_braided_xiaomi_2_d3fc069756.jpg'),
(3, 'Bộ sạc nhanh Baseus Super Si 25W kèm cáp USB-C to USB-C', 'Baseus', 'Phụ kiện điện tử tiện ích cho thiết bị tương thích.', 299000, 8, 'https://cdn2.fptshop.com.vn/unsafe/bo_sac_nhanh_baseus_super_si_25w_1_cong_kem_cap_type_c_to_type_c_1m_dd_da3512e1e5.jpg'),
(3, 'Cáp Devia Gracious Series PD USB-C to Lightning 1.5m', 'Devia', 'Phụ kiện điện tử tiện ích cho thiết bị tương thích.', 175000, 15, 'https://cdn2.fptshop.com.vn/unsafe/2022_11_22_638047060171322262_HASP-CAP-DEVIA-GRACIUOS-USBC-TO-LIGHTNING-1.5-DEN-AVT.jpg'),
(3, 'Cáp Innostyle UltraFlex A to USB-C 1.5m', 'Innostyle', 'Phụ kiện điện tử tiện ích cho thiết bị tương thích.', 135000, 22, 'https://cdn2.fptshop.com.vn/unsafe/2023_8_23_638284076389991874_cap-innostyle-ultraflex-a-to-type-c-1-5m-den-dd.jpg'),
(3, 'Củ sạc Devia Rocket Series PD USB-C 20W', 'Devia', 'Phụ kiện điện tử tiện ích cho thiết bị tương thích.', 199000, 29, 'https://cdn2.fptshop.com.vn/unsafe/cu_sac_nhanh_1_cong_20w_usb_c_rocket_series_pd_devia_d3fe0491f6.jpg'),
(3, 'Cáp Hub Ugreen USB-C to HDMI 5-in-1 1549', 'Ugreen', 'Phụ kiện điện tử tiện ích cho thiết bị tương thích.', 349000, 36, 'https://cdn2.fptshop.com.vn/unsafe/2024_5_20_638518124703307692_ugreen-15495-thumb.jpg')
;
