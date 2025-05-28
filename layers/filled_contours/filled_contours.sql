CREATE OR REPLACE FUNCTION layer_filled_contours(bbox geometry, zoom_level integer)
    RETURNS TABLE
            (
                geometry geometry,
                height   integer,
                area     integer
            )
AS
$$
SELECT geometry,
       height,
       area
FROM (SELECT id, geometry, height, area
      FROM filled_contours_gen_z4
      WHERE zoom_level = 4
        AND geometry && bbox
      UNION ALL
      SELECT id, geometry, height, area
      FROM filled_contours_gen_z5
      WHERE zoom_level = 5
        AND geometry && bbox
      UNION ALL
      SELECT id, geometry, height, area
      FROM filled_contours_gen_z6
      WHERE zoom_level = 6
        AND geometry && bbox
      UNION ALL
      SELECT id, geometry, height, area
      FROM filled_contours_gen_z7
      WHERE zoom_level = 7
        AND geometry && bbox
      UNION ALL
      SELECT id, geometry, height, area
      FROM filled_contours_gen_z8
      WHERE zoom_level = 8
        AND geometry && bbox
      UNION ALL
      SELECT id, geometry, height, area
      FROM filled_contours_gen_z9
      WHERE zoom_level = 9
        AND geometry && bbox
      UNION ALL
      SELECT id, geometry, height, area
      FROM filled_contours_gen_z10
      WHERE zoom_level = 10
        AND geometry && bbox
      ORDER BY height, id) zoom_levels
$$
    LANGUAGE SQL
    STABLE
    PARALLEL SAFE;
