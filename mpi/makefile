#                         MPI  Kent Milfeld 2019 04 24
MPI_F90 = mpif90

HOSTNAME := $(shell hostname --long)

ifeq ($(findstring stampede,$(HOSTNAME)),stampede)
        MPI_F90=mpif90
        FFLAGS=-O3 $(TACC_VEC_FLAGS) -mcmodel=large
endif

#ifeq ($(findstring ls6,$(HOSTNAME)),ls6)
        MPI_F90=mpif90
        FFLAGS=-O3 $(TACC_VEC_FLAGS) -mcmodel=large 
        WARNFLAGS=-diag-disable 10006
#endif

matmult: matmult.o 
	$(MPI_F90) matmult.o -o matmult $(WARNFLAGS)

matmult.o: matmult.f90
	$(MPI_F90) $(FFLAGS) -c matmult.f90  -o matmult.o $(WARNFLAGS)


clean:
	rm -rf *.o core matmult
