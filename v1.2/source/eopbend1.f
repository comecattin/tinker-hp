c
c     Sorbonne University
c     Washington University in Saint Louis
c     University of Texas at Austin
c
c     ###############################################################
c     ##                                                           ##
c     ##  subroutine eopbend1  --  out-of-plane energy and derivs  ##
c     ##                                                           ##
c     ###############################################################
c
c
c     "eopbend1" computes the out-of-plane bend potential energy and
c     first derivatives at trigonal centers via a Wilson-Decius-Cross
c     or Allinger angle
c
c
      subroutine eopbend1
      use angle
      use angpot
      use atmlst
      use atoms
      use bound
      use deriv
      use domdec
      use energi
      use group
      use math
      use opbend
      use usage
      use virial
      implicit none
      integer i,iopbend,iopbendloc
      integer ia,ib,ic,id
      integer ialoc,ibloc,icloc,idloc
      real*8 e,angle1,force
      real*8 dot,cosine
      real*8 cc,ee,bkk2,term
      real*8 deddt,dedcos
      real*8 dt,dt2,dt3,dt4
      real*8 xia,yia,zia
      real*8 xib,yib,zib
      real*8 xic,yic,zic
      real*8 xid,yid,zid
      real*8 xab,yab,zab
      real*8 xcb,ycb,zcb
      real*8 xdb,ydb,zdb
      real*8 xad,yad,zad
      real*8 xcd,ycd,zcd
      real*8 rdb2,rad2,rcd2
      real*8 rab2,rcb2
      real*8 dccdxia,dccdyia,dccdzia
      real*8 dccdxic,dccdyic,dccdzic
      real*8 dccdxid,dccdyid,dccdzid
      real*8 deedxia,deedyia,deedzia
      real*8 deedxic,deedyic,deedzic
      real*8 deedxid,deedyid,deedzid
      real*8 dedxia,dedyia,dedzia
      real*8 dedxib,dedyib,dedzib
      real*8 dedxic,dedyic,dedzic
      real*8 dedxid,dedyid,dedzid
      real*8 vxx,vyy,vzz
      real*8 vyx,vzx,vzy
      real*8 fgrp
      logical proceed
c
c
c     zero out out-of-plane energy and first derivatives
c
      eopb = 0.0d0
c
c     calculate the out-of-plane bending energy and derivatives
c
      do iopbendloc = 1, nopbendloc
         iopbend = opbendglob(iopbendloc)
         i = iopb(iopbend)
         ia = iang(1,i)
         ib = iang(2,i)
         ic = iang(3,i)
         id = iang(4,i)
         ialoc = loc(ia)
         ibloc = loc(ib)
         icloc = loc(ic)
         idloc = loc(id)
         force = opbk(iopbend)
c
c     decide whether to compute the current interaction
c
         if (use_group)  call groups (fgrp,ia,ib,ic,id,0,0)
         proceed = (use(ia) .or. use(ib) .or.
     &                              use(ic) .or. use(id))
c
c     get the coordinates of the atoms at trigonal center
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
            xid = x(id)
            yid = y(id)
            zid = z(id)
c
c     compute the out-of-plane bending angle
c
            xab = xia - xib
            yab = yia - yib
            zab = zia - zib
            xcb = xic - xib
            ycb = yic - yib
            zcb = zic - zib
            xdb = xid - xib
            ydb = yid - yib
            zdb = zid - zib
            xad = xia - xid
            yad = yia - yid
            zad = zia - zid
            xcd = xic - xid
            ycd = yic - yid
            zcd = zic - zid
            if (use_polymer) then
               call image (xab,yab,zab)
               call image (xcb,ycb,zcb)
               call image (xdb,ydb,zdb)
               call image (xad,yad,zad)
               call image (xcd,ycd,zcd)
            end if
c
c     W-D-C angle between A-B-C plane and B-D vector for D-B<AC
c
            if (opbtyp .eq. 'W-D-C') then
               rab2 = xab*xab + yab*yab + zab*zab
               rcb2 = xcb*xcb + ycb*ycb + zcb*zcb
               dot = xab*xcb+yab*ycb+zab*zcb
               cc = rab2*rcb2 - dot*dot
c
c     Allinger angle between A-C-D plane and D-B vector for D-B<AC
c
            else if (opbtyp .eq. 'ALLINGER') then
               rad2 = xad*xad + yad*yad + zad*zad
               rcd2 = xcd*xcd + ycd*ycd + zcd*zcd
               dot = xad*xcd + yad*ycd + zad*zcd
               cc = rad2*rcd2 - dot*dot
            end if
c
c     find the out-of-plane angle bending energy
c
            ee = xdb*(yab*zcb-zab*ycb) + ydb*(zab*xcb-xab*zcb)
     &              + zdb*(xab*ycb-yab*xcb)
            rdb2 = xdb*xdb + ydb*ydb + zdb*zdb
            if (rdb2.ne.0.0d0 .and. cc.ne.0.0d0) then
               bkk2 = rdb2 - ee*ee/cc
               cosine = sqrt(bkk2/rdb2)
               cosine = min(1.0d0,max(-1.0d0,cosine))
               angle1 = radian * acos(cosine)
               dt = angle1
               dt2 = dt * dt
               dt3 = dt2 * dt
               dt4 = dt2 * dt2
               e = opbunit * force * dt2
     &                * (1.0d0+copb*dt+qopb*dt2+popb*dt3+sopb*dt4)
               deddt = opbunit * force * dt * radian
     &                    * (2.0d0 + 3.0d0*copb*dt + 4.0d0*qopb*dt2
     &                        + 5.0d0*popb*dt3 + 6.0d0*sopb*dt4)
               dedcos = -deddt * sign(1.0d0,ee) / sqrt(cc*bkk2)
