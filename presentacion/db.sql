-- ============================================================
-- EQUIPO No. 3 | ADMINISTRACION DE BASES DE DATOS | SQL SERVER
-- db.sql - practica completa (estructura + CUERIs)
-- DB: TIENDA
-- Temas: Bitacora (3), Particiones (2), Publicacion y Replica (1 c/u)
-- ============================================================

-- Evita el mensaje "(n filas afectadas)" en cada lote, mas usado en triggers
SET NOCOUNT ON;
GO
USE master;
GO

-- Limpieza previa (re-ejecutable)
-- Primero se baja el distributor: si no, la BD Distribucion queda con
-- dependencias de replicacion y DROP DATABASE falla.
-- @no_checks = 1 evita que sp_dropdistributor pida confirmacion.
IF DB_ID('Distribucion') IS NOT NULL BEGIN
    BEGIN TRY
        EXEC sp_dropdistributor @no_checks=1;
    END TRY
    BEGIN CATCH
        PRINT 'Distribuidor no presente o ya eliminado';
    END CATCH
END
GO

-- SET SINGLE_USER WITH ROLLBACK IMMEDIATE expulsa las sesiones abiertas (incluida
-- la de SSMS), requisito para poder borrar despues la base con DROP DATABASE.
IF DB_ID('TIENDA')       IS NOT NULL BEGIN ALTER DATABASE TIENDA       SET SINGLE_USER WITH ROLLBACK IMMEDIATE; END
IF DB_ID('TIENDA_COPIA') IS NOT NULL BEGIN ALTER DATABASE TIENDA_COPIA SET SINGLE_USER WITH ROLLBACK IMMEDIATE; END
IF DB_ID('Distribucion') IS NOT NULL BEGIN ALTER DATABASE Distribucion SET SINGLE_USER WITH ROLLBACK IMMEDIATE; END
GO

IF DB_ID('TIENDA')       IS NOT NULL DROP DATABASE TIENDA;
IF DB_ID('TIENDA_COPIA') IS NOT NULL DROP DATABASE TIENDA_COPIA;
IF DB_ID('Distribucion') IS NOT NULL DROP DATABASE Distribucion;
GO

-- TIENDA_COPIA nace vacia: sus datos llegaran por la replica de la seccion 3
CREATE DATABASE TIENDA;
GO
CREATE DATABASE TIENDA_COPIA;
GO

USE TIENDA;
GO

-- Tablas
-- id_producto IDENTITY se rellena solo: la bitacora del ejemplo 1.1 se apoya en esta tabla
CREATE TABLE dbo.Producto (id_producto INT IDENTITY PRIMARY KEY, nombre VARCHAR(50) NOT NULL, precio DECIMAL(10,2) NOT NULL);
GO

-- Tabla con versionado temporal del motor: cada UPDATE guarda la fila anterior en
-- dbo.Empleado_Historial, que es una tabla de historial creada automaticamente.
-- valid_from y valid_to no se escriben a mano, los calcula SQL Server.
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

-- fecha va en la PK porque una PK de tabla particionada por rango tiene que incluir
-- la columna de particion
CREATE TABLE dbo.Venta (id_venta INT NOT NULL, fecha datetime2(0) NOT NULL, monto DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_Venta PRIMARY KEY (id_venta, fecha));
GO

-- mismo criterio que Venta, pero particionada por rango numerico en vez de por fecha
CREATE TABLE dbo.Pedido (id_pedido INT NOT NULL, monto INT NOT NULL,
    CONSTRAINT PK_Pedido PRIMARY KEY (id_pedido, monto));
GO

-- SECCION 1: TEMA BITACORA - 3 ejemplos

-- ESTRUCTURA 1.1 - Bitacora con trigger (sobre Producto)
-- Bitacora manual: no la llena el usuario, la escribe el trigger con SUSER_SNAME() y GETDATE()
CREATE TABLE dbo.BitacoraProducto (id_evento INT IDENTITY PRIMARY KEY, operacion VARCHAR(10), id_producto INT, nombre VARCHAR(50), precio DECIMAL(10,2), usuario SYSNAME, fecha DATETIME);
GO

