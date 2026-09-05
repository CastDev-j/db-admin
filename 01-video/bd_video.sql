CREATE DATABASE BD_VIDEOS;
GO
USE BD_VIDEOS;

CREATE TABLE itc_Cliente(
cve_C INT IDENTITY (1,1) NOT NULL,
nombre VARCHAR (40),
direccion VARCHAR (50),
telefono CHAR (20),
CONSTRAINT ClientePK PRIMARY KEY (cve_c)
)

CREATE TABLE itc_cat_devol(
cve_devol INT IDENTITY(1,1) NOT NULL,
situacion VARCHAR (20) NOT NULL,
CONSTRAINT DevolPK PRIMARY KEY (cve_devol)
)

CREATE TABLE itc_paises(
cve_pa INT IDENTITY (1,1) NOT NULL,
pais VARCHAR (30),
CONSTRAINT PaisesPK PRIMARY KEY (cve_pa)
)

CREATE TABLE itc_Director(
cve_d INT IDENTITY (1,1) NOT NULL,
nombre VARCHAR (40),
cve_pa INT,
CONSTRAINT DirectorPK PRIMARY KEY (cve_d),
CONSTRAINT DirectorFK FOREIGN KEY (cve_pa) REFERENCES itc_paises (cve_pa)
)

CREATE TABLE itc_Categoria(
cve_cat INT IDENTITY (1,1) NOT NULL,
nombre VARCHAR (30),
CONSTRAINT CategoriaPK PRIMARY KEY (cve_cat)
)

CREATE TABLE itc_estatus(
cve_es INT IDENTITY (1,1) NOT NULL,
situacion VARCHAR (30),
costoXdia VARCHAR (10),
CONSTRAINT estatusPK PRIMARY KEY (cve_es)
)

CREATE TABLE itc_genero(
cve_g INT IDENTITY (1,1) NOT NULL,
genero VARCHAR (30),
CONSTRAINT GeneroPK PRIMARY KEY (cve_g)
)

CREATE TABLE itc_Pelicula(
cve_P INT IDENTITY (1,1) NOT NULL,
estatus INT,
cve_ge INT,
pais_prod INT,
cve_dir INT,
cve_categ INT,
titulo VARCHAR (50) NOT NULL,
año CHAR (4),
existencia INT,
CONSTRAINT PeliculaPK PRIMARY KEY (cve_p),
CONSTRAINT PeliculaFK1 FOREIGN KEY (estatus) REFERENCES itc_estatus (cve_es),
CONSTRAINT PeliculaFK2 FOREIGN KEY (cve_ge) REFERENCES itc_genero (cve_g),
CONSTRAINT PeliculaFK3 FOREIGN KEY (pais_prod) REFERENCES itc_paises (cve_pa),
CONSTRAINT PeliculaFK4 FOREIGN KEY (cve_dir) REFERENCES itc_Director (cve_d),
CONSTRAINT PeliculaFK5 FOREIGN KEY (cve_categ) REFERENCES itc_categoria (cve_cat)
)

CREATE TABLE itc_Renta(
folio INT IDENTITY (1,1) NOT NULL,
cve_p INT,
cve_c INT,
cve_devol INT,
fecha_prestamo DATE,
dias INT,
costoXdia VARCHAR (10),
CONSTRAINT RentaPK PRIMARY KEY (folio),
CONSTRAINT RentaFK1 FOREIGN KEY (cve_p) REFERENCES itc_pelicula (cve_p),
CONSTRAINT RentaFK2 FOREIGN KEY (cve_c) REFERENCES itc_cliente (cve_c),
CONSTRAINT RentaFK3 FOREIGN KEY (cve_devol) REFERENCES itc_cat_devol (cve_devol)
)


