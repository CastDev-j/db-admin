# Actividad 2 — Esquemas, usuarios y permisos (BD Actuadores y Zero)

## Objetivo

Realizar **2 esquemas** en **2 bases de datos** nuevas (`Actuadores` y `Zero`), asignar
usuarios y permisos mediante **queries**, y aplicar un **comando para visualizar**
usuarios ➜ esquemas ➜ permisos de cada base de datos.

## Descripción general

En cada base de datos se crea:

| Base de datos | Esquema  | Tabla                    | Usuario       | Permisos aplicados        |
| ------------- | -------- | ------------------------ | ------------- | ------------------------- |
| `Actuadores`  | `actuadores` | `actuadores.dispositivo` | `usr_actuador` | `SELECT`, `INSERT` (GRANT) · `DELETE` (DENY) |
| `Zero`        | `zero`    | `zero.movimiento`        | `usr_zero`    | `SELECT`, `INSERT` (GRANT) · `DELETE` (DENY) |

## Diagrama del modelo de permisos

![[Pasted image 20261007213233.png]]

## Paso a paso en SSMS

1. Conectarse en SSMS (`localhost,1433`, Autenticación **SQL Server**, usuario `sa`).
	1. ![[Pasted image 20261007214900.png]]
2. Abrir **Nueva consulta**, pegar el script de la sección Entregable y ejecutarlo con **F5**.
	1. ![[Pasted image 20261007214944.png]]
3. El script hace: crear BDs → crear esquemas → crear tablas → insertar datos →
   crear logins/usuarios → conceder/denegar permisos → **visualizar** usuarios, esquemas y permisos.
	1. ![[Pasted image 20261007215111.png]]
4. **Prueba de acceso:** el script se impersona como cada usuario (`EXECUTE AS USER`)
   y consulta su tabla para demostrar que el permiso funciona.
	1. ![[Pasted image 20261007215135.png]]

## Queries aplicadas (documentadas)

