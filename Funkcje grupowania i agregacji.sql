-- Zad. 9.
SELECT DATEPART(yyyy, O.OrderDate) AS Year, 
C.CompanyName AS Customer,
SUM(OD.UnitPrice * OD.Quantity) AS OrdersValue
FROM Orders O JOIN [Order Details] OD
ON (O.OrderID = OD.OrderID)
JOIN Customers C
ON (C.CustomerID = O.CustomerID)
GROUP BY CUBE(DATEPART(yyyy, O.OrderDate), C.CompanyName)
ORDER BY Customer

-- Zad. 8, p. Remigiusz

/*Korzystając z tabeli Orders przedstaw analizuję liczby zamówień ze względu na wymiary:
• Kraj, region oraz miasto dostawy
• Kraj oraz region dostawy
• Kraj dostawy
• Podsumowanie
Dodaj kolumnę GroupingLevel objaśniającą poziom grupowania, która dla poszczególnych wymiarów przyjmie wartości odpowiednio:
• Country & Region & City
• Country & Region
• Country
• Total
Pole region może posiadać wartości puste – oznacz takie wartości jako „Not Provided”
Wynik posortuj alfabetycznie zgodnie z krajem dostawy.*/

select o.ShipCountry,
case 
when Grouping(o.ShipRegion) = 0 and o.ShipRegion  is null then 'Not Provided'
else o.ShipRegion
end ShipRegion
, o.ShipCity, count(o.OrderID),
GROUPING_ID(o.ShipCountry,o.ShipRegion, o.ShipCity),
case 
when GROUPING_ID (o.ShipCountry,o.ShipRegion, o.ShipCity) = 0 then 'Country, region, city'
 when GROUPING_ID (o.ShipCountry,o.ShipRegion, o.ShipCity) = 1 then 'Country, region'
  when GROUPING_ID (o.ShipCountry,o.ShipRegion, o.ShipCity) = 3 then 'Country'
    when GROUPING_ID (o.ShipCountry,o.ShipRegion, o.ShipCity) = 7 then 'total'
	end groupinglevel


from Orders o
group by Rollup( o.ShipCountry, o.ShipRegion,o.ShipCity)
order by 1,2

-- Zad . 11.
select 
k.CategoryName,
s.Country as SuppliersCountry,
c.Country as CustomerConuntry,
c.Region as CustomerRegion,
sum(p.UnitPrice * od.Quantity) as OrdersValue,
case GROUPING_ID (k.CategoryName,s.Country,c.Country,c.Region)
when 7 then 'Category'
when 11 then 'Country - Supplier'
when 12 then 'Country & Region - Customer'
end as GrupingLevel
from Products p
inner join Categories k on k.CategoryID = p.CategoryID
inner join Suppliers s on s.SupplierID = p.SupplierID
inner join [Order Details] od on od.ProductID = p.ProductID
inner join Orders o  on o.OrderID = od.OrderID
inner join Customers c on c.CustomerID = o.CustomerID
group by grouping sets ((k.CategoryName),(s.Country),(c.Country,c.Region))
order by GrupingLevel, OrdersValue desc






