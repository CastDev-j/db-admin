## Objetivo

| #   | Requisito                           | Cantidad      | Por comandos SQL      | Por editor grafico de SSMS |
| --- | ----------------------------------- | ------------- | --------------------- | -------------------------- |
| 1   | Logins (inicios de sesion)          | 2             | `fideliza_app`        | `fideliza_lectura`         |
| 2   | Usuarios de base de datos           | 2             | `usr_app`             | `usr_lectura`              |
| 3   | Permisos por usuario sobre 2 tablas | 2 por usuario | permisos de `usr_app` | permisos de `usr_lectura`  |
| 4   | Roles de servidor                   | 2             | `FidelizaSoporte`     | `FidelizaSeguridad`        |
| 5   | Roles de base de datos              | 2             | `FidelizaOperador`    | `FidelizaLectura`          |
| 6   | Esquemas                            | 2             | `operacion`           | `catalogo`                 |


## 1. Logins (2)

Un **login** es la credencial con la que una persona se conecta **al servidor**. Todavia no dice nada sobre que base de datos puede ver: eso lo define el usuario de base de datos.

### 1.1 Por comandos SQL — `fideliza_app`

```sql
USE master;
GO

CREATE LOGIN fideliza_app
WITH PASSWORD = 'Fideliza#2026',
     CHECK_POLICY = ON,
     CHECK_EXPIRATION = OFF;
GO

SELECT name, type_desc, is_policy_checked, is_disabled
FROM sys.sql_logins;
```

![[Pasted image 20260928134558.png]]

### 1.2 Por editor grafico de SSMS — `fideliza_lectura`

1. En **Object Explorer** hacer clic derecho sobre el **servidor** (`localhost,1433`) y elegir **Connect > Database Engine** si aun no hay conexion.
 - ![[Pasted image 20260928134719.png]]
1. Expandir el nodo del servidor y entrar a la carpeta **Security**.
2. Clic derecho sobre **Logins** y seleccionar **New Login...**.
	- ![[Pasted image 20260928135015.png]]
3. En la pestana **General**:
   - **Login name**: `fideliza_lectura`
   - **Authentication**: *SQL Server authentication*
   - **Password** y **Confirm password**: `Lectura#2026`
   - Dejar marcadas **Enforce password policy** y **Enforce password expiration**.
   - ![[Pasted image 20260928134859.png]]
4. En la pestana **User Mapping** se dejara vacia: aqui es donde despues se asigna el acceso a `BD_FIDELIZA` (se hace en el punto 2).
- ![[Pasted image 20260928135131.png]]
5. Clic en **OK** y aceptar el aviso de informacion.

![[Pasted image 20260928135312.png]]

## 2. Usuarios de base de datos (2)

El **usuario de base de datos** es el permiso de acceso **dentro de BD_FIDELIZA** y se liga a un login. El mismo login puede tener usuarios en varias bases de datos.

### 2.1 Por comandos SQL — `usr_app`

```sql
USE BD_FIDELIZA;
GO

CREATE USER usr_app FOR LOGIN fideliza_app;
GO

SELECT u.name AS usuario, l.name AS login
FROM sys.database_principals u
JOIN sys.sql_logins l ON l.sid = u.sid
WHERE u.type = 'S';
```

> No se usa `ALTER DATABASE ... SET TRUSTWORTHY` porque el login ya existe a nivel de servidor; solo hace falta vincularlo con `FOR LOGIN`.

![[Pasted image 20260928135520.png]]

### 2.2 Por editor grafico de SSMS — `usr_lectura`

1. En **Object Explorer** expandir **Databases > BD_FIDELIZA > Security > Users**.
2. Clic derecho sobre **Users** y elegir **New User...**.
	1. ![[Pasted image 20260928135650.png]]
3. En la pestana **General**:
   - **User name**: `usr_lectura`
   - **Type**: *SQL user with a login*
   - En **Login name** escribir `fideliza_lectura` (o pulsarlo con los puntos suspensivos y seleccionarlo del login creado en el punto 1.2).
   - ![[Pasted image 20260928135758.png]]
1. Clic en **OK**.

![[Pasted image 20260928135833.png]]

---

## 3. Permisos por usuario (2 por usuario, sobre 2 tablas)

Las dos tablas que se protegen son **`dbo.cliente`** y **`dbo.transaccion_puntos`**, porque concentran los datos sensibles del programa de fidelizacion.

