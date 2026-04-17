
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <sys/types.h>

#define  N1 1024*1024
#define  N2 1024/8
#define  N3 200

int main(){

double x;
double alloc, using;
int istat;
int i,j,k;
int ierr;

double **a;

   a    =(double **)malloc(N3*sizeof(double*));
   printf("Will do %d C malloc iterations of %d MB.\n",N3,N2*8);

   istat=usleep(3000000);
   for(k=0;k<N3;k++){
      printf(" Working on Row: %d\n",k);

      a[k] =(double * )malloc(N1*N2*sizeof(double ));
      alloc = k*8*(double)(N1*N2)/(double)(1024*1024*1024);

      for(j=0;j<N2;j++)
         for(i=0;i<N1;i++)
                a[k][i + j*N1] = i+j+k;

      if( a[k][2 + 2*N1] < 0.0e0 ) printf("HMMM, %f\n", a[k][2 + 2*N1] );
   
   
   } // end k
   istat=usleep(3000000);
   
}

