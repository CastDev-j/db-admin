# Actividad 5 — Partición horizontal en SQL Server (BD Video)

## Objetivo

Crear una **partición horizontal** en SQL Server sobre los datos de rentas de la base
`BD_VIDEOS`: una tabla se divide por **rangos de filas**, y cada rango se guarda en un
grupo de archivos distinto. La consulta sigue viendo **una sola tabla**, pero el motor
guarda cada rango (`folio < 10`, `10 <= folio < 20`, `folio >= 20`) en archivos separados.

## Concepto: partición horizontal

![[Pasted image 20261007221950.png]]

Componentes de la partición (y qué hace cada uno):

| Instrucción | Qué hace |
| ----------- | -------- |
| `ALTER DATABASE ... ADD FILEGROUP` | Crea los *grupos de archivos* que separarán físicamente los datos. |
| `ALTER DATABASE ... ADD FILE ... TO FILEGROUP` | Agrega un archivo `.ndf` a cada grupo (espacio propio para cada rango). |
| `CREATE PARTITION FUNCTION (INT) ... RANGE RIGHT FOR VALUES (10, 20)` | Define los **rangos**: filas < 10, 10–19 y >= 20. |
| `CREATE PARTITION SCHEME ... TO (FG_Renta01, FG_Renta02, [PRIMARY])` | Enlaza cada rango con su grupo de archivos. |
| `CREATE TABLE (...) ON ps_Renta(folio)` | Crea la tabla **particionada** usando la columna `folio` como llave de partición. |
| `INSERT ... SELECT` | Carga los datos de `itc_Renta`; el motor reparte cada fila a su partición. |
| Queries de `sys.partitions` / `$PARTITION` | Verifican filas por partición y a qué partición corresponde cada fila. |

![[Pasted image 20261007222517.png]]

![[Pasted image 20261007222536.png]]

![[Pasted image 20261007222544.png]]

![[Pasted image 20261007222552.png]]
![[Pasted image 20261007222603.png]]

![[Pasted image 20261007222623.png]]

![[Pasted image 20261007222632.png]]

![[Pasted image 20261007222648.png]]

![[Pasted image 20261007222659.png]]

![[Pasted image 20261007222711.png]]
## Queries aplicadas (documentadas)

