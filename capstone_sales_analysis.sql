-- Table Creations 
-- customers table
CREATE TABLE Customers (
    CustomerID VARCHAR(10) PRIMARY KEY,
    CompanyName VARCHAR(100) NOT NULL,
    City VARCHAR(50),
    Country VARCHAR(50)
);


-- employees tables
Drop Table Employees cascade
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    LastName VARCHAR(50),
    FirstName VARCHAR(50),
    Title VARCHAR(100),
    TitleOfCourtesy VARCHAR(25),
    BirthDate DATE,
    HireDate DATE,
    Address VARCHAR(255),
    City VARCHAR(50),
    Region VARCHAR(50),
    PostalCode VARCHAR(20),
    Country VARCHAR(50)
);

select * from employees
-- Shippers
CREATE TABLE Shippers (
    ShipperID INT PRIMARY KEY,
    CompanyName VARCHAR(100),
    Phone VARCHAR(20)
);

-- orders
drop table orders cascade
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID VARCHAR(10),
    EmployeeID INT,
    OrderDate DATE,
    RequiredDate DATE,
    ShippedDate DATE,
    ShipVia INT,
    Freight DECIMAL(10,2),
    ShipCountry VARCHAR(50),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
    FOREIGN KEY (ShipVia) REFERENCES Shippers(ShipperID)
);


-- order_details
CREATE TABLE Order_Details (
    OrderID INT,
    ProductID INT,
    UnitPrice DECIMAL(10,2),
    Quantity INT,
    Discount DECIMAL(4,2),
    PRIMARY KEY (OrderID, ProductID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- products
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    SupplierID INT,
    CategoryID INT,
    QuantityPerUnit VARCHAR(50),
    UnitPrice DECIMAL(10,2),
    UnitsInStock INT,
    UnitsOnOrder INT,
    ReorderLevel INT,
    Discontinued BIT,
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID),
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- suppliers
CREATE TABLE Suppliers (
    SupplierID INT PRIMARY KEY,
    CompanyName VARCHAR(100),
    City VARCHAR(50),
    Country VARCHAR(50)
);

-- categories
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(100),
    Description VARCHAR(255)
);




-- checking the columns and importing the data 
select * from customers
select * from employees
select * from orders
select * from Shippers
select * from products
select * from order_details
select * from suppliers
select * from categories




-- EDA Questions
-- What is the average number of orders per customer? Are there high-value repeat customers?

-- first part
select round(AVG(order_count),2) as avg_orders_per_customer
from(select 
			c.customerid,
			count(o.orderid) as order_count
			from orders o 
			join customers c on o.customerid = c.customerid
			group by 1 
			order by 2 desc) as g


-- second part
select	 c.customerid ,
		c.companyname,
		Count(o.orderid) as TotalOrder,
		SUM(od.quantity*od.unitprice*(1-discount)) as TotalAmount
	From customers c
	join Orders o on c.customerid = o.customerid
	join order_details  od on o.orderid = od.orderid
	Group by c.customerid ,c.companyname
	having Count(o.orderid) > 1 -- for repeating customers
	order by TotalAmount desc
	limit 10;

-- 2.What is the trend in customer orders over time? Use line chart or area chart to visualize.

	select 
			DATE_TRUNC('month', o.orderdate) AS OrderMonth,
			COUNT(o.orderid) as TotalOrders,
			round(SUM(od.quantity * od.unitprice * (1-od.discount)),2) as TotalRevenue 
			from customers c
			join orders o on c.customerid = o.customerid
			join order_details od on o.orderid = od.orderid
			group by 1
			order by TotalRevenue desc



SELECT 
    TO_CHAR(o.orderdate, 'Month') AS MonthName,
    EXTRACT(MONTH FROM o.orderdate) AS MonthNum,
    COUNT(DISTINCT o.orderid) AS TotalOrders,
    Round(SUM(od.quantity * od.unitprice * (1 - od.discount)),1) AS TotalRevenue
FROM orders o
JOIN order_details od ON o.orderid = od.orderid
GROUP BY MonthName, MonthNum
ORDER BY MonthNum;


-- 3.Can we cluster customers based on total spend, order count, and preferred categories?

select	 c.customerid ,
		c.companyname,
		cc.Categoryname,
		Count(o.orderid) as TotalOrder,
		round(SUM(od.quantity*od.unitprice*(1-discount)),2) as Totalspend
	From customers c
	join Orders o on c.customerid = o.customerid
	join order_details  od on o.orderid = od.orderid
	join products p on od.productid = p.productid
	join categories cc on p.categoryid = cc.categoryid
	Group by c.customerid ,c.companyname,cc.Categoryname
	order by Totalspend desc
	limit 10;




--4. Which product categories or products contribute most to order revenue?
-- Are there any correlations between orders and customer location or product category?

