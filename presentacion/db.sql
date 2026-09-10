-- EQUIPO No. 3 | ADMINISTRACION DE BASES DE DATOS | SQL SERVER
-- db.sql - creacion de estructura para la practica
-- DB sencilla: TIENDA
-- Temas: Bitacora (3), Particiones (2)

SET NOCOUNT ON;
GO
USE master;
GO

-- Limpieza previa 
IF DB_ID('Distribucion') IS NOT NULL BEGIN
    BEGIN TRY
        EXEC sp_dropdistributor @no_checks=1;
    END TRY
    BEGIN CATCH
        PRINT 'Distribuidor no presente o ya eliminado';
    END CATCH
END
GO

IF DB_ID('TIENDA')       IS NOT NULL BEGIN ALTER DATABASE TIENDA       SET SINGLE_USER WITH ROLLBACK IMMEDIATE; END
IF DB_ID('TIENDA_COPIA') IS NOT NULL BEGIN ALTER DATABASE TIENDA_COPIA SET SINGLE_USER WITH ROLLBACK IMMEDIATE; END
IF DB_ID('Distribucion') IS NOT NULL BEGIN ALTER DATABASE Distribucion SET SINGLE_USER WITH ROLLBACK IMMEDIATE; END
GO

IF DB_ID('TIENDA')       IS NOT NULL DROP DATABASE TIENDA;
IF DB_ID('TIENDA_COPIA') IS NOT NULL DROP DATABASE TIENDA_COPIA;
IF DB_ID('Distribucion') IS NOT NULL DROP DATABASE Distribucion;
GO

CREATE DATABASE TIENDA;
GO
CREATE DATABASE TIENDA_COPIA;
GO

USE TIENDA;
GO

-- Tablas
CREATE TABLE dbo.Producto (id_producto INT IDENTITY PRIMARY KEY, nombre VARCHAR(50) NOT NULL, precio DECIMAL(10,2) NOT NULL);
GO

CREATE TABLE dbo.Empleado (
    id_empleado INT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    sueldo DECIMAL(10,2) NOT NULL,
    valid_from DATETIME2 GENERATED ALWAYS AS ROW START,
    valid_to   DATETIME2 GENERATED ALWAYS AS ROW END,
    PERIOD FOR SYSTEM_TIME (valid_from, valid_to)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.Empleado_Historial));
GO

CREATE TABLE dbo.Venta (id_venta INT NOT NULL, fecha datetime2(0) NOT NULL, monto DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_Venta PRIMARY KEY (id_venta, fecha));
GO

CREATE TABLE dbo.Pedido (id_pedido INT NOT NULL, monto INT NOT NULL,
    CONSTRAINT PK_Pedido PRIMARY KEY (id_pedido, monto));
GO

-- =========== 1) TEMA: BITACORA ===========

-- Ejemplo 1.1 - Bitacora con trigger (sobre Producto)
CREATE TABLE dbo.BitacoraProducto (id_evento INT IDENTITY PRIMARY KEY, operacion VARCHAR(10), id_producto INT, nombre VARCHAR(50), precio DECIMAL(10,2), usuario SYSNAME, fecha DATETIME);
GO

CREATE TRIGGER dbo.trg_BitacoraProducto ON dbo.Producto AFTER INSERT, UPDATE, DELETE AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.BitacoraProducto SELECT 'INSERT', i.id_producto, i.nombre, i.precio, SUSER_SNAME(), GETDATE() FROM inserted i;
    INSERT INTO dbo.BitacoraProducto SELECT 'UPDATE', i.id_producto, i.nombre, i.precio, SUSER_SNAME(), GETDATE() FROM inserted i INNER JOIN deleted d ON d.id_producto = i.id_producto;
    INSERT INTO dbo.BitacoraProducto SELECT 'DELETE', d.id_producto, d.nombre, d.precio, SUSER_SNAME(), GETDATE() FROM deleted d;
END
GO

INSERT INTO dbo.Producto (nombre, precio) VALUES ('Refresco', 18.50), ('Papas', 24.00);
UPDATE dbo.Producto SET precio = 20.00 WHERE nombre = 'Refresco';
DELETE FROM dbo.Producto WHERE nombre = 'Papas';
GO

