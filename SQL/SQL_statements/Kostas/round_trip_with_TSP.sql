-- Finding the optimal order to visit the POIs using TSP. Notice that the points are not in a particular sequence.
-- The first vertex is also the end destination.
with tsp as

(select * from pgr_TSP (
$$
	select * from pgr_dijkstraCostMatrix(
	'select id, source, target, cost, reverse_cost from hh_2po_4pgr',
		array[45298, 25046],
		directed:=false
	)
	$$
) order by seq)

-- Using dijkstraVia to calculate the round-trip route that visits the POIS in the sequence computed from TSP
select d.*, h.geom_way
from hh_2po_4pgr h
join
(select * from pgr_dijkstraVia (
	'select id, source, target, cost, reverse_cost from hh_2po_4pgr', (select array_agg(node) from tsp), directed:=false, U_turn_on_edge:=false)
	where edge>0) d
on h.id=d.edge
