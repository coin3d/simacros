############################################################################
# Usage:
#  SIM_AC_CHECK_LIBSNDFILE([ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND]])
#
#  Try to find the libsndfile library. If it is found, these
#  shell variables are set:
#
#    $sim_ac_libsndfile_cppflags (extra flags the compiler needs for libsndfile)
#    $sim_ac_libsndfile_ldflags  (extra flags the linker needs for libsndfile)
#    $sim_ac_libsndfile_libs     (link libraries the linker needs for libsndfile)
#
#  The CPPFLAGS, LDFLAGS and LIBS flags will also be modified accordingly.
#  In addition, the variable $sim_ac_libsndfile_avail is set to "yes" if the
#  libsndfile development system is found.
#
#  Download libsndfile from http://www.zip.com.au/~erikd/libsndfile/
#
# Author: Thomas Hammer, <thammer@sim.no>

AC_DEFUN([SIM_AC_CHECK_LIBSNDFILE], [

AC_ARG_WITH(
  [libsndfile],
  AC_HELP_STRING([--with-libsndfile=DIR],
                 [libsndfile installation directory]),
  [],
  [with_libsndfile=yes])

sim_ac_libsndfile_avail=no

if test x"$with_libsndfile" != xno; then
  if test -d "${with_libsndfile}/include"; then
    sim_ac_libsndfile_cppflags="-I${with_libsndfile}/include"
    sim_ac_libsndfile_ldflags="-L${with_libsndfile}/lib"
    # binary distributions of libsndfile from at least 1.0.18 have the
    # libraries residing in the toplevel directory. 20090216 tamer.
    if ! test -d "${with_libsndfile}/lib"; then
      sim_ac_libsndfile_ldflags="-L${with_libsndfile}"
    fi
  else
    # According to thammer, this is the  directory layout in older
    # binary distributions of libsndfile for Windows. 20060307 kyrah
    if test x"$with_libsndfile" != xyes; then
      sim_ac_libsndfile_cppflags="-I${with_libsndfile}/src"
      sim_ac_libsndfile_ldflags="-L${with_libsndfile}"
    fi
  fi

  sim_ac_save_cppflags=$CPPFLAGS
  sim_ac_save_ldflags=$LDFLAGS
  sim_ac_save_libs=$LIBS

  CPPFLAGS="$CPPFLAGS $sim_ac_libsndfile_cppflags"
  LDFLAGS="$LDFLAGS $sim_ac_libsndfile_ldflags"

  AC_CACHE_CHECK(
    [for libsndfile],
    sim_cv_lib_libsndfile_avail,
    [
      sim_ac_lsf_libs="-lsndfile -lsndfile-1 -llibsndfile -llibsndfile-1"
      sim_ac_lsfchk_hit=false
      for sim_ac_lsf_lib in "" $sim_ac_lsf_libs; do
        if $sim_ac_lsfchk_hit; then :; else
          LIBS="$sim_ac_lsf_lib $sim_ac_save_libs"
          AC_TRY_LINK([#include <sndfile.h>],
                      [(void)sf_open(0, 0, 0);],
                      [
                        sim_ac_lsfchk_hit=true
                        LIBS="$sim_ac_lsf_lib $LIBS"
                        sim_cv_lib_libsndfile_avail=yes
                      ],
                      [sim_cv_lib_libsndfile_avail=no])
        fi
      done
    ]
  )

  if test x"$sim_cv_lib_libsndfile_avail" = xyes; then
    sim_ac_libsndfile_avail=yes
    $1
  else
    CPPFLAGS=$sim_ac_save_cppflags
    LDFLAGS=$sim_ac_save_ldflags
    LIBS=$sim_ac_save_libs
    $2
  fi
fi
])
