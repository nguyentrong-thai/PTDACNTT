-- Import this file into the target database selected by the operator.
-- This keeps the schema compatible with managed databases such as Railway MySQL.

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

-- Tạo tài khoản quản trị riêng bằng `npm run admin:create`.
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
(1, 'Samsung Galaxy S25 Ultra 256GB', 'Samsung', 'Điện thoại Android cao cấp, màn hình AMOLED lớn, camera đa tiêu cự và bút S Pen.', 33990000, 12, '/images/no-image.svg'),
(1, 'Samsung Galaxy S25+ 256GB', 'Samsung', 'Điện thoại màn hình AMOLED, kết nối 5G, camera đa dụng và sạc nhanh.', 26990000, 16, '/images/no-image.svg'),
(1, 'Samsung Galaxy S25 256GB', 'Samsung', 'Điện thoại nhỏ gọn, màn hình AMOLED, camera độ phân giải cao.', 22990000, 20, '/images/no-image.svg'),
(1, 'Samsung Galaxy S24 FE 256GB', 'Samsung', 'Điện thoại 5G màn hình AMOLED, camera góc rộng và pin dung lượng lớn.', 15990000, 18, '/images/no-image.svg'),
(1, 'Samsung Galaxy A56 5G 256GB', 'Samsung', 'Điện thoại 5G màn hình Super AMOLED, camera chống rung quang học.', 11990000, 25, '/images/no-image.svg'),
(1, 'Samsung Galaxy A36 5G 128GB', 'Samsung', 'Điện thoại 5G màn hình Super AMOLED, pin dùng cả ngày.', 7990000, 32, '/images/no-image.svg'),
(1, 'Samsung Galaxy A26 5G 128GB', 'Samsung', 'Điện thoại 5G màn hình AMOLED, camera chính độ phân giải cao.', 6490000, 29, '/images/no-image.svg'),
(1, 'Samsung Galaxy A16 128GB', 'Samsung', 'Điện thoại phổ thông màn hình lớn, pin dung lượng cao.', 4290000, 40, '/images/no-image.svg'),
(1, 'Samsung Galaxy Z Fold6 256GB', 'Samsung', 'Điện thoại gập màn hình lớn, đa nhiệm linh hoạt và hỗ trợ 5G.', 40990000, 5, '/images/no-image.svg'),
(1, 'Samsung Galaxy Z Flip6 256GB', 'Samsung', 'Điện thoại gập nhỏ gọn, màn hình phụ tiện dụng và camera kép.', 25990000, 7, '/images/no-image.svg'),
(1, 'Xiaomi 15 Ultra 512GB', 'Xiaomi', 'Điện thoại flagship 5G, màn hình AMOLED và hệ thống camera Leica.', 32990000, 8, '/images/no-image.svg'),
(1, 'Xiaomi 15 256GB', 'Xiaomi', 'Điện thoại 5G hiệu năng cao, màn hình AMOLED và camera đa dụng.', 22990000, 14, '/images/no-image.svg'),
(1, 'Xiaomi Redmi Note 14 Pro+ 5G 256GB', 'Xiaomi', 'Điện thoại 5G màn hình AMOLED, camera độ phân giải cao và sạc nhanh.', 10990000, 22, '/images/no-image.svg'),
(1, 'Xiaomi Redmi Note 14 Pro 256GB', 'Xiaomi', 'Điện thoại màn hình AMOLED, camera chống rung và pin dung lượng lớn.', 8990000, 24, '/images/no-image.svg'),
(1, 'Xiaomi Redmi 14C 128GB', 'Xiaomi', 'Điện thoại phổ thông màn hình lớn, pin bền và bộ nhớ mở rộng.', 3290000, 38, '/images/no-image.svg'),
(1, 'POCO X7 Pro 5G 256GB', 'POCO', 'Điện thoại 5G hướng đến hiệu năng, màn hình AMOLED và sạc nhanh.', 9990000, 17, '/images/no-image.svg'),
(1, 'POCO X7 5G 256GB', 'POCO', 'Điện thoại 5G màn hình AMOLED, camera chống rung quang học.', 7490000, 21, '/images/no-image.svg'),
(1, 'OPPO Find X8 Pro 512GB', 'OPPO', 'Điện thoại flagship 5G, màn hình AMOLED và camera Hasselblad.', 29990000, 6, '/images/no-image.svg'),
(1, 'OPPO Reno13 Pro 5G 512GB', 'OPPO', 'Điện thoại 5G thiết kế mỏng, camera chân dung và màn hình AMOLED.', 18990000, 13, '/images/no-image.svg'),
(1, 'OPPO Reno13 F 5G 256GB', 'OPPO', 'Điện thoại 5G màn hình AMOLED, camera đa dụng và pin lớn.', 9990000, 20, '/images/no-image.svg'),
(1, 'OPPO A5 Pro 5G 256GB', 'OPPO', 'Điện thoại 5G bền bỉ, màn hình lớn và pin dung lượng cao.', 7990000, 26, '/images/no-image.svg'),
(1, 'Vivo X200 Pro 512GB', 'vivo', 'Điện thoại flagship 5G, camera ZEISS và màn hình AMOLED.', 29990000, 5, '/images/no-image.svg'),
(1, 'Vivo V50 5G 256GB', 'vivo', 'Điện thoại 5G camera chân dung ZEISS, thiết kế mỏng nhẹ.', 13990000, 15, '/images/no-image.svg'),
(1, 'Vivo Y100 5G 128GB', 'vivo', 'Điện thoại 5G màn hình AMOLED, sạc nhanh và pin dung lượng lớn.', 6990000, 23, '/images/no-image.svg'),
(1, 'Google Pixel 9 Pro XL 256GB', 'Google', 'Điện thoại Android 5G, camera computational photography và màn hình OLED.', 26990000, 4, '/images/no-image.svg'),
(2, 'MacBook Air 13 inch M4 16GB 256GB', 'Apple', 'Laptop mỏng nhẹ với chip Apple M4, màn hình Liquid Retina và pin lâu.', 27990000, 10, '/images/no-image.svg'),
(2, 'MacBook Air 15 inch M4 16GB 256GB', 'Apple', 'Laptop màn hình Liquid Retina 15 inch, chip Apple M4 và thiết kế mỏng nhẹ.', 32990000, 8, '/images/no-image.svg'),
(2, 'MacBook Pro 14 inch M4 16GB 512GB', 'Apple', 'Laptop chuyên nghiệp với chip Apple M4, màn hình Liquid Retina XDR.', 39990000, 7, '/images/no-image.svg'),
(2, 'MacBook Pro 16 inch M4 Pro 24GB 512GB', 'Apple', 'Laptop hiệu năng cao, chip Apple M4 Pro và màn hình Liquid Retina XDR.', 59990000, 4, '/images/no-image.svg'),
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
(4, 'Samsung Galaxy Watch7 40mm', 'Samsung', 'Đồng hồ thông minh theo dõi sức khỏe, GPS và kết nối điện thoại Android.', 6990000, 13, '/images/no-image.svg'),
(4, 'Samsung Galaxy Watch7 44mm', 'Samsung', 'Đồng hồ thông minh màn hình lớn, theo dõi hoạt động và giấc ngủ.', 7490000, 11, '/images/no-image.svg'),
(4, 'Samsung Galaxy Watch Ultra', 'Samsung', 'Đồng hồ thể thao GPS, thiết kế bền bỉ và hỗ trợ theo dõi luyện tập.', 16990000, 3, '/images/no-image.svg'),
(4, 'Google Pixel Watch 3 41mm', 'Google', 'Đồng hồ thông minh Wear OS, theo dõi vận động và tích hợp Google services.', 8990000, 5, '/images/no-image.svg'),
(4, 'Garmin Venu 3 45mm', 'Garmin', 'Đồng hồ GPS đa môn thể thao, theo dõi sức khỏe và hỗ trợ nghe gọi.', 10990000, 7, '/images/no-image.svg'),
(4, 'Garmin Forerunner 965', 'Garmin', 'Đồng hồ chạy bộ GPS, bản đồ màu và các chỉ số luyện tập chuyên sâu.', 14990000, 5, '/images/no-image.svg'),
(4, 'Garmin Fenix 7 Pro Solar', 'Garmin', 'Đồng hồ outdoor GPS nhiều môn thể thao, sạc năng lượng mặt trời.', 18990000, 3, '/images/no-image.svg'),
(4, 'Garmin Instinct 2X Solar', 'Garmin', 'Đồng hồ GPS bền bỉ cho hoạt động ngoài trời, hỗ trợ sạc năng lượng mặt trời.', 9990000, 6, '/images/no-image.svg'),
(4, 'Huawei Watch GT 5 46mm', 'Huawei', 'Đồng hồ thông minh màn hình AMOLED, GPS và theo dõi sức khỏe.', 5990000, 12, '/images/no-image.svg'),
(4, 'Huawei Watch GT 5 Pro 46mm', 'Huawei', 'Đồng hồ thông minh cao cấp, vật liệu bền và chế độ luyện tập đa dạng.', 8990000, 6, '/images/no-image.svg'),
(4, 'Huawei Watch Fit 3', 'Huawei', 'Đồng hồ thông minh màn hình AMOLED vuông, theo dõi vận động hàng ngày.', 2990000, 18, '/images/no-image.svg'),
(4, 'Xiaomi Watch 2 Pro', 'Xiaomi', 'Đồng hồ Wear OS, hỗ trợ GPS, theo dõi hoạt động và kết nối điện thoại.', 4990000, 8, '/images/no-image.svg'),
(4, 'Xiaomi Smart Band 9 Pro', 'Xiaomi', 'Vòng đeo tay thông minh màn hình AMOLED, GPS và theo dõi sức khỏe.', 1990000, 22, '/images/no-image.svg'),
(4, 'Amazfit Balance', 'Amazfit', 'Đồng hồ thông minh GPS, theo dõi hoạt động và các chỉ số sức khỏe.', 5490000, 7, '/images/no-image.svg'),
(4, 'Amazfit Active 2', 'Amazfit', 'Đồng hồ thông minh AMOLED, GPS và nhiều chế độ luyện tập.', 2790000, 14, '/images/no-image.svg'),
(4, 'Amazfit T-Rex 3', 'Amazfit', 'Đồng hồ outdoor bền bỉ, GPS đa băng tần và hỗ trợ hoạt động ngoài trời.', 5990000, 5, '/images/no-image.svg'),
(4, 'Fitbit Versa 4', 'Fitbit', 'Đồng hồ thông minh theo dõi vận động, giấc ngủ và nhịp tim.', 4990000, 6, '/images/no-image.svg'),
(4, 'Fitbit Charge 6', 'Fitbit', 'Vòng đeo tay theo dõi sức khỏe, GPS và hoạt động thể chất hàng ngày.', 3990000, 10, '/images/no-image.svg'),
(4, 'Huawei Watch D2', 'Huawei', 'Đồng hồ thông minh theo dõi sức khỏe với tính năng đo huyết áp cổ tay.', 8990000, 4, '/images/no-image.svg'),
(4, 'OnePlus Watch 2', 'OnePlus', 'Đồng hồ Wear OS, GPS hai băng tần và thời lượng pin dài.', 6990000, 5, '/images/no-image.svg'),
(4, 'CMF Watch Pro 2', 'CMF', 'Đồng hồ thông minh màn hình AMOLED, GPS và cuộc gọi Bluetooth.', 1990000, 15, '/images/no-image.svg'),
(4, 'Xiaomi Redmi Watch 5 Lite', 'Xiaomi', 'Đồng hồ thông minh màn hình lớn, GPS và theo dõi hoạt động cơ bản.', 1490000, 20, '/images/no-image.svg'),
(4, 'Garmin Vivosmart 5', 'Garmin', 'Vòng đeo tay theo dõi sức khỏe, giấc ngủ và hoạt động hàng ngày.', 3490000, 8, '/images/no-image.svg'),
(4, 'Amazfit GTR Mini', 'Amazfit', 'Đồng hồ thông minh GPS nhỏ gọn, màn hình AMOLED và pin lâu.', 2490000, 11, '/images/no-image.svg');