| Usuario | Tabla | Permiso | Para que sirve |
|---------|-------|---------|----------------|
| `usr_app` | `dbo.cliente` | `SELECT` | Registrar y consultar clientes |
| `usr_app` | `dbo.transaccion_puntos` | `INSERT` | Generar acumulaciones y canjes |
| `usr_lectura` | `dbo.cliente` | `SELECT` | Reportes de clientes |
| `usr_lectura` | `dbo.transaccion_puntos` | `SELECT` | Reportes de puntos |

### 3.1 Por comandos SQL — permisos de `usr_app`

```sql
USE BD_FIDELIZA;
GO

GRANT SELECT ON dbo.cliente TO usr_app;
GRANT INSERT ON dbo.transaccion_puntos TO usr_app;
GO

EXEC sp_helpuser 'usr_app';
```

> `sp_helpuser` lista los permisos que tiene el usuario. Si se ejecuta un `SELECT` o un `INSERT` sobre una tabla sin permiso, SQL Server responde con el error 229: *The SELECT permission was denied on the object 'cliente'*.

![[Pasted image 20260928140040.png]]
### 3.2 Por editor grafico de SSMS — permisos de `usr_lectura`

Opcion A (recomendada, una sola vista):

1. En **Object Explorer** entrar a **Tables** de `BD_FIDELIZA` y seleccionar la tabla **`dbo.cliente`**.
	1. ![[Pasted image 20260928140213.png]]
2. Abrir el panel de propiedades con **View > Properties Window** (o `F4`).
	1. ![[Pasted image 20260928140314.png]]
3. En la pestana **Permissions** hacer clic en **Search** y elegir el tipo de objeto **Tables** o **Database Objects**.
4. Clic en **Add...**, seleccionar el principal **`usr_lectura`** y pulsar **OK**.
	1. ![[Pasted image 20260928140459.png]]
5. En la cuadricula marcar la casilla **Select** bajo la columna **Permisos**.
	1. ![[Pasted image 20260928140658.png]]
6. Repetir los pasos 1 a 5 para **`dbo.transaccion_puntos`** con el mismo usuario.
	1. ![[Pasted image 20260928140620.png]]


## 4. Esquemas (2)

Un **esquema** es un contenedor de objetos con formato `esquema.objeto`. Permite organizar los objetos y separarlos del usuario `dbo`.

- `operacion`: objetos que usa la aplicacion al momento de registrar movimientos.
- `catalogo`: objetos de solo consulta para reportes.

### 4.1 Por comandos SQL — `operacion`

```sql
USE BD_FIDELIZA;
GO

CREATE SCHEMA operacion AUTHORIZATION dbo;
GO

-- Objeto de ejemplo que se apoya en el esquema (una vista no cuenta como tabla del modelo)
CREATE VIEW operacion.v_movimientos_recientes
AS
SELECT t.tipo, t.puntos, t.monto_compra, t.fecha,
       c.nombre, c.apellido, s.nombre AS sucursal
FROM dbo.transaccion_puntos t
JOIN dbo.cliente c ON c.id_cliente = t.id_cliente
LEFT JOIN dbo.sucursal s ON s.id_sucursal = t.id_sucursal;
GO

GRANT SELECT ON SCHEMA::operacion TO usr_app;

SELECT name, schema_id, principal_id
FROM sys.schemas
WHERE name IN ('operacion', 'catalogo');
```

> El esquema se crea vacio y se le incorporan objetos con `esquema.objeto`. En este ejercicio la vista `operacion.v_movimientos_recientes` demuestra el uso del esquema sin agregar una tabla nueva al modelo de Fideliza.

![[Pasted image 20260928140934.png]]

### 4.2 Por editor grafico de SSMS — `catalogo`

1. En **Object Explorer** entrar a **Databases > BD_FIDELIZA > Security > Schemas**.
	1. ![[Pasted image 20260928141640.png]]
2. Clic derecho sobre **Schemas** y elegir **New Schema...**.
	1. ![[Pasted image 20260928141654.png]]
3. En el campo **Schema name** escribir `catalogo`.
4. En **Schema Owner** dejar o seleccionar `dbo`.
	1. ![[Pasted image 20260928141733.png]]
5. Clic en **OK**.

![[Pasted image 20260928141807.png]]

## 5. Roles de servidor (2)

Un **rol de servidor** agrupa logins y les concede permisos de alcance **todo el servidor**.

| Rol | Permiso de servidor | Que habilita |
|-----|---------------------|--------------|
| `FidelizaSoporte` | `VIEW SERVER STATE` | Ver el estado y el rendimiento del servidor para dar soporte |
| `FidelizaSeguridad` | `VIEW ANY DATABASE` | Ver los usuarios y permisos de todas las bases para auditar |

