USE DenyRevokeDemo;
GO
REVOKE SELECT ON Empleados FROM recursos;
GO
SELECT DP.name AS Usuario, PER.state_desc AS Estado, PER.permission_name AS Permiso, OBJECT_NAME(PER.major_id) AS Objeto
FROM sys.database_permissions PER JOIN sys.database_principals DP ON PER.grantee_principal_id = DP.principal_id
WHERE DP.name IN ('auditor', 'recursos');
GO
EXECUTE AS USER = 'recursos';
GO
SELECT 'Despues del REVOKE' AS Etapa, Id, Nombre, Salario FROM Empleados;
GO
REVERT;
GO
REVOKE SELECT ON Empleados FROM auditor;
GO
SELECT DP.name AS Usuario, PER.state_desc AS Estado, PER.permission_name AS Permiso, OBJECT_NAME(PER.major_id) AS Objeto
FROM sys.database_permissions PER JOIN sys.database_principals DP ON PER.grantee_principal_id = DP.principal_id
WHERE DP.name IN ('auditor', 'recursos');
GO
EXECUTE AS USER = 'auditor';
GO
SELECT 'Despues de REVOKE del DENY' AS Etapa, Id, Nombre, Salario FROM Empleados;
GO
REVERT;
GO