-- LOCAL ONLY: run against the electro_shop demo database, never production.
USE electro_shop;

UPDATE products
SET image_url = CASE name
  WHEN 'Samsung Galaxy S25 Ultra 256GB' THEN 'https://cdn.tgdd.vn/Products/Images/42/333347/samsung-galaxy-s25-ultra-blue-thumbai.jpg'
  WHEN 'Samsung Galaxy S25+ 256GB' THEN 'https://cdn.tgdd.vn/Products/Images/42/333359/samsung-galaxy-s25-plus-navy-thumbai.jpg'
  WHEN 'Samsung Galaxy S25 256GB' THEN 'https://cdn.tgdd.vn/Products/Images/42/333363/samsung-galaxy-s25-blue-thumbai.jpg'
  WHEN 'Samsung Galaxy S24 FE 256GB' THEN 'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/322789/samsung-galaxy-s24-fe-blue-1-638629861111934098.jpg'
  WHEN 'Samsung Galaxy A56 5G 256GB' THEN 'https://cdn.tgdd.vn/Products/Images/42/335177/samsung-galaxy-a56-5g-green-thumb.jpg'
  WHEN 'Samsung Galaxy A36 5G 128GB' THEN 'https://cdn.tgdd.vn/Products/Images/42/335174/samsung-galaxy-a36-5g-purple-thumb-1.jpg'
  WHEN 'Samsung Galaxy A26 5G 128GB' THEN 'https://cdn.tgdd.vn/Products/Images/42/334777/samsung-galaxy-a26-5g-green-thumbn.jpg'
  WHEN 'Samsung Galaxy A16 128GB' THEN 'https://cdn.tgdd.vn/Products/Images/42/331207/samsung-galaxy-a16-xanh-la-thumb.jpg'
  WHEN 'Samsung Galaxy Z Fold6 256GB' THEN 'https://cdn.tgdd.vn/Products/Images/42/320721/samsung-galaxy-z-fold6-xam-1-1.jpg'
  WHEN 'Samsung Galaxy Z Flip6 256GB' THEN 'https://cdn.tgdd.vn/Products/Images/42/320722/samsung-galaxy-z-flip6-blue-1jpg.jpg'
  WHEN 'Xiaomi 15 Ultra 512GB' THEN 'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/334169/xiaomi-15-ultra-bac-1-638773979973547578.jpg'
  WHEN 'Xiaomi 15 256GB' THEN 'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/320337/xiaomi-15-xanh-1-638774562882706299.jpg'
  WHEN 'OPPO Find X8 Pro 512GB' THEN 'https://cdn.tgdd.vn/Products/Images/42/322129/oppo-find-x8-pro-black-thumb.jpg'
  WHEN 'OPPO Reno13 Pro 5G 512GB' THEN 'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/332937/oppo-reno13-pro-5g-tim-1-638711719416037010.jpg'
  WHEN 'OPPO Reno13 F 5G 256GB' THEN 'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/42/332936/oppo-reno13-f-5g-blue-1-638708201380084918.jpg'
  WHEN 'OPPO A5 Pro 5G 256GB' THEN 'https://cdn.tgdd.vn/Products/Images/42/334404/oppo-a5-pro-hong-thumb-1.jpg'
  WHEN 'MacBook Air 13 inch M4 16GB 256GB' THEN 'https://cdn.tgdd.vn/Products/Images/44/335362/macbook-air-13-inch-m4-xanh-da-troi.jpg'
  WHEN 'MacBook Air 15 inch M4 16GB 256GB' THEN 'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/44/335372/macbook-air-15-inch-m4-tgdd-1-638772007305457970.jpg'
  WHEN 'MacBook Pro 14 inch M4 16GB 512GB' THEN 'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/44/331564/macbook-pro-14-inch-m4-16gb-512gb-bac-1-638660150192841121.jpg'
  WHEN 'MacBook Pro 16 inch M4 Pro 24GB 512GB' THEN 'https://cdnv2.tgdd.vn/mwg-static/tgdd/Products/Images/44/331574/macbook-pro-16-inch-m4-tgdd-bac-1-638660173449336788.jpg'
  WHEN 'Samsung Galaxy Watch7 40mm' THEN 'https://cdn.tgdd.vn/Products/Images/7077/327692/samsung-galaxy-watch7-40mm-kem-tn2.jpg'
  WHEN 'Samsung Galaxy Watch7 44mm' THEN 'https://cdn.tgdd.vn/Products/Images/7077/327692/samsung-galaxy-watch7-40mm-kem-tn2.jpg'
  WHEN 'Samsung Galaxy Watch Ultra' THEN 'https://cdn.tgdd.vn/Products/Images/7077/327693/galaxy-watch-ultra-trang-tn.jpg'
  WHEN 'Huawei Watch Fit 3' THEN 'https://cdn.tgdd.vn/Products/Images/7077/325375/huawei-watch-fit-3-white-tn.jpg'
  WHEN 'Xiaomi Watch 2 Pro' THEN 'https://cdn.tgdd.vn/Products/Images/7077/316986/xiaomi-watch-2-pro-tn-600x600.jpg'
  WHEN 'Amazfit Balance' THEN 'https://cdn.tgdd.vn/Products/Images/7077/322265/amazfit-balance-day-silicone-tn2-600x600.jpg'
  WHEN 'Amazfit Active 2' THEN 'https://cdn.tgdd.vn/Products/Images/7077/335088/amazfit-active-2-tb-600x600.jpg'
  WHEN 'Amazfit T-Rex 3' THEN 'https://cdn.tgdd.vn/Products/Images/7077/329945/amazfit-t-rex-3-den-tn-1.jpg'
  WHEN 'Garmin Instinct 2X Solar' THEN 'https://cdn.tgdd.vn/Products/Images/7077/324332/garmin-instinct-2x-solar-reu-tn.jpg'
  WHEN 'Amazfit GTR Mini' THEN 'https://cdn.tgdd.vn/Products/Images/7077/304893/amafit-gtr-mini-xanh-1.jpg'
  ELSE image_url
