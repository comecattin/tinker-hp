c
c     Sorbonne University
c     Washington University in Saint Louis
c     University of Texas at Austin
c
c     #################################################################
c     ##                                                             ##
c     ##  subroutine eangle1  --  angle bend energy and derivatives  ##
c     ##                                                             ##
c     #################################################################
c
c
c     "eangle1" calculates the angle bending potential energy and
c     the first derivatives with respect to Cartesian coordinates;
c     projected in-plane angles at trigonal centers, special linear
c     or Fourier angle bending terms are optionally used
c
c
      subroutine eangle1
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
      use usage
      use virial
      implicit none
      integer i,ia,ib,ic,id,j
      integer ialoc,ibloc,icloc,idloc
      integer iangle
      real*8 e,ideal,force
      real*8 fold,factor,dot
      real*8 cosine,sine
      real*8 angle1
      real*8 dt,dt2,dt3,dt4
      real*8 deddt,term
      real*8 terma,termc
      real*8 xia,yia,zia
      real*8 xib,yib,zib
      real*8 xic,yic,zic
      real*8 xid,yid,zid
      real*8 xab,yab,zab
      real*8 xcb,ycb,zcb
      real*8 xp,yp,zp,rp
      real*8 xad,yad,zad
      real*8 xbd,ybd,zbd
      real*8 xcd,ycd,zcd
      real*8 xip,yip,zip
      real*8 xap,yap,zap
      real*8 xcp,ycp,zcp
      real*8 rab2,rcb2
      real*8 rap2,rcp2
      real*8 xt,yt,zt
      real*8 rt2,ptrt2
      real*8 xm,ym,zm,rm
      real*8 delta,delta2
      real*8 dedxia,dedyia,dedzia
      real*8 dedxib,dedyib,dedzib
      real*8 dedxic,dedyic,dedzic
      real*8 dedxid,dedyid,dedzid
      real*8 dedxip,dedyip,dedzip
      real*8 dpdxia,dpdyia,dpdzia
      real*8 dpdxic,dpdyic,dpdzic
      real*8 vxx,vyy,vzz
      real*8 vyx,vzx,vzy
      real*8 fgrp
      logical proceed
      real*8 angle_mean
      real*8 fmat(15,3),dfmat(15,3)
      real*8 r_e,drab,drcb,x1,x2,x3
      real*8 gaussterm, dgaussdrab, dgaussdrcb
      real*8 dedrab,dedrcb,dtermdrab,dtermdrcb
      real*8 rab,rcb
c
c
c     zero out energy and first derivative components
c
      ea = 0.0d0
c
c     calculate the bond angle bending energy term
c
      do iangle = 1, nangleloc
         i = angleglob(iangle)
         ia = iang(1,i)
         ib = iang(2,i)
         ic = iang(3,i)
         id = iang(4,i)
         ialoc = loc(ia)
         ibloc = loc(ib)
         icloc = loc(ic)
         if (id.ne.0) idloc = loc(id)
         ideal = anat(i)
         force = ak(i)
         dedrab=0.d0
         dedrcb=0.d0
c
c     decide whether to compute the current interaction
c
         if (angtyp(i) .eq. 'IN-PLANE') then
            if (use_group)  call groups (fgrp,ia,ib,ic,id,0,0)
            proceed = (use(ia) .or. use(ib) .or.
     &                                 use(ic) .or. use(id))
         else
            if (use_group)  call groups (fgrp,ia,ib,ic,0,0,0)
            proceed = (use(ia) .or. use(ib) .or. use(ic))
         end if
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
c     compute the bond angle bending energy and gradient
c
            if (angtyp(i) .ne. 'IN-PLANE') then
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
               rab = sqrt(rab2) ; rcb = sqrt(rcb2)
               if (rab2.ne.0.0d0 .and. rcb2.ne.0.0d0) then
                  xp = ycb*zab - zcb*yab
                  yp = zcb*xab - xcb*zab
                  zp = xcb*yab - ycb*xab
                  rp = sqrt(xp*xp + yp*yp + zp*zp)
                  rp = max(rp,0.000001d0)
                  dot = xab*xcb + yab*ycb + zab*zcb
                  cosine = dot / sqrt(rab2*rcb2)
                  cosine = min(1.0d0,max(-1.0d0,cosine))
                  angle1 = radian * acos(cosine)
