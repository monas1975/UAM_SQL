-- Zad.1.
-- Bez CTE:
SELECT P.ProductID, P.ProductName
FROM Products P
WHERE UnitPrice >
(
	SELECT AVG(UnitPrice)
	FROM Products P1
	WHERE P.CategoryID = P1.CategoryID
)
ORDER BY P.UnitPrice

-- Z CTE:
WITH AvgUnitPriceInCategory AS
(
	SELECT CategoryID, AVG(UnitPrice) AS AvgUnitPrice
	FROM Products
	GROUP BY CategoryID
)
SELECT P.ProductID, P.ProductName
FROM Products P 
WHERE UnitPrice > (
	SELECT AvgUnitPrice
	FROM AvgUnitPriceInCategory A
	WHERE P.CategoryID = A.CategoryID
)
ORDER BY P.UnitPrice