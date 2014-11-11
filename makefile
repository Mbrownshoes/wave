# get BC census boundary and widdle downt to Nanaimo

build/subunits.json: build/Boundaries/CD_2011.shp
	ogr2ogr -f GeoJSON  -t_srs "+proj=latlong +datum=WGS84" -where "CDNAME IN ('Alberni-Clayoquot')" \
	build/subunits.json \
	build/Boundaries/CD_2011.shp

build/tofino_outline.json: build/subunits.json
	node_modules/.bin/topojson \
		-o $@ \
		-- $<

# make shp from DEM
build/tofino_e.shp: build/all/092f04/092f04_0100_deme.dem
	gdal_contour -a ELEV -i 1.0 build/all/092f04/092f04_0100_deme.dem build/tofino_e.shp

build/tofino_w.shp: build/all/092f04/092f04_0100_demw.dem
	gdal_contour -a ELEV -i 1.0 build/all/092f04/092f04_0100_demw.dem build/tofino_w.shp

# try making 1 and 30 m contour line shp
build/onem.shp: build/tofino_w.shp
	ogr2ogr build/onem.shp -f 'ESRI Shapefile' -where "ELEV = 1" build/tofino_w.shp

build/thirtym.shp: build/tofino_w.shp
	ogr2ogr build/thirtym.shp -f 'ESRI Shapefile' -where "ELEV = 30" build/tofino_w.shp

# merge together
build/twolevels.shp: build/onem.shp build/thirtym.shp
	ogr2ogr build/twolevels.shp build/onem.shp
	ogr2ogr -update -append build/twolevels.shp build/thirtym.shp

twoLevels.json: build/twolevels.shp
	node_modules/.bin/topojson \
	--id-property none \
	-p elevation=ELEV \
	-o $@ \
	-- twoLevels=$<




# run this in terminal to merge all contour shp files
	# for i in $(ls build/tofino*.shp); do ogr2ogr -f 'ESRI Shapefile' -where "ELEV < 31" -update -append build/merged_30m $i -nln contours done

# make Topojson file
build/contours.json: build/merged_30m/contours.shp
	node_modules/.bin/topojson \
	-o $@ \
	-p elevation="ELEV" \
	-- contours=$<


# merge boundary lines and contours 

build/merged.json: build/contours.json build/tofino_outline.json
	node_modules/.bin/topojson \
	-o build/merged.json -p elevation -- build/tofino_outline.json build/contours.json
# background first method

# gdal_translate build/all/092c09/092f04_0100_demw.dem stuff.tif
# gdal_translate build/all/092c09/092c09_0100_deme.dem stuffe.tif

# gdal_rasterize -a ELEV -ts 3000 3000 -l contours /Users/mathewbrown/projects/wave/build/merged_500m/contours.shp /Users/mathewbrown/projects/wave/build/out.tif

# gdal_calc.py -A build/out.tif --outfile=level0300.tif --calc="300*(A>300)" --overwrite

# gdal_polygonize.py level0300.tif -f "ESRI Shapefile" level0300.shp level_0300 elev

#topojson --id-property none -p elevation=elev -o final.json -- levels.json 
# build/contours.json: levels.shp
# 	node_modules/.bin/topojson \
# 	-o $@ \
# 	-p elevation="ELEV" \
# 	-- contours=$<