c
c     get the energy and master chain rule term for derivatives
c
                  if (angtyp(i) .eq. 'HARMONIC') then
                     dt = angle1 - ideal
                     dt2 = dt * dt
                     dt3 = dt2 * dt
                     dt4 = dt2 * dt2
                     e = angunit * force * dt2
     &                      * (1.0d0+cang*dt+qang*dt2+pang*dt3+sang*dt4)
                     deddt = angunit * force * dt * radian
     &                         * (2.0d0 + 3.0d0*cang*dt + 4.0d0*qang*dt2
     &                              + 5.0d0*pang*dt3 + 6.0d0*sang*dt4)
                  else if (angtyp(i) .eq. 'LINEAR') then
                     factor = 2.0d0 * angunit * radian**2
                     sine = sqrt(1.0d0-cosine*cosine)
                     e = factor * force * (1.0d0+cosine)
                     deddt = -factor * force * sine
                  else if (angtyp(i) .eq. 'FOURIER') then
                     fold = afld(i)
                     factor = 2.0d0 * angunit * (radian/fold)**2
                     cosine = cos((fold*angle1-ideal)/radian)
                     sine = sin((fold*angle1-ideal)/radian)
                     e = factor * force * (1.0d0+cosine)
                     deddt = -factor * force * fold * sine
                  elseif (angtyp(i) .eq. 'ANGLEPS') then
                     r_e = afld(i)
                     x3 = cosine - cos(ideal/radian)
                     sine = sin(angle1/radian)
                     drab = rab - r_e
                     drcb = rcb - r_e 
                     gaussterm = exp(-ak(i)*(drab**2+drcb**2))
                     dgaussdrab = -2.0d0*ak(i)*drab*gaussterm
                     dgaussdrcb = -2.0d0*ak(i)*drcb*gaussterm
                     x1 = drab/r_e
                     x2 = drcb/r_e
                     fmat(1,1)=1d0
                     fmat(1,2)=1d0
                     fmat(1,3)=1d0
                     dfmat(1,1)=0d0
                     dfmat(1,2)=0d0
                     dfmat(1,3)=0d0
                     do j=2,15
                      fmat(j,1)=fmat(j-1,1)*x1
                      fmat(j,2)=fmat(j-1,2)*x2
                      fmat(j,3)=fmat(j-1,3)*x3
                      !deriv with respect to rab
                      dfmat(j,1)=dfmat(j-1,1)*x1 + fmat(j-1,1)/r_e
                      !deriv with respect to rcb
                      dfmat(j,2)=dfmat(j-1,2)*x2 + fmat(j-1,2)/r_e
                      !deriv with respect to angle
                      dfmat(j,3)=dfmat(j-1,3)*x3 - fmat(j-1,3)*sine
                     enddo
                     e=0.d0
                     deddt=0.d0
                     dedrab=0.d0
                     dedrcb=0.d0
                     do j=2,245
                      term=fmat(idx_ps(j,1),1)*fmat(idx_ps(j,2),2) 
     &                    +fmat(idx_ps(j,2),1)*fmat(idx_ps(j,1),2)
                      dtermdrab=
     &                   dfmat(idx_ps(j,1),1)*fmat(idx_ps(j,2),2) 
     &                  +dfmat(idx_ps(j,2),1)*fmat(idx_ps(j,1),2)
                      dtermdrcb=
     &                   fmat(idx_ps(j,1),1)*dfmat(idx_ps(j,2),2) 
     &                  +fmat(idx_ps(j,2),1)*dfmat(idx_ps(j,1),2)

                      e=e+c5z_ps(j)*term*fmat(idx_ps(j,3),3)
                      deddt=deddt+c5z_ps(j)*term*dfmat(idx_ps(j,3),3)
                      dedrab=dedrab+c5z_ps(j)
     &                   *dtermdrab*fmat(idx_ps(j,3),3)
                      dedrcb=dedrcb+c5z_ps(j)
     &                   *dtermdrcb*fmat(idx_ps(j,3),3)
                     enddo
                     deddt = deddt*gaussterm
                     dedrab = dedrab*gaussterm + e*dgaussdrab
                     dedrcb = dedrcb*gaussterm + e*dgaussdrcb
                     e =  e*gaussterm ! + c5z_ps(1)
                  end if
c
c     scale the interaction based on its group membership
c
                  if (use_group) then
                     e = e * fgrp
                     deddt = deddt * fgrp
                  end if