select * from products
select * from categories
select * from order_details


select 	c.city as City,
		cc.categoryname as productCategory,
		round(sum(od.unitprice * od.Quantity * (1-od.Discount)),2) as "OrderRevenue"
		from customers c 
		join orders o on c.customerid = o.customerid
		join
		order_details od on o.orderid = od.orderid
		join 
		products p on od.productid = p.productid
		join 
		categories cc on p.categoryid = cc.categoryid
		group by 1,2
		order by "OrderRevenue" desc;

-- second approach
		SELECT  
    c.city AS City,
    SUM(CASE WHEN cc.categoryname = 'Beverages' 
             THEN od.unitprice * od.Quantity * (1 - od.Discount) ELSE 0 END) AS BeveragesRevenue,
    SUM(CASE WHEN cc.categoryname = 'Condiments' 
             THEN od.unitprice * od.Quantity * (1 - od.Discount) ELSE 0 END) AS CondimentsRevenue,
    SUM(CASE WHEN cc.categoryname = 'Confections' 
             THEN od.unitprice * od.Quantity * (1 - od.Discount) ELSE 0 END) AS ConfectionsRevenue,
    SUM(CASE WHEN cc.categoryname = 'Dairy Products' 
             THEN od.unitprice * od.Quantity * (1 - od.Discount) ELSE 0 END) AS DairyRevenue,
    SUM(CASE WHEN cc.categoryname = 'Grains/Cereals' 
             THEN od.unitprice * od.Quantity * (1 - od.Discount) ELSE 0 END) AS GrainsRevenue,
    SUM(CASE WHEN cc.categoryname = 'Meat/Poultry' 
             THEN od.unitprice * od.Quantity * (1 - od.Discount) ELSE 0 END) AS MeatRevenue,
    SUM(CASE WHEN cc.categoryname = 'Produce' 
             THEN od.unitprice * od.Quantity * (1 - od.Discount) ELSE 0 END) AS ProduceRevenue,
    SUM(CASE WHEN cc.categoryname = 'Seafood' 
             THEN od.unitprice * od.Quantity * (1 - od.Discount) ELSE 0 END) AS SeafoodRevenue
FROM customers c
JOIN orders o 
    ON c.customerid = o.customerid
JOIN order_details od 
    ON o.orderid = od.orderid
JOIN products p 
    ON od.productid = p.productid
JOIN categories cc 
    ON p.categoryid = cc.categoryid
GROUP BY c.city
ORDER BY City;




-- 5.How frequently do different customer segments place orders?

-- Get customer stats
WITH customer_stats AS (
    SELECT 
        c.CustomerID,
        COUNT(o.OrderID) AS TotalOrders,
        SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) AS TotalRevenue
    FROM Customers c
    JOIN Orders o ON c.CustomerID = o.CustomerID
    JOIN Order_Details od ON o.OrderID = od.OrderID
    GROUP BY c.CustomerID
)

-- Segment + Frequency
SELECT 
    CASE 
        WHEN TotalRevenue >= 10000 THEN 'High Spender'
        WHEN TotalRevenue BETWEEN 5000 AND 9999 THEN 'Medium Spender'
        ELSE 'Low Spender'
    END AS CustomerSegment,
    AVG(TotalOrders) AS AvgOrders,
    SUM(TotalOrders) AS TotalOrders
FROM customer_stats
GROUP BY 
    CASE 
        WHEN TotalRevenue >= 10000 THEN 'High Spender'
        WHEN TotalRevenue BETWEEN 5000 AND 9999 THEN 'Medium Spender'
        ELSE 'Low Spender'
    END;



-- 6.What is the geographic and title-wise distribution of employees?

SELECT * from employees

Select  Title,
		country,
		count(employeeid) as TotalEmployees
		from employees
		group by 1,2
		order by TotalEmployees desc



--7.What trends can we observe in hire dates across employee titles?

select * from products

Select Title as Employees_Roles,
		Extract(year From hiredate) as HireYear,
		Count(employeeid) as TotalEmployees
		from Employees
		group by 1,2
		order by TotalEmployees desc
		


-- 8.What patterns exist in employee title and courtesy title distributions?

SELECT 
    Title,
    TitleOfCourtesy,
    COUNT(*) AS EmployeeCount
FROM Employees
GROUP BY Title, TitleOfCourtesy
ORDER BY Title, EmployeeCount DESC;



--9.Are there correlations between product pricing, stock levels, and sales performance?

SELECT p.productid,
		p.productname,
		p.unitprice,     --product pricing
		p.unitsinstock,
		SUM(od.quantity) as TotalQuantity, -- total quantity been ordered
		ROund(SUM( od.Unitprice * od.quantity * (1-Discount)),1) as "TotalRevenue" -- sales performance 
		FROM products p
		join order_details as od on p.productid = od.productid
		group by 1,2,3,4
		order by "TotalRevenue" desc



