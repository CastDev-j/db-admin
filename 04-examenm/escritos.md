¡Perfecto! Aquí tienes el **examen completo con respuestas cortas y directas**:

---

# EXAMEN COMPLETO - RESPUESTAS CORTAS

---

## SECCIÓN 1: PREGUNTAS TEÓRICAS (Valor 20 pts)

---

### 1. Explica los 3 niveles de arquitectura del SMBD.

- **Interno (Físico):** Cómo se almacenan los datos en disco (archivos, páginas, extensiones).
- **Conceptual (Lógico):** Qué datos hay y sus relaciones (tablas, columnas, llaves).
- **Externo (Vistas):** Lo que ve cada usuario (vistas personalizadas).

---

### 2. Describe cada uno de los términos (Definir, Construir, Manipular) de un SGBD.

- **Definir:** Crear la estructura de la BD con DDL (`CREATE`, `ALTER`, `DROP`).
- **Construir:** Insertar, modificar y eliminar datos con DML (`INSERT`, `UPDATE`, `DELETE`).
- **Manipular:** Consultar y recuperar datos con `SELECT`.

---

### 3. Menciona 5 ventajas del uso de un SMBD.

1. Reduce redundancia de datos.
2. Mantiene consistencia de datos.
3. Proporciona seguridad (usuarios y permisos).
4. Permite integridad referencial (llaves foráneas).
5. Permite acceso concurrente de múltiples usuarios.

---

### 4. Menciona y describe 3 tipos de archivos que genera SQL Server.

1. **.mdf (Principal):** Almacena metadatos y todos los objetos de la BD. Es obligatorio.
2. **.ndf (Secundario):** Archivos opcionales para distribuir datos en varios discos.
3. **.ldf (Log):** Registro de transacciones para recuperación ante fallos.

---

### 5. Menciona y explica 4 tipos de páginas que crea SQL Server.

1. **Datos:** Almacenan filas de tablas.
2. **Índice:** Almacenan entradas de índices (estructuras de búsqueda).
3. **Asignación (GAM/SGAM/IAM):** Controlan qué páginas/extensiones están en uso.
4. **Texto/Imagen:** Almacenan datos grandes (TEXT, IMAGE, VARCHAR(MAX)).

---

### 6. Define índice y cómo se clasifican.

**Índice:** Estructura que acelera las búsquedas en una tabla.

**Clasificación:**
- **Agrupado (Clustered):** Ordena físicamente los datos. Solo 1 por tabla.
- **No Agrupado (Non-Clustered):** Estructura separada con punteros a los datos. Hasta 999 por tabla.

---

### 7. Menciona todas las bases de datos que crea SQL Server.

1. **master:** Configuración del servidor y logins.
2. **model:** Plantilla para nuevas BD.
3. **msdb:** Trabajos, alertas y backups del Agente SQL.
4. **tempdb:** Tablas temporales y operaciones internas.
5. **Resource:** Objetos del sistema (oculta).

---

### 8. Menciona 3 puntos por los cuales no se deba utilizar una base de datos.

1. Datos muy pocos y aplicación simple (ej. agenda personal).
2. Sistemas de tiempo real que requieren latencia mínima.
3. Aplicaciones estáticas que solo leen configuración secuencial.

---

### 9. Menciona 7 consideraciones para elegir un SMBD.

1. Costo (licencias y hardware).
2. Rendimiento y escalabilidad.
3. Seguridad (cifrado, autenticación).
4. Soporte ACID (transacciones).
5. Compatibilidad con SO.
6. Facilidad de administración.
7. Soporte técnico y comunidad.

---

### 10. Menciona 6 funciones de un administrador de BD.

1. Instalación y configuración.
2. Monitoreo y ajuste de rendimiento.
3. Gestión de seguridad (usuarios y permisos).
4. Backups y recuperación.
5. Mantenimiento (índices, estadísticas).
6. Planificación de capacidad (crecimiento futuro).

---

## SECCIÓN 2: INSTRUCCIONES SQL SERVER (Valor 10 pts)

| # | Comando/Rol | Descripción |
|---|-------------|-------------|
| 1 | **sp_who** | Muestra qué usuarios están usando el servidor. |
| 2 | **sp_help** | Muestra la estructura de una tabla. |
| 3 | **sp_helptext** | Muestra el código de un procedimiento almacenado. |
| 4 | **sp_helpuser** | Muestra los usuarios de una base de datos. |
| | **sysadmin** | Puede realizar todas las actividades de configuración y mantenimiento. |
| 5 | **setupadmin** | Puede agregar y quitar servidores vinculados. |
| 6 | **securityadmin** | Administra inicios de sesión y permisos de servidor. |
| 7 | **db_owner** o **ddladmin** | Puede ejecutar comandos DDL en una BD. |
| 8 | **public** | No pueden leer datos de tablas de usuarios (permisos básicos). |
| 9 | **ALTER LOGIN ... WITH DEFAULT_DATABASE =** | Especifica la BD predeterminada al inicio de sesión. |
| 10 | **GRANT, DENY, REVOKE** | Administra permisos (conceder, denegar, revocar). |

---

## SECCIÓN 3: EJERCICIO PRÁCTICO (Valor 15 pts)

```sql
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
```

---

¿Necesitas que acorte o simplifique alguna respuesta más?
