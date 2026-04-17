#                         MPI  Kent Milfeld 2017 11 15
F90 = ifort
FFLAGS=-O3
CC  = icc
CFLAGS=-O3 -xHOST 

HOSTNAME := $(shell hostname --long)

ifeq ($(findstring stampede,$(HOSTNAME)),stampede)
        $(shell sed -i 's/N3\s*[1-9][0-9]*/N3 150/' memoryc.c)
        $(shell sed -i 's/N3\s*=\s*[1-9][0-9]*/N3=150/' memoryf.F90)
        F90=ifx
        FFLAGS=-O3 $(TACC_VEC_FLAGS)
        CC=icx
        CFLAGS=-O3 $(TACC_VEC_FLAGS)
endif

ifeq ($(findstring lonestar,$(HOSTNAME)),lonestar)
        F90=ifort
        FFLAGS=-O3 $(TACC_VEC_FLAGS)
        CC=icc
        CFLAGS=-O3 $(TACC_VEC_FLAGS)
endif



# Frontera, decrease memory slightly
ifeq ($(findstring frontera,$(HOSTNAME)),frontera)
        $(shell sed -i 's/N3\s*[1-9][0-9]*/N3 120/' memoryc.c)
        $(shell sed -i 's/N3\s*=\s*[1-9][0-9]*/N3=120/' memoryf.F90)
        F90=ifort
        FFLAGS=-O3 $(TACC_VEC_FLAGS)
        CC=icc
        CFLAGS=-O3 $(TACC_VEC_FLAGS)
endif

ifeq ($(findstring vista,$(HOSTNAME)),vista)
        $(shell sed -i 's/N3\s*[1-9][0-9]*/N3 200/' memoryc.c)
        $(shell sed -i 's/N3\s*=\s*[1-9][0-9]*/N3=200/' memoryf.F90)
        F90=nvfortran
       #FFLAGS=-O3 $(TACC_VEC_FLAGS)
        FFLAGS=-O3 -Mvect=simd -w
        CC=nvc
       #CFLAGS=-O3 $(TACC_VEC_FLAGS)
        CFLAGS=-O3 -Mvect=simd -w
       #set_but_not_used
       #declared_but_not_referenced
endif

all: memoryf memoryc

memoryf: memoryf.o 
	$(F90) memoryf.o -o memoryf 

memoryf.o: memoryf.F90
	$(F90) $(FFLAGS) -c memoryf.F90  -o memoryf.o

memoryc: memoryc.o 
	$(CC) memoryc.o -o memoryc 

memoryc.o: memoryc.c
	$(CC) $(CFLAGS) -c memoryc.c  -o memoryc.o

clean:
	rm -rf *.o core memoryf memoryc *.mod
