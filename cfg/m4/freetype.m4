# **************************************************************************
# SIM_AC_CHECK_HEADER_FREETYPE([IF-FOUND], [IF-NOT-FOUND])
#
# This macro detects how to include the FreeType header files, and gives you
# the necessary CPPFLAGS in $sim_ac_freetype_cppflags, and also sets the
# config.h define HAVE_FREETYPE_H if one of them is found.

AC_DEFUN([SIM_AC_CHECK_HEADER_FREETYPE],
[sim_ac_freetype_header_avail=false
AC_MSG_CHECKING([how to include ft2build.h])
if test x"$with_freetype" != x"no"; then
  sim_ac_freetype_save_CPPFLAGS=$CPPFLAGS
  sim_ac_freetype_cppflags=

  if test x"$with_freetype" != xyes && test x"$with_freetype" != x""; then
    sim_ac_freetype_cppflags="-I${with_freetype}/include -I${with_freetype}/include/freetype2"
  fi

  CPPFLAGS="$CPPFLAGS $sim_ac_freetype_cppflags"

  SIM_AC_CHECK_HEADER_SILENT([ft2build.h], [
    sim_ac_freetype_header_avail=true
    sim_ac_freetype_header=ft2build.h
    AC_DEFINE([HAVE_FREETYPE_H], 1, [define that the FreeType header is available])
  ])

  CPPFLAGS="$sim_ac_freetype_save_CPPFLAGS"
  if $sim_ac_freetype_header_avail; then
    if test x"$sim_ac_freetype_cppflags" = x""; then
      AC_MSG_RESULT([@%:@include <$sim_ac_freetype_header>])
    else
      AC_MSG_RESULT([$sim_ac_freetype_cppflags, @%:@include <$sim_ac_freetype_header>])
    fi
    $1
  else
    AC_MSG_RESULT([not found])
    $2
  fi
else
  AC_MSG_RESULT([disabled])
  $2
fi
])# SIM_AC_CHECK_HEADER_FREETYPE


############################################################################
# Usage:
#  SIM_AC_HAVE_FREETYPE_IFELSE ( IF-FOUND, IF-NOT-FOUND )
#
#  Try to find the Freetype development system. If it is found, these
#  shell variables are set:
#
#    $sim_ac_freetype_cppflags (extra flags the compiler needs for freetype)
#    $sim_ac_freetype_ldflags  (extra flags the linker needs for freetype)
#    $sim_ac_freetype_libs     (link libraries the linker needs for freetype)
#
#  The CPPFLAGS, LDFLAGS and LIBS flags will also be modified accordingly.
#  In addition, the variable $sim_ac_freetype_avail is set to "yes" if the
#  freetype development system is found.
#
#  Download Freetype from www.freetype.org
#
# Authors: Pål-Robert Engnæs, <preng@sim.no>
#          <Code copied from check_openal.m4>
#

AC_DEFUN([SIM_AC_HAVE_FREETYPE_IFELSE],
[: ${sim_ac_have_freetype=false}
AC_ARG_WITH(
  [freetype],
  [AC_HELP_STRING([--with-freetype=PATH], [enable/disable Freetype support])],
  [case $withval in
  yes | "") sim_ac_want_freetype=true ;;
  no)       sim_ac_want_freetype=false ;;
  *)        sim_ac_want_freetype=true
            sim_ac_freetype_path=$withval ;;
  esac],
  [sim_ac_want_freetype=true])
case $sim_ac_want_freetype in
true)
  $sim_ac_have_freetype && break
  sim_ac_freetype_save_CPPFLAGS=$CPPFLAGS
  sim_ac_freetype_save_LDFLAGS=$LDFLAGS
  sim_ac_freetype_save_LIBS=$LIBS

  sim_ac_freetype_debug=false
  test -n "`echo -- $CPPFLAGS $CFLAGS $CXXFLAGS | grep -- '-g\\>'`" &&
    sim_ac_freetype_debug=true
  # test -z "$sim_ac_freetype_path" -a x"$prefix" != xNONE &&
  #   sim_ac_freetype_path=$prefix
  sim_ac_freetype_name=freetype
  sim_ac_freetype_libs="-l$sim_ac_freetype_name"
  if test -n "$sim_ac_freetype_path"; then
    for sim_ac_freetype_candidate in \
      `( ls $sim_ac_freetype_path/lib/freetype*.lib;
         ls $sim_ac_freetype_path/lib/freetype*d.lib;
         ls $sim_ac_freetype_path/lib/libfreetype*.lib;
         ls $sim_ac_freetype_path/lib/libfreetype*d.lib ) 2>/dev/null`
    do
      case $sim_ac_freetype_candidate in
      *d.lib)
        $sim_ac_freetype_debug &&
          sim_ac_freetype_name=`basename $sim_ac_freetype_candidate .lib` ;;
      *.lib)
        sim_ac_freetype_name=`basename $sim_ac_freetype_candidate .lib` ;;
      esac
    done
    sim_ac_freetype_cppflags="-I$sim_ac_freetype_path/include"
    CPPFLAGS="$CPPFLAGS $sim_ac_freetype_cppflags"
    sim_ac_freetype_ldflags="-L$sim_ac_freetype_path/lib"
    LDFLAGS="$LDFLAGS $sim_ac_freetype_ldflags"
    sim_ac_freetype_libs="-l$sim_ac_freetype_name"
    # unset sim_ac_freetype_candidate
    # unset sim_ac_freetype_path
  fi

  SIM_AC_CHECK_HEADER_FREETYPE([CPPFLAGS="$CPPFLAGS $sim_ac_freetype_cppflags"])

  AC_MSG_CHECKING([for FreeType])
  LIBS="$sim_ac_freetype_libs $LIBS"
  AC_TRY_LINK(
    [#include <ft2build.h>
     #include FT_FREETYPE_H],
    [FT_Library lib;
     unsigned long check_for_required_constants = FT_ENCODING_ADOBE_LATIN_1;
     FT_Init_FreeType(&lib);],
    [sim_ac_have_freetype=true])

  CPPFLAGS=$sim_ac_freetype_save_CPPFLAGS
  LDFLAGS=$sim_ac_freetype_save_LDFLAGS
  LIBS=$sim_ac_freetype_save_LIBS
  # unset sim_ac_freetype_debug
  # unset sim_ac_freetype_name
  # unset sim_ac_freetype_save_CPPFLAGS
  # unset sim_ac_freetype_save_LDFLAGS
  # unset sim_ac_freetype_save_LIBS
  ;;
esac
if $sim_ac_want_freetype; then
  if $sim_ac_have_freetype; then
    AC_MSG_RESULT([success ($sim_ac_freetype_libs)])
    $1
  else
    AC_MSG_RESULT([failure])
    $2
  fi
else
  AC_MSG_RESULT([disabled])
  $2
fi
# unset sim_ac_want_freetype
])
