CREATE OR REPLACE FUNCTION layer_os_named_place(bbox geometry,zoom_level integer)
    RETURNS TABLE
            (
                geometry         geometry,
                distinctive_name text,
                font_height      text,
                text_orientation integer
            )
AS
$$
SELECT geometry, distinctive_name, font_height, text_orientation
FROM os_vmdvec_named_place
WHERE geometry && bbox
  AND id NOT IN (SELECT os_id FROM dobih_os_link)
  AND CASE
          WHEN font_height = 'Extra Large' THEN zoom_level >= 8
          WHEN font_height = 'Large' THEN zoom_level >= 9
          WHEN font_height = 'Medium' THEN zoom_level >= 10
          ELSE zoom_level >= 11
    END
ORDER BY CASE
             WHEN font_height = 'Extra Large' THEN 1
             WHEN font_height = 'Large' THEN 2
             WHEN font_height = 'Medium' THEN 3
             WHEN font_height = 'Small' THEN 4
             ELSE 5
             END,
         fid;
$$
    LANGUAGE SQL
    STABLE
    PARALLEL SAFE;
