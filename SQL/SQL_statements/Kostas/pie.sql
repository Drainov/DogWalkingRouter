--from https://gis.stackexchange.com/questions/241393/how-to-split-circles-in-12-sections-in-postgis

WITH source AS ( 
	SELECT id, the_geom AS geom from uu_2po_4pgr_vertices_pgr where id=173461
)
,circle AS ( --first make a nice circle with a lot of segments
    SELECT id, ST_Buffer(geom, 0.0015,25) as geom FROM source
)
,segments AS ( --create segments from a smaller circle so we can find out later wich triangle belongs to which segment
     SELECT id, (pt).path path, ST_MakeLine(lag((pt).geom, 1, NULL) OVER (PARTITION BY id ORDER BY id, (pt).path), (pt).geom) AS geom
      FROM (SELECT id, ST_DumpPoints(ST_Buffer(geom,0.001,3)) AS pt FROM source) as dumps
)
,dump AS ( --make the pie segments, but make them bigger than the nice circle
    SELECT id, (ST_DumpPoints(ST_Buffer(geom,0.0017,3))).geom as geom
    FROM source --insert your point table here
    UNION ALL 
    SELECT id, geom FROM source --same here
)
,triangles AS ( --triangles will have a random order
    SELECT id, (ST_Dump(ST_DelaunayTriangles(ST_Collect(geom),0, 0))).geom geom
    FROM dump
    GROUP BY id
)
--now get the intersection between the nice circle and the segments, and add the ordernr of the triangle based on the segments we got earlier on
, pie AS (SELECT a.id, c.path[2]-1 path, ST_Intersection(a.geom, b.geom) geom
FROM circle as a, triangles as b
LEFT JOIN segments c ON ST_Intersects(b.geom,ST_Centroid(c.geom))
WHERE a.id = b.id
ORDER BY a.id, path
)

--SELECT id, path, ST_Centroid(geom) AS centroid_geom from pie;
-- ,inters AS (SELECT pois.*, pie.path FROM pie, pois where ST_Intersects(pois.the_geom, pie.geom))
-- SELECT distinct on (pie.path) pie.path, pois.* FROM pie, pois where ST_Within(pois.the_geom, pie.geom) 


, routepoints AS (SELECT distinct on (pie.path) pie.path, uu_2po_4pgr_vertices_pgr.* FROM pie, uu_2po_4pgr_vertices_pgr where ST_Within(uu_2po_4pgr_vertices_pgr.the_geom, pie.geom))

SELECT * from routepoints order by random() limit 3;