-- Trigger AFTER: se dispara DESPUES de aplicar el cambio.
-- inserted guarda las filas nuevas y deleted las viejas; en un UPDATE coexisten,
-- y por eso la primera rama es la del UPDATE.
-- Se registra una fila por registro afectado. No se dispara con TRUNCATE TABLE.
CREATE TRIGGER dbo.trg_BitacoraProducto 
ON dbo.Producto 
AFTER INSERT, UPDATE, DELETE 
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
        INSERT INTO dbo.BitacoraProducto
        SELECT 'UPDATE', i.id_producto, i.nombre, i.precio, SUSER_SNAME(), GETDATE()
        FROM inserted i
        INNER JOIN deleted d ON d.id_producto = i.id_producto;

    ELSE IF EXISTS (SELECT 1 FROM inserted)
        INSERT INTO dbo.BitacoraProducto
        SELECT 'INSERT', i.id_producto, i.nombre, i.precio, SUSER_SNAME(), GETDATE()
        FROM inserted i;

    ELSE
        INSERT INTO dbo.BitacoraProducto
        SELECT 'DELETE', d.id_producto, d.nombre, d.precio, SUSER_SNAME(), GETDATE()
        FROM deleted d;
END
GO

-- Datos de prueba: el INSERT, el UPDATE y el DELETE recorren las tres ramas del trigger
INSERT INTO dbo.Producto (nombre, precio) VALUES ('Refresco', 18.50), ('Papas', 24.00);
UPDATE dbo.Producto SET precio = 20.00 WHERE nombre = 'Refresco';
DELETE FROM dbo.Producto WHERE nombre = 'Papas';
GO

-- CUERI 1.1 - Bitacora con trigger: ver que se registro
-- Salida esperada: 3 eventos (INSERT, UPDATE y DELETE) en el orden del bloque anterior
SELECT operacion, id_producto, nombre, precio, usuario, fecha
FROM   dbo.BitacoraProducto
ORDER BY id_evento;
GO

-- ESTRUCTURA 1.2 - Bitacora con tabla temporal (historico automatico)
-- El UPDATE del sueldo queda registrado por el motor, sin ningun trigger
INSERT INTO dbo.Empleado (id_empleado, nombre, sueldo) VALUES (1, 'Juan', 8500), (2, 'Ana', 9200);
UPDATE dbo.Empleado SET sueldo = 9000 WHERE id_empleado = 1;
GO

-- CUERI 1.2 - Bitacora con tabla temporal: ver todo el historial
-- FOR SYSTEM_TIME ALL no es una tabla normal: es una forma de consultar que une
-- el estado actual con el historial. Solo funciona con SYSTEM_VERSIONING = ON.
-- Salida esperada: Juan con 8500 (historico) y Juan con 9000 (actual), mas Ana
SELECT *
FROM   dbo.Empleado
FOR SYSTEM_TIME ALL;
GO

-- ESTRUCTURA 1.3 - Bitacora de respaldos (historial en msdb)
-- RECOVERY FULL es requisito para poder respaldar el log de transacciones
ALTER DATABASE TIENDA SET RECOVERY FULL;
GO
-- WITH NAME rotula el juego de respaldo e INIT sobrescribe el archivo.
-- Las rutas son dentro del contenedor, sobre el volumen /var/opt/mssql.
BACKUP DATABASE TIENDA TO DISK = N'/var/opt/mssql/data/TIENDA_FULL.bak' WITH NAME = N'Full', INIT;
GO
BACKUP LOG TIENDA TO DISK = N'/var/opt/mssql/data/TIENDA_LOG.bak' WITH NAME = N'Log', INIT;
GO