```sql
-- ============================================================
-- ACTIVIDAD 5: Partición horizontal (copia particionada de rentas)
-- BD: BD_VIDEOS
-- ============================================================
USE BD_VIDEOS;
GO

-- (Se borran objetos previos para poder re-ejecutar)
IF OBJECT_ID('dbo.RentaParticionada', 'U') IS NOT NULL DROP TABLE dbo.RentaParticionada;
IF EXISTS (SELECT 1 FROM sys.partition_schemes WHERE name = 'ps_Renta') DROP PARTITION SCHEME ps_Renta;
IF EXISTS (SELECT 1 FROM sys.partition_functions WHERE name = 'pf_Renta') DROP PARTITION FUNCTION pf_Renta;
IF EXISTS (SELECT 1 FROM sys.database_files WHERE name = 'BD_VIDEOS_Renta01') ALTER DATABASE BD_VIDEOS REMOVE FILE BD_VIDEOS_Renta01;
IF EXISTS (SELECT 1 FROM sys.database_files WHERE name = 'BD_VIDEOS_Renta02') ALTER DATABASE BD_VIDEOS REMOVE FILE BD_VIDEOS_Renta02;
IF EXISTS (SELECT 1 FROM sys.filegroups WHERE name = 'FG_Renta01') ALTER DATABASE BD_VIDEOS REMOVE FILEGROUP FG_Renta01;
IF EXISTS (SELECT 1 FROM sys.filegroups WHERE name = 'FG_Renta02') ALTER DATABASE BD_VIDEOS REMOVE FILEGROUP FG_Renta02;
GO

-- PASO 1: Crear grupos de archivos (separación física de cada rango)
ALTER DATABASE BD_VIDEOS ADD FILEGROUP FG_Renta01;
ALTER DATABASE BD_VIDEOS ADD FILEGROUP FG_Renta02;
GO

-- PASO 2: Crear un archivo .ndf para cada grupo
-- (rutas Linux porque el servidor corre en Docker)
ALTER DATABASE BD_VIDEOS ADD FILE (
    NAME = 'BD_VIDEOS_Renta01', FILENAME = '/var/opt/mssql/data/BD_VIDEOS_Renta01.ndf',
    SIZE = 5MB, FILEGROWTH = 5MB) TO FILEGROUP FG_Renta01;
ALTER DATABASE BD_VIDEOS ADD FILE (
    NAME = 'BD_VIDEOS_Renta02', FILENAME = '/var/opt/mssql/data/BD_VIDEOS_Renta02.ndf',
    SIZE = 5MB, FILEGROWTH = 5MB) TO FILEGROUP FG_Renta02;
GO

-- PASO 3: Función de partición (define los rangos HORIZONTALES)
CREATE PARTITION FUNCTION pf_Renta (INT)
AS RANGE RIGHT FOR VALUES (10, 20); -- partición 1: folio<10 | 2: 10..19 | 3: >=20
GO

-- PASO 4: Esquema de partición (rango -> grupo de archivos)
CREATE PARTITION SCHEME ps_Renta
AS PARTITION pf_Renta TO (FG_Renta01, FG_Renta02, [PRIMARY]);
GO

-- Verificación intermedia: archivos y grupos creados
SELECT name, type_desc FROM sys.filegroups WHERE name LIKE 'FG_Renta%';
SELECT name, physical_name, size FROM sys.database_files WHERE name LIKE 'BD_VIDEOS_Renta%';
GO

-- PASO 5: Crear una tabla PARTIDA con la misma estructura que itc_Renta
CREATE TABLE dbo.RentaParticionada (
    folio          INT NOT NULL,
    cve_p          INT,
    cve_c          INT,
    cve_devol      INT,
    fecha_prestamo DATE,
    dias           INT,
    costoXdia      VARCHAR(10),
    CONSTRAINT PK_RentaParticionada PRIMARY KEY CLUSTERED (folio)
) ON ps_Renta(folio);   -- la columna de partición es folio
GO

-- PASO 6: Migrar los datos de la tabla real (26 rentas)
INSERT INTO dbo.RentaParticionada (folio, cve_p, cve_c, cve_devol, fecha_prestamo, dias, costoXdia)
SELECT folio, cve_p, cve_c, cve_devol, fecha_prestamo, dias, costoXdia
FROM dbo.itc_Renta;
GO

-- PASO 7: RESULTADO — filas por partición (sys.partitions)
SELECT p.partition_number AS particion, p.rows AS filas
FROM sys.partitions p
WHERE p.object_id = OBJECT_ID('dbo.RentaParticionada') AND p.index_id IN (0,1)
ORDER BY p.partition_number;
GO

-- PASO 8: RESULTADO — a qué partición corresponde cada folio
SELECT folio, $PARTITION.pf_Renta(folio) AS particion_asignada
FROM dbo.RentaParticionada
ORDER BY folio;
GO

-- PASO 9: RESULTADO — partición -> límite -> filegroup -> filas
SELECT p.partition_number AS particion,
       prv.value AS limite_superior,
       fg.name AS filegroup,
       p.rows AS filas
FROM sys.partitions p
JOIN sys.indexes i ON i.object_id = p.object_id AND i.index_id = p.index_id
JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id
JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = p.partition_number
JOIN sys.filegroups fg ON fg.data_space_id = dds.data_space_id
JOIN sys.partition_functions pf ON pf.function_id = ps.function_id
LEFT JOIN sys.partition_range_values prv ON prv.function_id = pf.function_id AND prv.boundary_id = p.partition_number
WHERE p.object_id = OBJECT_ID('dbo.RentaParticionada') AND p.index_id IN (0,1)
ORDER BY p.partition_number;
GO
```
