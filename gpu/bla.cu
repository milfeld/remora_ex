// nvcc thrd_config.cu

#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#include <math.h>

__global__ void saxpy(float *x, float *y, int n){
  int idx = blockIdx.x * blockDim.x + threadIdx.x;
  if (idx < n){ y[idx] = 2.0 * x[idx] + y[idx]; }
}

__global__ void sinitxy(float *x, float *y, int n){
  int idx = blockIdx.x * blockDim.x + threadIdx.x;
  if (idx < n){ y[idx] = 1.0; x[idx] = 1.0; }
}
__global__ void daxpy(double *x, double *y, int n){
  int idx = blockIdx.x * blockDim.x + threadIdx.x;
  if (idx < n){ y[idx] = 2.0 * x[idx] + y[idx]; }
}

__global__ void dinitxy(double *x, double *y, int n){
  int idx = blockIdx.x * blockDim.x + threadIdx.x;
  if (idx < n){ y[idx] = 1.0; x[idx] = 1.0; }
}

__global__ void dinit_sqrt(double *x, double *y, int n){
  int idx = blockIdx.x * blockDim.x + threadIdx.x;
  if (idx < n){ y[idx] = 1.0f/sqrt((double)idx);
                x[idx] = 1.0f/sqrt((double)idx); }
}
__global__ void daxpy_sqrt(double *x, double *y, int n){
  int idx = blockIdx.x * blockDim.x + threadIdx.x;
  if (idx < n){ y[idx] = 2.0 * sqrt((double)idx)*x[idx]  \
                             + sqrt((double)idx)*y[idx]; }
}


__global__ void dinit_sincos(double *x, double *y, int n){
  int idx = blockIdx.x * blockDim.x + threadIdx.x;
  if (idx < n){ y[idx] = 0.000000000001f*(double)idx;
                x[idx] = 0.000000000001f*(double)idx; }
}
__global__ void dsincos(double *x, double *y, int n){
  int idx = blockIdx.x * blockDim.x + threadIdx.x;
//if (idx < n){ y[idx] =  sin(x[idx]) * cos(x[idx]); }
  if (idx < n){ y[idx] =  sin(1.0f/x[idx]) * cos(1.0f/x[idx]) +
                          sin(     x[idx]) / cos(    x[idx]); }
}

  #define NREPEATS 500

