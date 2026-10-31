# Báo cáo rà soát bảo mật

Ngày rà soát: 2026-10-31

Phạm vi: rà soát tĩnh mã nguồn, cấu hình, dependency và đường đi xử lý request. Không sửa mã ứng dụng và không kiểm tra môi trường deploy đang chạy.

## Các vấn đề đã xác nhận và xử lý

| # | Mức độ | File / dòng | Vấn đề | Độ tin cậy |
|---|---|---|---|---:|
| 1 | 🟠 HIGH | [app.js](app.js#L44), [package-lock.json](package-lock.json#L705) | `body-parser@1.20.8` là dependency production bị ảnh hưởng bởi [GHSA-27r3-jxmh-p828](https://github.com/advisories/GHSA-27r3-jxmh-p828). App bật parser JSON và URL-encoded cho request trước khi xử lý route; request được tạo phù hợp có thể làm tiến trình bị crash, gây từ chối dịch vụ. **Đã xử lý:** cập nhật dependency lên bản đã vá, không đổi cách cấu hình parser. | 8/10 |
| 2 | 🟡 MEDIUM | [routes/adminRoutes.js](routes/adminRoutes.js#L282), [middlewares/authMiddleware.js](middlewares/authMiddleware.js#L10), [app.js](app.js#L50), [controllers/authController.js](controllers/authController.js#L112) | Xóa tài khoản nhân viên không thu hồi session hiện có. **Đã xử lý:** middleware staff/admin đọc lại role hiện tại từ database; nếu tài khoản đã bị xóa thì hủy session, nếu quyền đã thay đổi thì dùng role mới để quyết định truy cập. | 9/10 |

## Hướng xử lý ít ảnh hưởng dự án

1. Hai lỗi đã xác nhận được sửa theo hướng tương thích với luồng hiện tại. Chạy kiểm thử/build và `npm audit --omit=dev` trước khi deploy.
2. Triển khai trước trên môi trường staging và kiểm thử đăng nhập, quyền staff/admin, xóa nhân viên, và các endpoint nhận JSON/form.

## Cấu hình cần kiểm tra khi deploy

Các điểm dưới đây chưa được xác minh là lỗ hổng khai thác được; cần kiểm tra cấu hình thực tế trước khi kết luận:

- **Session secret:** file `.env` mẫu đã được bỏ khỏi Git; file môi trường local vẫn được giữ trên máy. Ứng dụng từ chối placeholder khi chạy production. Môi trường deploy vẫn cần đặt secret ngẫu nhiên, riêng tư. Nếu trước đây từng commit secret thật, hãy rotate.
- **TLS kết nối database:** [config/db.js](config/db.js#L4) bật TLS theo `DB_SSL`; xác nhận Render/TiDB hoặc môi trường đang dùng đặt tùy chọn TLS phù hợp và xác minh chứng chỉ. Không thể kết luận kết nối production có TLS hay không từ mã nguồn.
- Repo có hướng dẫn Render/TiDB nhưng cấu hình triển khai được kiểm tra không đủ để xác nhận giá trị secrets, quyền database, trusted proxy, TLS hoặc trạng thái runtime.

## Advisory dependency khác

`ip-address` và `qs` đã được nâng lên bản vá bằng `npm audit fix`. `npm audit --omit=dev` hiện vẫn báo advisory moderate cho `minimatch` thông qua chuỗi `EJS -> Jake -> filelist`; chưa xác minh được đường đi gọi chức năng glob bị ảnh hưởng từ request của ứng dụng. Cách fix tự động được npm đề xuất cần nâng EJS major, có rủi ro tương thích nên chưa áp dụng để tránh gây lỗi ngoài ý muốn. Cần xử lý riêng bằng nâng dependency tương thích và kiểm thử; audit production hiện chưa sạch hoàn toàn.

## Biện pháp đã thấy trong mã nguồn

Rà soát thấy truy vấn SQL có tham số; route quản trị có kiểm tra role; có middleware CSRF; session được regenerate khi đăng nhập; cookie có `HttpOnly`, `SameSite=Lax` và `Secure` trong production; template EJS escape output; một số dữ liệu client được đưa vào DOM bằng `textContent`; upload có giới hạn kích thước và được xử lý lại bằng Sharp; truy vấn đơn hàng được giới hạn theo người dùng.

## Giới hạn

Đây là rà soát tĩnh, không phải kiểm thử xâm nhập hoặc chứng nhận an toàn. Không truy cập Render/TiDB đang chạy, không kiểm tra biến môi trường production, database grants, cấu hình proxy/TLS thực tế hay kiểm thử khai thác trên hệ thống. Các biện pháp đã thấy không đảm bảo rằng không còn lỗi khác.
