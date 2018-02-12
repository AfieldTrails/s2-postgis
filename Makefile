EXTENSION = s2 # the extension's name
DATA = s2--0.0.2.sql  # script files to install
REGRESS = s2_test

# postgres build stuff
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
