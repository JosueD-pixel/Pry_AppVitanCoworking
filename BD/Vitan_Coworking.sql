-- =====================================================================
--  VITÁN Coworking · Base de datos del sistema de reservas
--  Motor: MySQL 8 / MariaDB (XAMPP) · Juego de caracteres: utf8mb4
--  Versión final (2026-11-19) · 17 tablas
--
--  Cambios respecto a la versión 3:
--   d. Tablas quienes_somos (un solo registro: información, misión, visión
--      y ubicación) y preguntas_frecuentes (5 preguntas): las modifica el
--      administrador.
--   e. usuarios.ap acepta NULL: la empresa no lleva apellidos.
--
--  Cambios respecto a la versión 2:
--   a. usuarios: pregunta_seguridad y respuesta_seguridad (hash) para
--      recuperar la cuenta sin correo.
--   b. Tabla carrusel: imágenes de la portada (como la práctica del profe).
--   c. Más reservas de ejemplo para el dashboard y Mis reservas, porque en
--      esta etapa reservar es solo de diseño.
--
--  Cambios respecto a la versión 1:
--   1. ROLES. Los roles son tres: administrador, cliente y empresa.
--      `usuarios` se liga a `roles` con id_rol. En el código (PHP / Kotlin)
--      Usuario es la clase padre y Administrador, Cliente y Empresa son sus
--      clases hijas (herencia y polimorfismo); el rol dice qué clase crear.
--      En la base de datos todos viven en la misma tabla `usuarios`.
--   2. FAVORITO. Campo BOOLEAN `favorito` en `usuarios` (lo marca el
--      administrador para clientes y empresas frecuentes).
--   3. PRECIOS. `salas` guarda precio_hora y precio_dia.
--   4. PROMOCIONES. Cada promoción es de una sala (id_sala) y la recibe
--      cualquier usuario que reserve esa sala en las fechas de la promoción.
--      La promoción es un porcentaje de descuento.
--
--  Catálogos puros (sin FK): roles, tipos_sala, mobiliario, servicios, carrusel,
--    quienes_somos, preguntas_frecuentes
--  Catálogos no puros: usuarios, salas, imagenes, promociones, asigna,
--    reservas, horarios, cancelaciones, pagos, asignar_servicios
--  La cotización NO se guarda: se calcula en pantalla
--  (horas × precio de la sala − % de promoción + servicios).
-- =====================================================================

DROP DATABASE IF EXISTS vitan_coworking;
CREATE DATABASE vitan_coworking
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE vitan_coworking;

-- ---------------------------------------------------------------------
--  CATÁLOGOS PUROS
-- ---------------------------------------------------------------------

CREATE TABLE roles (
  id_rol  INT          NOT NULL AUTO_INCREMENT,
  rol     VARCHAR(30)  NOT NULL,             -- administrador, cliente, empresa
  PRIMARY KEY (id_rol),
  UNIQUE KEY uq_roles_rol (rol)
) ENGINE=InnoDB;

CREATE TABLE tipos_sala (
  id_tipo_sala  INT           NOT NULL AUTO_INCREMENT,
  nombre        VARCHAR(50)   NOT NULL,
  descripcion   VARCHAR(255)  NULL,
  PRIMARY KEY (id_tipo_sala),
  UNIQUE KEY uq_tipos_sala_nombre (nombre)
) ENGINE=InnoDB;

CREATE TABLE mobiliario (
  id_mobiliario  INT           NOT NULL AUTO_INCREMENT,
  marca          VARCHAR(60)   NULL,
  nombre         VARCHAR(80)   NOT NULL,
  descripcion    VARCHAR(255)  NULL,
  PRIMARY KEY (id_mobiliario)
) ENGINE=InnoDB;

CREATE TABLE servicios (
  id_servicio  INT            NOT NULL AUTO_INCREMENT,
  nombre       VARCHAR(80)    NOT NULL,
  costo        DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
  PRIMARY KEY (id_servicio)
) ENGINE=InnoDB;


