drop database if exists dara;

create database dara;

use dara;

-- ====================================================================
-- 1) empresa
-- guarda tanto las desarrolladoras como las editoras (son el mismo
-- tipo de entidad: una empresa puede desarrollar y/o publicar juegos)
-- ====================================================================
create table empresa (
 id_empresa int auto_increment primary key,
 nombre_comercial varchar(100) not null,
 correo_electronico varchar(100) unique,
 telefono varchar(20),
 fecha_fundacion date
);

-- ====================================================================
-- 2) plataforma
-- ps5, xbox series x|s, pc, nintendo switch, etc.
-- ====================================================================
create table plataforma (
 id_plataforma int auto_increment primary key,
 nombre varchar(50) not null,
 fabricante varchar(50) not null,
 tipo varchar(20) not null   -- 'consola' o 'pc'
);

-- ====================================================================
-- 3) genero
-- acción, aventura, etc. (las categorias que ya existen en la web)
-- ====================================================================
create table genero (
 id_genero int auto_increment primary key,
 nombre_genero varchar(50) not null unique
);

-- ====================================================================
-- 4) videojuego
-- cada juego tiene una unica desarrolladora y una unica editora
-- (pueden ser la misma empresa), por eso son 2 claves foraneas
-- distintas que apuntan a la misma tabla "empresa"
-- ====================================================================
create table videojuego (
 id_videojuego int auto_increment primary key,
 titulo varchar(150) not null,
 fecha_lanzamiento date,
 precio decimal(6,2) not null check (precio >= 0),
 descripcion text,
 pegi enum('3', '7', '12', '16', '18'),
 idioma varchar(50),
 id_desarrolladora int not null,
 id_editora int not null,
 foreign key (id_desarrolladora) references empresa(id_empresa),
 foreign key (id_editora) references empresa(id_empresa)
);

-- ====================================================================
-- 5) disponible (videojuego <-> plataforma, relacion n:m)
-- un juego puede estar en varias plataformas y una plataforma aloja
-- muchos juegos
-- ====================================================================
create table disponible (
 id_videojuego int not null,
 id_plataforma int not null,
 primary key (id_videojuego, id_plataforma),
 foreign key (id_videojuego) references videojuego(id_videojuego) on delete cascade,
 foreign key (id_plataforma) references plataforma(id_plataforma) on delete cascade
);

-- ====================================================================
-- 6) pertenece (videojuego <-> genero, relacion n:m)
-- un juego puede pertenecer a uno o varios generos
-- ====================================================================
create table pertenece (
 id_videojuego int not null,
 id_genero int not null,
 primary key (id_videojuego, id_genero),
 foreign key (id_videojuego) references videojuego(id_videojuego) on delete cascade,
 foreign key (id_genero) references genero(id_genero) on delete cascade
);

-- ====================================================================
-- 9) compra (usuario <-> videojuego, relacion n:m con atributos)
-- guarda la fecha y el precio pagado (puede ser distinto al precio
-- actual del juego si hubo descuento)
-- ====================================================================
create table compra (
 id_usuario int not null,
 id_videojuego int not null,
 fecha_compra date not null,
 precio_pagado decimal(6,2) not null check (precio_pagado >= 0),
 primary key (id_usuario, id_videojuego),
 foreign key (id_usuario) references usuario(id_usuario) on delete cascade,
 foreign key (id_videojuego) references videojuego(id_videojuego) on delete cascade
);

-- ====================================================================
-- 7) empleado
-- personal de dara (segun el er, atiende a los usuarios registrados)
-- ====================================================================
create table empleado (
 dni varchar(9) primary key,
 nombre varchar(100) not null,
 tipo_contrato varchar(50),
 telefono varchar(20)
);

-- ====================================================================
-- 8) usuario
-- cada usuario registrado es atendido por un empleado (relacion
-- "atiende" del er). dni_empleado puede quedar vacio si aun no se
-- le ha asignado ninguno
-- ====================================================================
create table usuario (
 id_usuario int auto_increment primary key,
 nombre_usuario varchar(50) not null unique,
 contrasena varchar(255) not null,
 correo_electronico varchar(100) not null unique,
 fecha_registro date not null default (current_date),
 dni_empleado varchar(9),
 foreign key (dni_empleado) references empleado(dni) on delete set null
);