-- CUERI 1.3 - Bitacora de respaldos: ver historial en msdb
-- No hay tabla propia de historial de respaldos: el motor registra cada BACKUP en
-- msdb. backupset guarda un renglon por ejecucion y backupmediafamily el archivo.
SELECT bs.database_name,
       CASE bs.type WHEN 'D' THEN 'COMPLETO' WHEN 'L' THEN 'LOG' END AS tipo,
       bs.backup_start_date,
       bmf.physical_device_name
FROM   msdb.dbo.backupset bs
INNER JOIN msdb.dbo.backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
WHERE  bs.database_name = 'TIENDA';
GO

-- SECCION 2: TEMA PARTICIONES - 2 ejemplos

-- ESTRUCTURA 2.1 - Particion por fecha (tabla Venta)
-- Un solo valor limite genera 2 particiones. Con RANGE RIGHT el limite cae en la
-- particion de la derecha: particion 1 = fecha < 2026-01-01, particion 2 = >= 2026-01-01
CREATE PARTITION FUNCTION pf_Venta (datetime2(0)) AS RANGE RIGHT FOR VALUES ('2026-01-01');
GO
-- El esquema reparte las particiones en filegroups; aqui todas van a [PRIMARY],
-- el reparto real se usa cuando se quiere aislar fechas en discos distintos
CREATE PARTITION SCHEME ps_Venta AS PARTITION pf_Venta TO ([PRIMARY], [PRIMARY]);
GO
-- El indice no clusterizado se crea primero y despues se repite la PK como particionada,
-- porque una PK en tabla particionada debe incluir la columna de particion
CREATE INDEX IX_Venta_fecha ON dbo.Venta(fecha) ON ps_Venta(fecha);
ALTER TABLE dbo.Venta DROP CONSTRAINT PK_Venta;
ALTER TABLE dbo.Venta ADD CONSTRAINT PK_Venta PRIMARY KEY (id_venta, fecha) ON ps_Venta(fecha);
GO
-- Las ventas 1 y 2 caen en la particion 1; las ventas 3 y 4 en la particion 2
INSERT INTO dbo.Venta VALUES (1, '2025-03-14', 150), (2, '2025-11-02', 320), (3, '2026-02-20', 210), (4, '2026-07-08', 540);
GO

-- CUERI 2.1 - Particion por fecha: filas en cada particion
-- sys.partitions es una vista de catalogo: da una fila por indice y por particion.
-- Por eso conviene filtrar index_id; sin ese filtro cada particion sale duplicada
-- con filas = 0, que es lo que reporta el indice no clusterizado.
SELECT p.partition_number AS no_particion, p.rows AS filas
FROM   sys.partitions p
WHERE  p.object_id = OBJECT_ID('dbo.Venta')
GROUP BY p.partition_number, p.rows
ORDER BY p.partition_number;
GO

-- a que particion corresponde cada venta
-- El CASE reescribe en SQL la regla de RANGE RIGHT para poder ver el numero a mano
SELECT id_venta, fecha, monto,
       CASE WHEN fecha < '2026-01-01' THEN 1 ELSE 2 END AS no_particion
FROM   dbo.Venta;
GO

-- ESTRUCTURA 2.2 - Particion por rango numerico (tabla Pedido)
-- 2 valores limites generan 3 particiones:
-- 1 = monto < 100 | 2 = de 100 a 499 | 3 = >= 500
CREATE PARTITION FUNCTION pf_Pedido (int) AS RANGE RIGHT FOR VALUES (100, 500);
GO
CREATE PARTITION SCHEME ps_Pedido AS PARTITION pf_Pedido TO ([PRIMARY], [PRIMARY], [PRIMARY]);
GO
CREATE INDEX IX_Pedido_monto ON dbo.Pedido(monto) ON ps_Pedido(monto);
ALTER TABLE dbo.Pedido DROP CONSTRAINT PK_Pedido;
ALTER TABLE dbo.Pedido ADD CONSTRAINT PK_Pedido PRIMARY KEY (id_pedido, monto) ON ps_Pedido(monto);
GO
-- pedidos 1 -> particion 1 | pedidos 2 y 3 -> particion 2 | pedido 4 -> particion 3
INSERT INTO dbo.Pedido VALUES (1, 50), (2, 120), (3, 420), (4, 800);
GO

