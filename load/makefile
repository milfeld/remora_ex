#                         MPI  Kent Milfeld 2017 11 15
F90    = ifort
FFLAGS = -O3
CC     = icc
CFLAGS = -O3 -xHOST 

ifneq ($(findstring lengau,$(shell hostname -A)),)
        F90=gfortran -fopenmp
        FFLAGS=-O3
        CC=gcc
        CFLAGS=-O3
        OMPFLAG=-fopenmp
endif

ifneq ($(findstring frontera,$(shell hostname -A)),)
        F90=ifort -fopenmp
        FFLAGS=-O3 $(TACC_VEC_FLAGS)
#       CC=icpc
        CC=icc
        CFLAGS=-O3 $(TACC_VEC_FLAGS)
        OMPFLAG=-fopenmp
endif
ifneq ($(findstring stampede,$(shell hostname -A)),)
        F90=ifort -fopenmp
        FFLAGS=-O3 $(TACC_VEC_FLAGS)
        CC=icpc
        CFLAGS=-O3 $(TACC_VEC_FLAGS)
        OMPFLAG=-fopenmp
endif

ifneq ($(findstring vista,$(shell hostname -A)),)
        F90=nvfortran
       #FFLAGS=-O3 $(TACC_VEC_FLAGS)
        FFLAGS=-O3 -Mvect=simd -w
        CC=nvc
       #CFLAGS=-O3 $(TACC_VEC_FLAGS)
        CFLAGS=-O3 -Mvect=simd -w
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