```sql
-- ============================================================
-- ACTIVIDAD 2: Esquemas, usuarios y permisos en SQL Server
-- BD: Actuadores y Zero
-- ============================================================
USE master;
GO

-- Limpieza previa para poder re-ejecutar el script sin errores
IF DB_ID('Actuadores') IS NOT NULL
BEGIN ALTER DATABASE Actuadores SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE Actuadores; END
IF DB_ID('Zero') IS NOT NULL
BEGIN ALTER DATABASE Zero SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE Zero; END
IF SUSER_ID('usr_actuador') IS NOT NULL DROP LOGIN usr_actuador;
IF SUSER_ID('usr_zero') IS NOT NULL DROP LOGIN usr_zero;
GO

-- PASO 1: Crear las 2 bases de datos
CREATE DATABASE Actuadores;
GO
CREATE DATABASE Zero;
GO

-- ============================================================
-- BD ACTUADORES
-- ============================================================
USE Actuadores;
GO

-- PASO 2: Crear el esquema (agrupa objetos con lógica propia)
CREATE SCHEMA actuadores AUTHORIZATION dbo;
GO

-- PASO 3: Crear una tabla dentro del esquema
CREATE TABLE actuadores.dispositivo (
    id_dispositivo INT IDENTITY(1,1) CONSTRAINT PK_dispositivo PRIMARY KEY,
    nombre         VARCHAR(60)  NOT NULL,
    estado         VARCHAR(20)  NOT NULL DEFAULT 'ACTIVO'
);
GO

-- PASO 4: Insertar los datos de la tabla
INSERT INTO actuadores.dispositivo (nombre) VALUES
 ('Sensor de temperatura'), ('Valvula hidraulica'), ('Motor de paso'), ('Alarma sonora');
GO

-- PASO 5: Crear login (nivel servidor) y usuario (nivel base de datos)
IF SUSER_ID('usr_actuador') IS NULL
    CREATE LOGIN usr_actuador WITH PASSWORD = 'Actuador123!', CHECK_POLICY = OFF;
GO
CREATE USER usr_actuador FOR LOGIN usr_actuador;
GO

-- PASO 6: Asignar permisos sobre el esquema
GRANT SELECT, INSERT ON SCHEMA::actuadores TO usr_actuador;  -- permiso concedido
DENY  DELETE       ON SCHEMA::actuadores TO usr_actuador;    -- permiso denegado
GO

-- PASO 7: Visualizar usuarios, esquemas y permisos
EXEC sp_helpuser;                                                 -- comando: usuarios con su login y rol
GO
SELECT name AS usuario, type_desc AS tipo, authentication_type_desc AS autenticacion
FROM sys.database_principals
WHERE type IN ('S','U','G') AND name NOT IN ('dbo','guest','INFORMATION_SCHEMA','sys');
GO
SELECT s.name AS esquema, USER_NAME(s.principal_id) AS dueno
FROM sys.schemas s
WHERE s.schema_id NOT BETWEEN 0 AND 4 AND s.name NOT LIKE 'db[_]%'
  AND s.name NOT IN ('guest','INFORMATION_SCHEMA','sys');
GO
SELECT dp.name AS usuario, perm.permission_name AS permiso, perm.state_desc AS estado,
       CASE perm.class
            WHEN 0 THEN 'BASE DE DATOS'
            WHEN 1 THEN OBJECT_NAME(perm.major_id)
            WHEN 3 THEN SCHEMA_NAME(perm.major_id)
            ELSE 'clase ' + CAST(perm.class AS VARCHAR(5))
       END AS objeto
FROM sys.database_permissions perm
JOIN sys.database_principals dp ON perm.grantee_principal_id = dp.principal_id
WHERE dp.name NOT IN ('dbo','guest','PUBLIC','INFORMATION_SCHEMA','sys')
ORDER BY dp.name, perm.permission_name;
GO

-- PASO 8: Probamos que el usuario SÍ puede consultar (impersonación)
EXECUTE AS USER = 'usr_actuador';
SELECT * FROM actuadores.dispositivo;
REVERT;
GO

-- ============================================================
-- BD ZERO
-- ============================================================
USE Zero;
GO

CREATE SCHEMA zero AUTHORIZATION dbo;
GO
CREATE TABLE zero.movimiento (
    id_movimiento INT IDENTITY(1,1) CONSTRAINT PK_movimiento PRIMARY KEY,
    concepto      VARCHAR(80)     NOT NULL,
    monto         DECIMAL(12,2)   NOT NULL
);
GO
INSERT INTO zero.movimiento (concepto, monto) VALUES
 ('Venta mostrador', 150.00), ('Venta en linea', 890.50), ('Devolucion', -120.00), ('Ajuste de inventario', 0.00);
GO
IF SUSER_ID('usr_zero') IS NULL
    CREATE LOGIN usr_zero WITH PASSWORD = 'Zero123!', CHECK_POLICY = OFF;
GO
CREATE USER usr_zero FOR LOGIN usr_zero;
GO
GRANT SELECT, INSERT ON SCHEMA::zero TO usr_zero;
DENY  DELETE       ON SCHEMA::zero TO usr_zero;
GO

-- Mismas consultas de visualización aplicadas a Zero
EXEC sp_helpuser;
GO
SELECT name AS usuario, type_desc AS tipo, authentication_type_desc AS autenticacion
FROM sys.database_principals
WHERE type IN ('S','U','G') AND name NOT IN ('dbo','guest','INFORMATION_SCHEMA','sys');
GO
SELECT s.name AS esquema, USER_NAME(s.principal_id) AS dueno
FROM sys.schemas s
WHERE s.schema_id NOT BETWEEN 0 AND 4 AND s.name NOT LIKE 'db[_]%'
  AND s.name NOT IN ('guest','INFORMATION_SCHEMA','sys');
GO
SELECT dp.name AS usuario, perm.permission_name AS permiso, perm.state_desc AS estado,
       CASE perm.class
            WHEN 0 THEN 'BASE DE DATOS'
            WHEN 1 THEN OBJECT_NAME(perm.major_id)
            WHEN 3 THEN SCHEMA_NAME(perm.major_id)
            ELSE 'clase ' + CAST(perm.class AS VARCHAR(5))
       END AS objeto
FROM sys.database_permissions perm
JOIN sys.database_principals dp ON perm.grantee_principal_id = dp.principal_id
WHERE dp.name NOT IN ('dbo','guest','PUBLIC','INFORMATION_SCHEMA','sys')
ORDER BY dp.name, perm.permission_name;
GO
EXECUTE AS USER = 'usr_zero';
SELECT * FROM zero.movimiento;
REVERT;
GO
```

