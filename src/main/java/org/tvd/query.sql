USE storedatabase;

# 1. Lấy thông tin tất cả các sản phẩm đã được đặt trong một đơn đặt hàng cụ thể.
SELECT od.product_id, p.product_name, p.price, od.quantity
FROM orders AS o
    JOIN orderdetails AS od
ON O.order_id =od.order_id
JOIN products AS p
ON od.product_id = p.product_id
WHERE o.order_id = 301;

# 2. Tính tổng số tiền trong một đơn đặt hàng cụ thể.
SELECT o.order_id, SUM(p.price * od.quantity)
FROM orders AS o
JOIN orderdetails AS od
ON o.order_id = od.order_id
JOIN products AS p
     ON od.product_id = p.product_id
WHERE o.order_id = 301;

# 3. Lấy danh sách các sản phẩm chưa có trong bất kỳ đơn đặt hàng nào.
SELECT *
FROM products
WHERE product_id NOT IN (
    SELECT p.product_id
    FROM products AS p
    JOIN orderdetails AS od
    ON p.product_id = od.product_id
    GROUP BY P.product_id
);
# 4. Đếm số lượng sản phẩm trong mỗi danh mục. (category_name, total_products)
SELECT category_name, COUNT(P.product_id)
FROM categories AS c
         JOIN products AS p
              ON c.category_id = p.category_id
GROUP BY category_name;

# 5. Tính tổng số lượng sản phẩm đã đặt bởi mỗi khách hàng (customer_name, total_ordered)
SELECT c.customer_id, c.customer_name, SUM(temp.s_quantity) AS total_ordered
FROM customers AS c
         JOIN (
    SELECT o.customer_id, SUM(od.quantity) AS s_quantity
    FROM orders AS o
             JOIN orderdetails AS od
                  ON o.order_id = od.order_id
    GROUP BY o.order_id
) AS temp
              ON c.customer_id = temp.customer_id
GROUP BY c.customer_id, c.customer_name; #(Thêm customer_id để tránh trùng tên)

# 6. Lấy thông tin danh mục có nhiều sản phẩm nhất (category_name, product_count)
WITH CategoryProductCounts AS (
    SELECT c.category_name, COUNT(p.product_id) AS product_count
    FROM categories AS c
    LEFT JOIN products AS p
        ON c.category_id = p.category_id
    GROUP BY c.category_name
),

MaxProductCount AS (
    SELECT MAX(product_count) AS max_count
    FROM CategoryProductCounts
     )
SELECT cpc.category_name, cpc.product_count
FROM CategoryProductCounts AS cpc
         JOIN MaxProductCount AS mpc
              ON cpc.product_count = mpc.max_count;

# 7. Tính tổng số sản phẩm đã được đặt cho mỗi danh mục (category_name, total_ordered)
SELECT category_name, SUM(od.quantity) AS total_ordered
FROM orderdetails AS od
         JOIN products AS p
              ON od.product_id = p.product_id
         JOIN categories AS c
              ON p.category_id = c.category_id
GROUP BY category_name;

# 8. Lấy thông tin về top 3 khách hàng có số lượng sản phẩm đặt hàng lớn nhất (customer_id, customer_name, total_ordered)
SELECT c.customer_id, c.customer_name, SUM(temp.s_quantity) AS total_ordered
FROM customers AS c
         JOIN (
    SELECT o.customer_id, SUM(od.quantity) AS s_quantity
    FROM orders AS o
             JOIN orderdetails AS od
                  ON o.order_id = od.order_id
    GROUP BY o.order_id
) AS temp
              ON c.customer_id = temp.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_ordered DESC
    LIMIT 3;

SELECT * FROM orders
                  # 9. Lấy thông tin về khách hàng đã đặt hàng nhiều hơn một lần trong khoảng thời gian cụ thể từ ngày A -> ngày B (customer_id, customer_name, total_orders)
SELECT c.customer_id, customer_name, COUNT(o.order_id) AS total_odered
FROM customers AS c
         JOIN orders AS o
              ON c.customer_id = o.customer_id
WHERE order_date BETWEEN '2023-08-01' AND '2023-08-04'
GROUP BY c.customer_id
HAVING total_odered > 1;

# 10. Lấy thông tin về các sản phẩm đã được đặt hàng nhiều lần nhất và số lượng đơn đặt hàng tương ứng (product_id, product_name, total_ordered)
WITH ProductSales AS (
    SELECT p.product_id, p.product_name, SUM(od.quantity) AS total_sold
    FROM products AS p
    JOIN orderdetails AS od
        ON p.product_id = od.product_id
    GROUP BY p.product_id, p.product_name
),
MaxSales AS (
    SELECT MAX(total_sold) AS max_sold
    FROM ProductSales
)

SELECT ps.product_id, ps.product_name, ps.total_sold
FROM ProductSales AS ps
         JOIN MaxSales AS ms
              ON ps.total_sold = ms.max_sold;
