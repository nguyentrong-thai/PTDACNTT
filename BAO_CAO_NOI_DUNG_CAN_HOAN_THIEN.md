# Báo cáo rà soát nội dung cần hoàn thiện theo User Story

**Dự án:** ElectroShop  
**Ngày rà soát:** 17/10/2026  
**Tài liệu đối chiếu:** `Bao_cao_BTL_PTDA_ElectroShop.docx` và mã nguồn hiện có trong repository.

## 1. Kết luận

- Báo cáo liệt kê **24 user story**. Theo trạng thái trong báo cáo, **22/24** story nghiệp vụ đã hoàn thành; **US8.1** và **US8.2** vẫn là `To do`.
- Đã bổ sung unit tests cho quy tắc mật khẩu, phân quyền middleware, chuyển trạng thái đơn và gợi ý sản phẩm; `npm test` là bước kiểm tra tự động trước khi nghiệm thu.
- Đã chuẩn bị Railway config, biến môi trường mẫu, MySQL session store, persistent upload directory và health check. Chưa có quyền/kết nối Railway project để deploy thật.
- **US8.1 vẫn cần chạy checklist thủ công** trên database kiểm thử, ghi kết quả thực tế và bằng chứng tại [docs/ACCEPTANCE_TEST_CHECKLIST.md](./docs/ACCEPTANCE_TEST_CHECKLIST.md). Unit tests không thay thế UAT.
- **US8.2 vẫn cần thao tác trên Railway**: tạo MySQL và volume, nhập secrets, import schema, tạo admin ban đầu bằng lệnh bootstrap, deploy và ghi URL/kết quả smoke-test. Không đưa secrets vào repository.
- Mã nguồn đã được chỉnh cho các chỗ lệch báo cáo: mật khẩu hồ sơ thống nhất tối thiểu 8 ký tự; số điện thoại hồ sơ bắt buộc; trạng thái có thể chọn trên trang nhân viên bám theo luồng hợp lệ; lỗi checkout nghiệp vụ được nêu rõ, lỗi hệ thống đi middleware lỗi; trợ lý không trả kết quả không liên quan và từ chối câu hỏi quá 200 ký tự.

## 2. Rà soát từng User Story

Trạng thái “Có code; cần nghiệm thu” nghĩa là đã thấy luồng xử lý tương ứng khi đọc mã nguồn, nhưng chưa có kết quả kiểm thử được ghi nhận để xác nhận toàn bộ acceptance criteria.