-- Imágenes del carrusel de la portada (las sube el administrador)
CREATE TABLE carrusel (
  id_carrusel  INT           NOT NULL AUTO_INCREMENT,
  titulo       VARCHAR(150)  NULL,
  imagen       VARCHAR(255)  NOT NULL,        -- nombre del archivo en uploads/carrusel/
  orden        INT           NOT NULL DEFAULT 0,
  activo       TINYINT(1)    NOT NULL DEFAULT 1,
  created_at   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_carrusel)
) ENGINE=InnoDB;

-- Texto de ¿Quiénes somos? (también la sección ¿Qué es VITÁN? del inicio).
-- Es un solo registro: el administrador solo lo modifica (no hay alta ni baja).
CREATE TABLE quienes_somos (
  id_quienes   INT           NOT NULL AUTO_INCREMENT,
  informacion  TEXT          NOT NULL,        -- qué es VITÁN
  mision       TEXT          NOT NULL,
  vision       TEXT          NOT NULL,
  direccion    VARCHAR(200)  NOT NULL,        -- ubicación escrita
  mapa_url     VARCHAR(500)  NULL,            -- enlace de Google Maps para el iframe
  PRIMARY KEY (id_quienes)
) ENGINE=InnoDB;

-- Las 5 preguntas frecuentes: el administrador cambia la pregunta y la respuesta
CREATE TABLE preguntas_frecuentes (
  id_pregunta  INT           NOT NULL AUTO_INCREMENT,
  pregunta     VARCHAR(200)  NOT NULL,
  respuesta    TEXT          NOT NULL,
  PRIMARY KEY (id_pregunta)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
--  CATÁLOGOS NO PUROS
-- ---------------------------------------------------------------------

-- Clase padre en el código; el rol indica si es Administrador, Cliente o Empresa
CREATE TABLE usuarios (
  id_usuario  INT           NOT NULL AUTO_INCREMENT,
  id_rol      INT           NOT NULL,
  nombre      VARCHAR(60)   NOT NULL,          -- en una empresa: nombre de la empresa
  ap          VARCHAR(40)   NULL,              -- apellido paterno (la empresa no lleva apellidos)
  am          VARCHAR(40)   NULL,              -- apellido materno
  cp          CHAR(5)       NULL,
  calle       VARCHAR(100)  NULL,
  ciudad      VARCHAR(60)   NULL,
  colonia     VARCHAR(80)   NULL,
  correo      VARCHAR(120)  NOT NULL,
  telefono    VARCHAR(15)   NULL,
  contrasena  VARCHAR(255)  NOT NULL,          -- hash de password_hash() en PHP
  favorito    BOOLEAN       NOT NULL DEFAULT FALSE,  -- cliente o empresa favorito
  pregunta_seguridad   VARCHAR(150)  NULL,     -- se elige al crear la cuenta
  respuesta_seguridad  VARCHAR(255)  NULL,     -- hash de password_hash() (en minúsculas y sin espacios extra)
  PRIMARY KEY (id_usuario),
  UNIQUE KEY uq_usuarios_correo (correo),
  CONSTRAINT fk_usuarios_roles FOREIGN KEY (id_rol)
    REFERENCES roles (id_rol) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE salas (
  id_sala       INT            NOT NULL AUTO_INCREMENT,
  id_tipo_sala  INT            NOT NULL,
  nombre        VARCHAR(80)    NOT NULL,
  capacidad     INT            NOT NULL,
  descripcion   TEXT           NULL,
  precio_hora   DECIMAL(10,2)  NOT NULL,
  precio_dia    DECIMAL(10,2)  NOT NULL,
  PRIMARY KEY (id_sala),
  CONSTRAINT fk_salas_tipos_sala FOREIGN KEY (id_tipo_sala)
    REFERENCES tipos_sala (id_tipo_sala) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE imagenes (
  id_imagen  INT           NOT NULL AUTO_INCREMENT,
  id_sala    INT           NOT NULL,
  img        VARCHAR(160)  NOT NULL,           -- ruta del archivo
  PRIMARY KEY (id_imagen),
  CONSTRAINT fk_imagenes_salas FOREIGN KEY (id_sala)
    REFERENCES salas (id_sala) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- Promoción de una sala: la recibe todo usuario que reserve esa sala en esas fechas
CREATE TABLE promociones (
  id_promocion  INT           NOT NULL AUTO_INCREMENT,
  id_sala       INT           NOT NULL,
  descuento     DECIMAL(5,2)  NOT NULL,         -- porcentaje: 15.00 = 15 %
  estado        ENUM('activa','inactiva') NOT NULL DEFAULT 'activa',
  fecha_inicio  DATE          NOT NULL,
  fecha_fin     DATE          NOT NULL,
  PRIMARY KEY (id_promocion),
  CONSTRAINT fk_promociones_salas FOREIGN KEY (id_sala)
    REFERENCES salas (id_sala) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT ck_promociones_descuento CHECK (descuento > 0 AND descuento <= 100),
  CONSTRAINT ck_promociones_fechas CHECK (fecha_fin >= fecha_inicio)
) ENGINE=InnoDB;

-- Entidad asociativa: qué mobiliario tiene cada sala (N:M)
CREATE TABLE asigna (
  id_sala        INT  NOT NULL,
  id_mobiliario  INT  NOT NULL,
  PRIMARY KEY (id_sala, id_mobiliario),
  CONSTRAINT fk_asigna_salas FOREIGN KEY (id_sala)
    REFERENCES salas (id_sala) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_asigna_mobiliario FOREIGN KEY (id_mobiliario)
    REFERENCES mobiliario (id_mobiliario) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE reservas (
  id_reserva  INT   NOT NULL AUTO_INCREMENT,
  id_usuario  INT   NOT NULL,                  -- cliente o empresa que reserva
  id_sala     INT   NOT NULL,
  fecha       DATE  NOT NULL,                  -- día en que se hizo la reserva
  estado      ENUM('pendiente','confirmada','finalizada','cancelada') NOT NULL DEFAULT 'pendiente',
  modalidad   ENUM('hora','dia') NOT NULL DEFAULT 'hora',
  PRIMARY KEY (id_reserva),
  CONSTRAINT fk_reservas_usuarios FOREIGN KEY (id_usuario)
    REFERENCES usuarios (id_usuario) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_reservas_salas FOREIGN KEY (id_sala)
    REFERENCES salas (id_sala) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE horarios (
  id_horario   INT   NOT NULL AUTO_INCREMENT,
  id_reserva   INT   NOT NULL,
  fecha        DATE  NOT NULL,                 -- día en que se usa la sala
  hora_inicio  TIME  NOT NULL,
  hora_fin     TIME  NOT NULL,
  PRIMARY KEY (id_horario),
  CONSTRAINT fk_horarios_reservas FOREIGN KEY (id_reserva)
    REFERENCES reservas (id_reserva) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT ck_horarios_horas CHECK (hora_fin > hora_inicio)
) ENGINE=InnoDB;

CREATE TABLE cancelaciones (
  id_cancelacion  INT            NOT NULL AUTO_INCREMENT,
  id_reserva      INT            NOT NULL,     -- UQ: una reserva se cancela una sola vez
  motivo          VARCHAR(255)   NULL,
  penalizacion    DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
  PRIMARY KEY (id_cancelacion),
  UNIQUE KEY uq_cancelaciones_reserva (id_reserva),
  CONSTRAINT fk_cancelaciones_reservas FOREIGN KEY (id_reserva)
    REFERENCES reservas (id_reserva) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE pagos (
  id_pago     INT            NOT NULL AUTO_INCREMENT,
  id_reserva  INT            NOT NULL,
  fecha       DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  referencia  VARCHAR(60)    NULL,
  monto       DECIMAL(10,2)  NOT NULL,
  PRIMARY KEY (id_pago),
  CONSTRAINT fk_pagos_reservas FOREIGN KEY (id_reserva)
    REFERENCES reservas (id_reserva) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Entidad asociativa: servicios extra de cada reserva (N:M)
CREATE TABLE asignar_servicios (
  id_reserva   INT  NOT NULL,
  id_servicio  INT  NOT NULL,
  PRIMARY KEY (id_reserva, id_servicio),
  CONSTRAINT fk_asigserv_reservas FOREIGN KEY (id_reserva)
    REFERENCES reservas (id_reserva) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_asigserv_servicios FOREIGN KEY (id_servicio)
    REFERENCES servicios (id_servicio) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =====================================================================
--  DATOS DE EJEMPLO
--  Pregunta de seguridad de todos los usuarios de ejemplo:
--    ¿Cuál es el nombre de tu primera mascota?  →  firulais
--  Contraseñas (hash bcrypt de PHP):
--    admin@vitan.mx / Admin123
--    cliente@vitan.mx / Cliente123 (los demás clientes también Cliente123)
--    empresa@vitan.mx / Empresa123
-- =====================================================================

INSERT INTO roles (id_rol, rol) VALUES
 (1, 'administrador'),
 (2, 'cliente'),
 (3, 'empresa');

INSERT INTO tipos_sala (id_tipo_sala, nombre, descripcion) VALUES
 (1, 'Sala de conferencias', 'Sala amplia para capacitaciones, conferencias y presentaciones.'),
 (2, 'Sala ejecutiva',       'Sala de juntas para reuniones con clientes o de equipo.'),
 (3, 'Oficina privada',      'Oficina cerrada para trabajar sin distracciones.');

INSERT INTO mobiliario (id_mobiliario, marca, nombre, descripcion) VALUES
 (1, 'Offiho',   'Silla ejecutiva',     'Silla acolchada con brazos y ruedas.'),
 (2, 'Samsung',  'Pantalla de 75"',     'Pantalla para presentaciones con entrada HDMI.'),
 (3, 'Steren',   'Bocinas y micrófonos','Equipo de audio con dos micrófonos inalámbricos.'),
 (4, 'Mirage',   'Minisplit',           'Aire acondicionado de 1.5 toneladas.'),
 (5, 'Offiho',   'Mesa de juntas',      'Mesa ovalada para 10 personas.'),
 (6, 'LG',       'Televisión de 55"',   'Televisión para presentar desde la laptop.'),
 (7, 'Ofik',     'Escritorio',          'Escritorio de melamina de 1.20 m.'),
 (8, 'Ofik',     'Silla ergonómica',    'Silla con soporte lumbar y altura ajustable.'),
 (9, 'Ofik',     'Librero',             'Librero de cinco entrepaños.');

INSERT INTO servicios (id_servicio, nombre, costo) VALUES
 (1, 'Café y galletas (por persona)', 35.00),
 (2, 'Proyector',                     150.00),
 (3, 'Impresiones (paquete de 50)',   60.00),
 (4, 'Coffee break completo',         1200.00),
 (5, 'Rotafolio y plumones',          80.00);

INSERT INTO usuarios (id_usuario, id_rol, nombre, ap, am, cp, calle, ciudad, colonia, correo, telefono, contrasena, favorito, pregunta_seguridad, respuesta_seguridad) VALUES
 (1, 1, 'Dueño',                 'VITÁN',     NULL,       '43000', 'Av. Juárez 120',       'Huejutla de Reyes', 'Centro',                'admin@vitan.mx',   '7710000000', '$2y$10$lwflR0wPiDSRIxpYwwXshe2mIDDYOqnCRG7qr3pS4knFMEleRsJ5.', FALSE, '¿Cuál es el nombre de tu primera mascota?', '$2y$10$E3br/N4vkbCyp4uFvFJfGOdbtj1uVA2Kk5JIoswh06uLNVs7wujPG'),
 (2, 3, 'Consultores Huastecos', NULL,        NULL,       '43000', 'Calle Corona 33',      'Huejutla de Reyes', 'Centro',                'empresa@vitan.mx', '7711112233', '$2y$10$P7dt41zPek2tNB0.G1XcW.jgSbXnTfMqon4k73TfIaVx/i8fN5EMS', TRUE, '¿Cuál es el nombre de tu primera mascota?', '$2y$10$E3br/N4vkbCyp4uFvFJfGOdbtj1uVA2Kk5JIoswh06uLNVs7wujPG'),
 (3, 2, 'Mariana',               'Hernández', 'Cruz',     '43000', 'Calle Morelos 45',     'Huejutla de Reyes', 'Centro',                'cliente@vitan.mx', '7711234567', '$2y$10$HhHQ/crFCCdl7b.rlqr..OnFcT9tM/BcaAzaKWZ6dJzVzRB6eV7bm', TRUE, '¿Cuál es el nombre de tu primera mascota?', '$2y$10$E3br/N4vkbCyp4uFvFJfGOdbtj1uVA2Kk5JIoswh06uLNVs7wujPG'),
 (4, 2, 'Jorge',                 'Bautista',  'Martínez', '43010', 'Calle Hidalgo 210',    'Huejutla de Reyes', 'Tahuizán',              'jorge@correo.com', '7719876543', '$2y$10$HhHQ/crFCCdl7b.rlqr..OnFcT9tM/BcaAzaKWZ6dJzVzRB6eV7bm', FALSE, '¿Cuál es el nombre de tu primera mascota?', '$2y$10$E3br/N4vkbCyp4uFvFJfGOdbtj1uVA2Kk5JIoswh06uLNVs7wujPG'),
 (5, 2, 'Laura',                 'Martínez',  'Reyes',    '43020', 'Privada Las Flores 8', 'Huejutla de Reyes', 'Parque de Poblamiento', 'laura@correo.com', '7714442211', '$2y$10$HhHQ/crFCCdl7b.rlqr..OnFcT9tM/BcaAzaKWZ6dJzVzRB6eV7bm', FALSE, '¿Cuál es el nombre de tu primera mascota?', '$2y$10$E3br/N4vkbCyp4uFvFJfGOdbtj1uVA2Kk5JIoswh06uLNVs7wujPG');

INSERT INTO salas (id_sala, id_tipo_sala, nombre, capacidad, descripcion, precio_hora, precio_dia) VALUES
 (1, 1, 'Sala de conferencias', 30, 'Nuestra sala más amplia, con pantalla, audio, micrófonos y clima.', 500.00, 4000.00),
 (2, 2, 'Sala ejecutiva A',     10, 'Mesa para 10 personas y televisión para presentar.',              250.00, 1800.00),
 (3, 2, 'Sala ejecutiva B',      8, 'Sala con ventanal, ideal para entrevistas y firmas.',               220.00, 1600.00),
 (4, 3, 'Oficina privada 1',     2, 'Oficina cerrada con escritorio, internet y clima.',                 150.00, 1000.00),
 (5, 3, 'Oficina privada 2',     4, 'Oficina más grande, con ventana y librero.',                        180.00, 1200.00);

INSERT INTO imagenes (id_sala, img) VALUES
 (1, 'img/salas/conferencias_1.jpg'), (1, 'img/salas/conferencias_2.jpg'),
 (2, 'img/salas/ejecutiva_a_1.jpg'),  (2, 'img/salas/ejecutiva_a_2.jpg'),
 (3, 'img/salas/ejecutiva_b_1.jpg'),
 (4, 'img/salas/oficina_1.jpg'),
 (5, 'img/salas/oficina_2.jpg');

INSERT INTO promociones (id_sala, descuento, estado, fecha_inicio, fecha_fin) VALUES
 (1, 20.00, 'activa',   '2026-11-01', '2026-11-30'),
 (2, 10.00, 'activa',   '2026-11-01', '2026-12-31'),
 (4, 15.00, 'inactiva', '2026-09-01', '2026-10-31');

INSERT INTO asigna (id_sala, id_mobiliario) VALUES
 (1, 1), (1, 2), (1, 3), (1, 4),
 (2, 1), (2, 4), (2, 5), (2, 6),
 (3, 1), (3, 5), (3, 6),
 (4, 7), (4, 8),
 (5, 7), (5, 8), (5, 9);

INSERT INTO reservas (id_reserva, id_usuario, id_sala, fecha, estado, modalidad) VALUES
 (1, 3, 2, '2026-10-28', 'finalizada', 'hora'),
 (2, 4, 1, '2026-11-02', 'confirmada', 'dia'),
 (3, 3, 4, '2026-11-03', 'pendiente',  'hora'),
 (4, 5, 3, '2026-11-01', 'cancelada',  'hora'),
 (5, 2, 1, '2026-11-10', 'confirmada', 'dia');

INSERT INTO horarios (id_reserva, fecha, hora_inicio, hora_fin) VALUES
 (1, '2026-10-30', '10:00:00', '12:00:00'),
 (2, '2026-11-14', '08:00:00', '21:00:00'),
 (3, '2026-11-06', '09:00:00', '13:00:00'),
 (3, '2026-11-07', '09:00:00', '13:00:00'),
 (4, '2026-11-05', '16:00:00', '18:00:00'),
 (5, '2026-11-20', '08:00:00', '21:00:00');

INSERT INTO cancelaciones (id_reserva, motivo, penalizacion) VALUES
 (4, 'Se cambió la fecha de la entrevista.', 0.00);

INSERT INTO pagos (id_reserva, fecha, referencia, monto) VALUES
 (1, '2026-10-28 11:20:00', 'TRF-102801', 250.00),
 (1, '2026-10-30 12:05:00', 'EFE-103001', 250.00),
 (2, '2026-11-02 18:40:00', 'TRF-110201', 2500.00),
 (4, '2026-11-01 09:15:00', 'TRF-110101', 250.00),
 (5, '2026-11-10 10:30:00', 'TRF-111001', 2200.00);

INSERT INTO asignar_servicios (id_reserva, id_servicio) VALUES
 (1, 1),
 (2, 2), (2, 4), (2, 5),
 (3, 3),
 (5, 4);

-- Reservas de ejemplo extra (para el dashboard y los reportes)
INSERT INTO reservas (id_reserva, id_usuario, id_sala, fecha, estado, modalidad) VALUES
 (6, 3, 2, '2026-11-05', 'finalizada', 'hora'),
 (7, 4, 4, '2026-11-06', 'finalizada', 'hora'),
 (8, 2, 1, '2026-11-08', 'finalizada', 'dia'),
 (9, 5, 2, '2026-11-10', 'finalizada', 'hora'),
 (10, 3, 3, '2026-11-12', 'confirmada', 'hora'),
 (11, 2, 2, '2026-11-13', 'confirmada', 'hora'),
 (12, 4, 5, '2026-11-14', 'pendiente', 'hora'),
 (13, 3, 1, '2026-11-15', 'confirmada', 'dia'),
 (14, 5, 4, '2026-11-16', 'cancelada', 'hora'),
 (15, 2, 2, '2026-11-17', 'pendiente', 'hora'),
 (16, 4, 3, '2026-11-18', 'confirmada', 'hora'),
 (17, 3, 2, '2026-11-18', 'pendiente', 'hora');

INSERT INTO horarios (id_reserva, fecha, hora_inicio, hora_fin) VALUES
 (6, '2026-11-09', '10:00:00', '13:00:00'),
 (7, '2026-11-11', '09:00:00', '12:00:00'),
 (8, '2026-11-13', '09:00:00', '22:00:00'),
 (9, '2026-11-16', '16:00:00', '19:00:00'),
 (10, '2026-11-19', '11:00:00', '13:00:00'),
 (11, '2026-11-19', '17:00:00', '20:00:00'),
 (12, '2026-11-21', '09:00:00', '11:00:00'),
 (13, '2026-11-27', '09:00:00', '22:00:00'),
 (14, '2026-11-24', '10:00:00', '12:00:00'),
 (15, '2026-12-02', '10:00:00', '14:00:00'),
 (16, '2026-12-04', '16:00:00', '18:00:00'),
 (17, '2026-12-09', '10:00:00', '12:00:00');

INSERT INTO pagos (id_reserva, fecha, referencia, monto) VALUES
 (6, '2026-11-05 10:00:00', 'TRF-61', 375.00),
 (6, '2026-11-05 11:00:00', 'TRF-62', 375.00),
 (7, '2026-11-06 10:00:00', 'TRF-71', 225.00),
 (7, '2026-11-06 11:00:00', 'TRF-72', 225.00),
 (8, '2026-11-08 10:00:00', 'TRF-81', 2000.00),
 (8, '2026-11-08 11:00:00', 'TRF-82', 2000.00),
 (9, '2026-11-10 10:00:00', 'TRF-91', 375.00),
 (9, '2026-11-10 11:00:00', 'TRF-92', 375.00),
 (10, '2026-11-12 10:00:00', 'TRF-101', 220.00),
 (11, '2026-11-13 10:00:00', 'TRF-111', 375.00),
 (13, '2026-11-15 10:00:00', 'TRF-131', 2000.00),
 (14, '2026-11-16 10:00:00', 'TRF-141', 150.00),
 (16, '2026-11-18 10:00:00', 'TRF-161', 220.00);

INSERT INTO asignar_servicios (id_reserva, id_servicio) VALUES
 (6, 1),
 (8, 4),
 (8, 2),
 (9, 3),
 (11, 1),
 (11, 5),
 (13, 4),
 (15, 2),
 (17, 1);

INSERT INTO cancelaciones (id_reserva, motivo, penalizacion) VALUES
 (14, 'Se le cruzó otra cita.', 0.00);

INSERT INTO carrusel (titulo, imagen, orden, activo) VALUES
 ('Bienvenido a VITÁN Coworking', 'portada_fachada.jpg', 1, 1),
 ('Oficinas privadas', 'portada_oficina.jpg', 2, 1),
 ('Salas para tus eventos', 'portada_evento.jpg', 3, 1);

-- ¿Quiénes somos? (un solo registro)
INSERT INTO quienes_somos (id_quienes, informacion, mision, vision, direccion, mapa_url) VALUES
 (1,
  'VITÁN Coworking es el primer coworking de Huejutla de Reyes, Hidalgo. Renta oficinas privadas, salas ejecutivas y una sala de conferencias por hora o por día, con internet, clima y mobiliario de primer nivel.',
  'Ofrecer en Huejutla de Reyes salas de trabajo flexibles, cómodas y bien equipadas, que profesionistas, empresas e instituciones puedan consultar y reservar de forma fácil y segura, con una atención confiable que les permita enfocarse en lo que hacen.',
  'Ser el coworking de referencia en la Huasteca hidalguense, reconocido por la calidad de sus salas, la confianza de su servicio y una forma moderna de reservar en línea, y crecer con nuevos servicios y sucursales sin perder la atención cercana que nos distingue.',
  'Av. Juárez, Centro, Huejutla de Reyes, Hidalgo, C.P. 43000',
  'https://www.google.com/maps?q=Av.+Juarez+Huejutla+de+Reyes+Hidalgo&output=embed');

-- Preguntas frecuentes (son 5; el administrador solo las cambia)
INSERT INTO preguntas_frecuentes (id_pregunta, pregunta, respuesta) VALUES
 (1, '¿Cómo reservo una sala?', 'Crea tu cuenta o inicia sesión, elige la sala, el día y las horas libres, y confirma tu reserva.'),
 (2, '¿Cuánto debo pagar para apartar?', 'Un anticipo del 50 % del total. Con el anticipo pagado tu reserva queda confirmada.'),
 (3, '¿Puedo cancelar mi reserva?', 'Sí. Si cancelas con 5 días o más de anticipación no se cobra nada; con menos, el anticipo no se devuelve.'),
 (4, '¿Cuál es el horario?', 'Todos los días de 9:00 a 22:00. La reserva mínima es de 2 horas.'),
 (5, '¿Qué incluyen las salas?', 'Internet, clima, luz, agua, baño, sillas y escritorios; las salas ejecutivas y la de conferencias tienen pantalla o televisión.');