c
c     compute derivative components for this interaction
c
                  terma = -deddt / (rab2*rp)
                  termc = deddt / (rcb2*rp)
                  dedxia = terma * (yab*zp-zab*yp)
                  dedyia = terma * (zab*xp-xab*zp)
                  dedzia = terma * (xab*yp-yab*xp)
                  dedxic = termc * (ycb*zp-zcb*yp)
                  dedyic = termc * (zcb*xp-xcb*zp)
                  dedzic = termc * (xcb*yp-ycb*xp)
                  dedxib = -dedxia - dedxic
                  dedyib = -dedyia - dedyic
                  dedzib = -dedzia - dedzic

                  if (dedrab .ne. 0.0d0) then
                    if (use_group) dedrab=dedrab*fgrp
                    term = dedrab/rab
                    dedxia = dedxia + term * xab
                    dedxib = dedxib - term * xab
                    dedyia = dedyia + term * yab
                    dedyib = dedyib - term * yab
                    dedzia = dedzia + term * zab
                    dedzib = dedzib - term * zab
                  end if

                  if (dedrcb .ne. 0.0d0) then
                    if (use_group) dedrcb=dedrcb*fgrp
                    term = dedrcb/rcb
                    dedxic = dedxic + term * xcb
                    dedxib = dedxib - term * xcb
                    dedyic = dedyic + term * ycb
                    dedyib = dedyib - term * ycb
                    dedzic = dedzic + term * zcb
                    dedzib = dedzib - term * zcb
                  end if
c
c     increment the total bond angle energy and derivatives
c
                  ea = ea + e
                  dea(1,ibloc) = dea(1,ibloc) + dedxib
                  dea(2,ibloc) = dea(2,ibloc) + dedyib
                  dea(3,ibloc) = dea(3,ibloc) + dedzib
c
                  dea(1,ialoc) = dea(1,ialoc) + dedxia
                  dea(2,ialoc) = dea(2,ialoc) + dedyia
                  dea(3,ialoc) = dea(3,ialoc) + dedzia
c
                  dea(1,icloc) = dea(1,icloc) + dedxic
                  dea(2,icloc) = dea(2,icloc) + dedyic
                  dea(3,icloc) = dea(3,icloc) + dedzic
c
c     increment the internal virial tensor components
c
                  vxx = xab*dedxia + xcb*dedxic
                  vyx = yab*dedxia + ycb*dedxic
                  vzx = zab*dedxia + zcb*dedxic
                  vyy = yab*dedyia + ycb*dedyic
                  vzy = zab*dedyia + zcb*dedyic
                  vzz = zab*dedzia + zcb*dedzic
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
c
c     compute the projected in-plane angle energy and gradient
c
            else
               xid = x(id)
               yid = y(id)
               zid = z(id)
               xad = xia - xid
               yad = yia - yid
               zad = zia - zid
               xbd = xib - xid
               ybd = yib - yid
               zbd = zib - zid
               xcd = xic - xid
               ycd = yic - yid
               zcd = zic - zid
               if (use_polymer) then
                  call image (xad,yad,zad)
                  call image (xbd,ybd,zbd)
                  call image (xcd,ycd,zcd)
               end if
               xt = yad*zcd - zad*ycd
               yt = zad*xcd - xad*zcd
               zt = xad*ycd - yad*xcd
               rt2 = xt*xt + yt*yt + zt*zt
               delta = -(xt*xbd + yt*ybd + zt*zbd) / rt2
               xip = xib + xt*delta
               yip = yib + yt*delta
               zip = zib + zt*delta
               xap = xia - xip
               yap = yia - yip
               zap = zia - zip
               xcp = xic - xip
               ycp = yic - yip
               zcp = zic - zip
               if (use_polymer) then
                  call image (xap,yap,zap)
                  call image (xcp,ycp,zcp)
               end if
               rap2 = xap*xap + yap*yap + zap*zap
               rcp2 = xcp*xcp + ycp*ycp + zcp*zcp
               if (rap2.ne.0.0d0 .and. rcp2.ne.0.0d0) then
                  xm = ycp*zap - zcp*yap
                  ym = zcp*xap - xcp*zap
                  zm = xcp*yap - ycp*xap
                  rm = sqrt(xm*xm + ym*ym + zm*zm)
                  rm = max(rm,0.000001d0)
                  dot = xap*xcp + yap*ycp + zap*zcp
                  cosine = dot / sqrt(rap2*rcp2)
                  cosine = min(1.0d0,max(-1.0d0,cosine))
                  angle1 = radian * acos(cosine)
c
c     get the energy and master chain rule term for derivatives
c
                  dt = angle1 - ideal
                  dt2 = dt * dt
                  dt3 = dt2 * dt
                  dt4 = dt2 * dt2
                  e = angunit * force * dt2
     &                   * (1.0d0+cang*dt+qang*dt2+pang*dt3+sang*dt4)
                  deddt = angunit * force * dt * radian
     &                      * (2.0d0 + 3.0d0*cang*dt + 4.0d0*qang*dt2
     &                           + 5.0d0*pang*dt3 + 6.0d0*sang*dt4)
