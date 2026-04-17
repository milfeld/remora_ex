#                         MPI  Kent Milfeld 2017 11 15
F90    = ifort
FFLAGS = -O3

CC     = icc
CFLAGS = -O3

HOSTNAME := $(shell hostname --long)

ifeq ($(findstring ls6,$(HOSTNAME)),ls6)
        F90=ifort -fopenmp
        FFLAGS=-O3 $(TACC_VEC_FLAGS)

        CC=icc
        CFLAGS=-O3 $(TACC_VEC_FLAGS)

        OMPFLAG=-fopenmp
endif

ifeq ($(findstring stampede,$(HOSTNAME)),stampede)
        F90=ifx -qopenmp
        FFLAGS=-O3 $(TACC_VEC_FLAGS)

        CC=icx
        CFLAGS=-O3 $(TACC_VEC_FLAGS)

        OMPFLAG=-qopenmp
endif

ifeq ($(findstring vista,$(HOSTNAME)),vista)
        F90=nvfortran
        FFLAGS=-O3 $(TACC_VEC_FLAGS)
       #FFLAGS=-O3 -Mvect=simd -w

        CC=nvc
        CFLAGS=-O3 $(TACC_VEC_FLAGS)
       #CFLAGS=-O3 -Mvect=simd -w

       #set_but_not_used
       #declared_but_not_referenced

        OMPFLAG=-fopenmp
endif


all: loadc

loadc: loadc.o utils.o
	$(CC) $(OMPFLAG) loadc.o utils.o -o loadc 

loadc.o: loadc.c
	$(CC) $(CFLAGS) $(OMPFLAG) -c loadc.c  -o loadc.o

utils.o: utils.c
	$(CC) $(CFLAGS) -c utils.c  -o utils.o

clean:
	rm -rf *.o core loadc