c
c     scale the interaction based on its group membership
c
               if (use_group) then
                  e = e * fgrp
                  dedcos = dedcos * fgrp
               end if
c
c     chain rule terms for first derivative components
c
               if (opbtyp .eq. 'W-D-C') then
                  term = ee / cc
                  dccdxia = (xab*rcb2-xcb*dot) * term
                  dccdyia = (yab*rcb2-ycb*dot) * term
                  dccdzia = (zab*rcb2-zcb*dot) * term
                  dccdxic = (xcb*rab2-xab*dot) * term
                  dccdyic = (ycb*rab2-yab*dot) * term
                  dccdzic = (zcb*rab2-zab*dot) * term
                  dccdxid = 0.0d0
                  dccdyid = 0.0d0
                  dccdzid = 0.0d0
               else if (opbtyp .eq. 'ALLINGER') then
                  term = ee / cc
                  dccdxia = (xad*rcd2-xcd*dot) * term
                  dccdyia = (yad*rcd2-ycd*dot) * term
                  dccdzia = (zad*rcd2-zcd*dot) * term
                  dccdxic = (xcd*rad2-xad*dot) * term
                  dccdyic = (ycd*rad2-yad*dot) * term
                  dccdzic = (zcd*rad2-zad*dot) * term
                  dccdxid = -dccdxia - dccdxic
                  dccdyid = -dccdyia - dccdyic
                  dccdzid = -dccdzia - dccdzic
               end if
               term = ee / rdb2
               deedxia = ydb*zcb - zdb*ycb
               deedyia = zdb*xcb - xdb*zcb
               deedzia = xdb*ycb - ydb*xcb
               deedxic = yab*zdb - zab*ydb
               deedyic = zab*xdb - xab*zdb
               deedzic = xab*ydb - yab*xdb
               deedxid = ycb*zab - zcb*yab + xdb*term
               deedyid = zcb*xab - xcb*zab + ydb*term
               deedzid = xcb*yab - ycb*xab + zdb*term
c
c     compute first derivative components for this angle
c
               dedxia = dedcos * (dccdxia+deedxia)
               dedyia = dedcos * (dccdyia+deedyia)
               dedzia = dedcos * (dccdzia+deedzia)
               dedxic = dedcos * (dccdxic+deedxic)
               dedyic = dedcos * (dccdyic+deedyic)
               dedzic = dedcos * (dccdzic+deedzic)
               dedxid = dedcos * (dccdxid+deedxid)
               dedyid = dedcos * (dccdyid+deedyid)
               dedzid = dedcos * (dccdzid+deedzid)
               dedxib = -dedxia - dedxic - dedxid
               dedyib = -dedyia - dedyic - dedyid
               dedzib = -dedzia - dedzic - dedzid
c
c     increment the out-of-plane bending energy and gradient
c
               eopb = eopb + e
               deopb(1,ibloc) = deopb(1,ibloc) + dedxib
               deopb(2,ibloc) = deopb(2,ibloc) + dedyib
               deopb(3,ibloc) = deopb(3,ibloc) + dedzib
c
               deopb(1,ialoc) = deopb(1,ialoc) + dedxia
               deopb(2,ialoc) = deopb(2,ialoc) + dedyia
               deopb(3,ialoc) = deopb(3,ialoc) + dedzia
c
               deopb(1,icloc) = deopb(1,icloc) + dedxic
               deopb(2,icloc) = deopb(2,icloc) + dedyic
               deopb(3,icloc) = deopb(3,icloc) + dedzic
c
               deopb(1,idloc) = deopb(1,idloc) + dedxid
               deopb(2,idloc) = deopb(2,idloc) + dedyid
               deopb(3,idloc) = deopb(3,idloc) + dedzid
c
c     increment the internal virial tensor components
c
               vxx = xab*dedxia + xcb*dedxic + xdb*dedxid
               vyx = yab*dedxia + ycb*dedxic + ydb*dedxid
               vzx = zab*dedxia + zcb*dedxic + zdb*dedxid
               vyy = yab*dedyia + ycb*dedyic + ydb*dedyid
               vzy = zab*dedyia + zcb*dedyic + zdb*dedyid
               vzz = zab*dedzia + zcb*dedzic + zdb*dedzid
               vir(1,1) = vir(1,1) + vxx
               vir(2,1) = vir(2,1) + vyx
               vir(3,1) = vir(3,1) + vzx
               vir(1,2) = vir(1,2) + vyx
               vir(2,2) = vir(2,2) + vyy
               vir(3,2) = vir(3,2) + vzy
               vir(1,3) = vir(1,3) + vzx
               vir(2,3) = vir(2,3) + vzy
               vir(3,3) = vir(3,3) + vzz
            end if
         end if
      end do
      return
      end