| User Story | Trạng thái rà soát | Đối chiếu mã nguồn / phần còn thiếu |
|---|---|---|
| **US1.1 – Đăng ký tài khoản** | Có code; cần nghiệm thu | `controllers/authController.js`, `models/userModel.js`, `routes/authRoutes.js`: có kiểm tra đầu vào, mật khẩu tối thiểu 8 ký tự, bcrypt, kiểm tra trùng email/số điện thoại. Cần chạy và ghi kết quả các ca hợp lệ, email/số điện thoại trùng, mật khẩu ngắn và mật khẩu xác nhận không khớp. |
| **US1.2 – Đăng nhập, đăng xuất** | Có code; cần nghiệm thu | `controllers/authController.js`, `app.js`: có bcrypt, session, điều hướng admin và rate limit cấu hình ở app. Cần xác nhận đúng/sai mật khẩu, đăng xuất, điều hướng theo role và giới hạn 20 request/15 phút trên môi trường chạy thực tế. |
| **US1.3 – Phân quyền theo vai trò** | Có code; cần nghiệm thu | `middlewares/authMiddleware.js`, `routes/adminRoutes.js`, `routes/cartRoutes.js`, `routes/orderRoutes.js`, `routes/profileRoutes.js`, `routes/wishlistRoutes.js`: có middleware login/staff/admin. Cần kiểm thử truy cập trực tiếp URL bằng Guest, Customer, Employee và Admin, đặc biệt quyền Employee với `/admin/users` và `/admin/categories`. |
| **US2.1 – Quản lý danh mục** | Có code; cần nghiệm thu | `routes/adminRoutes.js`: có tạo/sửa/xóa danh mục, xử lý slug trùng và lỗi khóa ngoại khi danh mục còn sản phẩm. Cần chạy các ca admin CRUD, slug trùng, xóa danh mục đang được sử dụng và Employee truy cập trái quyền. |
| **US2.2 – Quản lý sản phẩm và ảnh** | Có code; cần nghiệm thu | `routes/adminRoutes.js`: có quản lý sản phẩm, upload giới hạn 5 MB, giới hạn loại ảnh, chuyển WebP, ẩn sản phẩm và xử lý xóa sản phẩm đã được đặt mua. Cần kiểm thử file hợp lệ/không hợp lệ, giới hạn dung lượng, xóa sản phẩm trong đơn và xác nhận ảnh được lưu/hiển thị sau triển khai. |
| **US3.1 – Trang chủ và danh sách sản phẩm** | Có code; cần nghiệm thu | `routes/index.js`, `routes/productRoutes.js`, `models/productModel.js`: trang chủ lấy sản phẩm hoạt động; danh sách phân trang 12 sản phẩm. Cần kiểm tra phân trang, dữ liệu hiển thị và việc sản phẩm đã ẩn không xuất hiện với Guest. |
| **US3.2 – Chi tiết sản phẩm** | Có code; cần nghiệm thu | `routes/productRoutes.js`, `views/products/detail.ejs`: có truy vấn thông tin sản phẩm, đánh giá và trả 404 khi không tìm thấy. Cần đối chiếu đủ thông tin hiển thị và kiểm thử ID không tồn tại/sản phẩm đã ẩn. |
| **US3.3 – Tìm kiếm và lọc sản phẩm** | Có code; cần nghiệm thu | `models/productModel.js`, `routes/productRoutes.js`, `views/products/index.ejs`: có tìm kiếm, lọc danh mục/thương hiệu và phân trang. Cần kiểm tra kết hợp bộ lọc, giữ bộ lọc khi chuyển trang và kết quả rỗng. |
| **US4.1 – Quản lý giỏ hàng** | Có code; cần nghiệm thu | `routes/cartRoutes.js`, `models/cartModel.js`: có thêm/cập nhật/xóa giỏ theo tài khoản. Cần kiểm tra số lượng vượt tồn kho, hàng hết/không hoạt động và xác nhận giỏ không bị mất khi đăng xuất/đăng nhập lại. |
| **US4.2 – Mua ngay** | Có code; cần nghiệm thu | `routes/cartRoutes.js`, `routes/orderRoutes.js`: có lưu mặt hàng mua ngay trong session và tách khỏi giỏ thường; Guest được chuyển qua đăng nhập. Cần kiểm tra sau đăng nhập quay lại checkout, số lượng không hợp lệ/hết hàng và giỏ thường không bị thay đổi. |
| **US5.1 – Checkout và tạo đơn** | Có code; cần nghiệm thu | `routes/orderRoutes.js`: có transaction, khóa sản phẩm, kiểm tra tồn, lưu giá tại thời điểm đặt, tạo chi tiết đơn, trừ kho và xóa giỏ sau khi thành công. Cần kiểm thử checkout từ giỏ/mua ngay, giỏ trống, thiếu hàng, rollback khi lỗi và nhiều checkout đồng thời. |
| **US5.2 – Xem và theo dõi đơn hàng** | Có code; cần nghiệm thu | `routes/orderRoutes.js`, `views/orders/index.ejs`, `views/orders/detail.ejs`: có danh sách theo tài khoản, lọc trạng thái, phân trang và truy vấn chi tiết theo `user_id`. Cần xác nhận khách không thể xem đơn của tài khoản khác và lọc/phân trang giữ đúng dữ liệu. |
| **US5.3 – Khách hủy đơn pending** | Có code; cần nghiệm thu | `routes/orderRoutes.js`: có khóa đơn theo user và trạng thái `pending`, hoàn kho và cập nhật trạng thái trong transaction. Cần kiểm thử hủy thành công, hủy lần hai, đơn không thuộc khách, đơn đã xác nhận và đối chiếu tồn kho trước/sau. |
| **US1.4 – Cập nhật hồ sơ** | Đã chỉnh; cần nghiệm thu | `routes/profileRoutes.js`, `views/profile/index.ejs`: số điện thoại bắt buộc, được kiểm tra định dạng/tính duy nhất. Cần chạy dữ liệu hợp lệ, trùng và sai định dạng. |
| **US1.5 – Đổi mật khẩu** | Đã chỉnh; cần nghiệm thu | `utils/passwordPolicy.js`, `routes/profileRoutes.js`, `views/profile/index.ejs`: mọi luồng tạo/đổi mật khẩu dùng tối thiểu 8 ký tự; mật khẩu hiện tại vẫn phải xác thực. Cần chạy ca sai hiện tại, xác nhận không khớp, 7/8 ký tự và đăng nhập lại. |
| **US6.1 – Nhân viên xử lý trạng thái đơn** | Đã chỉnh; cần nghiệm thu | `utils/orderStatus.js`, `routes/adminRoutes.js`, `views/admin/orders.ejs`: giao diện chỉ cho chọn chuyển tiếp hợp lệ; server vẫn xác thực chuyển tiếp và khóa dòng đơn. Cần kiểm thử luồng hợp lệ/sai, hai nhân viên cùng thao tác và trạng thái cuối. |
| **US6.2 – Nhân viên hủy đơn, hoàn kho** | Có code; cần nghiệm thu | `routes/adminRoutes.js`: chỉ hủy `pending`/`confirmed`, hoàn từng dòng hàng và cập nhật đơn trong transaction. Cần kiểm thử mỗi trạng thái được/không được hủy và xác nhận kho không bị hoàn hai lần khi thao tác đồng thời/lặp. |
| **US6.3 – Quản lý tài khoản nhân viên** | Có code; cần nghiệm thu | `routes/adminRoutes.js`: có tạo/sửa/xóa nhân viên, kiểm tra role, hash mật khẩu, bắt lỗi trùng email/số điện thoại; route được giới hạn cho admin. Cần kiểm thử CRUD, dữ liệu trùng, mật khẩu và Employee truy cập trái quyền. |
| **US6.4 – Thống kê tổng quan** | Có code; cần nghiệm thu | `routes/adminRoutes.js`, `views/admin/index.ejs`: có đếm sản phẩm hoạt động, đơn hàng và tài khoản. Cần đối chiếu số liệu với database và xác nhận cả Employee/Admin xem được. Báo cáo xác định rõ đây chưa phải báo cáo doanh thu/biểu đồ chuyên sâu. |
| **US7.1 – Đánh giá sản phẩm** | Có code; cần nghiệm thu | `routes/productRoutes.js`, `views/products/detail.ejs`: có điều kiện đơn `completed`, giới hạn điểm 1–5/bình luận 2.000 ký tự và cập nhật review trùng. Cần kiểm thử người chưa mua, đơn chưa hoàn tất, review hợp lệ và cập nhật review cũ. |
| **US7.2 – Wishlist** | Có code; cần nghiệm thu | `routes/wishlistRoutes.js`, `views/wishlist/index.ejs`: có thêm/xóa/xem theo tài khoản và chống bản ghi trùng. Cần kiểm thử Guest bị chuyển đăng nhập, thêm lặp, xóa và dữ liệu giữa các tài khoản. |
| **US7.3 – Trợ lý gợi ý sản phẩm** | Đã chỉnh; cần nghiệm thu | `routes/assistantRoutes.js`, `utils/recommendations.js`, `public/js/assistant.js`: từ chối câu hỏi trên 200 ký tự, lọc từ khóa không liên quan, giữ giới hạn 3 sản phẩm. Cần kiểm thử JSON, câu rỗng/quá dài, ngân sách và từ khóa/danh mục. |
| **US8.1 – Kiểm thử nghiệm thu** | **Đã chuẩn bị; UAT chưa chạy** | Có `npm test` với unit tests và kiểm tra cú pháp EJS; checklist theo vai trò ở `docs/ACCEPTANCE_TEST_CHECKLIST.md`. Cần chạy checklist trên DB riêng, ghi ngày/kết quả/bằng chứng và xác minh tồn kho/đơn đồng thời. |
| **US8.2 – Triển khai sản phẩm** | **Cấu hình sẵn; deploy chưa chạy** | Có `railway.json`, `.env.railway.example`, health endpoint `/healthz`, hỗ trợ Railway MySQL, session lưu trong MySQL và cấu hình `UPLOAD_DIR`. Cần tạo Railway services/volume, khai báo secret, import schema, deploy, smoke-test và ghi URL thực tế. |

