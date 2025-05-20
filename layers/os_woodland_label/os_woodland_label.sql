CREATE OR REPLACE FUNCTION layer_os_woodland_label(bbox geometry, zoom_level integer)
    RETURNS TABLE
            (
                geometry         geometry,
                distinctive_name text,
                font_height text
            )
AS
$$
SELECT geometry, distinctive_name, font_height
FROM os_vmdvec_named_place
WHERE feature_code = 25803
  AND geometry && bbox
  AND (font_height != 'Small' AND zoom_level >= 11) OR zoom_level >= 12
ORDER BY fid;
$$
    LANGUAGE SQL
    STABLE
    PARALLEL SAFE;
