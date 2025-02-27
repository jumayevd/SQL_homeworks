CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100)
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE
);

CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY,
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
    ProductID INT,
    Quantity INT,
    Price DECIMAL(10,2)
);

CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50)
);


-- Insert data into Customers table
INSERT INTO Customers (CustomerID, CustomerName) VALUES
(1, 'John Doe'),
(2, 'Jane Smith'),
(3, 'Alice Johnson'),
(4, 'Bob Brown'),
(5, 'Charlie Davis'),
(6, 'Eva Green'); -- Customer with no orders

-- Insert data into Products table
INSERT INTO Products (ProductID, ProductName, Category) VALUES
(101, 'Laptop', 'Electronics'),
(102, 'Smartphone', 'Electronics'),
(103, 'Tablet', 'Electronics'),
(104, 'Headphones', 'Accessories'),
(105, 'Keyboard', 'Accessories'),
(106, 'Notebook', 'Stationery'),
(107, 'Pen', 'Stationery');

-- Insert data into Orders table
INSERT INTO Orders (OrderID, CustomerID, OrderDate) VALUES
(1001, 1, '2023-10-01'),
(1002, 2, '2023-10-02'),
(1003, 3, '2023-10-03'),
(1004, 4, '2023-10-04'),
(1005, 5, '2023-10-05'),
(1006, 1, '2023-10-06'), -- John Doe places a second order
(1007, 2, '2023-10-07'); -- Jane Smith places a second order

-- Insert data into OrderDetails table
INSERT INTO OrderDetails (OrderDetailID, OrderID, ProductID, Quantity, Price) VALUES
(2001, 1001, 101, 1, 1200.00), -- Laptop
(2002, 1001, 104, 2, 50.00),    -- Headphones
(2003, 1002, 102, 1, 800.00),    -- Smartphone
(2004, 1003, 103, 1, 600.00),    -- Tablet
(2005, 1004, 105, 1, 100.00),    -- Keyboard
(2006, 1005, 101, 1, 1200.00),   -- Laptop
(2007, 1005, 102, 1, 800.00),    -- Smartphone
(2008, 1006, 106, 5, 10.00),     -- Notebook (Stationery)
(2009, 1006, 107, 10, 2.00),     -- Pen (Stationery)
(2010, 1007, 101, 1, 1200.00);   -- Laptop



-- Retrieve All Customers With Their Orders (Include Customers Without Orders)
SELECT c.CustomerID, c.CustomerName, o.OrderID, o.OrderDate
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID;

-- Find Customers Who Have Never Placed an Order
SELECT c.CustomerID, c.CustomerName
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderID IS NULL;

-- List All Orders With Their Products
SELECT od.OrderID, od.ProductID, p.ProductName, od.Quantity
FROM OrderDetails od
JOIN Products p ON od.ProductID = p.ProductID;

-- Find Customers With More Than One Order
SELECT c.CustomerID, c.CustomerName, COUNT(o.OrderID) AS OrderCount
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.CustomerName
HAVING COUNT(o.OrderID) > 1;

-- Find the Most Expensive Product in Each Order
SELECT od.OrderID, p.ProductName, od.Price
FROM OrderDetails od
JOIN Products p ON od.ProductID = p.ProductID
WHERE (od.OrderID, od.Price) IN (
    SELECT OrderID, MAX(Price) 
    FROM OrderDetails 
    GROUP BY OrderID
);

-- Find the Latest Order for Each Customer
SELECT c.CustomerID, c.CustomerName, 
       COALESCE(MAX(o.OrderDate), 'No Orders') AS LatestOrderDate
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.CustomerName;

-- Find Customers Who Ordered Only 'Electronics' Products
SELECT c.CustomerID, c.CustomerName
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
GROUP BY c.CustomerID, c.CustomerName
HAVING COUNT(DISTINCT CASE WHEN p.Category <> 'Electronics' THEN p.Category END) = 0;

-- Find Customers Who Ordered at Least One 'Stationery' Product
SELECT DISTINCT c.CustomerID, c.CustomerName
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
WHERE p.Category = 'Stationery';

-- Find Total Amount Spent by Each Customer
SELECT c.CustomerID, c.CustomerName, 
       COALESCE(SUM(od.Quantity * od.Price), 0) AS TotalSpent
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
LEFT JOIN OrderDetails od ON o.OrderID = od.OrderID
GROUP BY c.CustomerID, c.CustomerName
ORDER BY TotalSpent DESC;

-- Suggested Indexes for Performance Optimization
CREATE INDEX idx_orders_customer ON Orders(CustomerID);
CREATE INDEX idx_orderdetails_order ON OrderDetails(OrderID);
CREATE INDEX idx_orderdetails_product ON OrderDetails(ProductID);
CREATE INDEX idx_products_category ON Products(Category);