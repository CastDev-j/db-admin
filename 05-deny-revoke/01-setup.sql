CREATE DATABASE DenyRevokeDemo;
GO
ALTER DATABASE DenyRevokeDemo SET RECOVERY SIMPLE;
GO
USE DenyRevokeDemo;
GO
CREATE TABLE Empleados (Id INT IDENTITY(1,1) PRIMARY KEY, Nombre NVARCHAR(50) NOT NULL, Salario DECIMAL(10,2) NOT NULL);
GO
INSERT INTO Empleados (Nombre, Salario) VALUES ('Ana', 5000.00), ('Luis', 7000.00), ('Maria', 9000.00);
GO
IF SUSER_ID('usr_auditor') IS NULL CREATE LOGIN usr_auditor WITH PASSWORD = 'Passw0rd!', CHECK_POLICY = OFF;
GO
IF SUSER_ID('usr_recursos') IS NULL CREATE LOGIN usr_recursos WITH PASSWORD = 'Passw0rd!', CHECK_POLICY = OFF;
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'auditor') CREATE USER auditor FOR LOGIN usr_auditor;
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'recursos') CREATE USER recursos FOR LOGIN usr_recursos;
GO
GRANT SELECT ON Empleados TO auditor;
GO
GRANT SELECT ON Empleados TO recursos;
GO