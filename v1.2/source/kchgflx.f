c
c     ################################################################
c     ##                                                            ##
c     ##  subroutine kchgflx  --  charge flux parameter assignment  ##
c     ##                                                            ##
c     ################################################################
c
c
c     "kchgflx" assigns bond stretch and angle bend charge flux
c     correction values and processes any new or changed values
c     for these parameters
c
c
      subroutine kchgflx
      use sizes
      use angle
      use atmlst
      use atoms
      use atmtyp
      use bond
      use cflux
      use couple
      use domdec
      use inform
      use iounit
      use kangs
      use kbonds
      use kcflux
      use keys
      use potent
      use usage
      use mpi
      implicit none
      integer i,j
      integer ia,ib,ic
      integer ita,itb,itc
      integer na,nb
      integer size,next
      integer ierr
      real*8 cfb
      real*8 cfa1,cfa2
      real*8 cfb1,cfb2
      logical headerb
      logical headera
      character*4 pa,pb,pc
      character*8 blank8
      character*8 pt2
      character*8 ptab,ptbc
      character*12 blank12,pt3
      character*20 keyword
      character*240 record
      character*240 string
c
c     deallocate global pointers if necessary
c
      call dealloc_shared_chgflx
c
c     allocate global pointers
c
      call alloc_shared_chgflx
