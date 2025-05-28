DROP TABLE IF EXISTS filled_contours CASCADE;
CREATE TABLE filled_contours
(
    id       integer primary key generated always as identity,
    geometry geometry,
    height   integer,
    area     double precision -- in square km
);
CREATE INDEX IF NOT EXISTS filled_contours_geometry_idx ON filled_contours USING gist (geometry);

INSERT INTO filled_contours (geometry, height, area)
SELECT geometry,
       (floor(min / 50) * 50)      as height,
       st_area(geometry) / 1000000 as area
FROM (SELECT st_makepolygon(st_exteriorring((st_dump(geom)).geom)) as geometry,
             min
      FROM gdal_contour_polygons
      WHERE min >= 50) t;

DROP MATERIALIZED VIEW IF EXISTS clipped_filled_contours;
CREATE MATERIALIZED VIEW clipped_filled_contours AS
(
SELECT id,
       st_intersection(geometry, st_transform(st_makeenvelope(-10, 54.56, 0, 61, 4326), 3857)) as geometry,
       height,
       area
FROM filled_contours
WHERE geometry && st_transform(st_makeenvelope(-10, 54.56, 0, 61, 4326), 3857)
);
CREATE INDEX IF NOT EXISTS clipped_filled_contours_geometry_idx ON clipped_filled_contours USING gist (geometry);

DROP MATERIALIZED VIEW IF EXISTS filled_contours_gen_z4 CASCADE;
CREATE MATERIALIZED VIEW filled_contours_gen_z4 AS
(
SELECT id,
       st_simplify(st_chaikinsmoothing(geometry, 3),
       zres(7)) as geometry,
    height,
    area
    FROM filled_contours
        WHERE area > 3000
            AND height = 200
);
CREATE INDEX IF NOT EXISTS filled_contours_gen_z4_geometry_idx ON filled_contours_gen_z4 USING gist (geometry);

DROP MATERIALIZED VIEW IF EXISTS filled_contours_gen_z5;
CREATE MATERIALIZED VIEW filled_contours_gen_z5 AS
(
SELECT id,
       st_simplify(st_chaikinsmoothing(geometry, 3),
                   zres(8)) as geometry,
       height,
       area
FROM filled_contours
WHERE area > 900
  AND height = 200
    );
CREATE INDEX IF NOT EXISTS filled_contours_gen_z5_geometry_idx ON filled_contours_gen_z5 USING gist (geometry);

DROP MATERIALIZED VIEW IF EXISTS filled_contours_gen_z6 CASCADE;
CREATE MATERIALIZED VIEW filled_contours_gen_z6 AS
(
SELECT id,
       st_simplify(st_chaikinsmoothing(geometry, 3),
                   zres(9)) as geometry,
       height,
       area
FROM filled_contours
WHERE area > 300
  AND (height = 200 OR height = 500)
    );
CREATE INDEX IF NOT EXISTS filled_contours_gen_z6_geometry_idx ON filled_contours_gen_z6 USING gist (geometry);


DROP MATERIALIZED VIEW IF EXISTS filled_contours_gen_z7 CASCADE;
CREATE MATERIALIZED VIEW filled_contours_gen_z7 AS
(
SELECT id,
       st_simplify(st_chaikinsmoothing(geometry, 3),
                   zres(10)) as geometry,
       height,
       area
FROM filled_contours
WHERE area > 200
  AND (height = 200 OR height = 300 OR height = 500)
ORDER BY height, id
    );
CREATE INDEX IF NOT EXISTS filled_contours_gen_z7_geometry_idx ON filled_contours_gen_z7 USING gist (geometry);


DROP MATERIALIZED VIEW IF EXISTS filled_contours_gen_z8 CASCADE;
CREATE MATERIALIZED VIEW filled_contours_gen_z8 AS
(
SELECT id,
       st_simplify(st_chaikinsmoothing(geometry, 3),
                   zres(11)) as geometry,
       height,
       area
FROM filled_contours
WHERE area > 3
  AND (height = 100 OR height = 200 OR height = 400 OR height = 600)
ORDER BY height, id
    );
CREATE INDEX IF NOT EXISTS filled_contours_gen_z8_geometry_idx ON filled_contours_gen_z8 USING gist (geometry);

DROP MATERIALIZED VIEW IF EXISTS filled_contours_gen_z9 CASCADE;
CREATE MATERIALIZED VIEW filled_contours_gen_z9 AS
(
SELECT id,
       st_simplify(
               st_chaikinsmoothing(geometry, 3),
               zres(12)) as geometry,
       height,
       area
FROM clipped_filled_contours
WHERE area > 0.1
  AND mod(height, 100) = 0
ORDER BY height, id
    );
CREATE INDEX IF NOT EXISTS filled_contours_gen_z9_geometry_idx ON filled_contours_gen_z9 USING gist (geometry);

DROP MATERIALIZED VIEW IF EXISTS filled_contours_gen_z10 CASCADE;
CREATE MATERIALIZED VIEW filled_contours_gen_z10 AS
(
SELECT id,
       st_simplify(
               geometry,
               zres(13)) as geometry,
       height,
       area
FROM clipped_filled_contours
ORDER BY height, id
    );
CREATE INDEX IF NOT EXISTS filled_contours_gen_z10_geometry_idx ON filled_contours_gen_z10 USING gist (geometry);

-- The filled_contours I generated from the Terrain50 grid are visibly worse than the Terrain50 contours around z11.5
