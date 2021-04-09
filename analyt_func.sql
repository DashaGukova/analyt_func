USE AdventureWorks2019
GO
SELECT result.Name, SUM(result.Total) 
FROM (SELECT p.Name, 
		SUM(d.LineTotal) AS Total, 
		NTILE(10) OVER (ORDER BY SUM(d.LineTotal)) AS Blocks 
	  FROM Sales.SalesOrderHeader AS h
JOIN Sales.SalesOrderDetail AS d
	ON h.SalesOrderID = d.SalesOrderID
JOIN Production.Product AS p 
	ON d.ProductID = p.ProductID
	  WHERE h.OrderDate >= '2013-01-01' AND h.OrderDate < '2013-02-01'
	  GROUP BY p.Name) AS result
WHERE Blocks > 1 AND Blocks < 10;
GO

----------------------------------

SELECT result.*
FROM (SELECT p.Name,
		p.ListPrice,
        MIN(p.ListPrice) OVER (PARTITION BY p.ProductSubcategoryID ORDER BY p.ListPrice) AS MinPrice
      FROM Production.Product AS p
      WHERE p.ProductSubcategoryID IS NOT NULL
     ) AS result
WHERE result.ListPrice = result.MinPrice;
GO

---------------------------

SELECT result.Name, result.ListPrice
FROM (
    SELECT p.Name,
		p.ListPrice,
        DENSE_RANK() OVER (ORDER BY ListPrice DESC) AS DRank
    FROM Production.Product AS p
    WHERE ProductSubcategoryID = 1
    ) AS result
WHERE result.DRank = 2;
GO

----------------------------

SELECT result.ProductCategoryID,
	   result.Total,
	  (result.Total - result.Due)/result.Total AS ResultSale
FROM (SELECT c.ProductCategoryID,
		SUM(d.LineTotal) AS Total,
		Year(h.DueDate) as DateYear,
		LAG(SUM(h.TotalDue)) OVER (ORDER BY	c.ProductCategoryID) AS Due
	FROM	Sales.SalesOrderHeader AS h
	JOIN	Sales.SalesOrderDetail AS d
		ON	h.SalesOrderID = d.SalesOrderID
	JOIN	Production.Product AS p
		ON	d.ProductID = p.ProductID
	JOIN	Production.ProductSubcategory AS sc
		ON	p.ProductSubcategoryID = sc.ProductSubcategoryID
	JOIN	Production.ProductCategory AS c
		ON	sc.ProductCategoryID = c.ProductCategoryID
	WHERE	YEAR(h.DueDate) between 2013 and 2014 
	GROUP BY	c.ProductCategoryID, Year(h.DueDate)
) AS result
WHERE result.DateYear = 2013;
GO

-----------------------------------

SELECT CONCAT_WS('-', YEAR(h.OrderDate), MONTH(h.OrderDate), DAY(h.OrderDate)) AS DateOrder,
	FIRST_VALUE(MAX(d.LineTotal)) OVER (PARTITION BY h.OrderDate ORDER BY h.OrderDate ) AS MaxSale
FROM Sales.SalesOrderHeader AS h
JOIN Sales.SalesOrderDetail AS d
	ON	h.SalesOrderID = d.SalesOrderID
WHERE YEAR(h.OrderDate) = 2013 AND MONTH(h.OrderDate) = 01
GROUP BY h.OrderDate;
GO

---------------------------------

SELECT s.Name, 
	   FIRST_VALUE(p.Name) OVER (ORDER BY COUNT(p.Name) DESC) AS NameFirst
FROM Sales.SalesOrderHeader	AS h
JOIN Sales.SalesOrderDetail	AS d
	ON h.SalesOrderID = d.SalesOrderID
JOIN Production.Product	AS p
	ON d.ProductID = p.ProductID
JOIN Production.ProductSubcategory AS s
	ON	p.ProductSubcategoryID = s.ProductSubcategoryID
WHERE YEAR(h.DueDate) = 2013 AND MONTH(h.DueDate) = 01
GROUP BY s.Name, p.Name;
GO
