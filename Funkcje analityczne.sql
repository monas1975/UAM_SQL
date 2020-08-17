-- Zad. 7.
SELECT O.OrderID, C.CompanyName,
ROW_NUMBER() OVER (ORDER BY O.OrderDate ASC) as rowNum
FROM Orders O JOIN Customers C
ON O.CustomerID = C.CustomerID
ORDER BY O.OrderID 