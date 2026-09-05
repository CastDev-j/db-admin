CREATE DATABASE POEMAS;
GO
USE POEMAS;

CREATE TABLE escritor(
id_escritor INT NOT NULL,
nombre VARCHAR (256),
apellido VARCHAR (256),
direccion VARCHAR (256),
correo VARCHAR (256),
CONSTRAINT EscritoresPK PRIMARY KEY (id_escritor)
)

CREATE TABLE poema(
id_poema INT NOT NULL,
id_escritor INT NOT NULL,
titulo VARCHAR (256),
contenido VARCHAR (1024),
CONSTRAINT PoemaPK PRIMARY KEY (id_poema),
CONSTRAINT EscritorFK FOREIGN KEY (id_escritor) REFERENCES escritor (id_escritor)
)

CREATE TABLE libro(
id_libro INT NOT NULL,
titulo VARCHAR (256),
precio FLOAT,
CONSTRAINT LibroPK PRIMARY KEY (id_libro)
)

CREATE TABLE poema_libro(
id_poema INT NOT NULL,
id_libro INT NOT NULL,
CONSTRAINT PoemaLibroPK PRIMARY KEY (id_poema, id_libro),
CONSTRAINT PoemaFK FOREIGN KEY (id_poema) REFERENCES poema (id_poema),
CONSTRAINT LibroFK FOREIGN KEY (id_libro) REFERENCES libro (id_libro)
)

INSERT INTO escritor (id_escritor, nombre, apellido, direccion, correo) VALUES
(1, 'Pablo', 'Neruda', 'Santiago, Chile', 'pablo.neruda@gmail.com'),
(2, 'Octavio', 'Paz', 'Ciudad de Mexico, Mexico', 'octavio.paz@gmail.com'),
(3, 'Federico', 'Garcia Lorca', 'Granada, Espana', 'fed.garcia@gmail.com'),
(4, 'Sor', 'Juana', 'Ciudad de Mexico, Mexico', 'sor.juana@gmail.com'),
(5, 'Mario', 'Benedetti', 'Montevideo, Uruguay', 'mario.benedetti@gmail.com'),
(6, 'Jorge Luis', 'Borges', 'Buenos Aires, Argentina', 'jl.borges@gmail.com'),
(7, 'Gabriela', 'Mistral', 'Vicuna, Chile', 'gabriela.mistral@gmail.com'),
(8, 'Cesar', 'Vallejo', 'Santiago de Chuco, Peru', 'cesar.vallejo@gmail.com'),
(9, 'Alfonsina', 'Storni', 'Buenos Aires, Argentina', 'alfonsina.storni@gmail.com'),
(10, 'Dario', 'Jaramillo', 'Medellin, Colombia', 'dario.jaramillo@gmail.com'),
(11, 'Eugenio', 'Montale', 'Genova, Italia', 'eugenio.montale@gmail.com'),
(12, 'Rabindranath', 'Tagore', 'Calcuta, India', 'rabindranath.tagore@gmail.com'),
(13, 'William', 'Shakespeare', 'Stratford, Inglaterra', 'william.shakespeare@gmail.com'),
(14, 'Pablo', 'Antonio de Solis', 'Bogota, Colombia', 'pablo.solis@gmail.com'),
(15, 'Eduardo', 'Cote', 'Baranquilla, Colombia', 'eduardo.cote@gmail.com');

