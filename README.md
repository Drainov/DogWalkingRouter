# DogWalkingRouter

## Naming conventions

- One table called edges (geom_way renamed as the_geom if table was generated using osm2po)
- Vertices table using pgRouting: vertices_pgr 
- cite 
- nearest_edge query for GeoServer
- nearest_vertex query for GeoServer
- shortest_path query for GeoServer (TODO: needs buffer)

## Type validation

When using SQL views in GeoServer, make sure to validate the parameters correctly so that it accepts a floating point number. 

For example, you can use this regular expression:

`^[+-]?([0-9]+\.?[0-9]*|\.[0-9]+)$`
