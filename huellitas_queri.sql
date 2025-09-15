USE huellitas;

-- ----------------------------------------------------------------------------------------------------------------------------------------

-- o	Realizar una consulta que permita conocer en que zapatos fue usado determinado molde.



-- Parámetro: id del molde a consultar
SET @molde_id = 2;

-- Consulta: devuelve los zapatos que usaron ese molde
SELECT
  z.id_zapato,
  z.id_lote_zapatos,
  z.id_diseno,
  m.id_molde,
  m.tipo_zapato,
  m.talla_molde,
  d.nombre_diseno,
  z.fecha_construccion
FROM zapato z
JOIN molde m ON z.id_molde = m.id_molde
LEFT JOIN diseno d ON z.id_diseno = d.id_diseno
WHERE z.id_molde = @molde_id
ORDER BY z.fecha_construccion, z.id_zapato;

-- --------------------------------------------------------------------------------------------------------------------------------------------

-- o	Realizar una consulta que permita conocer que lotes de material fueron usados en la construcción de un zapato. 

-- Parámetro: id del zapato a inspeccionar
SET @zapato_id = 6;

-- Consulta: lista los trozos usados por el zapato y los lotes de material de origen
SELECT
  z.id_zapato,
  t.id_trozo,
  t.id_lote_material AS id_lote_material_origen,
  lm.id_lote             AS id_lote_material,
  lm.id_material,
  mat.descripcion        AS material_descripcion,
  lm.fecha_recepcion,
  lm.fecha_agotado,
  zut.cantidad           AS cantidad_usada_del_trozo
FROM zapato z
JOIN zapato_usa_trozo zut ON z.id_zapato = zut.id_zapato
JOIN trozo_material t ON zut.id_trozo = t.id_trozo
JOIN lote_material lm ON t.id_lote_material = lm.id_lote
JOIN material mat ON lm.id_material = mat.id_material
WHERE z.id_zapato = @zapato_id
ORDER BY t.id_trozo;
-- ----------------------------------------------------------------------------------------------------------------------------------------------

-- o	Realizar una consulta que permita conocer cuántos zapatos se crearon para un diseño determinado.

SET @diseno_id = 6;

SELECT
  d.id_diseno,
  d.nombre_diseno,
  COUNT(z.id_zapato) AS total_zapatos_registrados
FROM diseno d
LEFT JOIN zapato z ON d.id_diseno = z.id_diseno
WHERE d.id_diseno = @diseno_id
GROUP BY d.id_diseno, d.nombre_diseno;