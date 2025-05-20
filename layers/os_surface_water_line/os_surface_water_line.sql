CREATE OR REPLACE FUNCTION layer_os_surface_water_line(bbox geometry, zoom_level integer)
    RETURNS TABLE
            (
                geometry geometry
            )
AS
$$
SELECT geometry
FROM os_vmdvec_surface_water_line
WHERE geometry && bbox
  AND zoom_level >= 10
ORDER BY fid;
$$
    LANGUAGE SQL
    STABLE
    PARALLEL SAFE;
