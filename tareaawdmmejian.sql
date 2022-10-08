

	--======== Crear una vista de las que muestre un listado de los productos descontinuados========--


	IF OBJECT_ID ('Production.ProductosDescontinuados', 'V') IS NOT NULL  
	DROP VIEW Production.ProductosDescontinuados;  
	GO

	CREATE VIEW Production.ProductosDescontinuados
	AS
	SELECT * FROM Production.Product
	WHERE DiscontinuedDate IS NOT NULL
	GO

	SELECT * FROM Production.ProductosDescontinuados
	GO


	---=========Crea una vista que muestre un listado de productos=============--
	
	IF OBJECT_ID ('Production.ProductosCategoria', 'V') IS NOT NULL  
	DROP VIEW Production.ProductosCategoria;  
	GO

	CREATE VIEW Production.ProductosCategoria
	AS
	(SELECT p.ProductID,
		p.Name AS Producto,
		p.ProductModelID,
		m.Name AS Modelo,
		s.ProductSubcategoryID,
		s.Name AS Subcategoria, 
		c.ProductCategoryID,
		c.Name AS Categoria
		
	FROM Production.Product p
	FULL JOIN Production.ProductModel m ON p.ProductModelID = m.ProductModelID
	LEFT JOIN Production.ProductSubcategory s ON s.ProductSubcategoryID = p.ProductSubcategoryID
	LEFT JOIN Production.ProductCategory c ON c.ProductCategoryID = s.ProductCategoryID)
	GO

	SELECT * FROM Production.ProductosCategoria
	GO


	---=====Crea una consulta que obtenga los datos generales de los empleados 
	--(HumanResources.Employee) del departamento (HumanResources.Department) ‘Document Control’=======---

SELECT p.BusinessEntityID, p.FirstName, p.LastName, h.DepartmentID, d.Name
FROM Person.Person p
INNER JOIN HumanResources.Employee e ON p.BusinessEntityID = e.BusinessEntityID
INNER JOIN HumanResources.EmployeeDepartmentHistory h ON e.BusinessEntityID = h.BusinessEntityID
INNER JOIN HumanResources.Department d ON h.DepartmentID = d.DepartmentID


---Crea un procedimiento que obtenga lista de cumpleañeros del mes ordenados alfabéticamente por el primer apellido y por el nombre del departamento, 
---si no se especifica DepartmentID entonces deberá retornar todos los datos.----
IF EXISTS (
  SELECT * FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'HumanResources'
     AND SPECIFIC_NAME = N'usp_GetInfo' 
)
   DROP PROCEDURE HumanResources.usp_GetInfo
GO

CREATE PROCEDURE HumanResources.usp_GetInfo
	@DepartmentId INT = NULL
AS
	SELECT p.BusinessEntityID AS ID, p.FirstName AS Nombre, p.LastName AS Apellido, 
	e.BirthDate, e.Gender, h.DepartmentID AS IdDepartamento, d.Name AS Departamento
	FROM Person.Person p
	INNER JOIN HumanResources.Employee e ON p.BusinessEntityID = e.BusinessEntityID
	INNER JOIN HumanResources.EmployeeDepartmentHistory h ON e.BusinessEntityID = h.BusinessEntityID
	INNER JOIN HumanResources.Department d ON h.DepartmentID = d.DepartmentID
	WHERE @DepartmentId IS NULL OR @DepartmentId = d.DepartmentID
	ORDER BY d.DepartmentID ASC
GO

EXECUTE HumanResources.usp_GetInfo 15
GO


---=====Crea un procedimiento que obtenga lista de cumpleañeros del mes ordenados alfabéticamente 
--por el primer apellido y por el nombre del departamento====--

IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'HumanResources'
     AND SPECIFIC_NAME = N'usp_GetBirthDate' 
)
   DROP PROCEDURE HumanResources.usp_GetBirthDate
GO

CREATE PROCEDURE HumanResources.usp_GetBirthDate
	@DepartmentId INT = NULL