### 5.1 Por comandos SQL — `FidelizaSoporte`

```sql
USE master;
GO

CREATE SERVER ROLE FidelizaSoporte;
GO

GRANT VIEW SERVER STATE TO FidelizaSoporte;

ALTER SERVER ROLE FidelizaSoporte ADD MEMBER fideliza_app;
GO

SELECT r.name AS rol_servidor, p.permission_name AS permiso, p.state_desc AS estado
FROM sys.server_permissions p
INNER JOIN sys.server_principals r ON r.principal_id = p.grantee_principal_id
WHERE r.name = 'FidelizaSoporte';
GO

SELECT r.name AS rol_servidor, m.name AS miembro
FROM sys.server_role_members rm
INNER JOIN sys.server_principals r ON r.principal_id = rm.role_principal_id
INNER JOIN sys.server_principals m ON m.principal_id = rm.member_principal_id
WHERE r.name LIKE 'Fideliza%';
```

> A diferencia del usuario de base de datos, aqui el miembro se agrega con el nombre del **login**. El procedimiento `sp_helpsrvrole` solo acepta roles de servidor **fijos** (`sysadmin`, `dbcreator`, etc.), por eso los roles propios se verifican consultando `sys.server_permissions` y `sys.server_role_members`.

![[Pasted image 20260928142010.png]]

### 5.2 Por editor grafico de SSMS — `FidelizaSeguridad`

1. En **Object Explorer** del **servidor**, entrar a **Security > Server Roles**.
	1. ![[Pasted image 20260928142042.png]]
2. Clic derecho sobre **Server Roles** y elegir **New Server Role...**.
	1. ![[Pasted image 20260928142052.png]]
3. En **General** escribir el nombre `FidelizaSeguridad`.
	1. ![[Pasted image 20260928142117.png]]
4. Clic en **Permissions**, en la cuadricula marcar **View any database** y luego en **OK**.
5. Clic derecho sobre el rol creado y elegir **Properties**.
	1. ![[Pasted image 20260928142419.png]]
6. Pestana **Users**, clic en **Add...**, agregar el login `fideliza_lectura` y aceptar.
	1. ![[Pasted image 20260928142358.png]]

![[Pasted image 20260928142601.png]]

---

## 6. Roles de base de datos (2)

Un **rol de base de datos** agrupa **usuarios** (no logins) dentro de `BD_FIDELIZA` y es la forma correcta de conceder permisos cuando varios usuarios necesitan lo mismo.

| Rol | Permisos | Miembros |
|-----|----------|----------|
| `FidelizaOperador` | `SELECT, INSERT, UPDATE` sobre `dbo.cliente` e `INSERT` sobre `dbo.transaccion_puntos` | `usr_app` |
| `FidelizaLectura` | `SELECT` sobre `dbo.cliente` y `dbo.transaccion_puntos` | `usr_lectura` |

### 6.1 Por comandos SQL — `FidelizaOperador`

```sql
USE BD_FIDELIZA;
GO

CREATE ROLE FidelizaOperador AUTHORIZATION dbo;
GO

GRANT SELECT, INSERT, UPDATE ON dbo.cliente TO FidelizaOperador;
GRANT INSERT ON dbo.transaccion_puntos TO FidelizaOperador;

ALTER ROLE FidelizaOperador ADD MEMBER usr_app;
GO

EXEC sp_helpuser 'usr_app';
GO

SELECT r.name AS rol_base_datos, m.name AS miembro
FROM sys.database_role_members rm
INNER JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
INNER JOIN sys.database_principals m ON m.principal_id = rm.member_principal_id
WHERE r.name LIKE 'Fideliza%';
```

> En la salida de `sp_helpuser` el permiso aparece con el nombre del rol, porque un miembro hereda los permisos del rol al que pertenece. La segunda consulta lista a que rol pertenece cada usuario.

![[Pasted image 20260928142632.png]]

### 6.2 Por editor grafico de SSMS — `FidelizaLectura`

1. En **Object Explorer** entrar a **Databases > BD_FIDELIZA > Security > Database Roles**.
	1. ![[Pasted image 20260928142715.png]]
2. Clic derecho sobre **Database Roles** y elegir **New Database Role...**.
	1. ![[Pasted image 20260928142734.png]]
3. En **General** escribir el nombre `FidelizaLectura` y seleccionar como propietario `dbo`.
	1. ![[Pasted image 20260928142801.png]]
