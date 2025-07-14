IF EXISTS (SELECT 1 FROM [sys].[objects] WHERE type = 'V' AND name = 'vFactSales')
    DROP VIEW [dbo].[vFactSales]
GO

IF EXISTS (SELECT 1 FROM [sys].[objects] WHERE type = 'U' AND name = 'DimReseller')
    DROP TABLE [dbo].[DimReseller]
GO

IF EXISTS (SELECT 1 FROM [sys].[objects] WHERE type = 'U' AND name = 'DimPromotion')
    DROP TABLE [dbo].[DimPromotion]
GO

IF EXISTS (SELECT 1 FROM [sys].[objects] WHERE type = 'U' AND name = 'DimOrganization')
    DROP TABLE [dbo].[DimOrganization]
GO

IF EXISTS (SELECT 1 FROM [sys].[objects] WHERE type = 'U' AND name = 'DimEmployee')
    DROP TABLE [dbo].[DimEmployee]
GO

IF EXISTS (SELECT 1 FROM [sys].[objects] WHERE type = 'U' AND name = 'DimDepartmentGroup')
    DROP TABLE [dbo].[DimDepartmentGroup]
GO

IF EXISTS (SELECT 1 FROM [sys].[objects] WHERE type = 'U' AND name = 'DimCurrency')
    DROP TABLE [dbo].[DimCurrency]
GO

IF EXISTS (SELECT 1 FROM [sys].[objects] WHERE type = 'U' AND name = 'DimAccount')
    DROP TABLE [dbo].[DimAccount]
GO

IF EXISTS (SELECT 1 FROM [sys].[objects] WHERE type = 'U' AND name = 'DimSalesTerritory')
    DROP TABLE [dbo].[DimSalesTerritory]
GO

IF EXISTS (SELECT 1 FROM [sys].[objects] WHERE type = 'U' AND name = 'DimProductSubcategory')
    DROP TABLE [dbo].[DimProductSubcategory]
GO

IF EXISTS (SELECT 1 FROM [sys].[objects] WHERE type = 'U' AND name = 'DimProductCategory')
    DROP TABLE [dbo].[DimProductCategory]
GO

IF EXISTS (SELECT 1 FROM [sys].[objects] WHERE type = 'U' AND name = 'DimProduct')
    DROP TABLE [dbo].[DimProduct]
GO

IF EXISTS (SELECT 1 FROM [sys].[objects] WHERE type = 'U' AND name = 'DimGeography')
    DROP TABLE [dbo].[DimGeography]
GO

IF EXISTS (SELECT 1 FROM [sys].[objects] WHERE type = 'U' AND name = 'DimDate')
    DROP TABLE [dbo].[DimDate]
GO

IF EXISTS (SELECT 1 FROM [sys].[objects] WHERE type = 'U' AND name = 'DimCustomer')
    DROP TABLE [dbo].[DimCustomer]
GO

IF EXISTS (SELECT 1 FROM [sys].[objects] WHERE type = 'U' AND name = 'FactInternetSales')
    DROP TABLE [dbo].[FactInternetSales]
GO

IF EXISTS (SELECT 1 FROM [sys].[objects] WHERE type = 'U' AND name = 'FactResellerSales')
    DROP TABLE [dbo].[FactResellerSales]
GO

IF EXISTS (SELECT 1 FROM [sys].[objects] WHERE type = 'U' AND name = 'weather_forecast')
    DROP TABLE [dbo].[weather_forecast]
GO

IF EXISTS (SELECT 1 FROM [sys].[objects] WHERE type = 'U' AND name = 'StageCustomer')
    DROP TABLE [dbo].[StageCustomer]
GO

IF EXISTS (SELECT 1 FROM [sys].[objects] WHERE type = 'U' AND name = 'StageProduct')
    DROP TABLE [dbo].[StageProduct]
GO