END
WHERE (
    image_url = '/images/no-image.svg'
    OR image_url LIKE 'https://upload.wikimedia.org/%'
  )
  AND name IN (
    'Samsung Galaxy S25 Ultra 256GB',
    'Samsung Galaxy S25+ 256GB',
    'Samsung Galaxy S25 256GB',
    'Samsung Galaxy S24 FE 256GB',
    'Samsung Galaxy A56 5G 256GB',
    'Samsung Galaxy A36 5G 128GB',
    'Samsung Galaxy A26 5G 128GB',
    'Samsung Galaxy A16 128GB',
    'Samsung Galaxy Z Fold6 256GB',
    'Samsung Galaxy Z Flip6 256GB',
    'Xiaomi 15 Ultra 512GB',
    'Xiaomi 15 256GB',
    'OPPO Find X8 Pro 512GB',
    'OPPO Reno13 Pro 5G 512GB',
    'OPPO Reno13 F 5G 256GB',
    'OPPO A5 Pro 5G 256GB',
    'MacBook Air 13 inch M4 16GB 256GB',
    'MacBook Air 15 inch M4 16GB 256GB',
    'MacBook Pro 14 inch M4 16GB 512GB',
    'MacBook Pro 16 inch M4 Pro 24GB 512GB',
    'Samsung Galaxy Watch7 40mm',
    'Samsung Galaxy Watch7 44mm',
    'Samsung Galaxy Watch Ultra',
    'Huawei Watch Fit 3',
    'Xiaomi Watch 2 Pro',
    'Amazfit Balance',
    'Amazfit Active 2',
    'Amazfit T-Rex 3',
    'Garmin Instinct 2X Solar',
    'Amazfit GTR Mini'
  );

DELETE FROM products
WHERE image_url IS NULL
   OR TRIM(image_url) = ''
   OR image_url = '/images/no-image.svg'
   OR image_url LIKE 'https://upload.wikimedia.org/%'
   OR name = 'Acer Predator Helios 18 AI PH18 93P0';

DROP TEMPORARY TABLE IF EXISTS local_product_additions;
CREATE TEMPORARY TABLE local_product_additions (
  category_id INT NOT NULL,
  name VARCHAR(200) NOT NULL,
  brand VARCHAR(100) NULL,
  price DECIMAL(12,2) NOT NULL,
  stock_qty INT NOT NULL,
  image_url VARCHAR(255) NOT NULL
);

