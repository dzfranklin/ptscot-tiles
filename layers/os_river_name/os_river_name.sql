CREATE OR REPLACE FUNCTION layer_os_river_name(bbox geometry, zoom_level integer)
    RETURNS TABLE
            (
                geometry geometry,
                name     text,
                length   double precision
            )
AS
$$
-- labels look bad with sharp angles
SELECT st_simplify(
               st_chaikinsmoothing(
                       st_simplify(geometry, zres(zoom_level - 2)),
                       2),
               zres(zoom_level + 2)
       )                as geometry,
       watercourse_name as name,
       length
FROM os_oprvs_watercourse_link
WHERE geometry && bbox
  AND watercourse_name IS NOT NULL
ORDER BY length DESC
    -- TODO: filter based on zoom and length
$$
    LANGUAGE SQL
    STABLE
    PARALLEL SAFE;