-- Ejemplo 1.2 - Bitacora con tabla temporal (historico automatico)
INSERT INTO dbo.Empleado (id_empleado, nombre, sueldo) VALUES (1, 'Juan', 8500), (2, 'Ana', 9200);
UPDATE dbo.Empleado SET sueldo = 9000 WHERE id_empleado = 1;
GO

-- Ejemplo 1.3 - Bitacora de respaldos (historial en msdb)
ALTER DATABASE TIENDA SET RECOVERY FULL;
GO
BACKUP DATABASE TIENDA TO DISK = N'/var/opt/mssql/data/TIENDA_FULL.bak' WITH NAME = N'Full', INIT;
GO
BACKUP LOG TIENDA TO DISK = N'/var/opt/mssql/data/TIENDA_LOG.bak' WITH NAME = N'Log', INIT;
GO

-- =========== 2) TEMA: PARTICIONES ===========

-- Ejemplo 2.1 - Particion por fecha (tabla Venta)
CREATE PARTITION FUNCTION pf_Venta (datetime2(0)) AS RANGE RIGHT FOR VALUES ('2026-01-01');
GO
CREATE PARTITION SCHEME ps_Venta AS PARTITION pf_Venta TO ([PRIMARY], [PRIMARY]);
GO
CREATE INDEX IX_Venta_fecha ON dbo.Venta(fecha) ON ps_Venta(fecha);
ALTER TABLE dbo.Venta DROP CONSTRAINT PK_Venta;
ALTER TABLE dbo.Venta ADD CONSTRAINT PK_Venta PRIMARY KEY (id_venta, fecha) ON ps_Venta(fecha);
GO
INSERT INTO dbo.Venta VALUES (1, '2025-03-14', 150), (2, '2025-11-02', 320), (3, '2026-02-20', 210), (4, '2026-07-08', 540);
GO

-- Ejemplo 2.2 - Particion por rango numerico (tabla Pedido)
CREATE PARTITION FUNCTION pf_Pedido (int) AS RANGE RIGHT FOR VALUES (100, 500);
GO
CREATE PARTITION SCHEME ps_Pedido AS PARTITION pf_Pedido TO ([PRIMARY], [PRIMARY], [PRIMARY]);
GO
CREATE INDEX IX_Pedido_monto ON dbo.Pedido(monto) ON ps_Pedido(monto);
ALTER TABLE dbo.Pedido DROP CONSTRAINT PK_Pedido;
ALTER TABLE dbo.Pedido ADD CONSTRAINT PK_Pedido PRIMARY KEY (id_pedido, monto) ON ps_Pedido(monto);
GO
INSERT INTO dbo.Pedido VALUES (1, 50), (2, 120), (3, 420), (4, 800);
GO

-- =========== 3) TEMA: PUBLICACION Y REPLICA ===========
-- Se publica la tabla Producto de TIENDA hacia TIENDA_COPIA

-- Ejemplo 3.1 - Publicacion (distribuidor + publicacion + articulo)
USE master;
GO
EXEC sp_adddistributor @distributor = N'sqlserver';
GO
EXEC sp_adddistributiondb @database = N'Distribucion', @data_folder = N'/var/opt/mssql/data/', @log_folder = N'/var/opt/mssql/data/';
GO
EXEC sp_adddistpublisher @publisher = N'sqlserver', @distribution_db = N'Distribucion',
     @working_directory = N'/var/opt/mssql/data/RepData', @security_mode = 0,
     @login = N'sa', @password = N'YourStrong@Password123';
GO
EXEC master..sp_replicationdboption @dbname = N'TIENDA', @optname = N'publish', @value = N'true';
GO
USE TIENDA;
GO
EXEC sp_addpublication @publication = N'PubProductos', @description = N'Publicacion de la tabla Producto',
     @sync_method = N'native', @allow_push = N'true', @allow_pull = N'true',
     @repl_freq = N'continuous', @status = N'active', @retention = 0;
GO
EXEC sp_addarticle @publication = N'PubProductos', @article = N'Producto', @source_object = N'Producto', @source_owner = N'dbo';
GO

-- Ejemplo 3.2 - Replica (suscripcion push hacia TIENDA_COPIA)
EXEC sp_addsubscription @publication = N'PubProductos', @subscriber = N'sqlserver',
     @destination_db = N'TIENDA_COPIA', @subscription_type = N'push', @sync_type = N'automatic', @article = N'all';
GO

PRINT '=== db.sql terminado ===';
GO