AS
	SELECT p.FirstName AS Nombre, p.LastName AS Apellido, e.Gender, d.Name AS Departamento, e.BirthDate
	FROM Person.Person p
	INNER JOIN HumanResources.Employee e ON p.BusinessEntityID = e.BusinessEntityID
	INNER JOIN HumanResources.EmployeeDepartmentHistory h ON e.BusinessEntityID = h.BusinessEntityID
	INNER JOIN HumanResources.Department d ON h.DepartmentID = d.DepartmentID
	WHERE @DepartmentId IS NULL OR @DepartmentId = d.DepartmentID AND DATEPART(MONTH, e.BirthDate) = DATEPART(MONTH, GETDATE())
	ORDER BY Apellido, Departamento ASC
GO

EXEC HumanResources.usp_GetBirthDate 



----Crea un procedimiento almacenado que obtenga los datos generales de los empleados por departamento.----
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'HumanResources'
      
)
   DROP PROCEDURE HumanResources
GO

CREATE PROCEDURE HumanResources
	@DepartmentId INT = NULL
AS
	SELECT p.FirstName AS Nombre, p.LastName AS Apellido, e.Gender, d.Name AS Departamento
	FROM Person.Person p
	INNER JOIN HumanResources.Employee e ON p.BusinessEntityID = e.BusinessEntityID
	INNER JOIN HumanResources.EmployeeDepartmentHistory h ON e.BusinessEntityID = h.BusinessEntityID
	INNER JOIN HumanResources.Department d ON h.DepartmentID = d.DepartmentID
	WHERE @DepartmentId IS NULL OR @DepartmentId = d.DepartmentID 
	ORDER BY Apellido, Departamento ASC
GO

EXEC HumanResources


---======Crea un procedimiento que obtenga la cantidad de empleados por 
--departamento ordenados por nombre de departamento, si no se especifica DepartmentID entonces deberá retornar todos los datos======-----

IF EXISTS (
  SELECT * FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'HumanResources'
     AND SPECIFIC_NAME = N'usp_GetGeneralEmployee' 
)
   DROP PROCEDURE HumanResources.usp_GetGeneralEmployee
GO

CREATE PROCEDURE HumanResources.usp_GetGeneralEmployee
	@DepartmentId INT = NULL
AS
	SELECT COUNT (d.DepartmentID) AS CantidadEmpleados 
	FROM Person.Person p
	INNER JOIN HumanResources.Employee e ON p.BusinessEntityID = e.BusinessEntityID
	INNER JOIN HumanResources.EmployeeDepartmentHistory h ON e.BusinessEntityID = h.BusinessEntityID
	INNER JOIN HumanResources.Department d ON h.DepartmentID = d.DepartmentID
	WHERE @DepartmentId IS NULL OR @DepartmentId = d.DepartmentID 
	
GO

EXEC HumanResources.usp_GetGeneralEmployee 


---Cree un procedimiento que obtenga retorne el Id del producto, nombre del producto, cantidad total de ventas (Sales.SalesOrderDetail)---
---monto total de ventas en un rango de fechas (Sales.SalesOrderHeader)---
---El procedimiento debe tener los parámetros @StartDate, @EndDate y 2 parámetros de retorno, los parámetros pueden ser nulos, si no especifican las fechas deberá retornar los datos correspondientes al mes actual---
---El procedimiento debe validar que el rango de fechas sea válido, si el rango es inválido deberá indicarse en los parámetros de retorno---

IF EXISTS (
  SELECT * FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'Sales'
     AND SPECIFIC_NAME = N'usp_Ventas' 
)
   DROP PROCEDURE Sales.usp_Ventas
GO

CREATE PROCEDURE Sales.usp_Ventas
	@StartDate date = NULL,
	@EndDate date = NULL
AS
	IF ((@StartDate IS NOT NULL) AND (@EndDate IS NOT NULL) AND (@EndDate > GETDATE()) OR (@EndDate < '2011-05-31'))
		BEGIN  
			PRINT N'Rango de fechas no válido para mostras datos'  
        RETURN  
		END  
	ELSE IF((@StartDate IS NOT NULL) AND (@EndDate IS NOT NULL))
		SELECT s.ProductID, p.Name, s.OrderQty, s.LineTotal, S.SalesOrderID, h.OrderDate
		FROM Sales.SalesOrderDetail s
		INNER JOIN Production.Product p ON S.ProductID = p.ProductID
		INNER JOIN Sales.SalesOrderHeader h ON s.SalesOrderID = h.SalesOrderID
		WHERE h.OrderDate BETWEEN @StartDate AND @EndDate 	
	ELSE IF((@StartDate IS NULL) AND (@EndDate IS NULL))
		SELECT s.ProductID, p.Name, s.OrderQty, s.LineTotal, S.SalesOrderID, h.OrderDate
		FROM Sales.SalesOrderDetail s
		INNER JOIN Production.Product p ON S.ProductID = p.ProductID
		INNER JOIN Sales.SalesOrderHeader h ON s.SalesOrderID = h.SalesOrderID
		WHERE @StartDate= DATEADD(DAY,1,EOMONTH(GETDATE(),-1)) AND  @EndDate = EOMONTH(GETDATE())
