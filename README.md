# s2-postgis
S2 Cell Id functions for PostgreSQL and PostGIS

This extension makes it easy to convert GIS data to S2 data types - s2 cell ids and s2 cell id tokens in particular.

To use, you must install plpython3u (the PostgreSQL language) and s2sphere (the python3 exstension) on your postgresql server.

```
sudo apt-get install postgresql-plpython3-9.6
sudo pip3 install s2sphere
```

Then, to use, clone the respository on your server, then:

```
sudo make install && make installcheck
```

## Contributions

Functions are added completely opportunistically, so feel free to request something or contribute!

# Types


S2 cell ids are 8-bytes, so fit nicely in PostgreSQL's `bigint`. Tokens are a hex-encoding with the trailing 0's removed, so fit nicely as text.

Either representation will work well for sorted indices. I generally prefer the `bigint` ids but try to provide functions for both when appropriate.

If you're looking at the implementation, there is a dance around converting the unsigned representation used by python3 and s2sphere and the signed PostgreSQL implementation.

