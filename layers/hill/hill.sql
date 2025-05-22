CREATE OR REPLACE FUNCTION layer_hill(bbox geometry,
                                      zoom_level integer)
    RETURNS TABLE
            (
                dobih_number   integer,
                geometry       geometry,
                name           text,
                height         numeric,
                classification text[],
                is_munro       bool,
                is_corbett     bool,
                is_graham      bool
            )
AS
$$
SELECT dobih_number,
       geometry,
       name,
       height,
       classification,
       is_munro,
       is_corbett,
       is_graham
FROM (SELECT dobih.number                    as dobih_number,
             dobih.geometry,
             coalesce(os.distinctive_name, dobih.name) as name,
             floor(dobih.height)             as height,
             dobih.classification,
             dobih.classification @> '{"M"}' as is_munro,
             dobih.classification @> '{"C"}' as is_corbett,
             dobih.classification @> '{"G"}' as is_graham
      FROM dobih
               LEFT JOIN dobih_os_link link ON link.dobih_number = dobih.number
               LEFT JOIN os_vmdvec_named_place os ON os.id = link.os_id) d
WHERE geometry && bbox
  AND (zoom_level >= 10 OR (is_munro OR is_corbett OR is_graham))
ORDER BY height DESC, dobih_number
$$
    LANGUAGE SQL
    STABLE
    PARALLEL SAFE;
