c
c     Sorbonne University
c     Washington University in Saint Louis
c     University of Texas at Austin
c
c     #################################################################
c     ##                                                             ##
c     ##  subroutine initprm  --  initialize force field parameters  ##
c     ##                                                             ##
c     #################################################################
c
c
c     "initprm" completely initializes a force field by setting all
c     parameters to zero and using defaults for control values
c
c
      subroutine initprm
      use sizes
      use angpot
      use bndpot
      use atoms
      use chgpot
      use ctrpot
      use divcon
      use fields
      use kanang
      use kangs
      use kantor
      use katoms
      use kbonds
      use kchrge
      use kcpen
      use kctrn
      use kdsp
      use khbond
      use kiprop
      use kitors
      use kmulti
      use kopbnd
      use kopdst
      use kitors
      use kmulti
      use kpitor
      use kpolr
      use kpolpr
      use krepl
      use kstbnd
      use ksttor
      use ktorsn
      use ktrtor
      use kurybr
      use kvdws
      use kvdwpr
      use math
      use merck
      use mplpot
      use polpot
      use potent
      use reppot
      use torpot
      use units
      use urypot
      use vdwpot
      implicit none
      integer i,j,k
      character*3 blank3
      character*8 blank8
      character*12 blank12
      character*16 blank16
      character*20 blank20
      character*24 blank24
c
c
c     define blank character strings of various lengths
c
      blank3 = '   '
      blank8 = '        '
      blank12 = '            '
      blank16 = '                '
      blank20 = '                    '
      blank24 = '                        '
c
c     initialize strings of parameter atom types and classes
c
      do i = 1, maxnvp
         kvpr(i) = blank8
      end do
      do i = 1, maxnhb
         khb(i) = blank8
      end do
      do i = 1, maxnb
         kb(i) = blank8
      end do
      do i = 1, maxnbm
         kbm(i) = blank8
      end do
      do i = 1, maxnbm4
         kbm4(i) = blank8
      end do
      do i = 1, maxnb5
         kb5(i) = blank8
      end do
      do i = 1, maxnb4
         kb4(i) = blank8
      end do
      do i = 1, maxnb3
         kb3(i) = blank8
      end do
      do i = 1, maxnel
         kel(i) = blank12
      end do
      do i = 1, maxna
         ka(i) = blank12
      end do
      do i = 1, maxna5
         ka5(i) = blank12
      end do
      do i = 1, maxna4
         ka4(i) = blank12
      end do
      do i = 1, maxna3
         ka3(i) = blank12
      end do
      do i = 1, maxnap
         kap(i) = blank12
      end do
      do i = 1, maxnaf
         kaf(i) = blank12
      end do
      do i = 1, maxnaps
         kaps(i) = blank12
      end do
      do i = 1, maxnups
         kups(i) = blank12
      end do
      do i = 1, maxnuq
        kuq(i) = blank12
      end do
      do i = 1, maxnsb
         ksb(i) = blank12
      end do
      do i = 1, maxnu
         ku(i) = blank12
      end do
      do i = 1, maxnopb
         kopb(i) = blank8
      end do
      do i = 1, maxnopd
         kopd(i) = blank16
      end do
      do i = 1, maxndi
         kdi(i) = blank16
      end do
      do i = 1, maxnti
         kti(i) = blank16
      end do
      do i = 1, maxnt
         kt(i) = blank16
      end do
      do i = 1, maxnt5
         kt5(i) = blank16
      end do
      do i = 1, maxnt4
         kt4(i) = blank16
      end do
      do i = 1, maxnpt
         kpt(i) = blank8
      end do
      do i = 1, maxnbt
         kbt(i) = blank16
      end do
      do i = 1, maxnat
         kat(i) = blank16
      end do
      do i = 1, maxntt
         ktt(i) = blank20
      end do
      do i = 1, maxnmp
         kmp(i) = blank12
      end do
      do i = 1, maxnpp
         kppr(i) = blank8
      end do
c
c     initialize values of some force field parameters
c
      forcefield = blank20
      do i = 1, maxtyp
         symbol(i) = blank3
         atmcls(i) = 0
         atmnum(i) = 0
         weight(i) = 0.0d0
         ligand(i) = 0
         describe(i) = blank24
         rad(i) = 0.0d0
         eps(i) = 0.0d0
         rad4(i) = 0.0d0
         eps4(i) = 0.0d0
         reduct(i) = 0.0d0
         chg(i) = 0.0d0
         polr(i) = 0.0d0
         athl(i) = 0.0d0
         dthl(i) = 0.0d0
         do j = 1, maxvalue
            pgrp(j,i) = 0
         end do
         sibfacp(1,i) = 0.0d0
         sibfacp(2,i) = 0.0d0
         sibfacp(3,i) = 0.0d0
      end do
      do i = 1, maxclass
         do j = 1, 2
            stbn(j,i) = 0.0d0
         end do
         do j = 1, 3
            anan(j,i) = 0.0d0
         end do
         prsiz(i) = 0.0d0
         prdmp(i) = 0.0d0
         prele(i) = 0.0d0
         dspsix(i) = 0.0d0
         dspdmp(i) = 0.0d0
         cpele(i) = 0.0d0
         cpalp(i) = 0.0d0
         ctchg(i) = 0.0d0
         ctdmp(i) = 0.0d0
      end do
      do i = 1, maxbio
         biotyp(i) = 0
      end do
