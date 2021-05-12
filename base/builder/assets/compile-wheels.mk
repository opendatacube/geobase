#
# - Finds any source distribution files in current directory
# - Compiles each one into a wheel
# - Generates `.done` file containing name of the wheel that was built
pip ?= /opt/env0/bin/python -m pip
srcs := $(wildcard *.zip *.tar.gz *.tar *.tar.Z *.tar.xz *.tar.bz2 *.tgz *.tbz)
out := $(patsubst %, %.done, $(srcs))
extra ?=

all: $(out)

%.done: %
	@echo "Processing: " $<
	@(tt=$$(mktemp -d "/tmp/wheel-build-XXXX") && \
   echo ".. working in " $${tt} && \
	 $(pip) wheel --no-deps -w $${tt} $(extra) $< && \
   whl=$$(find $${tt} -name "*.whl") && \
   mv $${whl} ./ && \
   echo $$(basename $${whl}) | tee $@ && \
   rmdir $${tt} \
  )

dbg:
	@echo "sources:" $(srcs)
	@echo "out:" $(out)
	@echo "pip:" $(pip)

list:
	@find . -name "*.done" | xargs cat

clean:
	rm *.done

.PHONY: dbg all clean list
