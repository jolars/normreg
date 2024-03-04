JULIA := julia

.PHONY: install test 

all: install

install:
	$(JULIA) -e 'using Pkg; Pkg.develop(PackageSpec(path=pwd())); Pkg.instantiate()'

test:
	$(JULIA) --project=. -e 'using Pkg; Pkg.test()'
