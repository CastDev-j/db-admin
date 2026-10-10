# Actividad 6 — Crear una base de datos con sqlcmd (investigación aplicada)

## Objetivo

Investigar y poner en práctica **cómo crear una base de datos con sqlcmd** (línea de
comandos), con **espacio de almacenamiento definido**, **2 tablas** con **4 registros
cada una**, y **1 usuario** al que se asignan **2 roles**.

## Investigación: qué es sqlcmd

- `sqlcmd` es la herramienta de **línea de comandos** de SQL Server (no usa SSMS).
- Permite ejecutar consultas por archivo (`-i script.sql`) o directo (`-Q "..."`).
- Conexión típica:

```bash
sqlcmd -S localhost,1433 -U sa -P "YourStrong@Password123" -i script.sql
```

- Parámetros usados:

| Parámetro | Qué hace |
| --------- | -------- |
| `-S` | Servidor e instancia (`servidor,puerto`). |
| `-U` | Usuario (autenticación SQL Server). |
| `-P` | Contraseña. |
| `-i` | Ejecuta un archivo `.sql`. |
| `-o` | Guarda la salida en un archivo de texto. |
| `-C` | Confía en el certificado SSL del servidor (Docker). |
## Diagrama del proceso

![[Pasted image 20261007223234.png]]

![[Pasted image 20261007223315.png]]

![[Pasted image 20261007223329.png]]

![[Pasted image 20261007223343.png]]

![[Pasted image 20261007223354.png]]

![[Pasted image 20261007223401.png]]

![[Pasted image 20261007223413.png]]

![[Pasted image 20261007223429.png]]

![[Pasted image 20261007223440.png]]
## Script a ejecutar con sqlcmd (`script_act6.sql`)

```sql
-- ============================================================
-- ACTIVIDAD 6: Crear BD con sqlcmd + tablas + usuario con 2 roles
-- ============================================================
USE master;
GO

-- Limpieza previa (re-ejecutable)
IF DB_ID('BD_Act6') IS NOT NULL
BEGIN ALTER DATABASE BD_Act6 SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE BD_Act6; END
IF SUSER_ID('usr_act6') IS NOT NULL DROP LOGIN usr_act6;
GO

-- PASO 1: Crear la base de datos CON ESPACIO DE ALMACENAMIENTO definido
-- (rutas Linux porque el servidor corre en Docker; la clave está en SIZE, MAXSIZE y FILEGROWTH)
CREATE DATABASE BD_Act6
ON PRIMARY (
    NAME = 'BD_Act6_Prim',
    FILENAME = '/var/opt/mssql/data/BD_Act6.mdf',
    SIZE = 10MB,      -- tamaño inicial
    MAXSIZE = 50MB,   -- cuota máxima del archivo
    FILEGROWTH = 5MB  -- crecimiento automático por etapa
)
LOG ON (
    NAME = 'BD_Act6_Log',
    FILENAME = '/var/opt/mssql/data/BD_Act6_log.ldf',
    SIZE = 5MB,
    FILEGROWTH = 2MB
);
GO

-- PASO 2: Crear las 2 tablas
USE BD_Act6;
GO
CREATE TABLE dbo.alumno (
    id_alumno INT CONSTRAINT PK_alumno PRIMARY KEY,
    nombre    VARCHAR(60) NOT NULL,
    carrera   VARCHAR(60) NOT NULL
);
GO
CREATE TABLE dbo.materia (
    id_materia INT CONSTRAINT PK_materia PRIMARY KEY,
    clave      VARCHAR(10) NOT NULL,
    nombre     VARCHAR(60) NOT NULL
);
GO

-- PASO 3: Insertar 4 registros en cada tabla
INSERT INTO dbo.alumno VALUES
 (1, 'Ana Lopez', 'ISC'), (2, 'Luis Perez', 'IGE'), (3, 'Maria Ruiz', 'ISC'), (4, 'Juan Diaz', 'IM');
GO
INSERT INTO dbo.materia VALUES
 (1, 'ABD', 'Administracion de Bases de Datos'),
 (2, 'RED', 'Redes'),
 (3, 'SO',  'Sistemas Operativos'),
 (4, 'PRO', 'Programacion');
GO

-- PASO 4: Crear login (servidor) y usuario (en la BD)
CREATE LOGIN usr_act6 WITH PASSWORD = 'Act6Clave!', CHECK_POLICY = OFF;
GO
CREATE USER usr_act6 FOR LOGIN usr_act6;
GO

-- PASO 5: Asignar 2 roles al usuario
ALTER ROLE db_datareader ADD MEMBER usr_act6;  -- rol 1: puede LEER datos
ALTER ROLE db_datawriter  ADD MEMBER usr_act6;  -- rol 2: puede ESCRIBIR datos
GO

-- PASO 6: Verificación
SELECT 'alumno' AS tabla, COUNT(*) AS registros FROM dbo.alumno
UNION ALL
SELECT 'materia', COUNT(*) FROM dbo.materia;
GO
SELECT dp.name AS usuario, r.name AS rol
FROM sys.database_role_members drm
JOIN sys.database_principals r  ON drm.role_principal_id = r.principal_id
JOIN sys.database_principals dp ON drm.member_principal_id = dp.principal_id
WHERE dp.name = 'usr_act6';
GO
-- Prueba de acceso como el usuario creado (impersonación)
EXECUTE AS USER = 'usr_act6';
SELECT COUNT(*) AS alumnos_visible FROM dbo.alumno;
REVERT;
GO
```
