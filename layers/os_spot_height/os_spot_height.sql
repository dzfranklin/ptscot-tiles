CREATE OR REPLACE FUNCTION layer_os_spot_height(bbox geometry,
                                                zoom_level integer)
    RETURNS TABLE
            (
                geometry  geometry,
                height    integer,
                height_ft integer
            )
AS
$$
SELECT geometry, round(height) as height, round(height * 3.28084) as height_ft
FROM os_vmdvec_spotheight
WHERE geometry && bbox
  AND zoom_level >= 11
ORDER BY height;
$$
    LANGUAGE SQL
    STABLE
    PARALLEL SAFE;
