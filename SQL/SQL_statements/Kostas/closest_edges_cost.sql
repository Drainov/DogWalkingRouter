-- Selects the edges that are within a distance of 0.0003 of a greenspace and updates their cost on the edges table
-- open_spaces_utrecht_splitted is the polygon layer with the greenspaces
-- wkb_geometry is its geometry field

with closest_edges as (select e.id, e.the_geom, o.ogc_fid
from edges e
inner join open_spaces o
on ST_DWithin(e.the_geom, o.the_geom, 0.0003)
)
update edges set cost = cost/100 from closest_edges where closest_edges.id=dupe_edges.id