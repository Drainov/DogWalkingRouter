DROP FUNCTION IF EXISTS dogwalking_pie(integer,double precision);
create or replace function dogwalking_Pie (input int, distance float)
returns table (
	id bigint,
	path int,
	the_geom geometry
)
language plpgsql
as $$
begin
    RETURN QUERY
	WITH source AS (
		SELECT vertices_pgr.id, vertices_pgr.the_geom AS geom from vertices_pgr where vertices_pgr.id=input
	)
	,circle AS ( --first make a nice circle with a lot of segments
		SELECT source.id, ST_Buffer(geom, distance,25) as geom FROM source
	)
	,segments AS ( --create segments from a smaller circle so we can find out later wich triangle belongs to which segment
		 SELECT dumps.id, (pt).path path, ST_MakeLine(lag((pt).geom, 1, NULL) OVER (PARTITION BY dumps.id ORDER BY dumps.id, (pt).path), (pt).geom) AS geom
		  FROM (SELECT source.id, ST_DumpPoints(ST_Buffer(geom,distance*0.67,3)) AS pt FROM source) as dumps
	)
	,dump AS ( --make the pie segments, but make them bigger than the nice circle
		SELECT source.id, (ST_DumpPoints(ST_Buffer(geom,distance*1.13,3))).geom as geom
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
;

drop function if exists dogwalking_BufferInM (lat float, lon float, distance float);
create or replace function dogwalking_BufferInM (lat float, lon float, distance float);
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
begin
   SELECT * FROM vertices_pgr WHERE  ST_DWithin('POINT(-4.6314 54.0887)'::geography,
              ST_MakePoint(long,lat),8046.72); -- 8046.72 metres = 5 miles;
			  
	
end; $$
;


drop function if exists dogwalking_RandomRoutepoints (int, distance float);
create or replace function dogwalking_RandomRoutepoints (input int, distance float)
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
begin
    RETURN QUERY
	with pie as (select * from dogwalking_Pie(input, distance))
	,routepoints AS (SELECT distinct on (pie.path) pie.path, vertices_pgr.* FROM pie, vertices_pgr where ST_Within(vertices_pgr.the_geom, pie.the_geom))
	(SELECT *
	FROM routepoints order by random() limit 3 )
	UNION
    ( SELECT 1 as path, vertices_pgr.* from vertices_pgr where vertices_pgr.id=input) ;
end; $$
;

drop function if exists dogwalking_CircuitRoute (input int, distance float);
create or replace function dogwalking_CircuitRoute (input int, distance float)
returns table (
	seq int,
	path_id int,
	path_seq int,
	start_vid bigint,
	end_vid bigint,
	node bigint,
	edge bigint,
	cost double precision,
	agg_cost double precision,
	route_agg_cost double precision,
	the_geom geometry
)
language plpgsql
as $$
begin
    DROP TABLE IF EXISTS tmp;
	CREATE TEMP TABLE tmp as
    select * from dogwalking_RandomRoutepoints(input, distance) order by random() limit 3;
	RETURN QUERY
	with WHERE
  id = (SELECT id FROM edges WHERE the_geom && ST_MakeEnvelope(%bxsw%, %bysw%, %bxne%, %byne%, 4326) ORDER BY the_geom <-> ST_SetSRID(ST_MakePoint(%x%, %y%), 4326) LIMIT 1)
	with tsp as (
	select * from pgr_TSP( $dijkstra$
	select * from pgr_dijkstraCostMatrix(
		'select edges.id, edges.source, edges.target, edges.final_costs as cost, edges.final_costs as reverse_cost from edges',
		(select array_agg(tmp.id) from tmp),
			directed:=false
	)
	$dijkstra$) order by seq
	)
	select d.*, u.the_geom
	from edges u
	join
	(select * from pgr_dijkstraVia (
		'select edges.id, edges.source, edges.target, edges.final_costs as cost, edges.final_costs as reverse_cost from edges', (select array_agg(tsp.node) from tsp), directed:=false, U_turn_on_edge:=false) as via
		where via.edge>0) d
	on u.id=d.edge;
end; $$
;

drop function if exists dogwalking_CircuitRoute_buffer (input int, distance float, lat float, lon float);
create or replace function dogwalking_CircuitRoute_buffer (input int, distance float, lat float, lon float)
returns table (
	seq int,
	path_id int,
	path_seq int,
	start_vid bigint,
	end_vid bigint,
	node bigint,
	edge bigint,
	cost double precision,
	agg_cost double precision,
	route_agg_cost double precision,
	the_geom geometry
)
language plpgsql
as $$
begin
    DROP TABLE IF EXISTS tmp;
	CREATE TEMP TABLE tmp as
    select * from dogwalking_RandomRoutepoints(input, distance) order by random() limit 3;
	DROP TABLE IF EXISTS vicinity;
	CREATE TEMP TABLE vicinity as
	SELECT * FROM edges WHERE ST_DWithin(edges.the_geom,ST_MakePoint(lon,lat)::geography,1000);
	RETURN QUERY
	WITH tsp as (
	select * from pgr_TSP( $dijkstra$
	select * from pgr_dijkstraCostMatrix(
		'select vicinity.id, vicinity.source, vicinity.target, vicinity.final_costs as cost, vicinity.final_costs as reverse_cost from vicinity',
		(select array_agg(tmp.id) from tmp),
			directed:=false
	)
	$dijkstra$) order by seq
	)
	select d.*, u.the_geom
	from vicinity u
	join
	(select * from pgr_dijkstraVia (
		'select vicinity.id, vicinity.source, vicinity.target, vicinity.final_costs as cost, vicinity.final_costs as reverse_cost from vicinity', (select array_agg(tsp.node) from tsp), directed:=false, U_turn_on_edge:=false) as via
		where via.edge>0) d
	on u.id=d.edge;
end; $$
;