## 3. Việc cần hoàn thành theo thứ tự ưu tiên

### Ưu tiên 1 — Hoàn thành US8.1: kiểm thử nghiệm thu

1. Chạy `npm test`.
2. Chuẩn bị database kiểm thử riêng; áp dụng đúng schema/migration và có dữ liệu cho các vai trò, sản phẩm, tồn kho, đơn hàng.
3. Chạy checklist ở [docs/ACCEPTANCE_TEST_CHECKLIST.md](./docs/ACCEPTANCE_TEST_CHECKLIST.md) cho Guest, Customer, Employee, Admin và mọi vai trò.
4. Với từng ca, ghi **ngày chạy, dữ liệu/điều kiện đầu vào, kết quả thực tế, Đạt/Không đạt, lỗi phát hiện và bằng chứng**. Không chỉ ghi kết quả mong đợi.
5. Chạy các tình huống rủi ro: nhiều checkout đồng thời; hai nhân viên thao tác cùng đơn; tồn kho sau đặt/hủy; ảnh sau deploy; đăng nhập lại sau đổi mật khẩu.
6. Chỉ cập nhật trạng thái story/Definition of Done sau khi các tiêu chí chấp nhận có kết quả kiểm thử tương ứng.

### Ưu tiên 2 — Hoàn thành US8.2: triển khai

