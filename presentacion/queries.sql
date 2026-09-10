-- EQUIPO No. 3 | ADMINISTRACION DE BASES DE DATOS | SQL SERVER
-- queries.sql - CUERIs de la practica (cortas y sencillas, 1 por ejemplo)
-- DB sencilla: TIENDA
-- Requiere haber ejecutado antes: db.sql

USE TIENDA;
GO

-- =========== 1) TEMA: BITACORA (Responsable 1) ===========

-- CUERI 1.1 - Bitacora con trigger: ver que se registro
SELECT operacion, id_producto, nombre, precio, usuario, fecha
FROM   dbo.BitacoraProducto
ORDER BY id_evento;
GO

-- CUERI 1.2 - Bitacora con tabla temporal: ver todo el historial
SELECT *
FROM   dbo.Empleado
FOR SYSTEM_TIME ALL;
GO

-- CUERI 1.3 - Bitacora de respaldos: ver historial en msdb
SELECT bs.database_name,
       CASE bs.type WHEN 'D' THEN 'COMPLETO' WHEN 'L' THEN 'LOG' END AS tipo,
       bs.backup_start_date,
       bmf.physical_device_name
FROM   msdb.dbo.backupset bs
INNER JOIN msdb.dbo.backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
WHERE  bs.database_name = 'TIENDA';
GO

-- =========== 2) TEMA: PARTICIONES (Responsable 2) ===========

-- CUERI 2.1 - Particion por fecha: filas en cada particion
SELECT p.partition_number AS no_particion, p.rows AS filas
FROM   sys.partitions p
WHERE  p.object_id = OBJECT_ID('dbo.Venta')
GROUP BY p.partition_number, p.rows
ORDER BY p.partition_number;
GO

-- a que particion corresponde cada venta
SELECT id_venta, fecha, monto,
       CASE WHEN fecha < '2026-01-01' THEN 1 ELSE 2 END AS no_particion
FROM   dbo.Venta;
GO

-- CUERI 2.2 - Particion por rango numerico: filas por particion
SELECT p.partition_number AS no_particion, p.rows AS filas
FROM   sys.partitions p
WHERE  p.object_id = OBJECT_ID('dbo.Pedido')
GROUP BY p.partition_number, p.rows
ORDER BY p.partition_number;
GO

-- =========== 3) TEMA: PUBLICACION Y REPLICA (Responsable 3) ===========

-- CUERI 3.1 - Publicacion: ver publicacion y sus articulos
SELECT name AS publicacion, status FROM dbo.syspublications;
SELECT name AS articulo FROM dbo.sysarticles;
GO

-- CUERI 3.2 - Replica: ver la suscripcion creada
SELECT srvname AS suscriptor, dest_db AS base_destino, subscription_type
FROM   dbo.syssubscriptions;
GO

PRINT '=== queries.sql terminado ===';
GO