c
c     process keywords containing charge flux parameters
c
      blank8 = '        '
      blank12 = '            '
      size = 4
      headerb = .true.
      headera = .true.
      do i = 1, nkey
         next = 1
         record = keyline(i)
         call gettext (record,keyword,next)
         call upcase (keyword)
         if (keyword(1:9) .eq. 'BNDCFLUX ') then
            ia = 0
            ib = 0
            cfb = 0.0d0
            string = record(next:240)
            read (string,*,err=10,end=10) ia,ib,cfb
   10       continue
            if (headerb .and. .not.silent) then
               headerb = .false.
               write (iout,20)
   20          format (/,' Additional Bond Charge Flux Parameters :',
     &                 //,5x,'Atom Classes',19x,'K(CFB)',/)
            end if
            if (.not. silent) then
               write (iout,30)  ia,ib,cfb
   30          format (6x,2i4,13x,f15.6)
            end if
            call numeral (ia,pa,size)
            call numeral (ib,pb,size)
            if (ia .le. ib) then
               pt2 = pa//pb
            else
               pt2 = pb//pa
            end if
            do j = 1, maxncfb
               if (kcfb(j).eq.blank8 .or. kcfb(j).eq.pt2) then
                  kcfb(j) = pt2
                  if (ia .lt. ib) then
                     cflb(j) = cfb
                  else if (ib .lt. ia) then
                     cflb(j) = -cfb
                  else
                     cflb(j) = 0.0d0
                     write (iout,40)
   40                format (/,' KCHGFLX  --  Bond Charge Flux for',
     &                          ' Identical Classes Set to Zero')
                  end if
                  goto 50
               end if
            end do
   50       continue
         else if (keyword(1:9) .eq. 'ANGCFLUX ') then
            ia = 0
            ib = 0
            ic = 0
            cfa1 = 0.0d0
            cfa2 = 0.0d0
            cfb1 = 0.0d0
            cfb2 = 0.0d0
            string = record(next:240)
            read (string,*,err=60,end=60) ia,ib,ic,cfa1,cfa2,cfb1,cfb2
   60       continue
            if (headera .and. .not.silent) then
               headera = .false.
               write (iout,70)
   70          format (/,' Additional Angle Charge Flux Parameters :',
     &                 //,5x,'Atom Classes',10x,'K(CFA1)',
     &                    7x,'K(CFA2)',7x,'K(CFB1)',7x,'K(CFB2)',/)
            end if
            if (.not. silent) then
               write (iout,80)  ia,ib,ic,cfa1,cfa2,cfb1,cfb2
   80          format (4x,3i4,4x,4f14.6)
            end if
            call numeral (ia,pa,size)
            call numeral (ib,pb,size)
            call numeral (ic,pc,size)
            if (ia .le. ic) then
               pt3 = pa//pb//pc
            else
               pt3 = pc//pb//pa
            end if
            do j = 1, maxncfa
               if (kcfa(j).eq.blank12 .or. kcfa(j).eq.pt3) then
                  kcfa(j) = pt3
                  cfla(1,j) = cfa1
                  cfla(2,j) = cfa2
                  cflab(1,j) = cfb1
                  cflab(2,j) = cfb2
                  goto 90
               end if
            end do
   90       continue
         end if
      end do
c
c     determine the total number of forcefield parameters
c
      nb = maxncfb
      do i = maxncfb, 1, -1
         if (kcfb(i) .eq. blank8)  nb = i - 1
      end do
      na = maxncfa
      do i = maxncfa, 1, -1
         if (kcfa(i) .eq. blank12)  na = i - 1
      end do
c
c     assign bond charge flux parameters for each bond
c
      if (hostrank.ne.0) goto 100
      nbflx = 0
      do i = 1, nbond
         ia = ibnd(1,i)
         ib = ibnd(2,i)
         ita = class(ia)
         itb = class(ib)
         size = 4
         call numeral (ita,pa,size)
         call numeral (itb,pb,size)
         if (ita .le. itb) then
            pt2 = pa//pb
         else
            pt2 = pb//pa
         end if
         bflx(i) = 0.0d0
         do j = 1, nb
            if (kcfb(j) .eq. pt2) then
               nbflx = nbflx + 1
               if (ita .le. itb) then
                  bflx(i) = cflb(j)
               else
                  bflx(i) = -cflb(j)
               end if
            end if
         end do
      end do
c
c    assign angle charge flux parameters for each angle
c
      naflx = 0
      do i = 1, nangle
         ia = iang(1,i)
         ib = iang(2,i)
         ic = iang(3,i)
         ita = class(ia)
         itb = class(ib)
         itc = class(ic)
         call numeral (ita,pa,size)
         call numeral (itb,pb,size)
         call numeral (itc,pc,size)
         if (ita .le. itc) then
            pt3 = pa//pb//pc
         else
            pt3 = pc//pb//pa
         end if
         if (ita .le. itb) then
            ptab = pa//pb
         else
            ptab = pb//pa
         end if
         if (itb .le. itc) then
            ptbc = pb//pc
         else
            ptbc = pc//pb
         end if
         aflx(1,i) = 0.0d0
         aflx(2,i) = 0.0d0
         abflx(1,i) = 0.0d0
         abflx(2,i) = 0.0d0
         do j = 1, na
            if (kcfa(j) .eq. pt3) then
               naflx = naflx + 1
               aflx(1,i) = cfla(1,j)
               aflx(2,i) = cfla(2,j)
               abflx(1,i) = cflab(1,j)
               abflx(2,i) = cflab(2,j)
            end if
         end do
      end do
 100  call MPI_BARRIER(hostcomm,ierr)
      call MPI_BCAST(nbflx,1,MPI_INT,0,hostcomm,ierr)
      call MPI_BCAST(naflx,1,MPI_INT,0,hostcomm,ierr)
c
c     turn off bond and angle charge flux term if not used
c
      if (nbflx.eq.0 .and. naflx.eq.0)  use_chgflx = .false.
      if (.not.use_charge .and. .not.use_mpole
     &        .and. .not.use_polar)  use_chgflx = .false.
      return
      end
c
c     subroutine dealloc_shared_chgflx : deallocate shared memory pointers for chgflx
c     parameter arrays
c
      subroutine dealloc_shared_chgflx
      USE, INTRINSIC :: ISO_C_BINDING, ONLY : C_PTR, C_F_POINTER
      use cflux
      use mpi
      implicit none
      INTEGER(KIND=MPI_ADDRESS_KIND) :: windowsize
      INTEGER :: disp_unit,ierr
      TYPE(C_PTR) :: baseptr
c
      if (associated(aflx)) then
        CALL MPI_Win_shared_query(winaflx, 0, windowsize, disp_unit,
     $  baseptr, ierr)
        CALL MPI_Win_free(winaflx,ierr)
      end if
      if (associated(bflx)) then
        CALL MPI_Win_shared_query(winbflx, 0, windowsize, disp_unit,
     $  baseptr, ierr)
        CALL MPI_Win_free(winbflx,ierr)
      end if
      if (associated(abflx)) then
        CALL MPI_Win_shared_query(winabflx, 0, windowsize, disp_unit,
     $  baseptr, ierr)
        CALL MPI_Win_free(winabflx,ierr)
      end if
      return
      end
c
c     subroutine alloc_shared_chgflx : allocate shared memory pointers for chgflx
c     parameter arrays
c
      subroutine alloc_shared_chgflx
      USE, INTRINSIC :: ISO_C_BINDING, ONLY : C_PTR, C_F_POINTER
      use sizes
      use angle
      use atoms
      use bond
      use cflux
      use domdec
      use mpi
      implicit none
      INTEGER(KIND=MPI_ADDRESS_KIND) :: windowsize
      INTEGER :: disp_unit,ierr
      TYPE(C_PTR) :: baseptr
      integer :: arrayshape(1),arrayshape2(2)
c
c     aflx
c
      arrayshape2=(/2,nangle/)
      if (hostrank == 0) then
        windowsize = int(2*nangle,MPI_ADDRESS_KIND)*8_MPI_ADDRESS_KIND
      else
        windowsize = 0_MPI_ADDRESS_KIND
      end if
      disp_unit = 1
c
c    allocation
c
      CALL MPI_Win_allocate_shared(windowsize, disp_unit, MPI_INFO_NULL,
     $  hostcomm, baseptr, winaflx, ierr)
      if (hostrank /= 0) then
        CALL MPI_Win_shared_query(winaflx, 0, windowsize, disp_unit,
     $  baseptr, ierr)
      end if
c
c    association with fortran pointer
c
      CALL C_F_POINTER(baseptr,aflx,arrayshape2)
c
c     abflx
c
      arrayshape2=(/2,nangle/)
      if (hostrank == 0) then
        windowsize = int(2*nangle,MPI_ADDRESS_KIND)*8_MPI_ADDRESS_KIND
      else
        windowsize = 0_MPI_ADDRESS_KIND
      end if
      disp_unit = 1
c
c    allocation
c
      CALL MPI_Win_allocate_shared(windowsize, disp_unit, MPI_INFO_NULL,
     $  hostcomm, baseptr, winabflx, ierr)
      if (hostrank /= 0) then
        CALL MPI_Win_shared_query(winabflx, 0, windowsize, disp_unit,
     $  baseptr, ierr)
      end if
c
c    association with fortran pointer
c
      CALL C_F_POINTER(baseptr,abflx,arrayshape2)
c
c     bflx
c
      arrayshape=(/nbond/)
      if (hostrank == 0) then
        windowsize = int(nbond,MPI_ADDRESS_KIND)*8_MPI_ADDRESS_KIND
      else
        windowsize = 0_MPI_ADDRESS_KIND
      end if
      disp_unit = 1
c
c    allocation
c
      CALL MPI_Win_allocate_shared(windowsize, disp_unit, MPI_INFO_NULL,
     $  hostcomm, baseptr, winbflx, ierr)
      if (hostrank /= 0) then
        CALL MPI_Win_shared_query(winbflx, 0, windowsize, disp_unit,
     $  baseptr, ierr)
      end if
c
c    association with fortran pointer
c
      CALL C_F_POINTER(baseptr,bflx,arrayshape)
      return
      end
