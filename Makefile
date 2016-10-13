BINTARGETS = bin/main bin/sql_parse

include rules.mk

check: bin/sql_parse
	./testie -p bin test