1. Tạo Railway project, deploy repository và thêm MySQL service.
2. Thêm biến theo `.env.railway.example`; thay tham chiếu `${{MySQL...}}` theo tên service thực tế và tự tạo `SESSION_SECRET` ngẫu nhiên, không dùng giá trị mẫu.
3. Chọn database được Railway cấp, sao lưu trước khi cập nhật và import `database/schema.sql` vào đúng database đó.
4. Gắn Railway Volume tại `/app/data`; đặt `UPLOAD_DIR=/app/data/images/products`.
5. Tạo admin ban đầu bằng `npm run admin:create` với biến `ADMIN_NAME`, `ADMIN_EMAIL`, `ADMIN_PASSWORD` tạm thời; xóa biến mật khẩu sau khi chạy.
6. Đợi health check `/healthz` thành công; kiểm tra HTTPS/cookie secure. Schema không tạo mật khẩu admin mặc định.
7. Chạy smoke-test đăng ký/đăng nhập, đổi mật khẩu, mua hàng, xem/hủy đơn, phân quyền Employee/Admin và kiểm tra tồn kho/ảnh sau restart.
8. Ghi URL, ngày deploy, cấu hình/migration đã áp dụng, kết quả smoke-test và lỗi còn tồn tại vào báo cáo; thay placeholder ở mục 3.4.

### Ưu tiên 3 — Hoàn thiện hồ sơ báo cáo

- Thay các placeholder `[Họ tên SV – Mã SV]`, `[Họ tên giảng viên]` và phản hồi PO/giảng viên bằng thông tin thực tế.
- Cập nhật hình ảnh minh họa bằng ảnh chụp giao diện thực tế; đặc biệt không trình bày US8.1/US8.2 như đã nghiệm thu/triển khai khi chưa có bằng chứng.
- Thêm kết quả thực tế của checklist ở Phụ lục A, không chỉ để lại test case và kết quả mong đợi.
- Sau khi hoàn tất, đồng bộ trạng thái giữa Product Backlog, Sprint Backlog, phần kết luận, Phụ lục và lộ trình trong repository.

## 4. Phạm vi và giới hạn rà soát

Đã thực hiện sửa đổi mã nguồn và chạy kiểm tra tự động trong môi trường local. Chưa kết nối/chạy trên database kiểm thử, chưa thực hiện UAT trên trình duyệt và chưa kiểm tra Railway thật; vì vậy không đánh dấu US8.1/US8.2 là đã nghiệm thu/triển khai. Không có secrets hay cấu hình riêng tư nào được đưa vào tài liệu/repository.
