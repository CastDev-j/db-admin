CREATE DATABASE BD_FIDELIZA;
GO
USE BD_FIDELIZA;

CREATE TABLE negocio (
    id_negocio INT IDENTITY (1,1) NOT NULL,
    nombre VARCHAR (60) NOT NULL,
    giro VARCHAR (60) NOT NULL,
    tipo_empresa VARCHAR (20) NOT NULL,
    telefono VARCHAR (20),
    correo VARCHAR (60),
    direccion VARCHAR (120),
    ciudad VARCHAR (60),
    regla_puntos VARCHAR (200),
    fecha_registro DATE,
    CONSTRAINT NegocioPK PRIMARY KEY (id_negocio)
)

CREATE TABLE sucursal (
    id_sucursal INT IDENTITY (1,1) NOT NULL,
    id_negocio INT NOT NULL,
    nombre VARCHAR (60) NOT NULL,
    direccion VARCHAR (120),
    telefono VARCHAR (20),
    CONSTRAINT SucursalPK PRIMARY KEY (id_sucursal),
    CONSTRAINT SucursalFK FOREIGN KEY (id_negocio) REFERENCES negocio (id_negocio)
)

CREATE TABLE usuario (
    id_usuario INT IDENTITY (1,1) NOT NULL,
    id_negocio INT NOT NULL,
    nombre VARCHAR (60) NOT NULL,
    correo VARCHAR (60),
    contrasena VARCHAR (100),
    rol VARCHAR (20) NOT NULL,
    CONSTRAINT UsuarioPK PRIMARY KEY (id_usuario),
    CONSTRAINT UsuarioFK FOREIGN KEY (id_negocio) REFERENCES negocio (id_negocio)
)

CREATE TABLE cliente (
    id_cliente INT IDENTITY (1,1) NOT NULL,
    id_negocio INT NOT NULL,
    telefono VARCHAR (20) NOT NULL,
    nombre VARCHAR (40),
    apellido VARCHAR (40),
    correo VARCHAR (60),
    saldo_puntos INT NOT NULL DEFAULT 0,
    fecha_registro DATE,
    CONSTRAINT ClientePK PRIMARY KEY (id_cliente),
    CONSTRAINT ClienteFK FOREIGN KEY (id_negocio) REFERENCES negocio (id_negocio),
    CONSTRAINT ClienteTelefonoUQ UNIQUE (telefono)
)

CREATE TABLE recompensa (
    id_recompensa INT IDENTITY (1,1) NOT NULL,
    id_negocio INT NOT NULL,
    nombre VARCHAR (60) NOT NULL,
    descripcion VARCHAR (200),
    costo_puntos INT NOT NULL,
    fecha_inicio DATE,
    fecha_fin DATE,
    CONSTRAINT RecompensaPK PRIMARY KEY (id_recompensa),
    CONSTRAINT RecompensaFK FOREIGN KEY (id_negocio) REFERENCES negocio (id_negocio)
)

CREATE TABLE transaccion_puntos (
    id_transaccion INT IDENTITY (1,1) NOT NULL,
    id_cliente INT NOT NULL,
    id_sucursal INT,
    id_usuario INT,
    tipo VARCHAR (15) NOT NULL,
    puntos INT NOT NULL,
    monto_compra FLOAT,
    fecha DATETIME,
    CONSTRAINT TransaccionPK PRIMARY KEY (id_transaccion),
    CONSTRAINT TransaccionFK1 FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente),
    CONSTRAINT TransaccionFK2 FOREIGN KEY (id_sucursal) REFERENCES sucursal (id_sucursal),
    CONSTRAINT TransaccionFK3 FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
)

CREATE TABLE canje (
    id_canje INT IDENTITY (1,1) NOT NULL,
    id_transaccion INT NOT NULL,
    id_recompensa INT NOT NULL,
    id_cliente INT NOT NULL,
    puntos_usados INT NOT NULL,
    fecha DATETIME,
    CONSTRAINT CanjePK PRIMARY KEY (id_canje),
    CONSTRAINT CanjeFK1 FOREIGN KEY (id_transaccion) REFERENCES transaccion_puntos (id_transaccion),
    CONSTRAINT CanjeFK2 FOREIGN KEY (id_recompensa) REFERENCES recompensa (id_recompensa),
    CONSTRAINT CanjeFK3 FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente)
)

-- Datos de ejemplo: una taqueria que usa Fideliza

INSERT INTO negocio (nombre, giro, tipo_empresa, telefono, correo, direccion, ciudad, regla_puntos, fecha_registro)
VALUES ('Taqueria El Pastorcito', 'Alimentos y bebidas', 'Micro', '4611234567', 'contacto@elpastorcito.mx', 'Av. Mexico 210', 'Celaya, Gto.', '1 punto por cada $1 de compra', '2026-08-01')
INSERT INTO negocio (nombre, giro, tipo_empresa, telefono, correo, direccion, ciudad, regla_puntos, fecha_registro)
VALUES ('Cafe La Terraza', 'Alimentos y bebidas', 'Mediana', '4617654321', 'hola@cafelaterraza.mx', 'Blvd. Adolfo Lopez Mateos 505', 'Celaya, Gto.', '10 puntos por cada visita de $50 o mas', '2026-08-15')

