#                         MPI  Kent Milfeld 2025 07 07

ifneq ($(findstring vista,$(shell hostname -A)),)
        CC=nvcc
endif

all: bla

bla: bla.o
	$(CC) bla.o -o bla

bla.o: bla.cu
	$(CC)  -c  bla.cu  -o bla.o

clean:
	rm -rf *.o core bla

