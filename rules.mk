OCAMLBUILD = ocamlbuild
OCAMLBUILDFLAGS = -use-ocamlfind -pkg batteries -pkg ppx_deriving.std -cflags -warn-error,-a+8 -tag debug
SRCS = $(wildcard *.ml *.ml[ily])

all: _build/utop.top $(BINTARGETS)

$(BINTARGETS): $(SRCS)
	$(OCAMLBUILD) $(OCAMLBUILDFLAGS) $(notdir $@).byte
	@mv $(notdir $@).byte $@

_build/utop.top: $(BINTARGETS) utop.mltop
	$(OCAMLBUILD) $(OCAMLBUILDFLAGS) -no-links -tag thread -pkg utop utop.top

utop.mltop: $(SRCS)
	@find . -maxdepth 1 \( -name '*.ml' -or -name '*.ml[ly]' \) -not -name 'main*' \
		-exec basename {} \; | sed "s/\(.*\)\..*/\1/" > $@

clean:
	$(OCAMLBUILD) -clean
	rm -fr utop.mltop

utop: _build/utop.top
	@cd _build && ./utop.top

.PHONY: all clean test test-% utop
