############################################################################
# Usage:
#  SIM_AC_CHECK_OGGVORBIS([ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND]])
#
#  Try to find the OggVorbis development system. If it is found, these
#  shell variables are set:
#
#    $sim_ac_oggvorbis_cppflags (extra flags the compiler needs for oggvorbis)
#    $sim_ac_oggvorbis_ldflags  (extra flags the linker needs for oggvorbis)
#    $sim_ac_oggvorbis_libs     (link libraries the linker needs for oggvorbis)
#
#  The CPPFLAGS, LDFLAGS and LIBS flags will also be modified accordingly.
#  In addition, the variable $sim_ac_oggvorbis_avail is set to "yes" if the
#  oggvorbis development system is found.
#
#  Download Oggvorbis from http://www.xiph.org/ogg/vorbis/index.html
#
# Author: Thomas Hammer, <thammer@sim.no>

AC_DEFUN([SIM_AC_CHECK_OGGVORBIS], [

AC_ARG_WITH(
  [oggvorbis],
  AC_HELP_STRING([--with-oggvorbis=DIR],
                 [oggvorbis installation directory]),
  [],
  [with_oggvorbis=yes])

sim_ac_oggvorbis_avail=no

if test x"$with_oggvorbis" != xno; then
  if test x"$with_oggvorbis" != xyes; then
    sim_ac_oggvorbis_cppflags="-I${with_oggvorbis}/include"
    sim_ac_oggvorbis_ldflags="-L${with_oggvorbis}/lib"
  fi
  sim_ac_oggvorbis_libs="-logg -lvorbis -lvorbisfile"

  sim_ac_save_cppflags=$CPPFLAGS
  sim_ac_save_ldflags=$LDFLAGS
  sim_ac_save_libs=$LIBS

  CPPFLAGS="$CPPFLAGS $sim_ac_oggvorbis_cppflags"
  LDFLAGS="$LDFLAGS $sim_ac_oggvorbis_ldflags"
  LIBS="$sim_ac_oggvorbis_libs $LIBS"

  AC_CACHE_CHECK(
    [for Ogg Vorbis],
    sim_cv_lib_oggvorbis_avail,
    [AC_TRY_LINK([#include <vorbis/vorbisfile.h>],
                 [(void)ov_open(NULL, NULL, NULL, 0);],
                 [sim_cv_lib_oggvorbis_avail=yes],
                 [sim_cv_lib_oggvorbis_avail=no])])

  if test x"$sim_cv_lib_oggvorbis_avail" = xyes; then
    sim_ac_oggvorbis_avail=yes
    $1
  else
    CPPFLAGS=$sim_ac_save_cppflags
    LDFLAGS=$sim_ac_save_ldflags
    LIBS=$sim_ac_save_libs
    $2
  fi
fi
])
