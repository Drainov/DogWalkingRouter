# DogWalkingRouter

## Naming conventions

###  Database
- One table called edges (geom_way renamed as the_geom if table was generated using osm2po)
- Vertices table using pgRouting: vertices_pgr
- Layer with greenspaces and other related polygons: open_spaces (wkb_geometry renamed as the_geom)
- dogplaces table (containing the dog areas, grassbeheer attri(hondenspeelweide = Dog Playground, Hondentoilet = Dog toilet area) also saved as dogplaces binary )

### Geoserver layers

- We are using the cite namespace

#### cite:nearest_edge

`SELECT id, the_geom, string_agg(distinct(osm_name),',') AS streetname
FROM
  edges
WHERE
  id = (SELECT id FROM edges ORDER BY the_geom <-> ST_SetSRID(ST_MakePoint(%x%, %y%), 4326) LIMIT 1)
GROUP BY id, the_geom`

#### cite:nearest_vertex

`SELECT id, the_geom
FROM
  vertices_pgr
WHERE
  id = (SELECT id FROM vertices_pgr ORDER BY the_geom <-> ST_SetSRID(ST_MakePoint(%x%, %y%), 4326) LIMIT 1)
GROUP BY id, the_geom
`

#### cite:dogwalking_random_route_points

`SELECT * FROM dogwalking_RandomRoutepoints(%idvertex%,%distance%)`

#### cite:dogwalking_circuit_route

`SELECT * FROM dogwalking_CircuitRoute(%idvertex%,%distance%)`

##### cite:shortest_path query
Deprecated

##### cite:dogplaces
- Needed for the wms map (cite:dogplaces, also requires the dog2 sdl file, which can be applied in styles)

## Type validation

When using SQL views in GeoServer, make sure to validate the parameters correctly so that it accepts a floating point number.

For example, you can use this regular expression:

`^[+-]?([0-9]+\.?[0-9]*|\.[0-9]+)$`


## SQL-functions

- Please note that you will need to add the following SQL functions in your PostgreSQL server: `dogwalking_CircuitRoute`, `dogwalking_Pie`, `dogwalking_RandomRoutepoints`.
