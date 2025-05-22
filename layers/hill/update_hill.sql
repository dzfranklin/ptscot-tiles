DROP TABLE IF EXISTS dobih;
CREATE TABLE dobih
(
    number         integer primary key not null,
    geometry       geometry,
    name           text,
    classification text[],
    height         numeric
);

INSERT INTO dobih (number, geometry, name, classification, height)
SELECT cast("Number" as integer)                           as number,
       st_setsrid(st_transform(
                          st_makepoint(cast("Longitude" as double precision), cast("Latitude" as double precision)),
                          'epsg:4326', 'epsg:3857'), 3857) as geometry,
       "Name"                                              as name,
       string_to_array("Classification", ',')              as classification,
       cast("Metres" as numeric)                           as height
FROM dobih_csv
WHERE "Country" = 'S';

DELETE
FROM dobih
WHERE classification <@ '{"xMT","xC","xG","xDT","xN"}';