INSERT INTO itc_Cliente(nombre,direccion,telefono)
VALUES ('JOSE DOMINGUEZ PEREZ','BENITO JUAREZ #453','46289343')
INSERT INTO itc_Cliente(nombre,direccion,telefono)
VALUES ('LUCIA MARTINEZ PEREZ','FCO. JUAREZ #53','46282341')
INSERT INTO itc_Cliente(nombre,direccion,telefono)
VALUES ('MIGUEL LOPEZ LOPEZ','FCO. MADERO #45','46233443')
INSERT INTO itc_Cliente(nombre,direccion,telefono)
VALUES ('ANTONIA PEREZ PEREZ','VASCONCELOS #123','46285734')
INSERT INTO itc_Cliente(nombre,direccion,telefono)
VALUES ('JUAN JOSE YUNES PESCADOR','VASCONCELOS #452','461233243')
INSERT INTO itc_Cliente(nombre,direccion,telefono)
VALUES ('MARIA MARTINEZ JIMENEZ','AGUILAR Y MAYA #18','4612373')
INSERT INTO itc_Cliente(nombre,direccion,telefono)
VALUES ('JOSEFA DAMIAN VELASCO','JALISCO #120','461231943')
INSERT INTO itc_Cliente(nombre,direccion,telefono)
VALUES ('RICARDO JUAREZ FRANCO','BENITO ALMIRES #201','46144233')
INSERT INTO itc_Cliente(nombre,direccion,telefono)
VALUES ('ROSA MARIA IRIARTE GOMEZ','BENITO JUAREZ #453','46289343')
INSERT INTO itc_Cliente(nombre,direccion,telefono)
VALUES ('DANIEL ROMERO SANCHEZ','TAMAULIPAS #304','46134422')
INSERT INTO itc_Cliente(nombre,direccion,telefono)
VALUES ('ROBERTO RAMIREZ JUAREZ','BOULEVARD #1001','46135634')
INSERT INTO itc_Cliente(nombre,direccion,telefono)
VALUES ('HUGO DUARTE MIRANDA','BOULEVARD #1050','4614542233')


INSERT INTO itc_cat_devol(situacion)
VALUES ('ENTREGADO')
INSERT INTO itc_cat_devol(situacion)
VALUES ('ESPERA')


INSERT INTO itc_paises(pais)
VALUES ('MEXICO')
INSERT INTO itc_paises(pais)
VALUES ('USA')
INSERT INTO itc_paises(pais)
VALUES ('ITALIA')
INSERT INTO itc_paises(pais)
VALUES ('ESPAÑA')
INSERT INTO itc_paises(pais)
VALUES ('AUSTRALIA')
INSERT INTO itc_paises(pais)
VALUES ('INGLATERRA')



INSERT INTO itc_Director(nombre,cve_pa)
VALUES ('ALFONSO CUARON','1')
INSERT INTO itc_Director(nombre,cve_pa)
VALUES ('MEL GIBSON','5')
INSERT INTO itc_Director(nombre,cve_pa)
VALUES ('JAMES CAMERON','2')
INSERT INTO itc_Director(nombre,cve_pa)
VALUES ('TIM BURTON','2')
INSERT INTO itc_Director(nombre,cve_pa)
VALUES ('PEDRO ALMODOVAR','4')
INSERT INTO itc_Director(nombre,cve_pa)
VALUES ('GUILLERMO DEL TORO','1')
INSERT INTO itc_Director(nombre,cve_pa)
VALUES ('QUENTIN TARANTINO','2')
INSERT INTO itc_Director(nombre,cve_pa)
VALUES ('PETER JACKSON','2')
INSERT INTO itc_Director(nombre,cve_pa)
VALUES ('ROBERTO BENIGNI','3')



INSERT INTO itc_Categoria(nombre)
VALUES ('INFANTIL')
INSERT INTO itc_Categoria(nombre)
VALUES ('NIÑOS')
INSERT INTO itc_Categoria(nombre)
VALUES ('ADOLESCENTES')
INSERT INTO itc_Categoria(nombre)
VALUES ('ADULTOS')


