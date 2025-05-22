DROP TABLE IF EXISTS dobih_os_link;

CREATE TABLE dobih_os_link
(
    dobih_number integer not null,
    os_id        text    not null
);

INSERT INTO dobih_os_link (dobih_number, os_id)
SELECT dobih.number, os.id
FROM dobih
         LEFT JOIN (SELECT *, replace(unaccent(os.distinctive_name), ' or ', ' ') as normalized_name
                    FROM os_vmdvec_named_place os) os ON os.feature_code = 25802 AND
                                                         st_dwithin(dobih.geometry, os.geometry, 200)
WHERE coalesce(greatest(word_similarity(dobih.name, os.normalized_name),
                        word_similarity(os.normalized_name, dobih.name),
                        word_similarity(os.normalized_name, 'Point ' || dobih.height || 'm')), 0) > 0.55;
