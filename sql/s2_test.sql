CREATE LANGUAGE plpython3u;
CREATE EXTENSION s2;

--CREATE OR REPLACE FUNCTION s2_cellid_from_latlng(lat real, lng real) RETURNS bigint
SELECT s2_cellid_from_latlng(0, 0);
SELECT s2_cellid_from_latlng(40.5, -105.5);

--CREATE OR REPLACE FUNCTION s2_latlng_from_cellid(cellid bigint, OUT lat real, OUT lng real)
SELECT s2_latlng_from_cellid(-8689295774057980903);

SELECT s2_cellid_parent(-8689295774057980903, 20);
SELECT s2_cellid_parent(-8689295774057980903, 1);

SELECT s2_cellid_level(s2_cellid_from_latlng(40.5, -105.5));
SELECT s2_cellid_level(s2_cellid_parent(s2_cellid_from_latlng(40.5, -105.5), 21));

SELECT s2_cellid_children(-8689295774058545152);

--CREATE OR REPLACE FUNCTION s2_token_from_latlng(lat real, lng real) RETURNS text
SELECT s2_token_from_latlng(0, 0);
SELECT s2_token_from_latlng(40.5, -105.5);

--CREATE OR REPLACE FUNCTION s2_token_from_cellid(cellid bigint) RETURNS text
SELECT s2_token_from_cellid(0);
SELECT s2_token_from_cellid(s2_cellid_from_latlng(40.5, -105.5));
SELECT s2_token_from_cellid(s2_cellid_parent(s2_cellid_from_latlng(40.5, -105.5), 10));

--CREATE OR REPLACE FUNCTION s2_cellid_from_token(token text) RETURNS bigint
SELECT s2_cellid_from_token('');
SELECT s2_cellid_from_token('zzz'); -- Note this currently causes an error, not id 0
SELECT s2_cellid_from_token('87696b8806f89c19');
SELECT s2_cellid_from_token('8');

--CREATE OR REPLACE FUNCTION s2_latlng_from_token(token text, OUT lat real, OUT lng real)
SELECT s2_latlng_from_token('87696b8806f89c19');

--CREATE OR REPLACE FUNCTION s2_cellid_is_valid(cellid bigint) RETURNS int
SELECT s2_cellid_is_valid(-8689295774058545152);

--CREATE OR REPLACE FUNCTION s2_cellid_is_leaf(cellid bigint) RETURNS int
SELECT s2_cellid_is_leaf(s2_cellid_from_latlng(40.5, -105.5));
SELECT s2_cellid_is_leaf(s2_cellid_parent(-8689295774058545152, 15));

--CREATE OR REPLACE FUNCTION s2_cellid_level(cellid bigint) RETURNS int
SELECT s2_cellid_level(-8689295774058545152);

--CREATE OR REPLACE FUNCTION s2_cellid_parent(cellid bigint, parent_level int) RETURNS bigint
SELECT s2_cellid_parent(-8689295774058545152, 15);

--CREATE OR REPLACE FUNCTION s2_cellid_children(cellid bigint) RETURNS SETOF bigint
SELECT s2_cellid_children(-8689295774058545152);
SELECT s2_cellid_children(s2_cellid_from_latlng(40.5, -105.5));
SELECT s2_cellid_children(s2_cellid_parent(-8689295774058545152, 15));

--CREATE OR REPLACE FUNCTION s2_cellid_edge_neighbors(cellid bigint) RETURNS SETOF bigint
SELECT s2_cellid_edge_neighbors(-8689295774058545152);

--CREATE OR REPLACE FUNCTION s2_cellid_contains(a bigint, b bigint) RETURNS bool
SELECT s2_cellid_contains(-8689295774058545152, -8689295774058545152);
SELECT s2_cellid_contains(-8689295774058545152, s2_cellid_parent(-8689295774058545152, 20));
SELECT s2_cellid_contains(s2_cellid_parent(-8689295774058545152, 20), -8689295774058545152);

--CREATE OR REPLACE FUNCTION s2_cellid_intersects(a bigint, b bigint) RETURNS bool
SELECT s2_cellid_intersects(-8689295774058545152, -8689295774058545152);
SELECT s2_cellid_contains(-8689295774058545152, s2_cellid_parent(-8689295774058545152, 20));
SELECT s2_cellid_contains(s2_cellid_parent(-8689295774058545152, 20), -8689295774058545152);

--CREATE OR REPLACE FUNCTION s2_token_is_valid(token text) RETURNS bool
SELECT s2_token_is_valid('87696b8806f89c19');
SELECT s2_token_is_valid('8769b');

--CREATE OR REPLACE FUNCTION s2_token_is_leaf(token text) RETURNS bool
SELECT s2_token_is_leaf('87696b8806f89c19');
SELECT s2_token_is_leaf('8769b');

--CREATE OR REPLACE FUNCTION s2_token_level(token text) RETURNS int
SELECT s2_token_level('87696b8806f89c19');
SELECT s2_token_level('8769b');

--CREATE OR REPLACE FUNCTION s2_token_parent(token text, parent_level int) RETURNS text
SELECT s2_token_parent('87696b8806f89c19', 15);
SELECT s2_token_parent('8769b', 5);

--CREATE OR REPLACE FUNCTION s2_token_children(token text) RETURNS SETOF text
SELECT s2_token_children('87696b8806f89c19');
SELECT s2_token_children('8769b');

--CREATE OR REPLACE FUNCTION s2_token_edge_neighbors(token text) RETURNS SETOF text
SELECT s2_token_edge_neighbors('87696b8806f89c19');
SELECT s2_token_edge_neighbors('87696b');

--CREATE OR REPLACE FUNCTION s2_token_contains(a text, b text) RETURNS bool
SELECT s2_token_contains('87696b8806f89c19', '87696b');
SELECT s2_token_contains('87696b', '87696b8806f89c19');

--CREATE OR REPLACE FUNCTION s2_token_intersects(a text, b text) RETURNS bool
SELECT s2_token_intersects('87696b8806f89c19', '87696b');
SELECT s2_token_intersects('87696b', '87696b8806f89c19');

