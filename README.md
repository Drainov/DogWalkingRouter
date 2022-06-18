# DogWalkingRouter

## Naming conventions

###  Database
- One table called edges (geom_way renamed as the_geom if table was generated using osm2po)
- Vertices table using pgRouting: vertices_pgr 
- Layer with greenspaces and other related polygons: open_spaces (wkb_geometry renamed as the_geom)
- dogplaces table (containing the dog areas, grassbeheer attri(hondenspeelweide = Dog Playground, Hondentoilet = Dog toilet area) also saved as dogplaces binary )

### Geoserver
- cite 
- nearest_edge query for GeoServer
- nearest_vertex query for GeoServer
- shortest_path query for GeoServer (TODO: needs buffer)
- dogplaces for the wms map (cite:dogplaces, also requires the dog2 sdl file, which can be applied in styles)

## Type validation

When using SQL views in GeoServer, make sure to validate the parameters correctly so that it accepts a floating point number. 

For example, you can use this regular expression:

`^[+-]?([0-9]+\.?[0-9]*|\.[0-9]+)$`
