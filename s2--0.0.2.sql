-- Requires plpython3u language to be installed
-- CREATE LANGUAGE plpython3u;
-- Also requires the s2sphere extension to be installed on the system for python3.

-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION s2" to load this file. \quit

--
-- Conversion functions
--

-- PostgreSQL doesn't handle unsigned ints, so we have to re-interpret the byte representation
-- of the id.
CREATE OR REPLACE FUNCTION s2_cellid_from_latlng(lat double precision, lng double precision) RETURNS bigint
AS $$
  import s2sphere
  id = s2sphere.CellId.from_lat_lng(s2sphere.LatLng.from_degrees(lat, lng))
  return int.from_bytes(id.id().to_bytes(8, 'big', signed=False), 'big', signed=True)
$$ LANGUAGE plpython3u IMMUTABLE STRICT;

-- Convert from token (text) to cellid (long) representation.
CREATE OR REPLACE FUNCTION s2_cellid_from_token(token text) RETURNS bigint
AS $$
  import s2sphere
  id = s2sphere.CellId.from_token(token)
  return int.from_bytes(id.id().to_bytes(8, 'big', signed=False), 'big', signed=True)
$$ LANGUAGE plpython3u IMMUTABLE STRICT;

-- Get the string token for a cellid from the latitude and longitude
CREATE OR REPLACE FUNCTION s2_token_from_latlng(lat double precision, lng double precision) RETURNS text
AS $$
  import s2sphere
  id = s2sphere.CellId.from_lat_lng(s2sphere.LatLng.from_degrees(lat, lng))
  return id.to_token()
$$ LANGUAGE plpython3u IMMUTABLE STRICT;

-- Get the string token for a cellid from the raw id
CREATE OR REPLACE FUNCTION s2_token_from_cellid(cellid bigint) RETURNS text
AS $$
  import s2sphere
  id = s2sphere.CellId(int.from_bytes(cellid.to_bytes(8, 'big', signed=True), 'big', signed=False))
  return id.to_token()
$$ LANGUAGE plpython3u IMMUTABLE STRICT;

-- Get the latitude and longitude as degrees from a cellid
CREATE OR REPLACE FUNCTION s2_latlng_from_cellid(cellid bigint, OUT lat double precision, OUT lng double precision)
AS $$
  import s2sphere
  id = s2sphere.CellId(int.from_bytes(cellid.to_bytes(8, 'big', signed=True), 'big', signed=False))
  latlng = id.to_lat_lng()
  return (latlng.lat().degrees, latlng.lng().degrees)
$$ LANGUAGE plpython3u IMMUTABLE STRICT;

-- Get the latitude and longitude as degrees from a token 
CREATE OR REPLACE FUNCTION s2_latlng_from_token(token text, OUT lat double precision, OUT lng double precision)
AS $$
  import s2sphere
  id = s2sphere.CellId.from_token(token)
  latlng = id.to_lat_lng()
  return (latlng.lat().degrees, latlng.lng().degrees)
$$ LANGUAGE plpython3u IMMUTABLE STRICT;

--
-- CellId based functions
--

-- Return whether this is a valid s2 cellid.
CREATE OR REPLACE FUNCTION s2_cellid_is_valid(cellid bigint) RETURNS boolean
AS $$
  import s2sphere
  id = s2sphere.CellId(int.from_bytes(cellid.to_bytes(8, 'big', signed=True), 'big', signed=False))
  return id.is_valid()
$$ LANGUAGE plpython3u IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION s2_cellid_is_leaf(cellid bigint) RETURNS boolean
AS $$
  import s2sphere
  id = s2sphere.CellId(int.from_bytes(cellid.to_bytes(8, 'big', signed=True), 'big', signed=False))
  return id.is_leaf()
$$ LANGUAGE plpython3u IMMUTABLE STRICT;

-- Return the level of the cellid
CREATE OR REPLACE FUNCTION s2_cellid_level(cellid bigint) RETURNS int
AS $$
  import s2sphere
  id = s2sphere.CellId(int.from_bytes(cellid.to_bytes(8, 'big', signed=True), 'big', signed=False))
  return id.level()
$$ LANGUAGE plpython3u IMMUTABLE STRICT;

-- Return a cell id at a parent level for the passed in cell id
CREATE OR REPLACE FUNCTION s2_cellid_parent(cellid bigint, parent_level int) RETURNS bigint
AS $$
  import s2sphere
  id = s2sphere.CellId(int.from_bytes(cellid.to_bytes(8, 'big', signed=True), 'big', signed=False))
  newid = id.parent(parent_level)
  return int.from_bytes(newid.id().to_bytes(8, 'big', signed=False), 'big', signed=True)
