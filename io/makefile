#                         IO  Kent Milfeld 2017 11 15
pCC = mpicc
sCC =   icc
CFLAGS=-O3

HOSTNAME := $(shell hostname --long)

pCC=mpicc
sCC=$(shell  mpicc -show | awk '{print $1}' )


ifeq ($(findstring vista,$(HOSTNAME)),vista)
   sCC=$(shell mpicc -showme:command | xargs basename)
   CFLAGS=-O3 --diag_suppress=set_but_not_used,declared_but_not_referenced
endif

pio: pio.o 
	$(pCC) pio.o -o pio 

pio.o: pio.c
	$(pCC) $(CFLAGS) -c pio.c  -o pio.o

io: io.o 
	$(sCC) io.o -o io 

io.o: io.c
	$(sCC) $(CFLAGS) -c io.c  -o io.o


clean:
	rm -rf *.o core pio io
