CREATE OR REPLACE FUNCTION layer_os_woodland(bbox geometry, zoom_level integer)
    RETURNS TABLE
            (
                geometry geometry
            )
AS
$$
SELECT geometry
FROM os_vmdvec_woodland
WHERE geometry && bbox
  AND zoom_level >= 10;
$$
    LANGUAGE SQL
    STABLE
    PARALLEL SAFE;
