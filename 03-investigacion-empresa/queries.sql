-- ============================================================
-- CONSULTAS BD_FIDELIZA
-- ============================================================

-- 1.- Clientes de un negocio con su saldo de puntos

SELECT n.nombre AS negocio, c.nombre, c.apellido, c.telefono, c.saldo_puntos
FROM cliente c
INNER JOIN negocio n ON c.id_negocio = n.id_negocio
ORDER BY n.nombre, c.saldo_puntos DESC;

-- 2.- Historial de movimientos de puntos por cliente

SELECT c.nombre, c.apellido, t.tipo, t.puntos, t.monto_compra, t.fecha
FROM transaccion_puntos t
INNER JOIN cliente c ON t.id_cliente = c.id_cliente
ORDER BY t.fecha DESC;

-- 3.- Top de clientes con mas puntos acumulados

SELECT TOP 5 c.nombre, c.apellido, SUM(puntos) AS puntos_ganados
FROM transaccion_puntos t
INNER JOIN cliente c ON t.id_cliente = c.id_cliente
WHERE t.tipo = 'ACUMULACION'
GROUP BY c.nombre, c.apellido
ORDER BY puntos_ganados DESC;

-- 4.- Recompensas mas canjeadas

SELECT r.nombre AS recompensa, COUNT(cj.id_canje) AS total_canjes
FROM canje cj
INNER JOIN recompensa r ON cj.id_recompensa = r.id_recompensa
GROUP BY r.nombre
ORDER BY total_canjes DESC;

-- 5.- Clientes que canjearon recompensas con el detalle

SELECT c.nombre, c.apellido, r.nombre AS recompensa, cj.puntos_usados, cj.fecha
FROM canje cj
INNER JOIN cliente c ON cj.id_cliente = c.id_cliente
INNER JOIN recompensa r ON cj.id_recompensa = r.id_recompensa
ORDER BY cj.fecha DESC;

-- 6.- Puntos acumulados por sucursal

SELECT s.nombre AS sucursal, COUNT(t.id_transaccion) AS num_movimientos,
       SUM(t.puntos) AS puntos_acumulados
FROM transaccion_puntos t
INNER JOIN sucursal s ON t.id_sucursal = s.id_sucursal
WHERE t.tipo = 'ACUMULACION'
GROUP BY s.nombre
ORDER BY puntos_acumulados DESC;

-- 7.- Monto de compras registrado por negocio

SELECT n.nombre AS negocio, ISNULL(SUM(t.monto_compra), 0) AS monto_vigilado
FROM negocio n
LEFT JOIN sucursal s ON n.id_negocio = s.id_negocio
LEFT JOIN transaccion_puntos t ON t.id_sucursal = s.id_sucursal
                                 AND t.tipo = 'ACUMULACION'
GROUP BY n.nombre;

-- 8.- Saldo promedio de puntos de los clientes por negocio

SELECT n.nombre AS negocio, AVG(c.saldo_puntos) AS saldo_promedio
FROM cliente c
INNER JOIN negocio n ON c.id_negocio = n.id_negocio
GROUP BY n.nombre;

-- 9.- Usuarios autorizados por negocio y rol

SELECT n.nombre AS negocio, u.nombre, u.rol
FROM usuario u
INNER JOIN negocio n ON u.id_negocio = n.id_negocio
ORDER BY n.nombre, u.rol;

-- 10.- Catálogo de recompensas vigentes por negocio

SELECT n.nombre AS negocio, r.nombre AS recompensa, r.costo_puntos, r.descripcion
FROM recompensa r
INNER JOIN negocio n ON r.id_negocio = n.id_negocio
WHERE r.fecha_fin IS NULL OR r.fecha_fin >= GETDATE()
ORDER BY n.nombre, r.costo_puntos;