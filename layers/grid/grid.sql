CREATE OR REPLACE FUNCTION layer_grid(bbox geometry, zoom_level integer)
    RETURNS TABLE
            (
                geometry geometry,
                grid     text
            )
AS
$$
SELECT geom AS geometry, size || 'km' as grid
FROM (SELECT id, geom, 10 as size
      FROM "10km_grid"
      WHERE zoom_level >= 9
      UNION ALL
      SELECT id, geom, 5 as size
      FROM "5km_grid"
      WHERE zoom_level >= 10
      UNION ALL
      SELECT id, geom, 1 as size
      FROM "1km_grid"
      WHERE zoom_level >= 11) g
WHERE geom && bbox
ORDER BY size, id
$$
    LANGUAGE SQL STABLE
                 PARALLEL SAFE;