c
c     initialize values of some MMFF-specific parameters
c
      do i = 1, 100
         do j = 1, 100
            mmff_kb(j,i) = 1000.0d0
            mmff_kb1(j,i) = 1000.0d0
            mmff_b0(j,i) = 1000.0d0
            mmff_b1(j,i) = 1000.0d0
            bci(j,i) = 1000.0d0
            bci_1(j,i) = 1000.0d0
            do k = 1, 100
               stbn_abc(k,j,i) = 1000.0d0
               stbn_cba(k,j,i) = 1000.0d0
               stbn_abc1(k,j,i) = 1000.0d0
               stbn_cba1(k,j,i) = 1000.0d0
               stbn_abc2(k,j,i) = 1000.0d0
               stbn_cba2(k,j,i) = 1000.0d0
               stbn_abc3(k,j,i) = 1000.0d0
               stbn_cba3(k,j,i) = 1000.0d0
               stbn_abc4(k,j,i) = 1000.0d0
               stbn_cba4(k,j,i) = 1000.0d0
               stbn_abc5(k,j,i) = 1000.0d0
               stbn_cba5(k,j,i) = 1000.0d0
               stbn_abc6(k,j,i) = 1000.0d0
               stbn_cba6(k,j,i) = 1000.0d0
               stbn_abc7(k,j,i) = 1000.0d0
               stbn_cba7(k,j,i) = 1000.0d0
               stbn_abc8(k,j,i) = 1000.0d0
               stbn_cba8(k,j,i) = 1000.0d0
               stbn_abc9(k,j,i) = 1000.0d0
               stbn_cba9(k,j,i) = 1000.0d0
               stbn_abc10(k,j,i) = 1000.0d0
               stbn_cba10(k,j,i) = 1000.0d0
               stbn_abc11(k,j,i) = 1000.0d0
               stbn_cba11(k,j,i) = 1000.0d0
            end do
         end do
      end do
      do i = 0, 100
         do j = 1, 100
            do k = 0, 100
               mmff_ka(k,j,i) = 1000.0d0
               mmff_ka1(k,j,i) = 1000.0d0
               mmff_ka2(k,j,i) = 1000.0d0
               mmff_ka3(k,j,i) = 1000.0d0
               mmff_ka4(k,j,i) = 1000.0d0
               mmff_ka5(k,j,i) = 1000.0d0
               mmff_ka6(k,j,i) = 1000.0d0
               mmff_ka7(k,j,i) = 1000.0d0
               mmff_ka8(k,j,i) = 1000.0d0
               mmff_ang0(k,j,i) = 1000.0d0
               mmff_ang1(k,j,i) = 1000.0d0
               mmff_ang2(k,j,i) = 1000.0d0
               mmff_ang3(k,j,i) = 1000.0d0
               mmff_ang4(k,j,i) = 1000.0d0
               mmff_ang5(k,j,i) = 1000.0d0
               mmff_ang6(k,j,i) = 1000.0d0
               mmff_ang7(k,j,i) = 1000.0d0
               mmff_ang8(k,j,i) = 1000.0d0
            end do
         end do
      end do
      do i = 1, maxnt
         kt(i) = blank16
         kt_1(i) = blank16
         kt_2(i) = blank16
         t1(1,i) = 1000.0d0
         t1(2,i) = 1000.0d0
         t2(1,i) = 1000.0d0
         t2(2,i) = 1000.0d0
         t3(1,i) = 1000.0d0
         t3(2,i) = 1000.0d0
         t1_1(1,i) = 1000.0d0
         t1_1(2,i) = 1000.0d0
         t2_1(1,i) = 1000.0d0
         t2_1(2,i) = 1000.0d0
         t3_1(1,i) = 1000.0d0
         t3_1(2,i) = 1000.0d0
         t1_2(1,i) = 1000.0d0
         t1_2(2,i) = 1000.0d0
         t2_2(1,i) = 1000.0d0
         t2_2(2,i) = 1000.0d0
         t3_2(1,i) = 1000.0d0
         t3_2(2,i) = 1000.0d0
      end do
      do i = 1, 5
         do j = 1, 500
            eqclass(j,i) = 1000
         end do
      end do
      do i = 1, 6
         do j = 1, maxtyp
            mmffarom(j,i) = 0
            mmffaromc(j,i) = 0
            mmffaroma(j,i) = 0
         end do
      end do