$$ LANGUAGE plpython3u IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION s2_cellid_children(cellid bigint) RETURNS SETOF bigint
AS $$
  import s2sphere
  id = s2sphere.CellId(int.from_bytes(cellid.to_bytes(8, 'big', signed=True), 'big', signed=False))
  if not id.is_leaf():
    for child in id.children():
      yield int.from_bytes(child.id().to_bytes(8, 'big', signed=False), 'big', signed=True)
$$ LANGUAGE plpython3u IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION s2_cellid_edge_neighbors(cellid bigint) RETURNS SETOF bigint
AS $$
  import s2sphere
  id = s2sphere.CellId(int.from_bytes(cellid.to_bytes(8, 'big', signed=True), 'big', signed=False))
  for neighbor in id.get_edge_neighbors():
    yield int.from_bytes(neighbor.id().to_bytes(8, 'big', signed=False), 'big', signed=True)
$$ LANGUAGE plpython3u IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION s2_cellid_contains(a bigint, b bigint) RETURNS boolean
AS $$
  import s2sphere
  id_a = s2sphere.CellId(int.from_bytes(a.to_bytes(8, 'big', signed=True), 'big', signed=False))
  id_b = s2sphere.CellId(int.from_bytes(b.to_bytes(8, 'big', signed=True), 'big', signed=False))
  return id_a.contains(id_b)
$$ LANGUAGE plpython3u IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION s2_cellid_intersects(a bigint, b bigint) RETURNS boolean
AS $$
  import s2sphere
  id_a = s2sphere.CellId(int.from_bytes(a.to_bytes(8, 'big', signed=True), 'big', signed=False))
  id_b = s2sphere.CellId(int.from_bytes(b.to_bytes(8, 'big', signed=True), 'big', signed=False))
  return id_a.intersects(id_b)
$$ LANGUAGE plpython3u IMMUTABLE STRICT;

--
-- Token based functions
--

-- Return whether this is a valid s2 cellid.
CREATE OR REPLACE FUNCTION s2_token_is_valid(token text) RETURNS boolean
AS $$
  import s2sphere
  id = s2sphere.CellId.from_token(token)
  return id.is_valid()
$$ LANGUAGE plpython3u IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION s2_token_is_leaf(token text) RETURNS boolean
AS $$
  import s2sphere
  id = s2sphere.CellId.from_token(token)
  return id.is_leaf()
$$ LANGUAGE plpython3u IMMUTABLE STRICT;

-- Return the level of the cellid
CREATE OR REPLACE FUNCTION s2_token_level(token text) RETURNS int
AS $$
  import s2sphere
  id = s2sphere.CellId.from_token(token)
  return id.level()
$$ LANGUAGE plpython3u IMMUTABLE STRICT;

-- Return a cell id at a parent level for the passed in cell id
CREATE OR REPLACE FUNCTION s2_token_parent(token text, parent_level int) RETURNS text
AS $$
  import s2sphere
  id = s2sphere.CellId.from_token(token)
  newid = id.parent(parent_level)
  return newid.to_token()
$$ LANGUAGE plpython3u IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION s2_token_children(token text) RETURNS SETOF text
AS $$
  import s2sphere
  id = s2sphere.CellId.from_token(token)
  if not id.is_leaf():
    for child in id.children():
      yield child.to_token()
$$ LANGUAGE plpython3u IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION s2_token_edge_neighbors(token text) RETURNS SETOF text
AS $$
  import s2sphere
  id = s2sphere.CellId.from_token(token)
  for neighbor in id.get_edge_neighbors():
    yield neighbor.to_token()
$$ LANGUAGE plpython3u IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION s2_token_contains(a text, b text) RETURNS boolean
AS $$
  import s2sphere
  id_a = s2sphere.CellId.from_token(a)
  id_b = s2sphere.CellId.from_token(b)
  return id_a.contains(id_b)
$$ LANGUAGE plpython3u IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION s2_token_intersects(a text, b text) RETURNS boolean
AS $$
  import s2sphere
  id_a = s2sphere.CellId.from_token(a)
  id_b = s2sphere.CellId.from_token(b)
  return id_a.intersects(id_b)
$$ LANGUAGE plpython3u IMMUTABLE STRICT;