int main(){
  int  N=1<<28;

//                          Single Precision
  float *d_fy, *d_fx;
  float  h_fy[N];
  size_t fxy_sz = N*sizeof(float);

//                          Double Precision
  double *d_dy, *d_dx;
  double  h_dy[N];
  size_t dxy_sz = N*sizeof(double);

  dim3 grd(1,1,1);
  dim3 blk(1,1,1);

  struct timespec rt[2]; //timer
  double wt; 

  printf(" SP  Elements  Thrds/blk   Seconds  saxpy\n");

//for(int nt=32; nt<=32  ; nt=nt*2){
//for(int nt=32; nt<=1024; nt=nt*2){
  for(int nt=32; nt<=1024; nt=nt+992){
  
    grd.x=(N+nt-1)/nt;
    blk.x=nt;
  
    cudaMalloc((void**)&d_fx, fxy_sz);  //?  &d_fx works?
    cudaMalloc((void**)&d_fy, fxy_sz);
  
    clock_gettime(CLOCK_REALTIME, rt+0);
for(int knt=1; knt<=NREPEATS; knt++){  
    sinitxy<<<grd, blk>>>(d_fx, d_fy, N);
    cudaDeviceSynchronize();
    saxpy<<<grd, blk>>>(d_fx, d_fy, N);
    cudaDeviceSynchronize();
}
    clock_gettime(CLOCK_REALTIME, rt+1);
  
    wt = (rt[1].tv_sec-rt[ 0].tv_sec) +  \
         (rt[1].tv_nsec-rt[0].tv_nsec)*1.0e-9;
    printf("    %8d      %5d %8.7f\n",N,nt,wt);
  
    cudaMemcpy(h_fy, d_fy, fxy_sz, cudaMemcpyDeviceToHost);
    cudaFree(d_fx);
    cudaFree(d_fy);
  
    float fmaxerr = 0.0f;
    for (int i=0; i<N; i++) fmaxerr=max(fmaxerr, abs(h_fy[i]-3.0f));
    printf("%*s max error= %f\n",45,"", fmaxerr);
  }
  
  // Double precision
  
    printf(" DP  Elements  Thrds/blk   Seconds   daxpy\n");
  for(int nt=32; nt<=1024; nt=nt+992){
  
    grd.x=(N+nt-1)/nt;
    blk.x=nt;
  
    cudaMalloc((void**)&d_dx, dxy_sz);  //?  &d_dx works?
    cudaMalloc((void**)&d_dy, dxy_sz);
  
    clock_gettime(CLOCK_REALTIME, rt + 0);
for(int knt=1; knt<=NREPEATS; knt++){  
    dinitxy<<<grd, blk>>>(d_dx, d_dy, N);
    cudaDeviceSynchronize();
    daxpy<<<grd, blk>>>(d_dx, d_dy, N);
    cudaDeviceSynchronize();
}
    clock_gettime(CLOCK_REALTIME, rt + 1);
  
    wt = (rt[1].tv_sec-rt[ 0].tv_sec) +  \
         (rt[1].tv_nsec-rt[0].tv_nsec)*1.0e-9;
    printf("    %8d      %5d %8.7f      \n",N,nt,wt);
  
    cudaMemcpy(h_dy, d_dy, dxy_sz, cudaMemcpyDeviceToHost);
    cudaFree(d_dx);
    cudaFree(d_dy);
  
    float dmaxerr = 0.0;
    for (int i=0; i<N; i++)dmaxerr=max( dmaxerr, fabs(h_dy[i]-3.0));
    printf("%*s max error= %f\n",45,"", dmaxerr);
    
  }

//sqrt

    printf(" DP  Elements  Thrds/blk   Seconds  axpy-sqrt\n");
  for(int nt=32; nt<=1024; nt=nt+992){
  
    grd.x=(N+nt-1)/nt;
    blk.x=nt;
  
    cudaMalloc((void**)&d_dx, dxy_sz);  //?  &d_dx works?
    cudaMalloc((void**)&d_dy, dxy_sz);
  
    clock_gettime(CLOCK_REALTIME, rt+0); 
for(int knt=1; knt<=NREPEATS; knt++){  
    dinit_sqrt<<<grd, blk>>>(d_dx, d_dy, N); 
    cudaDeviceSynchronize();
    daxpy_sqrt<<<grd, blk>>>(d_dx, d_dy, N); 
    cudaDeviceSynchronize();
}
    clock_gettime(CLOCK_REALTIME, rt+1); 
  
    wt = (rt[1].tv_sec-rt[ 0].tv_sec) +  \
         (rt[1].tv_nsec-rt[0].tv_nsec)*1.0e-9;
    printf("    %8d      %5d %8.7f\n",N,nt,wt);
  
    cudaMemcpy(h_dy, d_dy, dxy_sz, cudaMemcpyDeviceToHost);
    cudaFree(d_dx);
    cudaFree(d_dy);
  
    float dmaxerr = 0.0;
    for (int i=0; i<N; i++)dmaxerr=max( dmaxerr, fabs(h_dy[i]-3.0));
    printf("%*s max error= %f\n",45,"", dmaxerr);
    
  }


//sincos start
    printf(" DP  Elements  Thrds/blk   Seconds  sincos\n");
  for(int nt=32; nt<=1024; nt=nt+992){
  
    grd.x=(N+nt-1)/nt;
    blk.x=nt;
  
    cudaMalloc((void**)&d_dx, dxy_sz);  //?  &d_dx works?
    cudaMalloc((void**)&d_dy, dxy_sz);

    clock_gettime(CLOCK_REALTIME, rt+0); 
for(int knt=1; knt<=NREPEATS; knt++){  
    dinit_sincos<<<grd, blk>>>(d_dx, d_dy, N); 
    cudaDeviceSynchronize();
    
    dsincos<<<grd, blk>>>(d_dx, d_dy, N); 
    cudaDeviceSynchronize();
}
    clock_gettime(CLOCK_REALTIME, rt+1); 
  
    wt = (rt[1].tv_sec-rt[ 0].tv_sec) +  \
         (rt[1].tv_nsec-rt[0].tv_nsec)*1.0e-9;
    printf("    %8d      %5d %8.7f      \n",N,nt,wt);
  
    cudaMemcpy(h_dy, d_dy, dxy_sz, cudaMemcpyDeviceToHost);
    cudaFree(d_dx);
    cudaFree(d_dy);

    /* 
    float dmaxerr = 0.0;
    for (int i=0; i<N; i++)dmaxerr=max( dmaxerr, fabs(h_dy[i]-3.0));
    printf("%*s max error= %f\n",45,"", dmaxerr);
    */

  }

  
 }
  // https://developer.nvidia.com/blog/easy-introduction-cuda-c-and-c/
