-- ============================================================
--  Laboratorio 4  "Austral Editores"
--  Editorial: autores, libros, colecciones y pagos (4 tablas)
--  ICN292 - Sistemas de Información para la Gestión
-- ============================================================

-- 1) Crear y seleccionar la base
DROP DATABASE IF EXISTS austral;
CREATE DATABASE austral;
USE austral;

-- ============================================================
--  TABLAS
-- ============================================================

-- Tabla nueva: se crea primero porque libros la referencia
CREATE TABLE colecciones (
    id_coleccion       INT AUTO_INCREMENT,
    titulo             VARCHAR(120) NOT NULL,
    fecha_publicacion  DATE NOT NULL,
    PRIMARY KEY (id_coleccion)
);

-- Tabla base
CREATE TABLE autores (
    id_autor    INT AUTO_INCREMENT,
    nombre      VARCHAR(80) NOT NULL,
    pais        VARCHAR(60),
    genero      ENUM('Cómic','Ensayo','Infantil','Novela','Poesía') NOT NULL,
    PRIMARY KEY (id_autor)
);

-- Tabla con clave foránea hacia autores y hacia colecciones
CREATE TABLE libros (
    id_libro             INT AUTO_INCREMENT,
    id_autor             INT,
    id_coleccion         INT,
    titulo               VARCHAR(120) NOT NULL,
    paginas              INT,
    ejemplares_vendidos  INT,
    anio                 INT,
    PRIMARY KEY (id_libro),
    FOREIGN KEY (id_autor) REFERENCES autores(id_autor),
    FOREIGN KEY (id_coleccion) REFERENCES colecciones(id_coleccion)
);

-- Tabla nueva, con clave foránea hacia autores
CREATE TABLE pagos (
    id_pago     INT AUTO_INCREMENT,
    id_autor    INT,
    fecha_pago  DATE NOT NULL,
    monto       DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_pago),
    FOREIGN KEY (id_autor) REFERENCES autores(id_autor)
);

-- ============================================================
--  CARGA OFICIAL
-- ============================================================

INSERT INTO autores (nombre, pais, genero) VALUES
('Elena Pizarro',     'Chile',          'Novela'),    -- 1
('Harold Finch',      'Inglaterra',     'Ensayo'),    -- 2
('Rodrigo Bahamonde', 'Chile',          'Poesía'),    -- 3
('Valentina Correa',  'Argentina',      'Infantil'),  -- 4
('Nora Keller',       'Estados Unidos', 'Novela');    -- 5

-- Autor sin país y sin libros: es el que sirve para ver los campos vacíos
INSERT INTO autores (nombre, pais, genero) VALUES ('Kenji Arakawa', NULL, 'Cómic');  -- 6

SELECT * FROM autores;

INSERT INTO libros (id_autor, titulo, paginas, ejemplares_vendidos, anio) VALUES
(1, 'Cielo de Enero',      210, 1500, 2024),
(1, 'Marea Baja',          185,  800, 2023),
(1, 'El Norte',            200, 2200, 2024),
(2, 'Estrellas que Caen',  240, 3000, 2022),
(2, 'Máquinas',            215,  450, 2024),
(3, 'Luz Artificial',      300, 1200, 2024),
(3, 'Ruido Blanco',        280,  600, 2023),
(4, 'El Barrio de Lila',   190, 5000, 2024),
(4, 'Antes del Amanecer',  205, 2700, 2024),
(4, 'La Calle 8',          175,  900, 2023),
(5, 'Flor de Hierro',      195, 4100, 2024),
(5, 'Hora Dorada',         220, 1800, 2022);

SELECT * FROM libros;

-- ============================================================
--  CONSULTAS
-- ============================================================

-- Consulta 1
-- Autores cuyo país no es Chile, incluido el que no tiene país
SELECT nombre, genero
FROM autores
WHERE pais <> 'Chile' OR pais IS NULL
ORDER BY nombre;

-- Consulta 2
-- Libros entre 190 y 220 páginas, de menor a mayor
SELECT titulo, paginas
FROM libros
WHERE paginas BETWEEN 190 AND 220
ORDER BY paginas;

