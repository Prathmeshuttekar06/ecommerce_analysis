-- Ecommerce analytics queries

-- 1. Total number of customers
SELECT COUNT(*) AS total_customers
FROM customers;

-- 2. Total revenue from all successful payments
SELECT COALESCE(SUM(amount), 0) AS total_revenue
FROM payments;

-- 3. Revenue by month
SELECT DATE_FORMAT(payment_date, '%Y-%m') AS month,
       COALESCE(SUM(amount), 0) AS revenue
FROM payments
GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
ORDER BY month;

-- 4. Top-selling product categories by revenue
SELECT c.category_name,
       ROUND(SUM(oi.quantity * p.price), 2) AS total_sales
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
JOIN categories c ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name
ORDER BY total_sales DESC;

-- 5. Best-selling products
SELECT p.product_name,
       SUM(oi.quantity) AS units_sold,
       ROUND(SUM(oi.quantity * oi.price), 2) AS revenue
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY revenue DESC;

-- 6. Top customers by lifetime value
SELECT c.customer_id,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       COUNT(DISTINCT o.order_id) AS total_orders,
       ROUND(COALESCE(SUM(p.amount), 0), 2) AS lifetime_value
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
LEFT JOIN payments p ON p.order_id = o.order_id
GROUP BY c.customer_id, customer_name
ORDER BY lifetime_value DESC;

-- 7. Order status distribution
SELECT status,
       COUNT(*) AS order_count
FROM orders
GROUP BY status
ORDER BY order_count DESC;

-- 8. Return rate by order
SELECT COUNT(DISTINCT o.order_id) AS total_orders,
       COUNT(DISTINCT r.order_id) AS returned_orders,
       ROUND((COUNT(DISTINCT r.order_id) / COUNT(DISTINCT o.order_id)) * 100, 2) AS return_rate_percent
FROM orders o
LEFT JOIN returns r ON r.order_id = o.order_id;

-- 9. Average order value
SELECT ROUND(COALESCE(AVG(total_amount), 0), 2) AS avg_order_value
FROM orders;

-- 10. Recent orders with payment details
SELECT o.order_id,
       o.order_date,
       o.status,
       o.total_amount,
       p.payment_method,
       p.amount AS payment_amount
FROM orders o
LEFT JOIN payments p ON p.order_id = o.order_id
ORDER BY o.order_date DESC;
