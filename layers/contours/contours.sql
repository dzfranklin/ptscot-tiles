CREATE OR REPLACE FUNCTION layer_contours(bbox geometry, zoom_level integer)
    RETURNS TABLE
            (
                height   double precision,
                nth_line integer,
                geometry geometry
            )
AS
$$
SELECT height, nth_line, geometry
FROM os_terr50_contour_line
WHERE geometry && bbox
  AND CASE
          WHEN zoom_level >= 13 THEN true
          WHEN zoom_level >= 12 THEN nth_line = 5 OR nth_line = 10 OR nth_line = 2
          WHEN zoom_level >= 11 THEN nth_line = 5 OR nth_line = 10
          WHEN zoom_level >= 10 THEN nth_line = 10
          ELSE false
    END
ORDER BY ogc_fid;
$$
    LANGUAGE SQL STABLE
                 PARALLEL SAFE;