-- Consulta 3
-- Resumen del catálogo en una sola fila
SELECT COUNT(*)                   AS libros,
       SUM(ejemplares_vendidos)   AS total_ejemplares,
       AVG(paginas)               AS paginas_prom,
       MIN(anio)                  AS anio_min,
       MAX(ejemplares_vendidos)   AS max_ejemplares
FROM   libros;

-- Consulta 4
-- Géneros distintos de los autores, en orden alfabético
SELECT DISTINCT genero
FROM autores
ORDER BY genero;

-- Consulta 5
-- Autores con más de un libro publicado en 2024
SELECT   a.nombre, COUNT(*) AS libros_2024
FROM     autores a
JOIN     libros  l ON a.id_autor = l.id_autor
WHERE    l.anio = 2024
GROUP BY a.id_autor, a.nombre
HAVING   COUNT(*) > 1
ORDER BY a.nombre;

-- Consulta 6
-- Libros de 2024 con más de 2000 ejemplares, solo los tres primeros
SELECT   titulo, ejemplares_vendidos
FROM     libros
WHERE    anio = 2024
  AND    ejemplares_vendidos > 2000
ORDER BY ejemplares_vendidos DESC
LIMIT 3;

-- Consulta 7
-- Workbench no deja hacer DELETE filtrando por algo que no sea el id,
-- así que se desactiva ese bloqueo
SET SQL_SAFE_UPDATES = 0;

-- Se inserta el libro (Rodrigo Bahamonde es el autor 3)
INSERT INTO libros (id_autor, titulo, paginas, ejemplares_vendidos, anio)
VALUES (3, 'Papel Mojado', 260, 50, 2024);

-- Antes del DELETE: la fila que se va a borrar
SELECT * FROM libros
WHERE titulo = 'Papel Mojado';

DELETE FROM libros
WHERE titulo = 'Papel Mojado';

-- Después del DELETE: ya no está
SELECT * FROM libros
WHERE titulo = 'Papel Mojado';

-- Consulta 8
-- Antes del UPDATE
SELECT titulo, ejemplares_vendidos
FROM libros
WHERE titulo = 'Cielo de Enero';

-- Se suman 100 al valor actual
UPDATE libros
SET ejemplares_vendidos = ejemplares_vendidos + 100
WHERE titulo = 'Cielo de Enero';

-- Después del UPDATE
SELECT titulo, ejemplares_vendidos
FROM libros
WHERE titulo = 'Cielo de Enero';

-- Consulta 9
-- Datos de prueba: tres colecciones
INSERT INTO colecciones (titulo, fecha_publicacion) VALUES
('La Florida',   '2022-01-01'),  -- 1
('Los de Abajo', '2023-05-04'),  -- 2
('U de Chile',   '2024-12-31');  -- 3

SELECT * FROM colecciones;

-- Cada libro va a la colección de su año
UPDATE libros SET id_coleccion = 1 WHERE anio = 2022;  -- La Florida
UPDATE libros SET id_coleccion = 2 WHERE anio = 2023;  -- Los de Abajo
UPDATE libros SET id_coleccion = 3 WHERE anio = 2024;  -- U de Chile

-- Cada libro con su colección y la fecha de la colección
SELECT l.titulo AS libro,
       c.titulo AS coleccion,
       c.fecha_publicacion
FROM   libros l
JOIN   colecciones c ON l.id_coleccion = c.id_coleccion
ORDER BY c.fecha_publicacion, l.titulo;

-- Consulta 10
-- Datos de prueba: tres pagos, dos de ellos a Valentina Correa
INSERT INTO pagos (id_autor, fecha_pago, monto) VALUES
(4, '2023-12-24', 650000.00),  -- Valentina Correa
(4, '2023-12-25', 400000.00),  -- Valentina Correa
(5, '2024-12-31', 380000.00);  -- Nora Keller

SELECT * FROM pagos;

-- Sentencia 1: cada pago con el nombre del autor
SELECT a.nombre, p.fecha_pago, p.monto
FROM   pagos p
JOIN   autores a ON p.id_autor = a.id_autor
ORDER BY p.fecha_pago;

-- Sentencia 2: total pagado a cada autor
SELECT   a.nombre, SUM(p.monto) AS total_pagado
FROM     pagos p
JOIN     autores a ON p.id_autor = a.id_autor
GROUP BY a.id_autor, a.nombre
ORDER BY a.nombre;