INSERT INTO local_product_additions (category_id, name, brand, price, stock_qty, image_url) VALUES
(1, 'Xiaomi Redmi Note 17', 'Xiaomi', 5490000, 5, 'https://cdn2.fptshop.com.vn/unsafe/xiaomi_redmi_note_17_tim_1_857b62ab92.png'),
(1, 'OPPO Reno16 F', 'OPPO', 14990000, 12, 'https://cdn2.fptshop.com.vn/unsafe/oppo_reno_16_f_bac_3741183f3e.png'),
(1, 'Xiaomi Redmi Note 17 Pro Max', 'Xiaomi', 13990000, 19, 'https://cdn2.fptshop.com.vn/unsafe/xiaomi_redmi_note_17_pro_max_trang_1_09bda6764d.png'),
(1, 'Samsung Galaxy S26 Ultra', 'Samsung', 29990000, 26, 'https://cdn2.fptshop.com.vn/unsafe/samsung_galaxy_s26_ultra_tim_d3898ec641.png'),
(1, 'OPPO Find X9 Ultra', 'OPPO', 45990000, 33, 'https://cdn2.fptshop.com.vn/unsafe/oppo_find_x9_ultra_den_1_10ea275163.png'),
(1, 'OPPO Find X9s', 'OPPO', 24990000, 40, 'https://cdn2.fptshop.com.vn/unsafe/oppo_find_x9s_cam_1_020275131c.png'),
(1, 'OPPO Reno15 F', 'OPPO', 10990000, 7, 'https://cdn2.fptshop.com.vn/unsafe/oppo_reno15_f_xanh_den_7715fc8ee7.png'),
(1, 'Xiaomi Redmi Note 15', 'Xiaomi', 4690000, 14, 'https://cdn2.fptshop.com.vn/unsafe/xiaomi_redmi_note_15_xanh_1935de8379.png'),
(1, 'Honor X9d', 'Honor', 10990000, 21, 'https://cdn2.fptshop.com.vn/unsafe/honor_x9d_do_5_5835eff2ec.png'),
(1, 'Samsung Galaxy A17', 'Samsung', 5190000, 28, 'https://cdn2.fptshop.com.vn/unsafe/samsung_galaxy_a17_xanh_884c7d34e7.png'),
(1, 'Honor X7d', 'Honor', 6490000, 35, 'https://cdn2.fptshop.com.vn/unsafe/honor_x7d_vang_5_3023d9c575.png'),
(1, 'iPhone 17 Pro', 'Apple', 38490000, 42, 'https://cdn2.fptshop.com.vn/unsafe/iphone_17_pro_cosmic_orange_1_12e8ea1358.png'),
(1, 'Samsung Galaxy A07', 'Samsung', 4190000, 9, 'https://cdn2.fptshop.com.vn/unsafe/samsung_galaxy_a07_tim_6ddc995eb4.png'),
(1, 'POCO M8 Pro 8GB', 'POCO', 8490000, 16, 'https://cdn2.fptshop.com.vn/unsafe/xiaomi_poco_m8_pro_xam_5_5fc1ed4d51.png'),
(1, 'Samsung Galaxy A08', 'Samsung', 4790000, 23, 'https://cdn2.fptshop.com.vn/unsafe/samsung_galaxy_a08_xanh_la_1_da60c776e3.png'),
(1, 'Honor 600s', 'Honor', 9490000, 30, 'https://cdn2.fptshop.com.vn/unsafe/honor_600s_vang_4_65f8d3bf67.png'),
(1, 'Samsung Galaxy S26 FE', 'Samsung', 15990000, 37, 'https://cdn2.fptshop.com.vn/unsafe/samsung_galaxy_s26_fe_xanh_3d3479feb5.png'),
(1, 'Xiaomi Redmi Note 17 5G', 'Xiaomi', 7490000, 44, 'https://cdn2.fptshop.com.vn/unsafe/xiaomi_redmi_note_17_den_1_665e74c52c.png'),
(1, 'Nubia A76 4GB (NFC)', 'Nubia', 2790000, 11, 'https://cdn2.fptshop.com.vn/unsafe/nubia_a76_xam_5_87aade2a96.jpg'),
(2, 'Acer Aspire Lite 14 AL14-44P-R0SP R7-7730U', 'Acer', 19490000, 18, 'https://cdn2.fptshop.com.vn/unsafe/00930661_acer_aspire_lite_14_al14_44_01_fb52eeb1fe.png'),
(2, 'HP 250R G10 Core 5-120U (C3SH7AT)', 'HP', 21990000, 25, 'https://cdn2.fptshop.com.vn/unsafe/hp_250r_g10_silver_no_figer_01_4189a6deca.png'),
(2, 'ASUS Vivobook X1404VA-EB355W Core 7 150U', 'ASUS', 22490000, 32, 'https://cdn2.fptshop.com.vn/unsafe/asus_vivobook_14_x1404_1_172d6c07b6.png'),
(2, 'Dell 14 DC14250 Core 5 120U (DC4C5386W)', 'Dell', 26990000, 39, 'https://cdn2.fptshop.com.vn/unsafe/dell_14_dc14250_bac_01_187ecc6453.png'),
(2, 'MacBook Neo 13 8GB/256GB', 'Apple', 18790000, 6, 'https://cdn2.fptshop.com.vn/unsafe/Mac_Book_13_in_A18_Pro_Citrus_1_f70ec68b06.png'),
(2, 'Lenovo IdeaPad Slim 3 16IWC11 (83RS002KVN)', 'Lenovo', 18690000, 13, 'https://cdn2.fptshop.com.vn/unsafe/00930377_lenovo_ideapad_slim_3_16iwc11_01_dae1811782.png'),
(2, 'Acer Aspire Lite 15 AL15-36P-30TN C3-N350', 'Acer', 16990000, 20, 'https://cdn2.fptshop.com.vn/unsafe/00930513_acer_aspire_lite_15_al15_36p_30tn_01_31569a6c93.png'),
(2, 'Colorful Rimbook L1 i5-12450H/CE50016512C-G-E1AC', 'Colorful', 19490000, 27, 'https://cdn2.fptshop.com.vn/unsafe/colorful_rimbook_l1_xam_1_96ce53228b.png'),
(2, 'MacBook Air 13 M5 2026 10CPU/8GPU/16GB/512GB', 'Apple', 33490000, 34, 'https://cdn2.fptshop.com.vn/unsafe/macbook_air_13_m5_starlight_1_bfd6f1c5ed.png'),
(2, 'Lenovo IdeaPad Slim 3 14IWC11 (83RQ002PVN)', 'Lenovo', 18590000, 41, 'https://cdn2.fptshop.com.vn/unsafe/00929657_lenovo_ideapad_slim_3_14iwc11_01_a7054ebbc2.png'),
(2, 'ASUS Vivobook 16 X1607CA-MB387W Ultra 5 225H', 'ASUS', 24490000, 8, 'https://cdn2.fptshop.com.vn/unsafe/00930030_asus_vivobook_16_x1607ca_bac_logo_ai_17df31a9b3.png'),
(2, 'HP 15-fd1289TU Ultra 7-155H (C2CV8PA)', 'HP', 24990000, 15, 'https://cdn2.fptshop.com.vn/unsafe/00922844_hp_15_fd1289tu_c2cv8pa_bac_01_216c5b8b09.png'),
(2, 'MacBook Pro 14 M5 2026 10CPU/10GPU/16GB/1TB/96W', 'Apple', 53990000, 22, 'https://cdn2.fptshop.com.vn/unsafe/macbook_pro_14_m5_2025_den_1_c0818fdf94.jpg'),
(2, 'HP OmniBook 7 14-fr0033TU Ultra 5-225U (C1MN2PA)', 'HP', 27990000, 29, 'https://cdn2.fptshop.com.vn/unsafe/00921488_hp_omnibook_7_14_fr0033tu_bac_01_fb14b7c88d.png'),
(2, 'HP 14-em0024AU Ryzen 5-7520U (D0BG8PA)', 'HP', 20990000, 36, 'https://cdn2.fptshop.com.vn/unsafe/hp_14_em_bac_01_f60ff4a623.png'),
(2, 'ASUS Vivobook Go 15 E1504FA-BQ340W R5-40', 'ASUS', 20490000, 43, 'https://cdn2.fptshop.com.vn/unsafe/asus_vivobook_go_15_oled_e1504f_silver_1_9cdc33fe4d.png'),
(2, 'Acer Aspire Lite 14 AL14-47P-R0TR R5-3500U', 'Acer', 17990000, 10, 'https://cdn2.fptshop.com.vn/unsafe/00931262_acer_aspire_lite_14_al14_47p_xam_01_177081f228.png'),
(2, 'HP 14-hc0028TU Ultra 5-225U (D72BJPA)', 'HP', 23590000, 17, 'https://cdn2.fptshop.com.vn/unsafe/hp_14_hc0028tu_bac_logo_ai_3260460d9f.png'),
(2, 'MSI Modern 14 F1MG-432VN Core 5-120U', 'MSI', 19290000, 24, 'https://cdn2.fptshop.com.vn/unsafe/00928695_laptop_msi_modern_14_f1mg_432vn_silver_01_06659a3978.png'),
(2, 'ASUS ExpertBook P3 G2 PM3406CHA-LY0089W R7-8840HS', 'ASUS', 25290000, 31, 'https://cdn2.fptshop.com.vn/unsafe/asus_expertbook_p3_g2_pm3406_01_logo_ai_389cba58ec.png'),
(2, 'Dell 15 DC15250 i5-1334U (884116652434-NK)', 'Dell', 19190000, 38, 'https://cdn2.fptshop.com.vn/unsafe/dell_15_dc15250_black_01_125a41fb5a.png'),
(2, 'HP OmniBook 5 AI 16-af1048TU Ultra 5-225U (BZ7Q9PA)', 'HP', 25990000, 5, 'https://cdn2.fptshop.com.vn/unsafe/00920700_hp_omnibook_5_ai_16_af10xx_silver_01_0eaec1bdde.png'),
(2, 'Lenovo IdeaPad Slim 3 14IPH11 U5-322 (83UQ003NVN)', 'Lenovo', 23590000, 12, 'https://cdn2.fptshop.com.vn/unsafe/00929020_lenovo_ideapad_slim_3_14iph11_01_8bc76725d6.png'),
(2, 'Acer Aspire Lite 14 AL14-45P-R7Z3', 'Acer', 16990000, 19, 'https://cdn2.fptshop.com.vn/unsafe/00928515_acer_aspire_lite_14_al14_45p_01_658e045a69.png'),
(3, 'Bộ sạc Samsung 25W kèm cáp Type-C to Type-C', 'Samsung', 543000, 26, 'https://cdn2.fptshop.com.vn/unsafe/bo_sac_samsung_25w_kem_cap_type_c_to_type_c_5_1ed3087200.png'),
(3, 'Tai nghe AirPods 5', 'Apple', 3790000, 33, 'https://cdn2.fptshop.com.vn/unsafe/airpods_5_2_770f2cece6.png'),
(3, 'Ốp lưng MagSafe Mipow iPhone 18 Pro Max/17 Pro Max TPU chống sốc', 'Mipow', 549000, 40, 'https://cdn2.fptshop.com.vn/unsafe/op_lung_magsafe_mipow_iphone_18_pro_max_17_pro_max_nhua_tpu_chong_soc_2_921725b1db.png'),
(3, 'Miếng dán kính cường lực camera ESR iPhone 18 Pro/18 Pro Max', 'ESR', 200000, 7, 'https://cdn2.fptshop.com.vn/unsafe/mieng_dan_kinh_cuong_luc_camera_esr_iphone_18_pro_18_pro_max_ee95263dd0.png'),
(3, 'Miếng dán màn hình chống nhìn trộm ESR iPhone 18 Pro', 'ESR', 250000, 14, 'https://cdn2.fptshop.com.vn/unsafe/mieng_dan_man_hinh_kinh_cuong_luc_chong_nhin_trom_esr_iphone_18_pro_b6e8ed0031.png'),
(3, 'Bộ sạc nhanh Baseus EnerCore CJ11 45W kèm cáp USB-C', 'Baseus', 799000, 21, 'https://cdn2.fptshop.com.vn/unsafe/bo_sac_nhanh_baseus_enercore_cj11_45w_kem_cap_rut_gon_type_c_usb_c_5_d67fa8bd04.jpg'),
(3, 'Tai nghe Bluetooth Open Ear Trusmi WS18-011', 'Trusmi', 299000, 28, 'https://cdn2.fptshop.com.vn/unsafe/tai_nghe_bluetooth_open_ear_trusmi_ws18_011_2_75fcd1af5c.jpg'),
(3, 'Miếng dán màn hình MacBook Neo 13 YVS', 'YVS', 89000, 35, 'https://cdn2.fptshop.com.vn/unsafe/mieng_dan_man_hinh_macbook_neo_13_yvs_77910884bd.jpg'),
(3, 'Bàn phím có dây Havit KB257', 'Havit', 179000, 42, 'https://cdn2.fptshop.com.vn/unsafe/00926955_Ban_phim_co_day_Havit_KB_257_Den_01_90aa108ff2.png'),
(3, 'Bàn phím không dây Havit HV-KB220BT', 'Havit', 279000, 9, 'https://cdn2.fptshop.com.vn/unsafe/00926954_Ban_phim_khong_day_Havit_HV_KB_220_BT_Den_xam_01_41565cd413.png'),
(3, 'Chuột gaming không dây Havit MS1020WB', 'Havit', 579000, 16, 'https://cdn2.fptshop.com.vn/unsafe/00926953_Chuot_gaming_khong_day_Havit_MS_1020_WB_Den_01_e7051c7802.png'),
(3, 'Pin sạc dự phòng 10000mAh Trusmi PB06 22.5W', 'Trusmi', 399000, 23, 'https://cdn2.fptshop.com.vn/unsafe/pin_sac_du_phong_10000mah_trusmi_pb06_225w_den_3_5581f9b738.jpg'),
(3, 'Bộ dụng cụ vệ sinh đa năng Devia 8in1', 'Devia', 249000, 30, 'https://cdn2.fptshop.com.vn/unsafe/bo_dung_cu_ve_sinh_da_nang_devia_8in1_3_09a5bbc654.jpg'),
(3, 'Bộ dụng cụ vệ sinh đa năng Coteci 20in1', 'Coteci', 299000, 37, 'https://cdn2.fptshop.com.vn/unsafe/bo_dung_cu_ve_sinh_da_nang_coteci_20in1_3_87fd409366.jpg'),
(3, 'Tai nghe có dây nhét tai Type-C Havit E336C', 'Havit', 99000, 44, 'https://cdn2.fptshop.com.vn/unsafe/tai_nghe_co_day_nhet_tai_type_c_havit_e336c_trang_1_0d898e60a0.png'),
(3, 'Tai nghe Bluetooth choàng đầu Havit H618BT', 'Havit', 269000, 11, 'https://cdn2.fptshop.com.vn/unsafe/tai_nghe_bluetooth_choang_dau_co_mic_havit_h618bt_kem_5_d2a4e7c0ce.png'),
(3, 'Miếng dán màn hình Honor X5c Plus YVS', 'YVS', 129000, 18, 'https://cdn2.fptshop.com.vn/unsafe/mieng_dan_man_hinh_kinh_cuong_luc_honor_x5c_plus_yvs_2191f76148.png'),
(3, 'USB OTG SanDisk Ultra DDC3 32/64GB', 'SanDisk', 469000, 25, 'https://cdn2.fptshop.com.vn/unsafe/usb_otg_32_64gb_sandisk_ultra_ddc3_1_be05b79525.jpg'),
(3, 'Chuột gaming có dây Logitech G102 Gen 2', 'Logitech', 400000, 32, 'https://cdn2.fptshop.com.vn/unsafe/chuot_gaming_co_day_logitech_g102_gen_2_den_1_3e7d45314e.png'),
(3, 'USB Kingston DataTraveler DTX 32/64GB', 'Kingston', 249000, 39, 'https://cdn2.fptshop.com.vn/unsafe/usb_32_64gb_kingston_dtx_2_b2a5e4f2bf.png'),
(3, 'Miếng dán màn hình Honor X9d 5G YVS', 'YVS', 129000, 6, 'https://cdn2.fptshop.com.vn/unsafe/mieng_dan_man_hinh_kinh_cuong_luc_honor_x9d_5g_yvs_1c54eb1142.png'),
(3, 'Loa karaoke xách tay Soncamedia CarryOn', 'Soncamedia', 1490000, 13, 'https://cdn2.fptshop.com.vn/unsafe/loa_karaoke_xach_tay_soncamedia_carryon_1_f3a510d21c.png'),
(3, 'Miếng dán màn hình Honor X7d YVS', 'YVS', 129000, 20, 'https://cdn2.fptshop.com.vn/unsafe/mieng_dan_man_hinh_kinh_cuong_luc_honor_x7d_yvs_c361767ed3.jpg'),
(3, 'Miếng dán màn hình OPPO A6 Pro YVS', 'YVS', 129000, 27, 'https://cdn2.fptshop.com.vn/unsafe/mieng_dan_man_hinh_kinh_cuong_luc_oppo_a6_pro_yvs_88e2d23f09.png'),
(3, 'Bộ sạc nhanh Baseus Super Si 20W kèm cáp USB-C to Lightning', 'Baseus', 299000, 34, 'https://cdn2.fptshop.com.vn/unsafe/bo_sac_nhanh_baseus_super_si_20w_1_cong_kem_cap_type_c_to_lightning_1m_dd_0e19c0de9a.jpg'),
(3, 'Cáp USB-C to USB-C 1m Xiaomi', 'Xiaomi', 340000, 41, 'https://cdn2.fptshop.com.vn/unsafe/cap_usb_c_to_usb_c_6a_braided_xiaomi_2_d3fc069756.jpg'),
(3, 'Bộ sạc nhanh Baseus Super Si 25W kèm cáp USB-C to USB-C', 'Baseus', 299000, 8, 'https://cdn2.fptshop.com.vn/unsafe/bo_sac_nhanh_baseus_super_si_25w_1_cong_kem_cap_type_c_to_type_c_1m_dd_da3512e1e5.jpg'),
(3, 'Cáp Devia Gracious Series PD USB-C to Lightning 1.5m', 'Devia', 175000, 15, 'https://cdn2.fptshop.com.vn/unsafe/2022_11_22_638047060171322262_HASP-CAP-DEVIA-GRACIUOS-USBC-TO-LIGHTNING-1.5-DEN-AVT.jpg'),
(3, 'Cáp Innostyle UltraFlex A to USB-C 1.5m', 'Innostyle', 135000, 22, 'https://cdn2.fptshop.com.vn/unsafe/2023_8_23_638284076389991874_cap-innostyle-ultraflex-a-to-type-c-1-5m-den-dd.jpg'),
(3, 'Củ sạc Devia Rocket Series PD USB-C 20W', 'Devia', 199000, 29, 'https://cdn2.fptshop.com.vn/unsafe/cu_sac_nhanh_1_cong_20w_usb_c_rocket_series_pd_devia_d3fe0491f6.jpg'),
(3, 'Cáp Hub Ugreen USB-C to HDMI 5-in-1 1549', 'Ugreen', 349000, 36, 'https://cdn2.fptshop.com.vn/unsafe/2024_5_20_638518124703307692_ugreen-15495-thumb.jpg');

INSERT INTO products (category_id, name, brand, description, price, stock_qty, image_url)
SELECT category_id,
       name,
       brand,
       CASE category_id
         WHEN 1 THEN 'Điện thoại thông minh phục vụ nhu cầu liên lạc, giải trí và công việc.'
         WHEN 2 THEN 'Laptop phục vụ học tập, công việc và giải trí.'
         ELSE 'Phụ kiện điện tử tiện ích cho thiết bị tương thích.'
       END,
       price,
       stock_qty,
       image_url
FROM local_product_additions AS additions
WHERE NOT EXISTS (
  SELECT 1 FROM products AS existing WHERE existing.name = additions.name
);

DROP TEMPORARY TABLE local_product_additions;

SELECT COUNT(*) AS total_products,
       SUM(image_url IS NULL
           OR TRIM(image_url) = ''
           OR image_url = '/images/no-image.svg'
           OR image_url LIKE 'https://upload.wikimedia.org/%') AS products_without_image
FROM products;
