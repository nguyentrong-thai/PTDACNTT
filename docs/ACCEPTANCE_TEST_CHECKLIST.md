# ElectroShop acceptance checklist

Use a disposable test database and separate test accounts. Do not run order or inventory tests against production data. Record the actual result and evidence for each case; the expected result alone is not a test result.

**Execution status:** Not run  
**Environment / URL:**  
**Database snapshot / identifier:**  
**Tester:**  
**Execution date:**  

| ID | Role | Test | Expected result | Actual result / evidence | Status |
|---|---|---|---|---|---|
| US1.1-A | Guest | Register with valid name, email, phone and matching password of at least 8 characters | Account is created with bcrypt hash and user is redirected to login | | Not run |
| US1.1-B | Guest | Register with duplicate email or phone, short password, invalid phone and mismatched confirmation | Account is not created; validation message is shown | | Not run |
| US1.2-A | All roles | Sign in with valid credentials and sign out | Session is created, admin goes to `/admin`, other roles go to the storefront, sign-out destroys the session | | Not run |
| US1.2-B | All roles | Submit invalid credentials repeatedly | Generic credential error; authentication rate limit rejects requests beyond its configured limit | | Not run |
| US1.3-A | Guest | Open `/cart`, `/orders`, `/profile` and `/wishlist` directly | Redirected to login | | Not run |
| US1.3-B | Employee | Open `/admin/products`, `/admin/orders`, `/admin/users` and `/admin/categories` directly | Product/order access allowed; employee management and categories denied | | Not run |
| US1.3-C | Customer | Open `/admin` directly | Access denied | | Not run |
| US2.1-A | Admin | Create, update and delete an unused category | CRUD succeeds and success messages are shown | | Not run |
| US2.1-B | Admin / Employee | Reuse a slug, delete a category with products, open categories as employee | Duplicate and referenced category changes are rejected; employee is denied | | Not run |
| US2.2-A | Employee / Admin | Create and edit a product with JPG/PNG/WebP image | Product is saved; uploaded image is resized and served as WebP | | Not run |
| US2.2-B | Employee / Admin | Upload invalid or over-5-MB file; delete a product referenced by an order | Invalid upload and protected delete are rejected with a useful message | | Not run |
| US2.2-C | Guest | Hide a product and open its store URL | Hidden product is absent from catalog and direct detail returns 404 | | Not run |
| US3.1-A | Guest | Open homepage and product pages 1 and 2 | Active products display, 12 per product-list page, hidden products are excluded | | Not run |
| US3.2-A | Guest | Open active product and nonexistent/hidden product URLs | Product details/reviews display; missing or hidden product returns 404 | | Not run |
| US3.3-A | Guest | Search by name/brand and combine category and brand filters across pages | Matching products are returned and filters remain selected while paging | | Not run |
| US3.3-B | Guest | Search for a term with no matches | Empty-results state is displayed | | Not run |
| US4.1-A | Customer | Add product, update quantity, remove product, sign out and back in | Cart changes persist per account; quantity cannot exceed available stock | | Not run |
| US4.1-B | Customer | Update a cart line after the product is hidden or depleted | Unavailable product cannot be checked out and the user sees a useful prompt | | Not run |
| US4.2-A | Guest / Customer | Use Buy now while signed out and while signed in | Guest returns to checkout after sign-in; signed-in customer enters checkout directly | | Not run |
| US4.2-B | Customer | Buy now while a different regular cart exists, then cancel the buy-now flow | Regular cart remains unchanged | | Not run |
| US5.1-A | Customer | Checkout from regular cart and Buy now with valid shipping details | One pending order is created, prices are snapshotted, inventory decreases, only the checked-out cart data is cleared | | Not run |
| US5.1-B | Customer | Checkout empty cart, invalid shipping details, or stock that became insufficient | No partial order/inventory changes; a specific validation or stock message is shown | | Not run |
| US5.1-C | Two customers | Checkout the final units concurrently | At most available stock is sold; failed transaction leaves no partial order | | Not run |
| US5.2-A | Customer | Filter own order history and open an order from another account | Own history filters/page correctly; other account's order returns 404 | | Not run |
| US5.3-A | Customer | Cancel own pending order, then attempt a second cancellation and cancel a confirmed order | First cancellation returns stock once; subsequent/confirmed cancellation does not change order or stock | | Not run |
| US1.4-A | Customer | Update name, phone and address with valid values, then use another account's phone | Valid update persists; duplicate/invalid phone is rejected | | Not run |
| US1.5-A | Customer | Change password with wrong current password, mismatched confirmation, 7-character and 8-character new passwords | Invalid attempts are rejected; 8-character password succeeds and new login works while old password fails | | Not run |
| US6.1-A | Employee / Admin | Advance pending → confirmed → shipping → completed | Each permitted state transition succeeds | | Not run |
| US6.1-B | Employee / Admin | Attempt backward, skipped and post-completion status changes | Invalid transitions and transitions from terminal states are rejected | | Not run |
| US6.1-C | Two employees | Update the same order concurrently | The final state is one valid transition; no duplicate inventory effect occurs | | Not run |
| US6.2-A | Employee / Admin | Cancel pending and confirmed orders; attempt to cancel shipping order | Allowed cancellations restore each order line's stock once; shipping cancellation is rejected | | Not run |
| US6.3-A | Admin | Create, update and delete employee; try duplicate email/phone and short password | Employee CRUD works; duplicates and passwords shorter than 8 characters are rejected | | Not run |
| US6.3-B | Employee | Open employee-management routes directly | Access is denied server-side | | Not run |
| US6.4-A | Employee / Admin | Compare dashboard counts with database | Active product, order and account counts match | | Not run |
| US7.1-A | Customer | Review before completion, after completion, update an existing review, submit invalid rating/comment | Only completed purchasers may review; rating/comment validation works and each user has one updatable review per product | | Not run |
| US7.2-A | Guest / Customer | Add the same product twice, remove it, and inspect as another account | Guest is asked to sign in; duplicate rows are prevented; removal and account isolation work | | Not run |
| US7.3-A | Guest | Ask with keyword/category/budget, ask for no matching result, submit empty message | JSON contains at most 3 active in-stock products; empty message returns 400 | | Not run |
| US8.1-A | All roles | Submit forms without CSRF token and exceed authentication rate limit | Requests are rejected; no protected action is performed | | Not run |
| US8.2-A | Production | Open deployed URL over HTTPS and inspect health endpoint | Deployment is healthy and `GET /healthz` returns 200 | | Not run |
| US8.2-B | Production | Upload an image, redeploy/restart, and load the image again | Image remains available from the configured persistent volume | | Not run |
| US8.2-C | Production | Run registration/login, password change, checkout, order tracking/cancel and role checks | Smoke-test passes and database inventory/order records remain consistent | | Not run |

## Automated checks

Run `npm test` for the repository's local automated unit and template-compilation checks. These checks do not replace the database-backed role, order, inventory, browser, or production acceptance tests above.
