# Actividad 3 — Práctica de Roles (BD Poemas)

## Conceptos clave

![[Pasted image 20261007215933.png]]

![[Pasted image 20261007220225.png]]

![[Pasted image 20261007220313.png]]

![[Pasted image 20261007220613.png]]

![[Pasted image 20261007220629.png]]

![[Pasted image 20261007220643.png]]

![[Pasted image 20261007220656.png]]

![[Pasted image 20261007220709.png]]

![[Pasted image 20261007220722.png]]

![[Pasted image 20261007220740.png]]

![[Pasted image 20261007220757.png]]

![[Pasted image 20261007220814.png]]
## Queries aplicadas (documentadas)

```sql
-- ============================================================
-- ACTIVIDAD 3: Práctica de roles - BD POEMAS
-- Muestra roles fijos de servidor y roles de la BD en uso
-- ============================================================
USE POEMAS;
GO

-- 1) Identificar el login y el usuario de la BD en uso
SELECT SUSER_SNAME() AS login_actual,      -- login usado para conectarse
       USER_NAME()     AS usuario_bd,      -- usuario dentro de la BD (dbo)
       CURRENT_USER    AS esquema_predeterminado; -- esquema por defecto (dbo)
GO

-- 2) ROLES FIJOS DE SERVIDOR: comando sp_helpsrvrole
-- Muestra los roles fijos de servidor y su descripción
EXEC sp_helpsrvrole;
GO

-- 2b) Roles fijos de servidor desde el catálogo sys.server_principals
SELECT name AS rol, type_desc, is_fixed_role AS es_fijo
FROM sys.server_principals
WHERE type = 'R' AND is_fixed_role = 1
ORDER BY name;
GO

-- 2c) Roles de servidor creados en este servidor (no fijos)
SELECT name AS rol, is_fixed_role AS es_fijo
FROM sys.server_principals
WHERE type = 'R' AND is_fixed_role = 0
ORDER BY name;
GO

-- 3) Miembros de los roles de servidor (qué login pertenece a qué rol)
EXEC sp_helpsrvrolemember;
GO

-- 4) ROLES DE LA BASE DE DATOS EN USO: sp_helprole
-- Lista los roles definidos dentro de la BD POEMAS
EXEC sp_helprole;
GO

-- 5) Roles asignados al usuario en uso (usuario de la BD activa)
SELECT r.name AS rol_asignado, r.type_desc AS tipo
FROM sys.database_role_members drm
JOIN sys.database_principals r ON drm.role_principal_id = r.principal_id
JOIN sys.database_principals m ON drm.member_principal_id = m.principal_id
WHERE m.name = USER_NAME();
GO

-- 6) Comprobación booleana con IS_ROLEMEMBER (0=no, 1=sí)
SELECT USER_NAME() AS usuario,
       IS_ROLEMEMBER('db_owner')        AS db_owner,
       IS_ROLEMEMBER('db_datareader')   AS db_datareader,
       IS_ROLEMEMBER('db_datawriter')   AS db_datawriter,
       IS_ROLEMEMBER('db_securityadmin') AS db_securityadmin;
GO

-- 7) Miembros de un rol concreto de la BD (sp_helprolemember)
EXEC sp_helprolemember 'db_owner';
GO
```
