.PHONY: all install uninstall

all: pa_bind.cmo pa_bind.cmxs

ifndef BINDIR
  BINDIR = $(shell dirname `which ocamlfind`)
endif

install: all
	ocamlfind install pa_bind \
	  META pa_bind.ml pa_bind.cmi pa_bind.cmo pa_bind.cmx pa_bind.cmxs
	dir=`ocamlfind query pa_bind`; \
        sed -e "s:@@:$$dir:" bind-pp.in > bind-pp
	install -m 0755 bind-pp "$(BINDIR)"

reinstall:
	-$(MAKE) uninstall
	$(MAKE) install

uninstall:
	rm -f "$(BINDIR)"/bind-pp
	-ocamlfind remove pa_bind

pa_bind.cmo: pa_bind.ml
	ocamlc -c -pp camlp4orf -dtypes -I +camlp4 pa_bind.ml

pa_bind.cmxs: pa_bind.ml
	ocamlopt -c -pp camlp4orf -dtypes -I +camlp4 pa_bind.ml
	ocamlopt -shared -o pa_bind.cmxs pa_bind.cmx

.PHONY: clean
clean:
	rm -f *~ *.cmi *.cmo *.cmx *.cmxs *.o *.annot bind-pp
