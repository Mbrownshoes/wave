# get BC census boundary and widdle downt to Tofino

build/subunits.json: build/Boundaries/CD_2011.shp
	ogr2ogr -f GeoJSON  -t_srs "+proj=latlong +datum=WGS84" -where "CDNAME IN ('Alberni-Clayoquot')" \
	-clipdst -125.1550643102 48.8344612907 -126.1800723924 49.2711484127 \
	build/subunits.json \
	build/Boundaries/CD_2011.shp

build/tofino_outline.json: build/subunits.json
	node_modules/.bin/topojson \
		-o $@ \
		-- $<

build/bands.shp: build/all/092f04/092f04_0100_demw.dem
	python \
	isobands_gdal.py  -i 20 -nln elev build/all/092f04/092f04_0100_demw.dem build/bands.shp

contours.json: build/bands.shp
	node_modules/.bin/topojson \
	-o contours.json -p elevation=elev -- build/bands.shp

# make shp from DEM
# build/tofino_e.shp: build/all/092f04/092f04_0100_deme.dem
# 	gdal_contour -a ELEV -i 1.0 build/all/092f04/092f04_0100_deme.dem build/tofino_e.shp

# build/tofino_w.shp: build/all/092f04/092f04_0100_demw.dem
# 	gdal_contour -a ELEV -i 1.0 build/all/092f04/092f04_0100_demw.dem build/tofino_w.shp

# # try making 1 and 30 m contour line shp
# build/onem.shp: build/all/polytofino.shp
# 	ogr2ogr build/onem.shp -f 'ESRI Shapefile' -where "ELEV = 1" build/all/polytofino.shp

# build/thirtym.shp: build/all/polytofino.shp
# 	ogr2ogr build/thirtym.shp -f 'ESRI Shapefile' -where "ELEV = 30" build/all/polytofino.shp

# # merge together
# build/twolevels.shp: build/onem.shp build/thirtym.shp
# 	ogr2ogr build/twolevels.shp build/onem.shp
# 	ogr2ogr -update -append build/twolevels.shp build/thirtym.shp

# twoLevels.json: build/twolevels.shp
# 	node_modules/.bin/topojson \
# 	--id-property none \
# 	-p elevation=ELEV \
# 	-o $@ \
# 	-- twoLevels=$<



# get roads down to Tofino level

# build/roads.json: build/roads/NRN_BC_11_0_ROADSEG.shp
# 	node_modules/.bin/topojson \
# 	-o $@ \
# 	--bbox="-125.8444564,49.0936733,-125.9267002,49.1666487" \
# 	-- roads=$<

build/roads.json: build/roads/NRN_BC_11_0_ROADSEG.shp
	ogr2ogr -f GeoJSON -clipdst -125.8444564 49.0936733 -125.9267002 49.1666487 \
	build/roads.json \
	build/roads/NRN_BC_11_0_ROADSEG.shp

roads.json: build/roads.json
	node_modules/.bin/topojson \
		-p
		-o $@ \
		-- $<


# run this in terminal to merge all contour shp files
	# for i in $(ls build/tofino*.shp); do ogr2ogr -f 'ESRI Shapefile' -where "ELEV < 31" -update -append build/merged_30m $i -nln contours done

# make Topojson file
# build/contours.json: build/merged_30m/contours.shp
# 	node_modules/.bin/topojson \
# 	-o $@ \
# 	-p elevation="ELEV" \
# 	-- contours=$<


# # merge boundary lines and contours 

merged.json: twoLevels.json roads.json
	node_modules/.bin/topojson \
	-o merged.json -p elevation -p roads -- twoLevels.json roads.json