INSERT INTO itc_estatus(situacion,costoXdia)
VALUES ('ESTRENO','35.5')
INSERT INTO itc_estatus(situacion,costoXdia)
VALUES ('RECIENTE','30')
INSERT INTO itc_estatus(situacion,costoXdia)
VALUES ('CLASICA','26.5')
INSERT INTO itc_estatus(situacion,costoXdia)
VALUES ('ANTIGUA','15')

INSERT INTO itc_genero(genero)
VALUES ('TERROR')
INSERT INTO itc_genero(genero)
VALUES ('ROMANCE')
INSERT INTO itc_genero(genero)
VALUES ('ACCION')
INSERT INTO itc_genero(genero)
VALUES ('CIENCIA FICCION')
INSERT INTO itc_genero(genero)
VALUES ('SUSPENSO')
INSERT INTO itc_genero(genero)
VALUES ('WESTERN')
INSERT INTO itc_genero(genero)
VALUES ('BELICOS')
INSERT INTO itc_genero(genero)
VALUES ('DRAMA')
INSERT INTO itc_genero(genero)
VALUES ('COMEDIA')
INSERT INTO itc_genero(genero)
VALUES ('EPICAS HISTORIAS')
INSERT INTO itc_genero(genero)
VALUES ('ANIMACION')