4. Clic en **Securables** y mediante **Add...** agregar los objetos `cliente` y `transaccion_puntos`.
	1. ![[Pasted image 20260928143432.png]]
	2. ![[Pasted image 20260928143449.png]]
5. En la cuadricula marcar **Select** para ambos objetos y pulsar **OK**.
	1. ![[Pasted image 20260928143508.png]]
6. Clic derecho sobre el rol creado > **Properties** > pestana **Members** > **Add...** > elegir el usuario `usr_lectura` > **OK**.
	1. ![[Pasted image 20260928143550.png]]

![[Pasted image 20260928143614.png]]

---

## 7. Verificacion

Consultas de comprobacion para incluir como evidencia de la practica.

### 7.1 Logins, usuarios y roles creados

```sql
SELECT name, type_desc, create_date
FROM sys.server_principals
WHERE name LIKE 'Fideliza%'
ORDER BY name;
GO

SELECT name, type_desc
FROM sys.database_principals
WHERE name LIKE 'usr[_]%'
   OR name LIKE 'Fideliza%'
ORDER BY name;
GO

SELECT s.name AS esquema, o.name AS objeto, o.type_desc
FROM sys.objects o
JOIN sys.schemas s ON s.schema_id = o.schema_id
WHERE s.name IN ('operacion', 'catalogo');
```

![[Pasted image 20260928143652.png]]

### 7.2 Permisos efectivos por usuario

```sql
USE BD_FIDELIZA;
GO

SELECT dp.name AS principal,
       CASE dp.type WHEN 'R' THEN 'ROL' ELSE 'USUARIO' END AS tipo_principal,
       CASE perm.class
            WHEN 1 THEN OBJECT_SCHEMA_NAME(perm.major_id) + '.' + OBJECT_NAME(perm.major_id)
            ELSE 'ESQUEMA: ' + SCHEMA_NAME(perm.major_id)
       END AS objeto,
       perm.permission_name AS permiso,
       perm.state_desc AS estado
FROM sys.database_permissions perm
INNER JOIN sys.database_principals dp ON dp.principal_id = perm.grantee_principal_id
WHERE perm.class IN (1, 3)
  AND (dp.name LIKE 'usr[_]%' OR dp.name LIKE 'Fideliza%')
ORDER BY dp.name, objeto, permiso;
```

> En `sys.database_permissions`, `class = 1` corresponde a permisos de objeto (las tablas) y `class = 3` a permisos de esquema. Ojo: la columna `state` es `char(1)` con los valores `G` (grant) y `W` (with deny), y el texto legible esta en `state_desc`.

> Los permisos concedidos directamente a un usuario y los heredados de un rol se listan por separado; en tiempo de ejecucion SQL Server toma la union de ambos.

![[Pasted image 20260928143722.png]]

### 7.3 Prueba de bloqueo

```sql
USE BD_FIDELIZA;
GO

EXECUTE AS USER = 'usr_lectura';
GO

SELECT USER_NAME() AS usuario_simulado;
GO

-- Debe funcionar: el usuario tiene SELECT
SELECT TOP 3 * FROM dbo.cliente;
GO

-- Debe fallar con el error 229: UPDATE no concedido
UPDATE dbo.cliente SET nombre = 'Prueba';
GO

REVERT;
```


![[Pasted image 20260928145740.png]]

![[Pasted image 20260928145755.png]]

## 8. Resumen de objetos creados

| Objeto | Tipo | Creado por | Pertenece a |
|--------|------|-----------|-------------|
| `fideliza_app` | Login | Comandos SQL | Servidor |
| `fideliza_lectura` | Login | Editor grafico SSMS | Servidor |
| `usr_app` | Usuario de BD | Comandos SQL | `BD_FIDELIZA` |
| `usr_lectura` | Usuario de BD | Editor grafico SSMS | `BD_FIDELIZA` |
| `operacion` | Esquema | Comandos SQL | `BD_FIDELIZA` |
| `catalogo` | Esquema | Editor grafico SSMS | `BD_FIDELIZA` |
| `FidelizaSoporte` | Rol de servidor | Comandos SQL | Servidor |
| `FidelizaSeguridad` | Rol de servidor | Editor grafico SSMS | Servidor |
| `FidelizaOperador` | Rol de BD | Comandos SQL | `BD_FIDELIZA` |
| `FidelizaLectura` | Rol de BD | Editor grafico SSMS | `BD_FIDELIZA` |

