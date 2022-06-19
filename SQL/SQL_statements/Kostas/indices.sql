--Geometry-related indices. They make a big difference
create index idx_edges_the_geom on edges using gist (the_geom);
create index idx_open_spaces_the_geom on open_spaces using gist (the_geom);
create index idx_vertices_pgr_the_geom on vertices_pgr using gist (the_geom);

-- Update-related indices. On a second note it may make it slower. Will check to verify
create index idx_edges_cost on edges (cost);