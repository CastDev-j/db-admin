-- =============================================
-- EXAMEN PRÁCTICO - SECCIÓN 3
-- SCRIPTS EJECUTABLES EN SQL SERVER (Docker)
-- =============================================

-- 1. Crear BD y tablas con PK
CREATE DATABASE Torneo;
GO
USE Torneo;
GO

CREATE TABLE Actividad (
    cve_ac INT PRIMARY KEY,
    Nom_act VARCHAR(100),
    lugar VARCHAR(100)
);
GO

CREATE TABLE Jefe (
    cve_encar INT PRIMARY KEY,
    nombre VARCHAR(100),
    puesto VARCHAR(50)
);
GO

-- 2. Crear índice agrupado y eliminarlo
CREATE CLUSTERED INDEX IX_Nom_act ON Actividad (Nom_act);
GO
DROP INDEX IX_Nom_act ON Actividad;
GO

-- 3. Crear login y usuario
CREATE LOGIN invitado WITH PASSWORD = 'Seguro123!';
GO
USE Torneo;
GO
CREATE USER Nuevo FOR LOGIN invitado;
GO

-- 4. Permisos: lectura en Actividad, denegado en Jefe
GRANT SELECT ON Actividad TO Nuevo;
GO
DENY SELECT ON Jefe TO Nuevo;
GO

-- 5. Crear índice no agrupado (aunque ya exista otro índice)
CREATE NONCLUSTERED INDEX IX_lugar ON Actividad (lugar);
GO
