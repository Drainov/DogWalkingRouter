/* pgr_dijkstraVia can accept an array of nodes and it uses dijkstra to compute a path that passes from all those points.
The parameter U_turn_on_edge is of great importance here, as when reaching the last vertex it decides whether the same path should
be visited on the way back, or if it should search for an alternative path. Default value is true, so by setting it to false
it can create a different returning route a visual example can be seen on a word document.

It needs to be stressed that it will visit the points on the order that they appear on the array, so TSP can be first used to
find the quickest way to visit those points. Will update with TSP as well.*/

with d as
(select * from pgr_dijkstraVia (
'select id, source, target, cost, reverse_cost from hh_2po_4pgr', array[17772, 52014, 17772], directed:=false, U_turn_on_edge:=false))

select d.*, h.geom_way
from hh_2po_4pgr h
join d on h.id=d.edge