INSERT INTO poema (id_poema, id_escritor, titulo, contenido) VALUES
(1, 1, 'Soneto XVII', 'No te amo como si fueras rosa de sal, topacio... te amo como a ciertas cosas oscuras, secretamente, entre la sombra y el alma.'),
(2, 1, 'Oda al tomate', 'El tomate se regaba con agua de colonia, y se reunian en la cafeteria los coleccionistas de rayos de sol.'),
(3, 1, 'Poema 20', 'Puedo escribir los versos mas tristes esta noche. Escribir, por ejemplo: La noche esta estrellada, y tiritan, azules, los astros, a lo lejos.'),
(4, 2, 'Piedra de sol', 'Un rayo de luz cayendo desde el aire infinito hasta la tierra. La piedra de sol que gira y gira sin cesar.'),
(5, 2, 'Blanco', 'Hacia lo blanco voy, hacia lo blanco, sinfonia de aire puro, vapor de nieve.'),
(6, 3, 'Romance sonambulo', 'Verde que te quiero verde. Verde viento. Verdes ramas. El barco sobre la mar y el caballo en la montana.'),
(7, 3, 'La guitarra', 'Empieza el llanto de la guitarra. Se rompen copas de madrugada. Empieza el llanto de la guitarra.'),
(8, 4, 'Hombres necios que acusais', 'Hombres necios que acusais a la mujer sin razon, sin ver que sois la occasion de lo mismo que culpais.'),
(9, 4, 'Primero sueno', 'Yo no naci para ensemble. Mi genio es de soledad.'),
(10, 5, 'Sobre la mesa', 'Un cafesito y vos, con la mano en la mano. Cafe y pan con mantequilla.'),
(11, 5, 'Vamos andando', 'Anda, ven, vamo a sentarnos en la orilla del mar, a ver las olitas que vienen y van.'),
(12, 6, 'El Aleph', 'Vi el populoso mar, vi el alba y la tarde, vi las muchedumbres de America.'),
(13, 6, 'Poema de los dones', 'Nadie rebaje a lagrimas mi prosa. Ha muerto el menor de mis hijos.'),
(14, 6, 'Instantes', 'Que el olvido que produce la muerte sea apenas un preludio para volver a encontrarnos.'),
(15, 7, 'Sonetos de la muerte', 'Del panteon de las familias me van a llevar a las niñas muertas.'),
(16, 7, 'Balada', 'Todavia verde, todavia polvareda, caminito de la sierra.'),
(17, 8, 'Los heraldos negros', 'Hay golpes en la vida, tan fuertes... Yo no se! Golpes como del odio de Dios, como si ante ellos, la resaca de todo lo vivido se ozara en el alma.'),
(18, 8, 'Trilce I', 'Hoy me vinieron a visitar de parte del cielo.'),
(19, 9, 'Los insignificantess', 'Si me morire, me morire de amor.'),
(20, 9, 'Languidez', 'Curva, blanca, bonita, cometa incomparable y de vuelo incorrecto.'),
(21, 10, 'De amores', 'Debes saber que he viajado muy lejos. Me he perdido en mil ciudades. Pero siempre, siempre me he encontrado contigo.'),
(22, 11, 'Mio', 'Tengo miedo de perderla. Aun no la amo. La miro, no la toco. La siento, no la miro.'),
(23, 12, 'El jardinero', 'Si al fin el amor no puede ser, dejemos que la rosa nos hiera con su espinazo.'),
(24, 13, 'Soneto 18', 'Shall I compare thee to a summers day? Thou art more lovely and more temperate.'),
(25, 13, 'Hamlet Soliloquy', 'To be or not to be, that is the question.'),
(26, 14, 'Camino de la paz', 'El camino hacia la paz es largo, pero lleno de luz.'),
(27, 14, 'Suenos', 'Duermo y sueno. Los dos al mismo tiempo.'),
(28, 15, 'Solo', 'Me siento solo pero no soy el unico.'),
(29, 15, 'Noche', 'La noche es larga cuando no te tengo.'),
(30, 15, 'Viento', 'El viento me trae tu nombre.');

INSERT INTO libro (id_libro, titulo, precio) VALUES
(1, 'Veinte poemas de amor y una cancion desesperada', 15.99),
(2, 'Canto general', 25.50),
(3, 'Piedra de sol', 18.75),
(4, 'Romancero gitano', 12.00),
(5, 'Poemas selectos', 10.99),
(6, 'Ficciones', 14.50),
(7, 'El Aleph', 13.25),
(8, 'Tres tristes tigres', 16.00),
(9, 'Sonetos de la muerte', 8.50),
(10, 'Poemas de amor, vida y muerte', 11.99),
(11, 'Los heraldos negros', 9.75),
(12, 'Trilce', 19.99),
(13, 'Poemas de la patria', 7.50),
(14, 'Espanol: literatura', 22.00),
(15, 'Obras completas', 35.00);

INSERT INTO poema_libro (id_poema, id_libro) VALUES
(1, 1),
(2, 1),
(3, 1),
(4, 3),
(5, 3),
(6, 4),
(7, 4),
(8, 5),
(9, 5),
(10, 5),
(11, 5),
(12, 6),
(13, 6),
(14, 7),
(15, 8),
(16, 8),
(17, 9),
(18, 9),
(19, 10),
(20, 10),
(21, 10),
(22, 11),
(23, 12),
(24, 13),
(25, 13),
(26, 14),
(27, 14),
(28, 15),
(29, 15),
(30, 15);