-- ====================================================================
-- 10) resena
-- un usuario puede reseñar varios juegos, pero solo una reseña por
-- cada juego que haya comprado. por eso la clave foranea compuesta
-- (id_usuario, id_videojuego) apunta a la tabla "compra": solo se
-- puede reseñar un juego que conste como comprado, y el unique
-- impide repetir reseña sobre el mismo juego
-- ====================================================================
create table resena (
 id_resena int auto_increment primary key,
 id_usuario int not null,
 id_videojuego int not null,
 puntuacion decimal(3,1) not null check (puntuacion between 1.0 and 5.0),
 comentario text,
 fecha_resena date not null,
 unique (id_usuario, id_videojuego),
 foreign key (id_usuario, id_videojuego)
 references compra(id_usuario, id_videojuego) on delete cascade
);


-- ====================================================================
-- DATOS DE EJEMPLO
-- ====================================================================

-- ----- plataformas (las que aparecen en la web) -----
INSERT INTO plataforma (nombre, fabricante, tipo) VALUES
  ('PS4','Sony','consola'),
  ('PS5','Sony','consola'),
  ('Xbox One','Microsoft', 'consola'),
  ('Xbox Series X|S','Microsoft','consola'),
  ('Nintendo Switch','Nintendo','consola'),
  ('PC','Varios','pc');

-- ----- generos (las categorias de la web: Acción y Aventura) -----
INSERT INTO genero (nombre_genero) VALUES
  ('Acción'),
  ('Aventura');

-- ----- empresas (desarrolladoras / editoras de los juegos de la web) -----
INSERT INTO empresa (nombre_comercial, correo_electronico, telefono, fecha_fundacion) VALUES
 ('Naughty Dog','contacto@naughtydog.com','111111111','1984-09-27'),
 ('Sony Computer Entertainment','contacto@sony.com','222222222','1993-11-16'),
 ('Rockstar Games',  'contacto@rockstargames.com','333333333', '1998-12-01'),
 ('EA DICE','contacto@dice.se','444444444', '1992-10-15'),
 ('Electronic Arts','contacto@ea.com','555555555', '1982-05-28'),
 ('id Software','contacto@idsoftware.com','666666666', '1991-02-01'),
 ('Bethesda Softworks','contacto@bethesda.net','777777777', '1986-06-28'),
 ('Game Science','contacto@gamescience.com','888888888', '2014-05-01'),
 ('NetEase Games','contacto@neteasegames.com','999999999', '2001-06-01'),
 ('Infinity Ward','contacto@infinityward.com','101010101', '2002-05-01'),
 ('Activision','contacto@activision.com','121212121', '1979-10-01'),
 ('Visceral Games','contacto@visceralgames.com','131313131', '1998-02-11'),
 ('FromSoftware','contacto@fromsoftware.jp','141414141', '1986-11-01'),
 ('Bandai Namco Entertainment','contacto@bandainamco.com','151515151', '2006-03-31');

-- ----- videojuegos -----
insert into videojuego(titulo, fecha_lanzamiento, precio, descripcion, pegi, idioma, id_desarrolladora, id_editora) values
('Uncharted 4: A Thief''s End', '2016-05-10', 19.99,
 'Videojuego de acción y aventura en tercera persona. Nathan Drake, cazador de tesoros retirado, regresa al mundo de los ladrones cuando su hermano Sam, a quien creía muerto, reaparece pidiendo ayuda.',
 '16', 'Español', 1, 2),

('Grand Theft Auto VI (GTA 6)', '2026-05-26', 79.99,
 'El juego transporta a los jugadores al estado ficticio de Leonida (basado en Florida), con una version rediseñada de Vice City. Protagonizado por Lucia y Jason, un duo criminal inspirado en Bonnie y Clyde.',
 '18', 'Español', 3, 3),

