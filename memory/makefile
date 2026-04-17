#                         MPI  Kent Milfeld 2017 11 15
F90 = ifort
FFLAGS=-O3
CC  = icc
CFLAGS=-O3 -xHOST 

ifneq ($(findstring lengau,$(shell hostname -A)),)
        F90=gfortran
        FFLAGS=-O3
        CC=gcc
        CFLAGS=-O3
endif

ifneq ($(findstring stampede,$(shell hostname -A)),)
        F90=ifort
        FFLAGS=-O3 $(TACC_VEC_FLAGS)
        CC=icc
        CFLAGS=-O3 $(TACC_VEC_FLAGS)
endif



# Frontera, decrease memory slightly
ifneq ($(findstring frontera,$(shell hostname -A)),)
        $(shell sed -i 's/N3\s*[1-9][0-9]*/N3 120/' memoryc.c)
        $(shell sed -i 's/N3\s*=\s*[1-9][0-9]*/N3=120/' memoryf.F90)
        F90=ifort
        FFLAGS=-O3 $(TACC_VEC_FLAGS)
        CC=icc
        CFLAGS=-O3 $(TACC_VEC_FLAGS)
endif

ifneq ($(findstring vista,$(shell hostname -A)),)
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

