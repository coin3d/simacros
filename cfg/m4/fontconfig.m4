# **************************************************************************
# SIM_AC_CHECK_HEADER_FONTCONFIG([IF-FOUND], [IF-NOT-FOUND])
#
# This macro detects how to include the Fontconfig header files, and gives you
# the necessary CPPFLAGS in $sim_ac_fontconfig_cppflags, and also sets the 
# config.h define HAVE_FONTCONFIG_H if one of them is found.

AC_DEFUN([SIM_AC_CHECK_HEADER_FONTCONFIG],
[sim_ac_fontconfig_header_avail=false
AC_MSG_CHECKING([how to include fontconfig.h])
if test x"$with_fontconfig" != x"no"; then
  sim_ac_fontconfig_save_CPPFLAGS=$CPPFLAGS
  sim_ac_fontconfig_cppflags=

  if test x"$with_fontconfig" != xyes && test x"$with_fontconfig" != x""; then
    sim_ac_fontconfig_cppflags="-I${with_fontconfig}/include -I${with_fontconfig}/include/fontconfig"
  fi

  CPPFLAGS="$CPPFLAGS $sim_ac_fontconfig_cppflags"

  SIM_AC_CHECK_HEADER_SILENT([fontconfig/fontconfig.h], [
    sim_ac_fontconfig_header_avail=true
    sim_ac_fontconfig_header=fontconfig.h
    AC_DEFINE([HAVE_FONTCONFIG_H], 1, [define that the Fontconfig header is available])
  ])

  CPPFLAGS="$sim_ac_fontconfig_save_CPPFLAGS"
  if $sim_ac_fontconfig_header_avail; then
    if test x"$sim_ac_fontconfig_cppflags" = x""; then
      AC_MSG_RESULT([@%:@include <$sim_ac_fontconfig_header>])
    else
      AC_MSG_RESULT([$sim_ac_fontconfig_cppflags, @%:@include <$sim_ac_fontconfig_header>])
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
])# SIM_AC_CHECK_HEADER_FONTCONFIG


# **************************************************************************
# SIM_AC_HAVE_FONTCONFIG_IFELSE( IF-FOUND, IF-NOT-FOUND )
#
#  Try to find the Fontconfig development system. If it is found, these
#  shell variables are set:
#
#    $sim_ac_fontconfig_cppflags (extra flags the compiler needs for fontconfig)
#    $sim_ac_fontconfig_ldflags  (extra flags the linker needs for fontconfig)
#    $sim_ac_fontconfig_libs     (link libraries the linker needs for fontconfig)
#
#  The CPPFLAGS, LDFLAGS and LIBS flags will also be modified accordingly.
#  In addition, the variable $sim_ac_fontconfig_avail is set to "yes" if the
#  fontconfig development system is found.
#
#  Download Fontconfig from www.fontconfig.org
#
# Authors:
#   Tamer Fahmy <tamer@tammura.at>
#

AC_DEFUN([SIM_AC_HAVE_FONTCONFIG_IFELSE],
[: ${sim_ac_have_fontconfig=false}
AC_ARG_WITH(
  [fontconfig],
  [AC_HELP_STRING([--with-fontconfig=PATH], [enable/disable Fontconfig support])],
  [case $withval in
  yes | "") sim_ac_want_fontconfig=true ;;
  no)       sim_ac_want_fontconfig=false ;;
  *)        sim_ac_want_fontconfig=true
            sim_ac_fontconfig_path=$withval ;;
  esac],
  [sim_ac_want_fontconfig=true])
case $sim_ac_want_fontconfig in
true)
  $sim_ac_have_fontconfig && break
  sim_ac_fontconfig_save_CPPFLAGS=$CPPFLAGS
  sim_ac_fontconfig_save_LDFLAGS=$LDFLAGS
  sim_ac_fontconfig_save_LIBS=$LIBS

  sim_ac_fontconfig_debug=false
  test -n "`echo -- $CPPFLAGS $CFLAGS $CXXFLAGS | grep -- '-g\\>'`" &&
    sim_ac_fontconfig_debug=true
  # test -z "$sim_ac_fontconfig_path" -a x"$prefix" != xNONE &&
  #   sim_ac_fontconfig_path=$prefix
  sim_ac_fontconfig_name=fontconfig
  sim_ac_fontconfig_libs="-l$sim_ac_fontconfig_name"
  if test -n "$sim_ac_fontconfig_path"; then
    for sim_ac_fontconfig_candidate in \
      `( ls $sim_ac_fontconfig_path/lib/fontconfig*.lib;
         ls $sim_ac_fontconfig_path/lib/fontconfig*d.lib; 
         ls $sim_ac_fontconfig_path/lib/libfontconfig*.lib; 
         ls $sim_ac_fontconfig_path/lib/libfontconfig*d.lib ) 2>/dev/null`
    do
      case $sim_ac_fontconfig_candidate in
      *d.lib)
        $sim_ac_fontconfig_debug &&
          sim_ac_fontconfig_name=`basename $sim_ac_fontconfig_candidate .lib` ;;
      *.lib)
        sim_ac_fontconfig_name=`basename $sim_ac_fontconfig_candidate .lib` ;;
      esac
    done
    sim_ac_fontconfig_cppflags="-I$sim_ac_fontconfig_path/include"
    CPPFLAGS="$CPPFLAGS $sim_ac_fontconfig_cppflags"
    sim_ac_fontconfig_ldflags="-L$sim_ac_fontconfig_path/lib"
    LDFLAGS="$LDFLAGS $sim_ac_fontconfig_ldflags"
    sim_ac_fontconfig_libs="-l$sim_ac_fontconfig_name"
    # unset sim_ac_fontconfig_candidate
    # unset sim_ac_fontconfig_path
  fi

  SIM_AC_CHECK_HEADER_FONTCONFIG([CPPFLAGS="$CPPFLAGS $sim_ac_fontconfig_cppflags"])

  AC_MSG_CHECKING([for Fontconfig])
  LIBS="$sim_ac_fontconfig_libs $LIBS"
  AC_TRY_LINK(
    [#include <fontconfig/fontconfig.h>],
    [FcGetVersion();],
    [sim_ac_have_fontconfig=true])

  CPPFLAGS=$sim_ac_fontconfig_save_CPPFLAGS
  LDFLAGS=$sim_ac_fontconfig_save_LDFLAGS
  LIBS=$sim_ac_fontconfig_save_LIBS
  # unset sim_ac_fontconfig_debug
  # unset sim_ac_fontconfig_name
  # unset sim_ac_fontconfig_save_CPPFLAGS
  # unset sim_ac_fontconfig_save_LDFLAGS
  # unset sim_ac_fontconfig_save_LIBS
  ;;
esac
if $sim_ac_want_fontconfig; then
  if $sim_ac_have_fontconfig; then
    AC_MSG_RESULT([success ($sim_ac_fontconfig_libs)])
    $1
  else
    AC_MSG_RESULT([failure])
    $2
  fi
else
  AC_MSG_RESULT([disabled])
  $2
fi
# unset sim_ac_want_fontconfig
])