('Battlefield 6', '2025-10-10', 34.99,
 'Videojuego de disparos en primera persona ambientado en un futuro cercano, con batallas masivas de hasta 128 jugadores, clima dinamico y personalizacion de armas.',
 '18', 'Español', 4, 5),

('Doom Eternal', '2020-03-20', 9.89,
 'Videojuego de disparos en primera persona ambientado en un universo horroroso, donde el Doom Slayer lucha gegen demonios y criaturas sobrenaturales.',
 '18', 'Español', 6, 7),

('Black Myth: Wukong', '2024-08-20', 59.99,
 'Videojuego de accion y aventura inspirado en la mitologia china, donde el jugador controla a un guerrero con habilidades sobrenaturales.',
 '16', 'Español', 8, 9),

('Call of Duty: Modern Warfare II', '2022-10-28', 69.99,
 'Thriller militar en primera persona. Una crisis global sin precedentes junto a la Fuerza Operativa 141, con el Capitan Price, Ghost y Soap.',
 '18', 'Español', 10, 11),

('Red Dead Redemption 2', '2018-10-26', 39.99,
 'Videojuego de aventura y accion ambientado en el oeste salvaje de 1899, siguiendo a Arthur Morgan, miembro de la banda de los Van der Linde.',
 '18', 'Español', 3, 3),

('Dead Space', '2023-01-27', 59.99,
 'Videojuego de terror y ciencia ficcion a bordo de la estacion espacial USS Titan, donde el ingeniero Isaac Clarke lucha contra horrores alienigenas.',
 '18', 'Español', 12, 5),

('Elden Ring Tarnished Edition', '2022-02-25', 49.99,
 'Videojuego de rol y aventura ambientado en el mundo ficticio de Elden Ring, donde el jugador explora un vasto universo y se enfrenta a desafios epicos.',
 '16', 'Español', 13, 14);

-- ----- generos de cada juego -----
INSERT INTO pertenece (id_videojuego, id_genero) VALUES
 (1, 1), -- Uncharted 4 -> Acción
 (2, 1), -- GTA 6 -> Acción
 (3, 1), -- Battlefield 6 -> Acción
 (4, 1), -- Doom Eternal -> Acción
 (5, 1), -- Black Myth: Wukong -> Acción
 (6, 1), -- Call of Duty: MW II -> Acción
 (7, 2), -- Red Dead Redemption 2 -> Aventura
 (8, 2), -- Dead Space -> Aventura
 (9, 2); -- Elden Ring -> Aventura

-- ----- plataformas disponibles para cada juego -----
INSERT INTO disponible (id_videojuego, id_plataforma) VALUES
 (1, 1), (1, 2), (1, 3),-- Uncharted 4 (PS4, PS5, PC)
 (2, 2), (2, 4),-- GTA 6 (PS5, Xbox Series X|S)
 (3, 2), (3, 4), (3, 3),-- Battlefield 6 (PS5, Xbox Series X|S, PC)
 (4, 2), (4, 4), (4, 5), (4, 3),-- Doom Eternal (PS5, Xbox Series X|S, Switch, PC)
 (5, 2), (5, 4), (5, 3),-- Black Myth: Wukong (PS5, Xbox Series X|S, PC)
 (6, 1), (6, 2), (6, 3), (6, 4), (6, 6),-- Call of Duty: MW II (PS4, PS5, PC, Xbox Series X|S, Xbox One)
 (7, 1), (7, 3), (7, 6),-- Red Dead Redemption 2 (PS4, PC, Xbox One)
 (8, 2), (8, 3), (8, 4),-- Dead Space (PS5, PC, Xbox Series X|S)
 (9, 1), (9, 2), (9, 3), (9, 4), (9, 6);-- Elden Ring (PS4, PS5, PC, Xbox Series X|S, Xbox One)

-- ----- empleados de ejemplo -----
INSERT INTO empleado (dni, nombre, tipo_contrato, telefono) VALUES
 ('11111111A', 'Daymer',  'Indefinido', '600111111'),
 ('22222222B', 'Ander',   'Indefinido', '600222222'),
 ('33333333C', 'Aimar',   'Temporal',   '600333333');

