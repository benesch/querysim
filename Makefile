BINTARGETS = \
	bin/awv \
	bin/awv2 \
	bin/awv3 \
	bin/awv_simple \
	bin/awv_migrate \
	bin/hotcrp \
	bin/simple \
	bin/shareddb \
	bin/sql_parse \
	bin/test \

include rules.mk

check: bin/sql_parse bin/test
	bin/test && ./testie -p bin test
