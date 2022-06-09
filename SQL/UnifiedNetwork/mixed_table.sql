CREATE TABLE mixed_table AS
TABLE hh_2po_4pgr;

INSERT INTO mixed_table(id, source, target, geom_way, cost, clazz)
SELECT (d.id +100000) AS id, (d.source + 100000) AS source, (d.target  + 100000) AS target, ST_LineMerge(d.geom) AS geom_way, 0.0001 AS cost, 99 as clazz
FROM delaunay_attemp1_edges as d;

SELECT pgr_createTopology('mixed_table', 0.001, 'geom_way'); 
