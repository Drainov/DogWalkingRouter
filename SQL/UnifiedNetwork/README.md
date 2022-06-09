# Unified Network (pedestrian paths and open spaces)

The current directory provides .sql files to generate the usual osm2po network for pedestrians,
plus a Delaunay triangulation for leisure parks, minus the water areas. 

Please note that this is just a test and not comprehensive at all. 

## How the triangulation was generated

OSM layers for the features we wanted were downloaded using QGIS, and then saved as shapefiles. 
This may or may not be optimal. 

Then a delaunay triangulation was calculated accordingly. There are better ways of caltulating 
possible paths inside a polygon. Delaunay was selected just as a first attempt. 

PostGIS has tools to convert shp into a database table, which is exactly what we have dumped into
the delaunay_test script. 

## How to mix both types of database

Formats are different, we can try and translate using sql. For example, making sure that the ids
used do not overlap. You can find some sql in the mixed_table file. This does not work yet as 
some fields (x1, y1, etc) are still missing. Even though the network creation does not fail as of
now, pgRouting cannot calculate an optimal route until these fields are all there. 

Also, cost calculation could be better than a constant (for example, based on length for a first 
approximation). 