GO

EXEC Sales.usp_Ventas '2006-01-10', '2012-03-10'
GO


---====Cree una función que obtenga retorne el Id del producto, nombre del producto, 
--cantidad total de ventas, monto total de ventas. La función debe tener dos parámetros @StartDate y @EndDate, los parámetros pueden ser nulos---
---si no especifican las fechas deberá retornar los datos correspondientes al mes actual--


IF  OBJECT_ID ( N ' Sales.ufn_Ventas' ) IS NOT NULL
      DROP FUNCTION Sales.ufn_Ventas
GO

CREATE FUNCTION Sales.ufn_Ventas (@StartDate Date  =  NULL , @EndDate Date  =  NULL )
RETURNS @TablaVentas TABLE (
		ID_producto INT ,
		Nombre_producto NVARCHAR ( 50 ),
		Cantidad SMALLINT ,
		TotalNUMERICO NUMERIC( 38 , 6 ),
		IdOrden INT ,
		FechaOrden DATETIME
		)
AS
BEGIN
	IF (@StartDate IS NULL  AND @EndDate IS NULL )
	SET @StartDate =  DATEADD ( DAY , 1 , EOMES ( GETDATE (), - 1 ));
	SET @EndDate =  EOMES ( GETDATE ());

	INSERT INTO @TablaVentas (ID_producto, Nombre_producto, Cantidad, TotalNUMERICO, IdOrden, FechaOrden)
	SELECT  s.ProductID , s.ProductID , s.OrderQty , s.LineTotal, S.SalesOrderID , h.OrderDate
		FROM  Sales.SalesOrderDetail s
		 INNER JOIN Production.Product p ON  s.ProductID  =  p .ProductID
		 INNER JOIN Sales.SalesOrderHeader h ON  s .SalesOrderID  =  h .SalesOrderID
		where ( h .OrderDate between @StartDate and @EndDate)	
		Return ;
end		
go

Select  *
from Sales. ufn_Ventas ( ' 2010-06-01' , ' 2014-05-06' )


---Cree una función que obtenga retorne el Id del producto, nombre del producto, cantidad total de ventas, monto total de ventas de un año.---
---La función debe tener un parámetro @year, si no se especifica el año deberá retornar los datos correspondientes al año actual.---

 OBJECT_ID (N'Sales.ufn_VentasAnuales') IS NOT NULL
   DROP FUNCTION Sales.ufn_VentasAnuales
GO

CREATE FUNCTION Sales.ufn_VentasAnuales(@Year int = NULL)
RETURNS @TablaVentas TABLE(
		ProductID INT,
		ProductName NVARCHAR(50),
		Cantidad SMALLINT,
		Total NUMERIC(38,6),
		IdOrden INT,
		FechaOrden DATETIME
		)
AS
BEGIN 
	IF(@Year IS NULL)
	SET @Year= CONVERT(INT, DATEPART(YEAR, GETDATE()), 101);
	
	INSERT INTO @TablaVentas (ProductID, ProductName, Cantidad, Total, IdOrden, FechaOrden)
	SELECT s.ProductID, p.Name, s.OrderQty, s.LineTotal, S.SalesOrderID, h.OrderDate
		FROM Sales.SalesOrderDetail s
		INNER JOIN Production.Product p ON S.ProductID = p.ProductID
		INNER JOIN Sales.SalesOrderHeader h ON s.SalesOrderID = h.SalesOrderID
		WHERE (CONVERT(INT, DATEPART(YEAR, h.OrderDate),101) =  @Year)	
		RETURN;
END		
GO

SELECT * FROM Sales.ufn_VentasAnuales(2018)
GO