-- ----- usuarios de ejemplo -----
INSERT INTO usuario (nombre_usuario, contrasena, correo_electronico, fecha_registro, dni_empleado) VALUES
 ('Aimar_Baaasterretxea', 'contraseña123', 'aimar@correo.com','2026-01-15', '11111111A'),
 ('Nerea_99','contraseña456', 'nerea@correo.com','2026-02-03','22222222B'),
 ('PatataAritz','contraseña789','aritz@correo.com', '2026-03-20','11111111A');

-- ----- compras de ejemplo -----
INSERT INTO compra (id_usuario, id_videojuego, fecha_compra, precio_pagado) VALUES
 (1, 2, '2026-06-01', 79.99), -- Aimar_Baaasterretxea compra GTA 6
 (2, 5, '2026-06-05', 59.99), -- Nerea_99 compra Black Myth: Wukong
 (3, 5, '2026-06-07', 59.99); -- PatataAritz compra Black Myth: Wukong

-- ----- reseñas de ejemplo -----
INSERT INTO resena (id_usuario, id_videojuego, puntuacion, comentario, fecha_resena) VALUES
 (1, 2, 10.0, 'El mapa mas grande y detallado que ha hecho Rockstar, se nota cada euro invertido.', '2026-06-10'),
 (2, 5, 9.0,  'Lo compre por recomendacion de um amigo, esta demasiado bien.', '2026-06-12');
 
 -- ====================================================================
-- creación de usuarios de mysql y asignación de privilegios
-- ====================================================================

-- 1. crear los usuarios (con contraseña segura para localhost o acceso remoto)
create user 'dara_admin'@'localhost' identified by 'AdminSeguro_123!';
create user 'dara_empleado'@'localhost' identified by 'EmpleadoPass_456!';
create user 'dara_cliente'@'localhost' identified by 'ClienteWeb_789!';


-- ====================================================================
-- 2. asignar funcionalidades / privilegios según su rol
-- ====================================================================

-- ----- rol 1: administrador (control total de la bd) -----
-- puede hacer de todo (crear tablas, modificar datos, borrar, gestionar usuarios, etc.)
grant all privileges on dara.* to 'dara_admin'@'localhost';


-- ----- rol 2: empleado / gestor (gestión operativa) -----
-- puede ver, insertar y modificar videojuegos, empresas, plataformas, empleados y ver compras/reseñas, 
-- pero no puede borrar la base de datos ni alterar la estructura de las tablas (drop/alter).
grant select, insert, update on dara.videojuego to 'dara_empleado'@'localhost';
grant select, insert, update on dara.empresa to 'dara_empleado'@'localhost';
grant select, insert, update on dara.plataforma to 'dara_empleado'@'localhost';
grant select, insert, update on dara.genero to 'dara_empleado'@'localhost';
grant select, insert, update on dara.compra to 'dara_empleado'@'localhost';
grant select, insert, update on dara.resena to 'dara_empleado'@'localhost';
grant select, insert, update on dara.usuario to 'dara_empleado'@'localhost';
grant select on dara.empleado to 'dara_empleado'@'localhost';


-- ----- rol 3: cliente / usuario web (acceso limitado al escaparate y su cuenta) -----
-- solo puede consultar los catálogos (juegos, plataformas, géneros), 
-- registrarse/actualizar sus datos de usuario y realizar sus propias compras/reseñas.
grant select on dara.videojuego to 'dara_cliente'@'localhost';
grant select on dara.plataforma to 'dara_cliente'@'localhost';
grant select on dara.genero to 'dara_cliente'@'localhost';
grant select on dara.empresa to 'dara_cliente'@'localhost';

-- permisos sobre su propio perfil, compras y reseñas
grant select, insert, update on dara.usuario to 'dara_cliente'@'localhost';
grant select, insert on dara.compra to 'dara_cliente'@'localhost';
grant select, insert, update on dara.resena to 'dara_cliente'@'localhost';


-- ====================================================================
-- 3. aplicar los cambios
-- ====================================================================
flush privileges;