-- CUERI 2.2 - Particion por rango numerico: filas por particion
-- Misma vista de catalogo que en el CUERI 2.1, con el mismo detalle del index_id
SELECT p.partition_number AS no_particion, p.rows AS filas
FROM   sys.partitions p
WHERE  p.object_id = OBJECT_ID('dbo.Pedido')
GROUP BY p.partition_number, p.rows
ORDER BY p.partition_number;
GO

-- SECCION 3: TEMA PUBLICACION Y REPLICA 
-- Publica la tabla Producto de TIENDA hacia TIENDA_COPIA

-- ESTRUCTURA 3.1 - Publicacion (distribuidor + publicacion + articulo)
-- El nombre N'sqlserver' es el hostname del contenedor segun docker-compose.yml
USE master;
GO
-- sp_adddistributor registra la instancia como distribuidor. Solo corre una vez.
EXEC sp_adddistributor @distributor = N'sqlserver';
GO
-- Crea la base de trabajo del distribuidor, con los archivos en el volumen del contenedor
EXEC sp_adddistributiondb @database = N'Distribucion', @data_folder = N'/var/opt/mssql/data/', @log_folder = N'/var/opt/mssql/data/';
GO
-- @security_mode = 0 pide autenticacion de SQL Server (1 seria Windows integrada).
-- @working_directory es donde el agente deja los archivos de sincronizacion.
EXEC sp_adddistpublisher @publisher = N'sqlserver', @distribution_db = N'Distribucion',
     @working_directory = N'/var/opt/mssql/data/RepData', @security_mode = 0,
     @login = N'sa', @password = N'YourStrong@Password123';
GO
-- Marca TIENDA como publicable. Es lo que habilita las vistas de catalogo del CUERI 3.1
EXEC master..sp_replicationdboption @dbname = N'TIENDA', @optname = N'publish', @value = N'true';
GO
USE TIENDA;
GO
-- @sync_method = native compara las tablas directamente, sin generar scripts.
-- @repl_freq = continuous manda los cambios al instante en vez de por horario.
-- @retention = 0 conserva todos los comandos, sin podar los antiguos.
EXEC sp_addpublication @publication = N'PubProductos', @description = N'Publicacion de la tabla Producto',
     @sync_method = N'native', @allow_push = N'true', @allow_pull = N'true',
     @repl_freq = N'continuous', @status = N'active', @retention = 0;
GO
-- Decide que tabla entra en la publicacion
EXEC sp_addarticle @publication = N'PubProductos', @article = N'Producto', @source_object = N'Producto', @source_owner = N'dbo';
GO

-- CUERI 3.1 - Publicacion: ver publicacion y sus articulos
-- syspublications y sysarticles las crea el propio motor al marcar la base como
-- publicable, por eso se consultan con el prefijo dbo. y sin filtrar.
SELECT name AS publicacion, status FROM dbo.syspublications;
SELECT name AS articulo FROM dbo.sysarticles;
GO

-- ESTRUCTURA 3.2 - Replica (suscripcion push hacia TIENDA_COPIA)
-- push significa que los cambios los empuja el publicador, y eso exige que el
-- SQL Server Agent este corriendo. sync_type = automatic aplica los cambios de
-- golpe al crearse la suscripcion, y por eso TIENDA_COPIA ya queda con Producto.
EXEC sp_addsubscription @publication = N'PubProductos', @subscriber = N'sqlserver',
     @destination_db = N'TIENDA_COPIA', @subscription_type = N'push', @sync_type = N'automatic', @article = N'all';
GO

-- CUERI 3.2 - Replica: ver la suscripcion creada
-- syssubscriptions guarda, por cada articulo, que servidor y que base reciben los cambios
SELECT srvname AS suscriptor, dest_db AS base_destino, subscription_type
FROM   dbo.syssubscriptions;
GO