-- 10.How does product demand change over months or seasons?

select TO_CHAR(o.orderdate, 'Month') AS monthname,
    EXTRACT(MONTH FROM o.orderdate) AS monthnum,
    EXTRACT(YEAR FROM o.orderdate) AS yearnum,
		SUM(od.Quantity) as TotalUnitsold,
		ROUND(Sum( od.unitprice * od.quantity * (1-Discount)),2) as TotalRevenue
		from Orders o
		join
		order_details od on o.orderid = od.orderid
		group by 1,2,3
		ORDER BY yearnum desc, monthnum;





-- 11.Can we identify anomalies in product sales or revenue performance?
WITH product_revenue AS (
    SELECT 
        p.productid,
        p.productname,
        c.categoryname,
        Round(SUM(od.quantity * od.unitprice * (1 - od.discount)),2) AS totalrevenue
    FROM products p
    JOIN categories c ON p.categoryid = c.categoryid
    JOIN order_details od ON p.productid = od.productid
    GROUP BY p.productid, p.productname, c.categoryname
),
category_stats AS (
    SELECT 
        categoryname,
        round(AVG(totalrevenue),2) AS avg_revenue,
        STDDEV(totalrevenue) AS stddev_revenue
    FROM product_revenue
    GROUP BY categoryname
)
SELECT 
    pr.productid,
    pr.productname,
    pr.categoryname,
    pr.totalrevenue,
    cs.avg_revenue,
    cs.stddev_revenue,
    CASE 
        WHEN pr.totalrevenue > cs.avg_revenue + 2*cs.stddev_revenue THEN 'High Anomaly'
        WHEN pr.totalrevenue < cs.avg_revenue - 2*cs.stddev_revenue THEN 'Low Anomaly'
        ELSE 'Normal'
    END AS anomaly_flag
FROM product_revenue pr
JOIN category_stats cs ON pr.categoryname = cs.categoryname
ORDER BY pr.categoryname, pr.totalrevenue DESC;


-- second Approach
SELECT 
    p.productid,
    p.productname,
    c.categoryname,
    SUM(od.quantity * od.unitprice * (1 - od.discount)) AS total_revenue,
    AVG(SUM(od.quantity * od.unitprice * (1 - od.discount))) OVER (PARTITION BY c.categoryname) AS avg_revenue,
    CASE 
        WHEN SUM(od.quantity * od.unitprice * (1 - od.discount)) > 
             2 * AVG(SUM(od.quantity * od.unitprice * (1 - od.discount))) OVER (PARTITION BY c.categoryname)
        THEN 'High Anomaly'
        WHEN SUM(od.quantity * od.unitprice * (1 - od.discount)) < 
             0.5 * AVG(SUM(od.quantity * od.unitprice * (1 - od.discount))) OVER (PARTITION BY c.categoryname)
        THEN 'Low Anomaly'
        ELSE 'Normal'
    END AS anomaly_flag
FROM products p
JOIN categories c ON p.categoryid = c.categoryid
JOIN order_details od ON p.productid = od.productid
GROUP BY p.productid, p.productname, c.categoryname
ORDER BY c.categoryname, total_revenue DESC;


-- 12.Are there any regional trends in supplier distribution and pricing?

select * from suppliers
select * from products

SELECT 
    s.country,
    s.city,
    ROUND(AVG(p.unitprice), 2) AS avg_price,
    COUNT(DISTINCT s.supplierid) AS total_suppliers,
    COUNT(p.productid) AS total_products
FROM suppliers s
JOIN products p 
    ON s.supplierid = p.supplierid
GROUP BY s.country, s.city
ORDER BY avg_price DESC;


-- 13.How are suppliers distributed across different product categories?


SELECT 
    c.categoryname AS ProductCategory,
    COUNT(DISTINCT s.supplierid) AS TotalSuppliers
FROM suppliers s
JOIN products p ON s.supplierid = p.supplierid
JOIN categories c ON p.categoryid = c.categoryid
GROUP BY c.categoryname
ORDER BY TotalSuppliers DESC;


-- 14.How do supplier pricing and categories relate across different regions?									

SELECT 
    s.country AS Region,
    c.categoryname AS Category,
    ROUND(AVG(p.unitprice), 2) AS AvgPrice,
    MIN(p.unitprice) AS MinPrice,
    MAX(p.unitprice) AS MaxPrice,
    COUNT(p.productid) AS TotalProducts,
    COUNT(DISTINCT s.supplierid) AS TotalSuppliers
FROM suppliers s
JOIN products p ON s.supplierid = p.supplierid
JOIN categories c ON p.categoryid = c.categoryid
GROUP BY s.country, c.categoryname
ORDER BY s.country, AvgPrice DESC;



