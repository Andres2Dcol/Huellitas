USE huellitas;
-- o   Insertar 3 maestros zapateros, 2 ayudantes y 2 cortadores en base de datos.

-- Nuevos empleados (ids fijos para referenciarlos después: 6..12)
INSERT INTO empleado (id_empleado, nombre_completo, numero_telefono, direccion_residencia, fecha_nacimiento, id_cargo) VALUES
(6, 'Roberto Diaz',    '3106000006', 'Cll 30 #10-10, Bucaramanga', '1985-02-10', 1), -- Maestro
(7, 'Sergio Ramos',    '3106000007', 'Cll 31 #11-11, Floridablanca',  '1982-08-20', 1), -- Maestro
(8, 'Andres Silva',    '3106000008', 'Cll 32 #12-12, Giron',           '1988-12-05', 1), -- Maestro
(9, 'Paula Navarro',   '3106000009', 'Cll 33 #13-13, Bucaramanga',     '1994-04-02', 2), -- Ayudante
(10,'Diego Torres',    '3106000010', 'Cll 34 #14-14, Bucaramanga',     '1993-09-15', 2), -- Ayudante
(11,'Mateo Cruz',      '3106000011', 'Cll 35 #15-15, Giron',           '1996-06-22', 3), -- Cortador
(12,'Lucia Peña',      '3106000012', 'Cll 36 #16-16, Floridablanca',  '1997-11-30', 3); -- Cortador

-- Registrar en historial de roles (opcional pero recomendado)
INSERT INTO empleado_rol_hist (id_empleado, id_cargo, fecha_inicio) VALUES
(6, 1, CURDATE()), (7, 1, CURDATE()), (8, 1, CURDATE()),
(9, 2, CURDATE()), (10, 2, CURDATE()),
(11, 3, CURDATE()), (12, 3, CURDATE());


-- ------------------------------------------------------------------------------------------------------------------------------------------

-- o	Insertar un nuevo diseño de un zapato.

-- Nuevo diseño
INSERT INTO diseno (id_diseno, nombre_diseno, descripcion, id_suela, id_empleado_maestro, version, fecha_creacion)
VALUES (6, 'StreetPlus', 'Zapato urbano con refuerzo lateral y cordon reflectante', 1, 6, 1, CURDATE());

-- Materiales requeridos para el diseño (ejemplo: cuero + sintético)
INSERT INTO diseno_material (id_diseno, id_material, cantidad_trozos) VALUES
(6, 1, 2),  -- 2 trozos de cuero
(6, 3, 1);  -- 1 trozo sintético

-- -----------------------------------------------------------------------------------------------------------------------------------------------
-- o	Insertar un nuevo lote de 10 zapatos generados a partir de este diseño y con los empleados ya creados.

-- Lote de 10 zapatos para el diseno 6
INSERT INTO lote_zapatos (id_lote_zapatos, id_diseno, cantidad_zapatos, fecha_inicio, tiempo_estimado)
VALUES (6, 6, 10, CURDATE(), 40);

-- Insertar 10 zapatos instanciados (relacionados con el lote 6)
-- alterno maestros (6,7,8) y ayudantes (9,10) para ejemplo
INSERT INTO zapato (id_zapato, id_lote_zapatos, id_diseno, id_molde, id_empleado_maestro, id_empleado_ayudante, id_suela, fecha_construccion) VALUES
(6, 6, 6, 2, 6, 9, 1, CURDATE()),
(7, 6, 6, 2, 7,10, 1, CURDATE()),
(8, 6, 6, 2, 8, 9, 1, CURDATE()),
(9, 6, 6, 2, 6,10, 1, CURDATE()),
(10,6, 6, 2, 7, 9, 1, CURDATE()),
(11,6, 6, 2, 8,10, 1, CURDATE()),
(12,6, 6, 2, 6, 9, 1, CURDATE()),
(13,6, 6, 2, 7,10, 1, CURDATE()),
(14,6, 6, 2, 8, 9, 1, CURDATE()),
(15,6, 6, 2, 6,10, 1, CURDATE());

-- ------------------------------------------------------------------------------------------------------------------------------------------------------

-- o	Modificar el rol de un empleado de ayudante a maestro zapatero. 

START TRANSACTION;

-- 1) cerrar el periodo activo en el historial (si existe)
UPDATE empleado_rol_hist
SET fecha_fin = CURDATE()
WHERE id_empleado = 2 AND fecha_fin IS NULL;

-- 2) insertar nuevo registro de rol (maestro)
INSERT INTO empleado_rol_hist (id_empleado, id_cargo, fecha_inicio)
VALUES (2, 1, CURDATE());

-- 3) actualizar el cargo actual en la tabla empleado
UPDATE empleado
SET id_cargo = 1
WHERE id_empleado = 2;

COMMIT;


-- ----------------------------------------------------------------------------------------------------------------------------------------------------

-- o	Actualizar un diseño de un zapato agregando un accesorio nuevo.

-- Crear accesorio nuevo
INSERT INTO accesorio (id_accesorio, descripcion) VALUES (6, 'Cordon reflectante');

-- Enlazar accesorio al diseño 6
INSERT INTO diseno_accesorio (id_diseno, id_accesorio) VALUES (6, 6);


-- -------------------------------------------------------------------------------------------------------------------------------------------------------

-- o	Actualizar un diseño de un zapato agregando un trozo de un material diferente.

INSERT INTO diseno_material (id_diseno, id_material, cantidad_trozos)
VALUES (6, 4, 1);


-- -------------------------------------------------------------------------------------------------------------------------------------------------

-- o	Eliminar un zapato de un lote.

START TRANSACTION;

-- 1) borrar el zapato
DELETE FROM zapato WHERE id_zapato = 15;

-- 2) decrementar el contador del lote (si deseas mantener cantidad real)
UPDATE lote_zapatos
SET cantidad_zapatos = GREATEST(0, cantidad_zapatos - 1)
WHERE id_lote_zapatos = 6;

COMMIT;


-- ---------------------------------------------------------------------------------------------------------------------------------------------

-- o	Eliminar un diseño de un zapato en base de datos que ya tenga un lote de 10 zapatos generados. 

START TRANSACTION;

-- 1) borrar zapatos del/los lote(s) del diseno 6
DELETE z FROM zapato z
JOIN lote_zapatos l ON z.id_lote_zapatos = l.id_lote_zapatos
WHERE l.id_diseno = 6;

-- 2) borrar los lotes asociados al diseno 6
DELETE FROM lote_zapatos WHERE id_diseno = 6;

-- 3) finalmente borrar el diseño
DELETE FROM diseno WHERE id_diseno = 6;

COMMIT;

-- --------------------------------------------------------------------------------------------------------------------------------------------------------

-- o	Insertar un nuevo accesorio en base de datos y luego insertar un diseño que use este accesorio.

-- Nuevo accesorio (id 7)
INSERT INTO accesorio (id_accesorio, descripcion) VALUES (7, 'Placa metalica logo');

-- Nuevo diseño (id 7) que usa la suela id=2 y el maestro id=7
INSERT INTO diseno (id_diseno, nombre_diseno, descripcion, id_suela, id_empleado_maestro, version, fecha_creacion)
VALUES (7, 'SignatureLogo', 'Diseño premium con placa metalica en el empeine', 2, 7, 1, CURDATE());

-- Enlazar el accesorio 7 con el diseño 7
INSERT INTO diseno_accesorio (id_diseno, id_accesorio) VALUES (7, 7);
