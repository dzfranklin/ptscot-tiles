CREATE OR REPLACE FUNCTION layer_hillshade_clip()
    RETURNS TABLE
            (
                geom geometry
            )
AS
$$
SELECT geom
FROM (VALUES (st_transform(st_geomfromgeojson('{
      "type": "Polygon",
      "coordinates": [
        [
          [-45, 40.97989807],
          [0, 40.97989807],
          [0, 66.513260443],
          [-45, 66.513260443],
          [-45, 40.97989807]
        ],
        [
          [-9.9, 60.9],
          [-0.1, 60.9],
          [-0.1, 54.6],
          [-9.9, 54.6],
          [-9.9, 60.9]
        ]
      ]
      }'), 'epsg:4326', 'epsg:3857'))) AS v (geom)
$$
    LANGUAGE SQL
    STABLE
    PARALLEL SAFE;
