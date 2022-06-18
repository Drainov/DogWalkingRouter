DROP FUNCTION dogwalking_Pie(integer);
create or replace function dogwalking_Pie (input int) 
returns table (
	id int,
	path int,
	the_geom geometry
) 
language plpgsql
as $$
declare 
    someconstant record;
begin
    RETURN QUERY 
	WITH source AS ( 
		SELECT edgesbkp.id, geom_way AS geom from edgesbkp where edgesbkp.id=input
	)
	,circle AS ( --first make a nice circle with a lot of segments
		SELECT source.id, ST_Buffer(geom, 0.0015,25) as geom FROM source
	)
	,segments AS ( --create segments from a smaller circle so we can find out later wich triangle belongs to which segment
		 SELECT dumps.id, (pt).path path, ST_MakeLine(lag((pt).geom, 1, NULL) OVER (PARTITION BY dumps.id ORDER BY dumps.id, (pt).path), (pt).geom) AS geom
		  FROM (SELECT source.id, ST_DumpPoints(ST_Buffer(geom,0.001,3)) AS pt FROM source) as dumps
	)
	,dump AS ( --make the pie segments, but make them bigger than the nice circle
		SELECT source.id, (ST_DumpPoints(ST_Buffer(geom,0.0017,3))).geom as geom
		FROM source --insert your point table here
		UNION ALL 
		SELECT source.id, geom FROM source --same here
	) 
	,triangles AS ( --triangles will have a random order
		SELECT dump.id, (ST_Dump(ST_DelaunayTriangles(ST_Collect(geom),0, 0))).geom geom
		FROM dump
		GROUP BY dump.id
	)
	--now get the intersection between the nice circle and the segments, and add the ordernr of the triangle based on the segments we got earlier on
	SELECT a.id, c.path[2]-1 path, ST_Intersection(a.geom, b.geom) geom
	FROM circle as a, triangles as b
	LEFT JOIN segments c ON ST_Intersects(b.geom,ST_Centroid(c.geom))
	WHERE a.id = b.id
	ORDER BY a.id, path;
end; $$


drop function dogwalking_RandomRoutepoints (int);
create or replace function dogwalking_RandomRoutepoints (input int) 
returns table (
	path int,
	id bigint,
	cnt int,
	chk int,
	ein int,
	eout int,
	the_geom geometry
) 
language plpgsql
as $$
declare 
    someconstant record;
begin
    RETURN QUERY 
	with pie as (select * from dogwalking_Pie(input))
	,routepoints AS (SELECT distinct on (pie.path) pie.path, edgesbkp_vertices_pgr.* FROM pie, edgesbkp_vertices_pgr where ST_Within(edgesbkp_vertices_pgr.the_geom, pie.the_geom))
	SELECT * 
	FROM routepoints order by random() limit 3;
end; $$


select * from dogwalking_RandomRoutepoints(25639);

