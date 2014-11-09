# build/ETOPO1_Ice_g_geotiff.zip:
# 	mkdir -p $(dir $@)
# 	curl -o $@ http://www.ngdc.noaa.gov/mgg/global/relief/ETOPO1/data/ice_surface/grid_registered/georeferenced_tiff/$(notdir $@)

# build/ETOPO1_Ice_g_geotiff.tif: build/ETOPO1_Ice_g_geotiff.zip
# 	unzip -od $(dir $@) $<
# 	touch $@

# build/crop.tif: build/ETOPO1_Ice_g_geotiff.tif
# 	gdal_translate -projwin -126.178 49.3978 -125.3171 48.9171 build/ETOPO1_Ice_g_geotiff.tif build/crop.tif
# 	# ulx uly lrx lry  // W S E N

# make shp from DEM
build/tofino_e.shp: build/all/092f04/092f04_0100_deme.dem
	gdal_contour -a ELEV -i 50.0 build/all/092f04/092f04_0100_deme.dem build/tofino_e.shp

build/tofino_w.shp: build/all/092f04/092f04_0100_demw.dem
	gdal_contour -a ELEV -i 50.0 build/all/092f04/092f04_0100_demw.dem build/tofino_w.shp

# run this in terminal to merge all contour shp files
	# for i in $(ls build/*.shp); do ogr2ogr -f 'ESRI Shapefile' -where "ELEV < 500" -update -append build/merged_500m $i -nln contours done

# make Topojson file
build/contours.json: build/merged_500m/contours.shp
	node_modules/.bin/topojson \
	-o $@ \
	-p elevation="ELEV" \
	-- contours=$<

# background first method

# gdal_translate build/all/092c09/092c09_0100_demw.dem stuff.tif
# gdal_translate build/all/092c09/092c09_0100_deme.dem stuffe.tif

# gdal_rasterize -a ELEV -ts 3000 3000 -l contours /Users/mathewbrown/projects/wave/build/merged_500m/contours.shp /Users/mathewbrown/projects/wave/build/out.tif

# gdal_calc.py -A build/out.tif --outfile=level0300.tif --calc="300*(A>300)" --overwrite

# gdal_polygonize.py level0300.tif -f "ESRI Shapefile" level0300.shp level_0300 elev

build/contours.json: levels.shp
	node_modules/.bin/topojson \
	-o $@ \
	-p elevation="ELEV" \
	-- contours=$<