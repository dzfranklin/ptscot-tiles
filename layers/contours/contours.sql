CREATE OR REPLACE FUNCTION layer_contours(bbox geometry, zoom_level integer)
    RETURNS TABLE
            (
                geometry geometry,
                height   double precision,
                nth_line integer
            )
AS
$$
SELECT geometry, height, nth_line
FROM (SELECT fid,
             geometry,
             property_value as height,
             CASE
                 WHEN mod(cast(property_value as numeric), 100) = 0 THEN 10
                 WHEN mod(cast(property_value as numeric), 50) = 0 THEN 5
                 WHEN mod(cast(property_value as numeric), 20) = 0 THEN 2
                 WHEN mod(cast(property_value as numeric), 10) = 0 THEN 1
                 ELSE 0 END AS nth_line
      FROM os_terr50_contour_line) os
WHERE geometry && bbox
  AND CASE
          WHEN zoom_level >= 13 THEN true
          WHEN zoom_level >= 12 THEN nth_line = 5 OR nth_line = 10 OR nth_line = 2
          WHEN zoom_level >= 11 THEN nth_line = 5 OR nth_line = 10
          WHEN zoom_level >= 10 THEN nth_line = 10
          ELSE false
    END
ORDER BY fid
$$
    LANGUAGE SQL STABLE
                 PARALLEL SAFE;
