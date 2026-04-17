/*  MPI-IO Code
                                    Kent Milfeld 20100317  */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <mpi.h>
//#define  M 8
//#define  N 8
#define  M 5000
#define  N 5000
#define NTRIALS 30

void number_cell(int irank, int nrank, int m,int n, double **data);
void checkpoint (int irank, int nrank, int m,int n, double **data);
double mysecond();

int main(int argc, char *argv[]){ 

  int i;

  double *datablk;
  double **data;

  int irank, nrank, ierr;

  double t0, t1, t10=0.0e0, datasize, bw;

                                             /* MPI initialization */
  ierr = MPI_Init(&argc, &argv                );
  ierr = MPI_Comm_rank(MPI_COMM_WORLD, &irank );
  ierr = MPI_Comm_size(MPI_COMM_WORLD, &nrank);

                                             /*  Create  data array */
  datablk = (double * )malloc((M+2)*(N+2)*sizeof(double  ) );
  data    = (double **)malloc((M+2)      *sizeof(double *) );
  for(i=0; i<=M+1; i++) data[i] = &datablk[i*(N+2)];

                                             /*  number elements row-wise */
  number_cell(irank, nrank, M,N, data);
                                             /*  Store element row-wise, rank order */
  t0=mysecond();
for(i=1;i<=NTRIALS;i++){
  checkpoint (irank, nrank, M,N, data);
  printf("rank %3d finished its checkpoint # %3d out of %d\n",irank,i,2*NTRIALS);
}
system("sleep 4");
for(i=1;i<=NTRIALS;i++){
  checkpoint (irank, nrank, M,N, data);
  printf("rank %3d finished its checkpoint # %3d out of %d\n",irank,i+NTRIALS,2*NTRIALS);
}

  t1=mysecond();
  datasize = ( (double)(nrank*8*NTRIALS) )*((double)(N*M)/1048576.0e0);
//datasize = ( (double)(nrank*8        ) )*((double)(N*M)/1048576.0e0);

/*if(irank==0) printf("Ranks: %3.3d  Time(s):%8.2f Total Data Moved(MB):%9.2f  BW(MB/s):%6.2f\n",
   nrank, t1-t0,datasize,datasize/(t1-t0));
*/
  if(irank==0) printf("Finished Run, with checkpointing.\n");
  ierr = MPI_Finalize();

}

void checkpoint(int irank, int nrank, int m,int n, double **data){

  long i8_one=1;

  MPI_Status   status;
  int idble_size, ierr;

  MPI_Datatype idt_suba;
  int          array_size[2], array_subsize[2], array_start[2];

  MPI_Datatype mdt_suba;
  int          iblksize, iblks, istride;

                                          /* File IO info */
  MPI_File     fh;
  int          iamode;
  MPI_Offset   disp;
  MPI_Datatype etype,filetype;

  double  blk_size_mb, size_mb;

                                          /* Get File info */
  char *filename;
  char * lustre_dir;

  lustre_dir = getenv("LUSTRE_DIR");

  if(lustre_dir != NULL){
     filename = malloc(strlen(lustre_dir)+strlen("/data2")+1);
     strcpy(filename,lustre_dir);
     strcat(filename,"/data2");
  }
  else{
     filename = malloc(strlen("./data2")+1);
     strcpy(filename,"./data2");
  }


                           /* start at data[1][1] */
                           /* subarray of mxn  */
     array_size[0] = m+2;
     array_size[1] = n+2;
  array_subsize[0] = m;
  array_subsize[1] = n;
    array_start[0] = 1; 
    array_start[1] = 1;

  MPI_Type_create_subarray(2, array_size, array_subsize, array_start, MPI_ORDER_C, MPI_DOUBLE, &idt_suba);
  MPI_Type_commit(&idt_suba);

                            /* Create MPI Datatype single block file view */
                            /* This could have been a MPI_Type_Contiguous */
  iblksize = m*n;
  iblks    = 1;
  istride  = iblksize;

  ierr=MPI_Type_vector(iblks, iblksize, istride, MPI_DOUBLE, &mdt_suba);
  ierr=MPI_Type_commit(                                      &mdt_suba);
  ierr=MPI_Type_size(MPI_DOUBLE,&idble_size);

                           /* consolidate File view info */ 

  disp     = (MPI_Offset)(irank*(i8_one*iblksize)*idble_size);
  etype    = MPI_DOUBLE;
  filetype = mdt_suba;

                            /* Set mode, open file, set view, write data */

  iamode = (MPI_MODE_CREATE|MPI_MODE_WRONLY);

  ierr=MPI_File_open(MPI_COMM_WORLD,filename, iamode, MPI_INFO_NULL,&fh);

  ierr=MPI_File_set_view(fh,disp,etype,filetype,"native",MPI_INFO_NULL);

  ierr=MPI_File_write_all(fh,(void *)&data[0][0],1,idt_suba,&status);

  ierr=MPI_File_sync(  fh);
  ierr=MPI_File_close(&fh);

  blk_size_mb =      8.0*iblksize/(1048576.0e0);
  size_mb     =      8.0*iblksize*nrank/(1048576.0e0);
//if(irank == 0){printf("%3.3d ranks  size/rank(MB):%9.2f  TotSize(MB):%11.2f\n",nrank, blk_size_mb, size_mb);}

  ierr =  MPI_Type_free(&mdt_suba);

}

void number_cell(int irank, int nrank, int m,int n, double **data){

   long i8_off, i8_one=1;

   int  ivec, i;

      for(i=1; i<=m; i++){
//    i8_off = nrank*(i8_one*n)*(i-1) + irank*(i8_one*m);
      i8_off =               n *(i-1) + irank*(i8_one*m*n);
        for(ivec=1; ivec<=n; ivec++){
        data[i][ivec] = (double) (ivec + i8_off);
      }
   }

   for(i=0; i<m+1; i++)         data[  i][   0] = 0.0e0;
   for(i=0; i<m+1; i++)         data[  i][ n+1] = 0.0e0;
   for(ivec=1; ivec<=n; ivec++) data[  0][ivec] = 0.0e0;
   for(ivec=1; ivec<=n; ivec++) data[m+1][ivec] = 0.0e0;


}

double mysecond()
{
   struct timeval tp;
   struct timezone tzp;
   int i;
   i = gettimeofday(&tp,&tzp);
   return ( (double) tp.tv_sec + (double) tp.tv_usec * 1.e-6 );
}

