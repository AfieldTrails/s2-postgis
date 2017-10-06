-- Requires plpython3u language to be installed
-- CREATE LANGUAGE plpython3u;
-- Also requires the s2sphere extension to be installed on the system for python3.

-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION s2" to load this file. \quit

-- PostgreSQL doesn't handle unsigned ints, so we have to re-interpret the byte representation
-- of the id.
CREATE OR REPLACE FUNCTION s2_cellid_from_latlng(lat real, lng real) RETURNS bigint
AS $$
  import s2sphere
  id = s2sphere.CellId.from_lat_lng(s2sphere.LatLng.from_degrees(lat, lng)).id()
  return int.from_bytes(id.to_bytes(8, 'big', signed=False), 'big', signed=True)
$$ LANGUAGE plpython3u IMMUTABLE STRICT;

-- Get the string token for a cellid from the latitude and longitude
CREATE OR REPLACE FUNCTION s2_token_from_latlng(lat real, lng real) RETURNS text
AS $$
  import s2sphere
  id = s2sphere.CellId.from_lat_lng(s2sphere.LatLng.from_degrees(lat, lng))
  return id.to_token()
$$ LANGUAGE plpython3u IMMUTABLE STRICT;

-- Get the string token for a cellid from the raw id
CREATE OR REPLACE FUNCTION s2_token_from_cellid(cellid bigint) RETURNS text
AS $$
  import s2sphere
  id = int.from_bytes(cellid.to_bytes(8, 'big', signed=True), 'big', signed=False)
  return s2sphere.CellId(id).to_token()
$$ LANGUAGE plpython3u IMMUTABLE STRICT;

-- Get the latitude and longitude as degrees from a cellid
CREATE OR REPLACE FUNCTION s2_latlng_from_cellid(cellid bigint, OUT lat real, OUT lng real)
AS $$
  import s2sphere
  id = int.from_bytes(cellid.to_bytes(8, 'big', signed=True), 'big', signed=False)
  latlng = s2sphere.CellId(id).to_lat_lng()
  return (latlng.lat().degrees, latlng.lng().degrees)
$$ LANGUAGE plpython3u IMMUTABLE STRICT;


-- Return the level of the cellid
CREATE OR REPLACE FUNCTION s2_cellid_level(cellid bigint) RETURNS int
AS $$
  import s2sphere
  id = int.from_bytes(cellid.to_bytes(8, 'big', signed=True), 'big', signed=False)
  return s2sphere.CellId(id).level()
$$ LANGUAGE plpython3u IMMUTABLE STRICT;

-- Return a cell id at a parent level for the passed in cell id
CREATE OR REPLACE FUNCTION s2_cellid_parent(cellid bigint, parent_level int) RETURNS bigint
AS $$
  import s2sphere
  id = int.from_bytes(cellid.to_bytes(8, 'big', signed=True), 'big', signed=False)
  newid = s2sphere.CellId(id).parent(parent_level)
  return int.from_bytes(newid.to_bytes(8, 'big', signed=False), 'big', signed=True)
$$ LANGUAGE plpython3u IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION s2_cellid_children(cellid bigint) RETURNS SETOF bigint
AS $$
  import s2sphere
  id = int.from_bytes(cellid.to_bytes(8, 'big', signed=True), 'big', signed=False)
  for child in s2sphere.CellId(id).children():
    yield int.from_bytes(child.id().to_bytes(8, 'big', signed=False), 'big', signed=True)
$$ LANGUAGE plpython3u IMMUTABLE STRICT;
