---
--- Regression tests for PostGIS SFCGAL backend
---

-- We only care about testing PostGIS prototype here
-- Behaviour is already handled by SFCGAL own tests

SELECT 'postgis_sfcgal_version', count(*) FROM (SELECT postgis_sfcgal_version()) AS f;
SELECT 'ST_Tesselate', ST_AsText(ST_Tesselate('GEOMETRYCOLLECTION(POINT(4 4),POLYGON((0 0,1 0,1 1,0 1,0 0)))'));
SELECT 'ST_3DArea', ST_3DArea('POLYGON((0 0 0,1 0 0,1 1 0,0 1 0,0 0 0))');
SELECT 'ST_Extrude_point', ST_AsText(ST_Extrude('POINT(0 0)', 1, 0, 0));
SELECT 'ST_Extrude_line', ST_AsText(ST_Extrude(ST_Extrude('POINT(0 0)', 1, 0, 0), 0, 1, 0));
-- In the first SFCGAL versions, the extruded face was wrongly oriented
-- we change the extrusion result to match the original
SELECT 'ST_Extrude_surface',
CASE WHEN postgis_sfcgal_version() = '1.0'
THEN
    ST_AsText(ST_Extrude(ST_Extrude(ST_Extrude('POINT(0 0)', 1, 0, 0), 0, 1, 0), 0, 0, 1))
ELSE
    regexp_replace(
    regexp_replace(
    ST_AsText(ST_Extrude(ST_Extrude(ST_Extrude('POINT(0 0)', 1, 0, 0), 0, 1, 0), 0, 0, 1)) ,
    '\(\(0 1 0,1 1 0,1 0 0,0 1 0\)\)', '((1 1 0,1 0 0,0 1 0,1 1 0))'),
    '\(\(0 1 0,1 0 0,0 0 0,0 1 0\)\)', '((1 0 0,0 0 0,0 1 0,1 0 0))')
END;

SELECT 'ST_ForceLHR', ST_AsText(ST_ForceLHR('POLYGON((0 0,0 1,1 1,1 0,0 0))'));
SELECT 'ST_Orientation_1', ST_Orientation(ST_ForceLHR('POLYGON((0 0,0 1,1 1,1 0,0 0))'));
SELECT 'ST_Orientation_2', ST_Orientation(ST_ForceRHR('POLYGON((0 0,0 1,1 1,1 0,0 0))'));
SELECT 'ST_MinkowskiSum', ST_AsText(ST_MinkowskiSum('LINESTRING(0 0,4 0)','POLYGON((0 0,1 0,1 1,0 1,0 0))'));
SELECT 'ST_StraightSkeleton', ST_AsText(ST_StraightSkeleton('POLYGON((1 1,2 1,2 2,1 2,1 1))'));

-- Performance evaluation tests
SELECT 'postgis_sfcgal_noop_1', ST_Z(postgis_sfcgal_noop(ST_AsText('POINT(1 2 3)')));
SELECT 'postgis_sfcgal_noop_2', ST_NPoints(postgis_sfcgal_noop(ST_AsText('LINESTRINGZ(0 0 3, 1 1 3, 2 2 3, 3 3 3)')));
SELECT 'postgis_sfcgal_noop_3', ST_SRID(postgis_sfcgal_noop(ST_AsEWKT('SRID=4326;POLYHEDRALSURFACEZ(((0 0 0, 0 1 0, 1 1 0, 0 0 0)), ((0 0 0, 0 1 0, 0 1 1, 0 0 0)))')));

-- Backend switch tests
SET postgis.backend = 'geos';
SELECT 'intersection_geos', ST_astext(ST_intersection('LINESTRING(0 10, 0 -10)', 'LINESTRING(0 0, 1 1)'));

SET postgis.backend = 'sfcgal';
SELECT 'intersection_sfcgal', ST_astext(ST_intersection('LINESTRING(0 10, 0 -10)', 'LINESTRING(0 0, 1 1)'));

SET postgis.backend = 'foo';
SET postgis.backend = '';