c
c     set default control parameters for local geometry terms
c
      bndtyp_default = 'HARMONIC'
      bndunit = 1.0d0
      cbnd = 0.0d0
      qbnd = 0.0d0
      angunit = 1.0d0 / radian**2
      cang = 0.0d0
      qang = 0.0d0
      pang = 0.0d0
      sang = 0.0d0
      stbnunit = 1.0d0 / radian
      ureyunit = 1.0d0
      cury = 0.0d0
      qury = 0.0d0
      aaunit = 1.0d0 / radian**2
      opbtyp = 'W-D-C'
      opbunit = 1.0d0 / radian**2
      copb = 0.0d0
      qopb = 0.0d0
      popb = 0.0d0
      sopb = 0.0d0
      opdunit = 1.0d0
      copd = 0.0d0
      qopd = 0.0d0
      popd = 0.0d0
      sopd = 0.0d0
      idihunit = 1.0d0 / radian**2
      itorunit = 1.0d0
      torsunit = 1.0d0
      ptorunit = 1.0d0
      storunit = 1.0d0
      atorunit = 1.0d0
      atorunit = 1.0d0 / radian
      ttorunit = 1.0d0
c
c     set default control parameters for van der Waals terms
c
      vdwindex = 'CLASS'
      vdwtyp = 'LENNARD-JONES'
      radrule = 'ARITHMETIC'
      radtyp = 'R-MIN'
      radsiz = 'RADIUS'
      epsrule = 'GEOMETRIC'
      gausstyp = 'NONE'
      ngauss = 0
      abuck = 0.0d0
      bbuck = 0.0d0
      cbuck = 0.0d0
      ghal = 0.12d0
      dhal = 0.07d0
      v2scale = 0.0d0
      v3scale = 0.0d0
      v4scale = 1.0d0
      v5scale = 1.0d0
      use_vcorr = .false.
c
c     set default control parameters for repulsion terms
c
      r2scale = 0.0d0
      r3scale = 0.0d0
      r4scale = 1.0d0
      r5scale = 1.0d0
c
c     set default control parameters for charge-charge terms
c
      electric = coulomb
      dielec = 1.0d0
      ebuffer = 0.0d0
      c2scale = 0.0d0
      c3scale = 0.0d0
      c4scale = 1.0d0
      c5scale = 1.0d0
      neutnbr = .false.
      neutcut = .false.
c
c     set default control parameters for polarizable multipoles
c
      pentyp = 'GORDON1'
      m2scale = 0.0d0
      m3scale = 0.0d0
      m4scale = 1.0d0
      m5scale = 1.0d0
      p2scale = 0.0d0
      p3scale = 0.0d0
      p4scale = 1.0d0
      p5scale = 1.0d0
      p2iscale = 0.0d0
      p3iscale = 0.0d0
      p4iscale = 0.5d0
      p5iscale = 1.0d0
c
c     set default control parameters for polarizable multipoles
c
      m2scale = 0.0d0
      m3scale = 0.0d0
      m4scale = 1.0d0
      m5scale = 1.0d0
      p2scale = 0.0d0
      p3scale = 0.0d0
      p4scale = 1.0d0
      p5scale = 1.0d0
      p41scale = 0.5d0
c
c     set default control parameters for induced dipoles
c
      poltyp = 'MUTUAL'
      politer = 500
      polprt = 0
      polalg = 5
      polalgshort = 5
      polgsf = 0
      polff  = 0
      tcgprec = .true.
      tcgguess = .false.
      tcgpeek = .true.
      tcgprecshort = .true.
      tcgguessshort = .false.
      tcgpeekshort = .false.
      tcgorder = 2
      tcgordershort = 1
      tcgomega = 1.0d0
      tcgomegafit = .false.
      omegafitfreq = 1000
      poleps = 0.00001d0
      d1scale = 0.0d0
      d2scale = 1.0d0
      d3scale = 1.0d0
      d4scale = 1.0d0
      u1scale = 1.0d0
      u2scale = 1.0d0
      u3scale = 1.0d0
      u4scale = 1.0d0
      w2scale = 1.0d0
      w3scale = 1.0d0
      w4scale = 1.0d0
      w5scale = 1.0d0
      use_chgpen = .false.
      use_thole = .true.
      use_tholed = .false.
      dpequal = .false.
c
c     set default divide and conquer ji/diis parameters
c
      clsttype = 2
      precomp = 0
      nocomdiis = 0
      natprblk = 60
c
c     set default control parameters for charge transfer terms
c
      ctrntyp = 'SEPARATE'
      return
      end
