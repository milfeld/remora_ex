//#include <string.h>
//#include <cstdlib>
#include  <stdio.h>
#include    <omp.h>
#include <unistd.h>
#include <stdlib.h>

void load_cpu_nsec(int sec );

int main(){
  int nsec        = 5;
  int niters      = 7;
  int nthreads    = 16;
  int nthreads_h  = 16/2;

  if( nthreads%2 != 0 ){ 
    printf(" Error: nthreads not even.\n"); 
    exit(EXIT_FAILURE);  // must be even
  }
  printf(" EVEN/ODD iterations(%d) alternate LOAD on different set of %d threads \n", \
           niters,nthreads_h);

  for(int iter=0; iter<niters; iter++){

     #pragma omp parallel num_threads(nthreads)
     {
        if( omp_get_thread_num() <  nthreads_h   && iter%2 == 0 ){
         if(omp_get_thread_num() == 0) 
           printf(" EVEN iteration: %d sec, iter=%2d, using %d thrds out of %d\n",\
                                    nsec,   iter+1,   nthreads_h,        nthreads);
           load_cpu_nsec(nsec);
        }

        if( omp_get_thread_num() >= nthreads_h   && iter%2 == 1 ){
         if(omp_get_thread_num() == nthreads_h) 
           printf(" ODD  iteration: %d sec, iter=%2d, using %d thrds out of %d\n",\
                                    nsec,   iter+1,   nthreads_h,        nthreads);
           load_cpu_nsec(nsec);
        }

     } // End parallel region
   }   // End loop

   printf("Finished\n");
}
