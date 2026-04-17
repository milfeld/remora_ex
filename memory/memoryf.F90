module my_sleep_us
interface
   function usleep(usec) bind(C)
      use iso_c_binding, only : c_int32_t
      integer(c_int32_t), value :: usec
      integer(c_int32_t)        :: usleep
   end function
end interface
end module my_sleep_us




program use_memory

use iso_c_binding, only : c_int32_t
use my_sleep_us
implicit none

integer,parameter :: N1=1024*1024, N2=1024/8, N3=200
real*8, allocatable, dimension(:,:,:) :: a,b,c
real*8  ::  alloc, using
integer :: istat

integer i,j,k,m, ii

alloc = 1.0d0*8*N1*N2*N3/(1024*1024*1024)  
allocate(     a(N1,N2,N3))
write(*,'("Will work on ",I," columns of a Fortran Allocated Matrix",I," MB")') N3,N2*8

do k=1,N3
   using = 1.0d0*8*N1*N2*k/(1024*1024*1024)  
   write( *, '(" Working on Column: ",I5)' ) k

   do j=1,N2

      do i=1,N1
        !A(i,j,k) = real(i+j*2.1d0,8)*real(j+i*1.1d0,8)*k*10000
         A(i,j,k) = i + J +k
         if(A(i,j,k)<0.0e0) print*, "HMMM.", A(i,j,k) 
      enddo

   enddo !end j

enddo !end k

end program
