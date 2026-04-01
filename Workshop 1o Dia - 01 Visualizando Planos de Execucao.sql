/**********************************************************************
 Workshop SQL Server Expert 2a Edição
 Otimização de Consultas

 Autor: Landry

 Hands On: 
 - Visualizando Planos de Execução
***********************************************************************/
use AdventureWorks
go


SELECT h.SalesOrderID, h.OrderDate, h.[Status], 
h.CustomerID, p.FirstName, p.LastName
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader h ON c.CustomerID = h.CustomerID
JOIN Person.Person p ON p.BusinessEntityID = c.PersonID
WHERE h.OrderDate = '20110531'

/*******************
 Plano de Execução
********************/
set statistics io on
set statistics io off

set statistics time on
set statistics time off

set statistics profile on
set statistics profile off

set statistics xml on
set statistics xml off

/*******************
 Plano Estimado
********************/
set showplan_all on 
set showplan_all off

set showplan_xml on
set showplan_xml on


/************************************************************
 Cria Banco de Dados: WorkshopDB
*************************************************************/
use master
go

CREATE DATABASE WorkshopDB
go
ALTER DATABASE WorkshopDB SET RECOVERY simple
go

/*********************************
 Cria Tabela: dbo.Customer
**********************************/
use WorkshopDB
go

DROP TABLE IF exists dbo.Customer
go
SELECT c.CustomerID as CustomerID,PersonID,FirstName,MiddleName,Lastname,PersonType,
EmailPromotion,'RJ' as Region, dateadd(d,-BusinessEntityID,getdate()) DataCadastro 
INTO dbo.Customer
FROM AdventureWorks.Sales.Customer c 
JOIN AdventureWorks.Person.Person p ON p.BusinessEntityID = c.PersonID

/**********************************************
 - Interpretando Plano de Execução
***********************************************/
set statistics io on

-- Tabela Heap -> Table Scan
SELECT CustomerID,FirstName,MiddleName,Lastname,PersonType,EmailPromotion,Region,DataCadastro
FROM dbo.Customer

-- Tabela com Índice Clustered -> Clustered Index Scan = Table Scan
CREATE UNIQUE CLUSTERED INDEX IX_Customer_CustomerID ON dbo.Customer(CustomerID)

SELECT CustomerID,FirstName,MiddleName,Lastname,PersonType,EmailPromotion,Region,DataCadastro
FROM dbo.Customer

-- Clustered Index Seek
SELECT CustomerID,FirstName,MiddleName,Lastname,PersonType,EmailPromotion,Region,DataCadastro
FROM dbo.Customer
WHERE CustomerID = 11000

-- NonClustered Index Seek
CREATE INDEX IX_Customer_FirstName ON dbo.Customer(FirstName)

SELECT CustomerID,FirstName,MiddleName,Lastname,PersonType,EmailPromotion,Region,DataCadastro
FROM dbo.Customer
WHERE FirstName = 'John'
-- Index Seek + Bookmark Lookup (Key Lookup)

DROP INDEX dbo.Customer.IX_Customer_FirstName
DROP INDEX dbo.Customer.IX_Customer_CustomerID

-- Bookmark Lookup com RID Lookup
CREATE INDEX IX_Customer_FirstName ON dbo.Customer(FirstName)

SELECT CustomerID,FirstName,MiddleName,Lastname,PersonType,EmailPromotion,Region,DataCadastro
FROM dbo.Customer
WHERE FirstName = 'John'
-- Index Seek + Bookmark Lookup (RID Lookup)


/*************************
 Exclui Tabela
**************************/
DROP TABLE IF exists dbo.Customer
go


