c
c     Sorbonne University
c     Washington University in Saint Louis
c     University of Texas at Austin
c
c     ################################################################
c     ##                                                            ##
c     ##  subroutine image  --  compute the minimum image distance  ##
c     ##                                                            ##
c     ################################################################
c
c
c     "image" takes the components of pairwise distance between
c     two points in a periodic box and converts to the components
c     of the minimum image distance
c
c
      subroutine image (xr,yr,zr)
      use sizes
      use boxes
      use cell
      implicit none
      real*8 xr,yr,zr
c
c
c     for orthogonal lattice, find the desired image directly
c
      if (orthogonal) then
         do while (abs(xr) .gt. xcell2)
            xr = xr - sign(xcell,xr)
         end do
         do while (abs(yr) .gt. ycell2)
            yr = yr - sign(ycell,yr)
         end do
         do while (abs(zr) .gt. zcell2)
            zr = zr - sign(zcell,zr)
         end do
c
c     for monoclinic lattice, convert "xr" and "zr" to
c     fractional coordinates, find desired image and then
c     translate fractional coordinates back to Cartesian
c
      else if (monoclinic) then
         zr = zr / beta_sin
         xr = xr - zr*beta_cos
         do while (abs(xr) .gt. xcell2)
            xr = xr - sign(xcell,xr)
         end do
         do while (abs(yr) .gt. ycell2)
            yr = yr - sign(ycell,yr)
         end do
         do while (abs(zr) .gt. zcell2)
            zr = zr - sign(zcell,zr)
         end do
         xr = xr + zr*beta_cos
         zr = zr * beta_sin
c
c     for triclinic lattice, convert pairwise components to
c     fractional coordinates, find desired image and then
c     translate fractional coordinates back to Cartesian
c
      else if (triclinic) then
         zr = zr / gamma_term
         yr = (yr - zr*beta_term) / gamma_sin
         xr = xr - yr*gamma_cos - zr*beta_cos
         do while (abs(xr) .gt. xcell2)
            xr = xr - sign(xcell,xr)
         end do
         do while (abs(yr) .gt. ycell2)
            yr = yr - sign(ycell,yr)
         end do
         do while (abs(zr) .gt. zcell2)
            zr = zr - sign(zcell,zr)
         end do
         xr = xr + yr*gamma_cos + zr*beta_cos
         yr = yr*gamma_sin + zr*beta_term
         zr = zr * gamma_term
c
c     for truncated octahedron, use orthogonal box equations,
c     then perform extra tests to remove corner pieces
c
      else if (octahedron) then
         do while (abs(xr) .gt. xbox2)
            xr = xr - sign(xbox,xr)
         end do
         do while (abs(yr) .gt. ybox2)
            yr = yr - sign(ybox,yr)
         end do
         do while (abs(zr) .gt. zbox2)
            zr = zr - sign(zbox,zr)
         end do
         if (abs(xr)+abs(yr)+abs(zr) .gt. box34) then
            xr = xr - sign(xbox2,xr)
            yr = yr - sign(ybox2,yr)
            zr = zr - sign(zbox2,zr)
         end if
      end if
      return
      end
c
cold  subroutine imagevec (pos,n)
cold  use sizes
cold  use cell
cold  implicit none
cold  integer n,i
cold  real*8 pos(3,n)
cold  real*8 xr,yr,zr
cold
cold  do i = 1, n
cold    xr = pos(1,i)
cold    yr = pos(2,i)
cold    zr = pos(3,i)
cold
cold    for orthogonal lattice, find the desired image directly
cold
cold    if (orthogonal) then
cold    do while (abs(xr) .gt. xcell2)
cold       xr = xr - sign(xcell,xr)
cold    end do
cold    do while (abs(yr) .gt. ycell2)
cold       yr = yr - sign(ycell,yr)
cold    end do
cold    do while (abs(zr) .gt. zcell2)
cold       zr = zr - sign(zcell,zr)
cold    end do
cold    end if
cold    pos(1,i) = xr
cold    pos(2,i) = yr 
cold    pos(3,i) = zr
cold  end do
cold   do while (any(abs(pos(1,1:n)).gt.xcell2))
cold      where (    abs(pos(1,1:n)).gt.xcell2)
cold         pos(1,1:n) = pos(1,1:n) -sign(xcell,pos(1,1:n))
cold      end where
cold   enddo
cold   do while (any(abs(pos(2,1:n)).gt.ycell2))
cold      where (    abs(pos(2,1:n)).gt.ycell2)
cold         pos(2,1:n) = pos(2,1:n) -sign(ycell,pos(2,1:n))
cold      end where
cold   enddo
cold   do while (any(abs(pos(3,1:n)).gt.zcell2))
cold      where (    abs(pos(3,1:n)).gt.zcell2)
cold         pos(3,1:n) = pos(3,1:n) -sign(zcell,pos(3,1:n))
cold      end where
cold   enddo
cold  return
cold  end
