CREATE OR REPLACE FUNCTION layer_os_ornament(bbox geometry, zoom_level integer)
    RETURNS TABLE
            (
                geometry geometry
            )
AS
$$
SELECT geometry
FROM os_vmdvec_ornament
WHERE geometry && bbox
  AND zoom_level >= 11
ORDER BY fid;
$$
    LANGUAGE SQL
    STABLE
    PARALLEL SAFE;
