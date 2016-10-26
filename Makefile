BINTARGETS = bin/awv bin/hotcrp bin/sql_parse bin/test

include rules.mk

check: bin/sql_parse bin/test
	bin/test && ./testie -p bin test
