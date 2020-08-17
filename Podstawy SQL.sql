SELECT	COUNT(*)
FROM	Orders
WHERE	ShipRegion NOT IN (SELECT ShipRegion FROM Orders WHERE CustomerID = 'HANAR')

SELECT  COUNT(*) 
FROM	Orders O
WHERE	NOT EXISTS (
	SELECT	1
	FROM	Orders P
	WHERE	P.CustomerID = 'HANAR'
	AND		O.ShipRegion = P.ShipRegion)
	
SELECT COUNT(*) FROM Orders WHERE ShipRegion IS NULL

-- Zad. 8. p. Tomek

select count(*)
 from dbo.orders ox
 where not exists (
select 'as'
 from dbo.employees e
    join dbo.orders o on e.employeeid = o.employeeid
where lastname = 'King'
 and firstname = 'Robert'
 and ox.shipregion = o.shipregion
 --group by o.shipregion
 );
 
 
 --Zad. 9. p. Remigiusz

select distinct ShipCountry from Orders where ShipRegion is not null
INTERSECT
select distinct  ShipCountry from Orders where ShipRegion is null;

-- Zad. 9 p. Marcin

SELECT DISTINCT O1.ShipCountry FROM Orders O1
WHERE EXISTS (SELECT 1 FROM Orders O2 WHERE O2.ShipCountry=O1.ShipCountry 
AND O2.ShipRegion IS NULL)
AND EXISTS (SELECT 1 FROM Orders O2 WHERE O2.ShipCountry=O1.ShipCountry 
AND O2.ShipRegion IS NOT NULL)

-- Zad.10. - p. Marcin

SELECT DISTINCT P1.ProductID, P1.ProductName, S1.Country AS SupplierCountry, S1.City AS SupplierCity, O1.ShipCountry, O1.ShipCity,
CASE
WHEN S1.City = O1.ShipCity
THEN 'Y'
ELSE 'N'
END AS FullMatch
FROM
Products P1 INNER JOIN Suppliers S1 ON P1.SupplierID=S1.SupplierID
INNER JOIN [Order Details] OD1 ON P1.[ProductID] = OD1.[ProductID]
INNER JOIN Orders O1 ON OD1.OrderID = O1.OrderID
WHERE
EXISTS (SELECT 1 FROM ORDERS WHERE [ShipCountry]=O1.[ShipCountry] 
AND [ShipCountry]=S1.Country)
ORDER BY FullMatch DESC, ProductName

--zad9. p. Maciej
select o.ShipCountry
FROM Orders o 
inner join Orders o2 on  o.ShipCountry =  o2.ShipCountry
and o.ShipRegion is not null  and o2.ShipRegion is null
group by o.ShipCountry