c
c     scale the interaction based on its group membership
c
                  if (use_group) then
                     e = e * fgrp
                     deddt = deddt * fgrp
                  end if
c
c     chain rule terms for first derivative components
c
                  terma = -deddt / (rap2*rm)
                  termc = deddt / (rcp2*rm)
                  dedxia = terma * (yap*zm-zap*ym)
                  dedyia = terma * (zap*xm-xap*zm)
                  dedzia = terma * (xap*ym-yap*xm)
                  dedxic = termc * (ycp*zm-zcp*ym)
                  dedyic = termc * (zcp*xm-xcp*zm)
                  dedzic = termc * (xcp*ym-ycp*xm)
                  dedxip = -dedxia - dedxic
                  dedyip = -dedyia - dedyic
                  dedzip = -dedzia - dedzic
c
c     chain rule components for the projection of the central atom
c
                  delta2 = 2.0d0 * delta
                  ptrt2 = (dedxip*xt + dedyip*yt + dedzip*zt) / rt2
                  term = (zcd*ybd-ycd*zbd) + delta2*(yt*zcd-zt*ycd)
                  dpdxia = delta*(ycd*dedzip-zcd*dedyip) + term*ptrt2
                  term = (xcd*zbd-zcd*xbd) + delta2*(zt*xcd-xt*zcd)
                  dpdyia = delta*(zcd*dedxip-xcd*dedzip) + term*ptrt2
                  term = (ycd*xbd-xcd*ybd) + delta2*(xt*ycd-yt*xcd)
                  dpdzia = delta*(xcd*dedyip-ycd*dedxip) + term*ptrt2
                  term = (yad*zbd-zad*ybd) + delta2*(zt*yad-yt*zad)
                  dpdxic = delta*(zad*dedyip-yad*dedzip) + term*ptrt2
                  term = (zad*xbd-xad*zbd) + delta2*(xt*zad-zt*xad)
                  dpdyic = delta*(xad*dedzip-zad*dedxip) + term*ptrt2
                  term = (xad*ybd-yad*xbd) + delta2*(yt*xad-xt*yad)
                  dpdzic = delta*(yad*dedxip-xad*dedyip) + term*ptrt2
c
c     compute derivative components for this interaction
c
                  dedxia = dedxia + dpdxia
                  dedyia = dedyia + dpdyia
                  dedzia = dedzia + dpdzia
                  dedxib = dedxip
                  dedyib = dedyip
                  dedzib = dedzip
                  dedxic = dedxic + dpdxic
                  dedyic = dedyic + dpdyic
                  dedzic = dedzic + dpdzic
                  dedxid = -dedxia - dedxib - dedxic
                  dedyid = -dedyia - dedyib - dedyic
                  dedzid = -dedzia - dedzib - dedzic
c
c     increment the total bond angle energy and derivatives
c
                  ea = ea + e
                  dea(1,ibloc) = dea(1,ibloc) + dedxib
                  dea(2,ibloc) = dea(2,ibloc) + dedyib
                  dea(3,ibloc) = dea(3,ibloc) + dedzib
c
                  dea(1,ialoc) = dea(1,ialoc) + dedxia
                  dea(2,ialoc) = dea(2,ialoc) + dedyia
                  dea(3,ialoc) = dea(3,ialoc) + dedzia
c
                  dea(1,icloc) = dea(1,icloc) + dedxic
                  dea(2,icloc) = dea(2,icloc) + dedyic
                  dea(3,icloc) = dea(3,icloc) + dedzic
c
                  dea(1,idloc) = dea(1,idloc) + dedxid
                  dea(2,idloc) = dea(2,idloc) + dedyid
                  dea(3,idloc) = dea(3,idloc) + dedzid
c
c     increment the internal virial tensor components
c
                  vxx = xad*dedxia + xbd*dedxib + xcd*dedxic
                  vyx = yad*dedxia + ybd*dedxib + ycd*dedxic
                  vzx = zad*dedxia + zbd*dedxib + zcd*dedxic
                  vyy = yad*dedyia + ybd*dedyib + ycd*dedyic
                  vzy = zad*dedyia + zbd*dedyib + zcd*dedyic
                  vzz = zad*dedzia + zbd*dedzib + zcd*dedzic
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
         end if
      end do
      return
      end