INSERT INTO itc_pelicula(titulo,año,pais_prod,existencia,estatus,cve_dir,cve_categ,cve_ge)
VALUES ('TERMINATOR','1984','2','3','3','3','3','4')
INSERT INTO itc_pelicula(titulo,año,pais_prod,existencia,estatus,cve_dir,cve_categ,cve_ge)
VALUES ('EL SECRETO DEL ABISMO','1989','2','4','4','3','3','4')
INSERT INTO itc_pelicula(titulo,año,pais_prod,existencia,estatus,cve_dir,cve_categ,cve_ge)
VALUES ('ALIEN','1986','2','6','3','3','4','1')
INSERT INTO itc_pelicula(titulo,año,pais_prod,existencia,estatus,cve_dir,cve_categ,cve_ge)
VALUES ('TITANIC','1997','2','7','3','3','3','2')
INSERT INTO itc_pelicula(titulo,año,pais_prod,existencia,estatus,cve_dir,cve_categ,cve_ge)
VALUES ('CORAZON VALIENTE','1995','3','3','2','2','4','8')
INSERT INTO itc_pelicula(titulo,año,pais_prod,existencia,estatus,cve_dir,cve_categ,cve_ge)
VALUES ('EL HOMBRE SIN ROSTRO','1993','2','1','4','2','4','8')
INSERT INTO itc_pelicula(titulo,año,pais_prod,existencia,estatus,cve_dir,cve_categ,cve_ge)
VALUES ('LA PASION DE CRISTO','2004','5','4','2','2','4','8')
INSERT INTO itc_pelicula(titulo,año,pais_prod,existencia,estatus,cve_dir,cve_categ,cve_ge)
VALUES ('HARRY POTTER Y EL PRISIONERO DE ASKHABAM','2004','6','4','2','1','3','3')
INSERT INTO itc_pelicula(titulo,año,pais_prod,existencia,estatus,cve_dir,cve_categ,cve_ge)
VALUES ('Y TU MAMA TAMBIEN','2001','1','3','4','1','3','9')
INSERT INTO itc_pelicula(titulo,año,pais_prod,existencia,estatus,cve_dir,cve_categ,cve_ge)
VALUES ('GRANDES ESPERANZAS','1997','2','3','4','1','4','8')
INSERT INTO itc_pelicula(titulo,año,pais_prod,existencia,estatus,cve_dir,cve_categ,cve_ge)
VALUES ('ELCADAVER DE LA NOVIA','2005','2','5','2','4','2','11')
INSERT INTO itc_pelicula(titulo,año,pais_prod,existencia,estatus,cve_dir,cve_categ,cve_ge)
VALUES ('SLEEPY HOLLOW','1999','2','7','3','4','4','1')
INSERT INTO itc_pelicula(titulo,año,pais_prod,existencia,estatus,cve_dir,cve_categ,cve_ge)
VALUES ('BATMAN RETURNS','1992','2','3','4','4','3','3')
INSERT INTO itc_pelicula(titulo,año,pais_prod,existencia,estatus,cve_dir,cve_categ,cve_ge)
VALUES ('EDUARDO MANOS DE TIJERAS','1990','2','4','4','4','4','8')
INSERT INTO itc_pelicula(titulo,año,pais_prod,existencia,estatus,cve_dir,cve_categ,cve_ge)
VALUES ('HABLE CON ELLA','2002','4','1','4','5','4','8')
INSERT INTO itc_pelicula(titulo,año,pais_prod,existencia,estatus,cve_dir,cve_categ,cve_ge)
VALUES ('EL LABERINTO DEL FAUNO','2006','4','4','1','6','3','3')
INSERT INTO itc_pelicula(titulo,año,pais_prod,existencia,estatus,cve_dir,cve_categ,cve_ge)
VALUES ('HELL BOY','2004','2','5','4','6','3','3')
INSERT INTO itc_pelicula(titulo,año,pais_prod,existencia,estatus,cve_dir,cve_categ,cve_ge)
VALUES ('EL ESPINAZO DEL DIABLO','2000','4','6','4','6','4','1')
INSERT INTO itc_pelicula(titulo,año,pais_prod,existencia,estatus,cve_dir,cve_categ,cve_ge)
VALUES ('MIMIC','1997','2','3','4','6','4','1')
INSERT INTO itc_pelicula(titulo,año,pais_prod,existencia,estatus,cve_dir,cve_categ,cve_ge)
VALUES ('BLADE II','2002','2','1','4','6','3','3')
INSERT INTO itc_pelicula(titulo,año,pais_prod,existencia,estatus,cve_dir,cve_categ,cve_ge)
VALUES ('KILL BILL 1','2003','2','1','4','7','3','3')
INSERT INTO itc_pelicula(titulo,año,pais_prod,existencia,estatus,cve_dir,cve_categ,cve_ge)
VALUES ('KILL BILL 2','2004','2','2','4','7','3','3')
INSERT INTO itc_pelicula(titulo,año,pais_prod,existencia,estatus,cve_dir,cve_categ,cve_ge)
VALUES ('KING KONG','2005','2','5','2','8','4','3')
INSERT INTO itc_pelicula(titulo,año,pais_prod,existencia,estatus,cve_dir,cve_categ,cve_ge)
VALUES ('LA COMUNIDAD DEL ANILLO','2001','6','5','3','8','3','3')
INSERT INTO itc_pelicula(titulo,año,pais_prod,existencia,estatus,cve_dir,cve_categ,cve_ge)
VALUES ('LAS DOS TORRES EL SECUESTRO','2002','6','8','3','8','3','3')
INSERT INTO itc_pelicula(titulo,año,pais_prod,existencia,estatus,cve_dir,cve_categ,cve_ge)
VALUES ('LA VIDA ES BELLA','1997','3','1','4','9','4','8')



INSERT INTO itc_Renta(cve_p,cve_c,fecha_prestamo,dias,costoXdia,cve_devol)
           values('4','7','20070101','3','38.5','1');
INSERT INTO itc_Renta(cve_p,cve_c,fecha_prestamo,dias,costoXdia,cve_devol)
           values('20','4','20070102','2','25','1');
INSERT INTO itc_Renta(cve_p,cve_c,fecha_prestamo,dias,costoXdia,cve_devol)
           values('1','5','20070104','4','25.5','2');
