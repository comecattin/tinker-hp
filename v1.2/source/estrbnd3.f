c
c     Sorbonne University
c     Washington University in Saint Louis
c     University of Texas at Austin
c
c     ###############################################################
c     ##                                                           ##
c     ##  subroutine estrbnd3  --  stretch-bend energy & analysis  ##
c     ##                                                           ##
c     ###############################################################
c
c
c     "estrbnd3" calculates the stretch-bend potential energy;
c     also partitions the energy among the atoms
c
c
      subroutine estrbnd3
      use action
      use analyz
      use angle
      use angpot
      use atmlst
      use atmtyp
      use atoms
      use bond
      use bound
      use domdec
      use energi
      use group
      use inform
      use iounit
      use math
      use strbnd
      use usage
      implicit none
      integer i,j,k,istrbnd,istrbndloc
      integer ia,ib,ic,ibloc
      real*8 e,dr1,dr2,dt
      real*8 angle1
      real*8 force1,force2
      real*8 dot,cosine
      real*8 xia,yia,zia
      real*8 xib,yib,zib
      real*8 xic,yic,zic
      real*8 xab,yab,zab
      real*8 xcb,ycb,zcb
      real*8 rab,rab2
      real*8 rcb,rcb2
      real*8 fgrp
      logical proceed
      logical header,huge
c
c
c     zero out the energy component and partitioning terms
c
      neba = 0
      eba = 0.0d0
      aeba = 0.0d0
      header = .true.
c
c     calculate the stretch-bend energy term
c
      do istrbndloc = 1, nstrbndloc
         istrbnd = strbndglob(istrbndloc)
         i = isb(1,istrbnd)
         ia = iang(1,i)
         ib = iang(2,i)
         ibloc = loc(ib)
         ic = iang(3,i)
         force1 = sbk(1,istrbnd)
         force2 = sbk(2,istrbnd)
c
c     decide whether to compute the current interaction
c
         if (use_group)  call groups (fgrp,ia,ib,ic,0,0,0)
         proceed = (use(ia) .or. use(ib) .or. use(ic))
c
c     get the coordinates of the atoms in the angle
c
         if (proceed) then
            xia = x(ia)
            yia = y(ia)
            zia = z(ia)
            xib = x(ib)
            yib = y(ib)
            zib = z(ib)
            xic = x(ic)
            yic = y(ic)
            zic = z(ic)
c
c     compute the value of the bond angle
c
            xab = xia - xib
            yab = yia - yib
            zab = zia - zib
            xcb = xic - xib
            ycb = yic - yib
            zcb = zic - zib
            if (use_polymer) then
               call image (xab,yab,zab)
               call image (xcb,ycb,zcb)
            end if
            rab2 = xab*xab + yab*yab + zab*zab
            rcb2 = xcb*xcb + ycb*ycb + zcb*zcb
            if (rab2.ne.0.0d0 .and. rcb2.ne.0.0d0) then
               rab = sqrt(rab2)
               rcb = sqrt(rcb2)
               dot = xab*xcb + yab*ycb + zab*zcb
               cosine = dot / (rab*rcb)
               cosine = min(1.0d0,max(-1.0d0,cosine))
               angle1 = radian * acos(cosine)
               dt = angle1 - anat(i)
c
c     get the stretch-bend interaction energy
c
               j = isb(2,istrbnd)
               k = isb(3,istrbnd)
               dr1 = rab - bl(j)
               dr2 = rcb - bl(k)
               e = stbnunit * (force1*dr1+force2*dr2) * dt
c
c     scale the interaction based on its group membership
c
               if (use_group)  e = e * fgrp
c
c     increment the total stretch-bend energy
c
               neba = neba + 1
               eba = eba + e
               aeba(ibloc) = aeba(ibloc) + e
c
c     print a message if the energy of this interaction is large
c
               huge = (abs(e) .gt. 2.0d0)
               if (debug .or. (verbose.and.huge)) then
                  if (header) then
                     header = .false.
                     write (iout,10)
   10                format (/,' Individual Stretch-Bend',
     &                          ' Interactions :',
     &                       //,' Type',18x,'Atom Names',18x,'dSB 1',
     &                          5x,'dSB 2',6x,'Energy',/)
                  end if
                  write (iout,20)  ia,name(ia),ib,name(ib),
     &                             ic,name(ic),dr1*dt,dr2*dt,e
   20             format (' StrBend',3x,3(i7,'-',a3),2x,2f10.4,f12.4)
               end if
            end if
         end if
      end do
      return
      end
