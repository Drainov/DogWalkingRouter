/* Using a table of pois, it selects the nearest vertex to a poi from the vertex table */

select x.id, x.the_geom
from uu_2po_4pgr_vertices_pgr x

join

(select ST_CLosestPoint (ST_Collect(u.the_geom), p.the_geom) as geom
from pois p, uu_2po_4pgr_vertices_pgr u
group by p.p_id, p.the_geom) q

on q.geom=x.the_geom