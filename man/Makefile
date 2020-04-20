none:

% : %.ronn
	ronn -r --pipe $< > $@
	sed -i '/^\.TH /s/ ""$$//' $@ || true

cleanall:
	rm *[1-8]
