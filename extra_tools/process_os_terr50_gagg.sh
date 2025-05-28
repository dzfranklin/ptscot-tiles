#!/usr/bin/env bash
set -euo pipefail

input="$1"

cd "$input"

scot_minx=-10
scot_miny=54.56
scot_maxx=0
scot_maxy=61

if [[ ! -f data.tif || ! -f data_scot.tif ]]; then
  if [[ ! -d data ]]; then
    echo "Missing downloaded terrain50 grid data"
    exit 1
  fi

  # Skip NR33 since it is all zeros and thus autodetected as integers instead of floats
  find data -name '*.asc' | sed '/NR33.asc/d' > input_list.txt

  echo "Compiling data to vrt..."
  gdalbuildvrt data.vrt -input_file_list input_list.txt
  rm input_list.txt

  echo "Warping data to web mercator..."
  gdalwarp -t_srs epsg:3857 data.vrt data.tif
  rm data.vrt
  rm -r data

  echo "Generating Scotland-only tif..."
  gdal_translate -projwin_srs 'epsg:4326' -projwin $scot_minx $scot_maxy $scot_maxx $scot_miny data.tif data_scot.tif
fi

if [[ ! -f gdal_contour_polygons.gpkg ]]; then
  echo "Generating contour polygons..."
  gdal_contour \
    -p \
    -i 50 \
    -amin min \
    -amax max \
    -inodata \
    -nln gdal_contour_polygons \
    data.tif gdal_contour_polygons.gpkg
  echo "Generated contour polygons"
fi

if [[ ! -f rgb_dem_scotland.mbtiles ]]; then
  echo "Generating RGB DEM.."

  dem_minz=3
  dem_maxz=9

  echo "- Encoding as mapbox raster dem..."
  rio rgbify --workers 8 -b -10000 -i 0.1 data_scot.tif rgb_dem_scot.tif

  echo "- Tiling..."
  test -d rgb_dem_scot_tiles && rm -r ./rgb_dem_scot_tiles
  gdal2tiles.py --zoom=$dem_minz-$dem_maxz \
    --xyz --resampling=cubic --tilesize=512 --exclude \
    --webp-lossless --tiledriver=WEBP \
    --processes="$(nproc)" --webviewer=leaflet \
    --title="RGB DEM (Scotland)" --copyright="<a href=\"http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/\" target=\"_blank\">&copy; Ordnance Survey</a>" \
    rgb_dem_scot.tif rgb_dem_scot_tiles
  rm rgb_dem_scot.tif

  echo "- Creating mbtiles archive..."
  test -f rgb_dem_scotland.mbtiles && rm rgb_dem_scotland.mbtiles
  cat <<EOF >rgb_dem_scot_tiles/metadata.json
{
  "name": "RGB DEM (Scotland)",
  "description": "An excerpt of OS Terrain 50",
  "attribution": "<a href=\"http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/\" target=\"_blank\">&copy; Ordnance Survey</a>",
  "type": "overlay",
  "bounds": "$scot_minx,$scot_miny,$scot_maxx,$scot_maxy",
  "center": "-4.343,56.664,7",
  "maxzoom": $dem_maxz,
  "minzoom": $dem_minz,
  "format": "webp"
}
EOF
  mb-util --image_format=webp \
    ./rgb_dem_scot_tiles rgb_dem_scotland.mbtiles
  rm -r rgb_dem_scot_tiles

  echo "Generated RGB DEM"
fi
