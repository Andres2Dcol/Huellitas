-- Crear Tablas Para la Base de Datos 
CREATE DATABASE IF NOT EXISTS huellitas CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE huellitas;

-- Cargos de empleados (maestro, ayudante, cortador, etc.)
CREATE TABLE cargo_empleado (
  id_cargo INT AUTO_INCREMENT PRIMARY KEY,
  nombre_cargo VARCHAR(45) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- Empleados
CREATE TABLE empleado (
  id_empleado INT AUTO_INCREMENT PRIMARY KEY,
  nombre_completo VARCHAR(100) NOT NULL,
  numero_telefono VARCHAR(45),
  direccion_residencia VARCHAR(150),
  fecha_nacimiento DATE,
  -- cargo actual (nullable si usas historial)
  id_cargo INT,
  CONSTRAINT fk_emp_cargo FOREIGN KEY (id_cargo) REFERENCES cargo_empleado(id_cargo)
    ON UPDATE RESTRICT ON DELETE SET NULL
) ENGINE=InnoDB;

-- Historial de roles (permite preservar rol por periodo)
CREATE TABLE empleado_rol_hist (
  id_hist INT AUTO_INCREMENT PRIMARY KEY,
  id_empleado INT NOT NULL,
  id_cargo INT NOT NULL,
  fecha_inicio DATE NOT NULL,
  fecha_fin DATE DEFAULT NULL,
  CONSTRAINT fk_erh_emp FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_erh_cargo FOREIGN KEY (id_cargo) REFERENCES cargo_empleado(id_cargo)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Proveedores
CREATE TABLE proveedor (
  id_proveedor INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  direccion VARCHAR(150),
  correo VARCHAR(100),
  numero_telefono VARCHAR(45)
) ENGINE=InnoDB;

-- Materiales (tipo/material)
CREATE TABLE material (
  id_material INT AUTO_INCREMENT PRIMARY KEY,
  descripcion VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

-- Lotes de material (recepción y agotamiento) gestionados por un ayudante
CREATE TABLE lote_material (
  id_lote INT AUTO_INCREMENT PRIMARY KEY,
  id_material INT NOT NULL,
  cantidad_material INT NOT NULL,
  fecha_recepcion DATE NOT NULL,
  fecha_agotado DATE DEFAULT NULL,
  id_empleado_ayudante INT,
  id_proveedor INT,
  CONSTRAINT fk_lm_material FOREIGN KEY (id_material) REFERENCES material(id_material)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_lm_ayudante FOREIGN KEY (id_empleado_ayudante) REFERENCES empleado(id_empleado)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_lm_prov FOREIGN KEY (id_proveedor) REFERENCES proveedor(id_proveedor)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- Molde y lote de moldes
CREATE TABLE molde (
  id_molde INT AUTO_INCREMENT PRIMARY KEY,
  tipo_zapato VARCHAR(100),
  talla_molde VARCHAR(20),
  fabricante VARCHAR(100)
) ENGINE=InnoDB;

CREATE TABLE lote_molde (
  id_lote INT AUTO_INCREMENT PRIMARY KEY,
  id_molde INT NOT NULL,
  cantidad_molde INT NOT NULL,
  fecha_recepcion DATE NOT NULL,
  fecha_agotado DATE DEFAULT NULL,
  id_proveedor INT,
  CONSTRAINT fk_lm_molde FOREIGN KEY (id_molde) REFERENCES molde(id_molde)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_lm_molde_prov FOREIGN KEY (id_proveedor) REFERENCES proveedor(id_proveedor)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- Suela y lote de suelas
CREATE TABLE suela (
  id_suela INT AUTO_INCREMENT PRIMARY KEY,
  descripcion VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE lote_suela (
  id_lote INT AUTO_INCREMENT PRIMARY KEY,
  id_suela INT NOT NULL,
  cantidad_suela INT NOT NULL,
  fecha_recepcion DATE NOT NULL,
  fecha_agotado DATE DEFAULT NULL,
  id_proveedor INT,
  CONSTRAINT fk_ls_suela FOREIGN KEY (id_suela) REFERENCES suela(id_suela)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_ls_prov FOREIGN KEY (id_proveedor) REFERENCES proveedor(id_proveedor)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- Accesorios y lote de accesorios
CREATE TABLE accesorio (
  id_accesorio INT AUTO_INCREMENT PRIMARY KEY,
  descripcion VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE lote_accesorio (
  id_lote INT AUTO_INCREMENT PRIMARY KEY,
  id_accesorio INT NOT NULL,
  cantidad_accesorio INT NOT NULL,
  fecha_recepcion DATE NOT NULL,
  fecha_agotado DATE DEFAULT NULL,
  id_proveedor INT,
  CONSTRAINT fk_la_acc FOREIGN KEY (id_accesorio) REFERENCES accesorio(id_accesorio)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_la_prov FOREIGN KEY (id_proveedor) REFERENCES proveedor(id_proveedor)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- Diseño (versionable)
CREATE TABLE diseno (
  id_diseno INT AUTO_INCREMENT PRIMARY KEY,
  nombre_diseno VARCHAR(100) NOT NULL,
  descripcion TEXT,
  id_suela INT,
  id_empleado_maestro INT, -- autor del diseño
  version INT NOT NULL DEFAULT 1,
  fecha_creacion DATE DEFAULT (CURRENT_DATE),
  CONSTRAINT fk_diseno_suela FOREIGN KEY (id_suela) REFERENCES suela(id_suela)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_diseno_maestro FOREIGN KEY (id_empleado_maestro) REFERENCES empleado(id_empleado)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- Materiales requeridos por un diseño (cuántos trozos de cada material)
CREATE TABLE diseno_material (
  id_diseno_material INT AUTO_INCREMENT PRIMARY KEY,
  id_diseno INT NOT NULL,
  id_material INT NOT NULL,
  cantidad_trozos INT NOT NULL DEFAULT 1,
  CONSTRAINT fk_dm_diseno FOREIGN KEY (id_diseno) REFERENCES diseno(id_diseno)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_dm_material FOREIGN KEY (id_material) REFERENCES material(id_material)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Accesorios por diseño
CREATE TABLE diseno_accesorio (
  id_diseno_ac INT AUTO_INCREMENT PRIMARY KEY,
  id_diseno INT NOT NULL,
  id_accesorio INT NOT NULL,
  CONSTRAINT fk_da_diseno FOREIGN KEY (id_diseno) REFERENCES diseno(id_diseno)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_da_acc FOREIGN KEY (id_accesorio) REFERENCES accesorio(id_accesorio)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Lote de zapatos (producción)
CREATE TABLE lote_zapatos (
  id_lote_zapatos INT AUTO_INCREMENT PRIMARY KEY,
  id_diseno INT NOT NULL,
  cantidad_zapatos INT NOT NULL,
  fecha_inicio DATE,
  fecha_fin DATE DEFAULT NULL,
  tiempo_estimado INT DEFAULT NULL, -- en horas por ejemplo
  CONSTRAINT fk_lz_diseno FOREIGN KEY (id_diseno) REFERENCES diseno(id_diseno)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Zapato (instancia fabricada)
CREATE TABLE zapato (
  id_zapato INT AUTO_INCREMENT PRIMARY KEY,
  id_lote_zapatos INT NOT NULL,
  id_diseno INT NOT NULL,         -- referencia a la versión de diseño usada
  id_molde INT,
  id_empleado_maestro INT,        -- quien lo realizó
  id_empleado_ayudante INT,       -- ayudante que asistió
  id_suela INT,                   -- suela usada
  fecha_construccion DATE DEFAULT (CURRENT_DATE),
  CONSTRAINT fk_z_lote FOREIGN KEY (id_lote_zapatos) REFERENCES lote_zapatos(id_lote_zapatos)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_z_diseno FOREIGN KEY (id_diseno) REFERENCES diseno(id_diseno)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_z_molde FOREIGN KEY (id_molde) REFERENCES molde(id_molde)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_z_maestro FOREIGN KEY (id_empleado_maestro) REFERENCES empleado(id_empleado)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_z_ayudante FOREIGN KEY (id_empleado_ayudante) REFERENCES empleado(id_empleado)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_z_suela FOREIGN KEY (id_suela) REFERENCES suela(id_suela)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- Trozos/materiales cortados (cada registro es un trozo o lote de trozos creado por un cortador)
CREATE TABLE trozo_material (
  id_trozo INT AUTO_INCREMENT PRIMARY KEY,
  id_lote_material INT NOT NULL,   -- lote de donde proviene
  id_material INT NOT NULL,
  cantidad_trozos INT NOT NULL DEFAULT 1,
  id_cortador INT,                 -- empleado que hizo los trozos
  fecha_generacion DATE DEFAULT (CURRENT_DATE),
  CONSTRAINT fk_tm_lote FOREIGN KEY (id_lote_material) REFERENCES lote_material(id_lote)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_tm_mat FOREIGN KEY (id_material) REFERENCES material(id_material)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_tm_cortador FOREIGN KEY (id_cortador) REFERENCES empleado(id_empleado)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- Relación trozos usados por zapato (trazabilidad)
CREATE TABLE zapato_usa_trozo (
  id_zut INT AUTO_INCREMENT PRIMARY KEY,
  id_zapato INT NOT NULL,
  id_trozo INT NOT NULL,
  cantidad INT NOT NULL DEFAULT 1,
  CONSTRAINT fk_zut_zap FOREIGN KEY (id_zapato) REFERENCES zapato(id_zapato)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_zut_trozo FOREIGN KEY (id_trozo) REFERENCES trozo_material(id_trozo)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Relación zapato-accesorio (si se añadió accesorio a un zapato)
CREATE TABLE zapato_accesorio (
  id_za INT AUTO_INCREMENT PRIMARY KEY,
  id_zapato INT NOT NULL,
  id_accesorio INT NOT NULL,
  id_lote_accesorio INT DEFAULT NULL,
  CONSTRAINT fk_za_zap FOREIGN KEY (id_zapato) REFERENCES zapato(id_zapato)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_za_acc FOREIGN KEY (id_accesorio) REFERENCES accesorio(id_accesorio)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_za_lote FOREIGN KEY (id_lote_accesorio) REFERENCES lote_accesorio(id_lote)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;