INSERT INTO itc_Renta(cve_p,cve_c,fecha_prestamo,dias,costoXdia,cve_devol)
           values('5','2','20070108','1','15','1');
INSERT INTO itc_Renta(cve_p,cve_c,fecha_prestamo,dias,costoXdia,cve_devol)
           values('14','6','20070115','3','15','2');
INSERT INTO itc_Renta(cve_p,cve_c,fecha_prestamo,dias,costoXdia,cve_devol)
           values('6','3','20070122','4','25.5','1');
INSERT INTO itc_Renta(cve_p,cve_c,fecha_prestamo,dias,costoXdia,cve_devol)
           values('4','8','20070204','3','36','1');
INSERT INTO itc_Renta(cve_p,cve_c,fecha_prestamo,dias,costoXdia,cve_devol)
           values('16','2','20070208','3','30','1');
INSERT INTO itc_Renta(cve_p,cve_c,fecha_prestamo,dias,costoXdia,cve_devol)
           values('20','1','20070218','4','25.5','1');
INSERT INTO itc_Renta(cve_p,cve_c,fecha_prestamo,dias,costoXdia,cve_devol)
           values('2','3','20070227','1','18.3','1');
INSERT INTO itc_Renta(cve_p,cve_c,fecha_prestamo,dias,costoXdia,cve_devol)
           values('12','3','20070303','1','25.5','1');
INSERT INTO itc_Renta(cve_p,cve_c,fecha_prestamo,dias,costoXdia,cve_devol)
           values('6','5','20070312','4','25.5','2');
INSERT INTO itc_Renta(cve_p,cve_c,fecha_prestamo,dias,costoXdia,cve_devol)
           values('1','6','20070402','2','20.4','1');
INSERT INTO itc_Renta(cve_p,cve_c,fecha_prestamo,dias,costoXdia,cve_devol)
           values('10','6','20070414','3','25','1');
INSERT INTO itc_Renta(cve_p,cve_c,fecha_prestamo,dias,costoXdia,cve_devol)
           values('13','5','20070423','4','25.5','1');
INSERT INTO itc_Renta(cve_p,cve_c,fecha_prestamo,dias,costoXdia,cve_devol)
           values('4','12','20070505','3','38.5','1');
INSERT INTO itc_Renta(cve_p,cve_c,fecha_prestamo,dias,costoXdia,cve_devol)
           values('12','12','20070515','3','25.5','1');
INSERT INTO itc_Renta(cve_p,cve_c,fecha_prestamo,dias,costoXdia,cve_devol)
           values('19','6','20070619','2','15','2');
INSERT INTO itc_Renta(cve_p,cve_c,fecha_prestamo,dias,costoXdia,cve_devol)
           values('3','7','20070626','1','26.5','1');
INSERT INTO itc_Renta(cve_p,cve_c,fecha_prestamo,dias,costoXdia,cve_devol)
           values('12','7','20070708','2','26.5','1');
INSERT INTO itc_Renta(cve_p,cve_c,fecha_prestamo,dias,costoXdia,cve_devol)
           values('22','6','20070721','2','15','1');
INSERT INTO itc_Renta(cve_p,cve_c,fecha_prestamo,dias,costoXdia,cve_devol)
           values('24','1','20070805','3','26.5','1');
INSERT INTO itc_Renta(cve_p,cve_c,fecha_prestamo,dias,costoXdia,cve_devol)
           values('25','1','20070818','3','26.5','2');
INSERT INTO itc_Renta(cve_p,cve_c,fecha_prestamo,dias,costoXdia,cve_devol)
           values('7','9','20070910','2','33.5','1');
INSERT INTO itc_Renta(cve_p,cve_c,fecha_prestamo,dias,costoXdia,cve_devol)
           values('8','10','20071011','4','30','1');
INSERT INTO itc_Renta(cve_p,cve_c,fecha_prestamo,dias,costoXdia,cve_devol)
           values('11','7','20071020','5','30','1');





