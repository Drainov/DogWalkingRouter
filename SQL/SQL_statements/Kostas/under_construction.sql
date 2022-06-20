-- Function to select the nearest pois from the dogparks_polylines_vertices_pgr from a given network vertex id and distance
create or replace function dogwalking_nearestpois(v_id bigint, distance float)
returns table (
   the_geom geometry,
   id bigint
)
language plpgsql
as $$
begin
   return query
   Select pois.the_geom, pois.id from dogparks_polylines_vertices_pgr as pois
   join (select * from vertices_pgr where vertices_pgr.id=v_id) vertex
   on ST_DWithin(vertex.the_geom, pois.the_geom, distance);
end;
$$;

/* Working on trying to call the usual function for the route, that selects random points
in case no pois are found in the vicinity*/


CREATE OR REPLACE FUNCTION checker(v_id bigint, distance float)
RETURNS TABLE (
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
LANGUAGE PLPGSQL
as $$
BEGIN
   RETURN QUERY
   IF NOT EXISTS (select * from dogwalking_nearestpois(v_id, distance)) THEN
      select * from dogwalking_pie(v_id, distance);
   ELSE
      RAISE NOTICE 'mia xara';
   END IF;
END
$$;
