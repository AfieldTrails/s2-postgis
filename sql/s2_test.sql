CREATE LANGUAGE plpython3u;
CREATE EXTENSION s2;

SELECT s2_cellid_from_latlng(0, 0);
SELECT s2_cellid_from_latlng(40.5, -105.5);

SELECT s2_token_from_latlng(0, 0);
SELECT s2_token_from_latlng(40.5, -105.5);