INSERT INTO sucursal (id_negocio, nombre, direccion, telefono) VALUES (1, 'Matriz Centro', 'Av. Mexico 210', '4611234567')
INSERT INTO sucursal (id_negocio, nombre, direccion, telefono) VALUES (1, 'Sucursal Campestre', 'Calz. Heroes 1500', '4612233445')
INSERT INTO sucursal (id_negocio, nombre, direccion, telefono) VALUES (2, 'Cafe Principal', 'Blvd. Adolfo Lopez Mateos 505', '4617654321')

INSERT INTO usuario (id_negocio, nombre, correo, contrasena, rol)
VALUES (1, 'Maria Lopez', 'maria@elpastorcito.mx', '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918', 'Administrador')
INSERT INTO usuario (id_negocio, nombre, correo, contrasena, rol)
VALUES (1, 'Juan Perez', 'juan@elpastorcito.mx', '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918', 'Cajero')
INSERT INTO usuario (id_negocio, nombre, correo, contrasena, rol)
VALUES (2, 'Ana Torres', 'ana@cafelaterraza.mx', '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918', 'Administrador')

INSERT INTO cliente (id_negocio, telefono, nombre, apellido, correo, saldo_puntos, fecha_registro)
VALUES (1, '4611001111', 'Pedro', 'Garcia', 'pedro.garcia@gmail.com', 0, '2026-08-02')
INSERT INTO cliente (id_negocio, telefono, nombre, apellido, correo, saldo_puntos, fecha_registro)
VALUES (1, '4611002222', 'Laura', 'Sanchez', 'laura.sanchez@gmail.com', 0, '2026-08-02')
INSERT INTO cliente (id_negocio, telefono, nombre, apellido, correo, saldo_puntos, fecha_registro)
VALUES (1, '4611003333', 'Carlos', 'Nunez', NULL, 0, '2026-08-05')
INSERT INTO cliente (id_negocio, telefono, nombre, apellido, correo, saldo_puntos, fecha_registro)
VALUES (2, '4611004444', 'Rosa', 'Millan', 'rosa.millan@gmail.com', 0, '2026-08-16')

INSERT INTO recompensa (id_negocio, nombre, descripcion, costo_puntos, fecha_inicio, fecha_fin)
VALUES (1, 'Taco gratis', 'Un taco al pastor gratis en cualquier sucursal', 50, '2026-08-01', NULL)
INSERT INTO recompensa (id_negocio, nombre, descripcion, costo_puntos, fecha_inicio, fecha_fin)
VALUES (1, 'Orden de gringas', 'Orden de gringas de cortesia', 120, '2026-08-01', NULL)
INSERT INTO recompensa (id_negocio, nombre, descripcion, costo_puntos, fecha_inicio, fecha_fin)
VALUES (2, 'Cafe gratis', 'Cafe americano o capuchino de cortesia', 100, '2026-08-15', NULL)

-- Acumulaciones de puntos en el negocio 1 (1 punto por cada $1)

INSERT INTO transaccion_puntos (id_cliente, id_sucursal, id_usuario, tipo, puntos, monto_compra, fecha)
VALUES (1, 1, 2, 'ACUMULACION', 120, 120.00, '2026-08-03 13:20:00')
INSERT INTO transaccion_puntos (id_cliente, id_sucursal, id_usuario, tipo, puntos, monto_compra, fecha)
VALUES (2, 1, 2, 'ACUMULACION', 85, 85.50, '2026-08-03 14:05:00')
INSERT INTO transaccion_puntos (id_cliente, id_sucursal, id_usuario, tipo, puntos, monto_compra, fecha)
VALUES (1, 1, 2, 'ACUMULACION', 60, 60.00, '2026-08-10 20:15:00')
INSERT INTO transaccion_puntos (id_cliente, id_sucursal, id_usuario, tipo, puntos, monto_compra, fecha)
VALUES (3, 2, 2, 'ACUMULACION', 45, 45.00, '2026-08-12 19:40:00')
INSERT INTO transaccion_puntos (id_cliente, id_sucursal, id_usuario, tipo, puntos, monto_compra, fecha)
VALUES (2, 2, 2, 'ACUMULACION', 90, 90.00, '2026-08-15 13:55:00')
INSERT INTO transaccion_puntos (id_cliente, id_sucursal, id_usuario, tipo, puntos, monto_compra, fecha)
VALUES (4, 3, 3, 'ACUMULACION', 150, 150.00, '2026-08-17 10:30:00')

-- Canje: Laura canjea 1 taco gratis (50 puntos)

INSERT INTO transaccion_puntos (id_cliente, id_sucursal, id_usuario, tipo, puntos, monto_compra, fecha)
VALUES (2, 1, 2, 'CANJE', -50, 0.00, '2026-08-20 13:10:00')

INSERT INTO canje (id_transaccion, id_recompensa, id_cliente, puntos_usados, fecha)
VALUES (7, 1, 2, 50, '2026-08-20 13:10:00')

-- Actualiza el saldo de cada cliente de acuerdo a sus movimientos

UPDATE cliente SET saldo_puntos =
    (SELECT ISNULL(SUM(puntos), 0) FROM transaccion_puntos t
     WHERE t.id_cliente = cliente.id_cliente)