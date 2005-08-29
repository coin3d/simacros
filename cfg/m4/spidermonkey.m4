# **************************************************************************
# SIM_AC_CHECK_HEADER_SPIDERMONKEY([IF-FOUND], [IF-NOT-FOUND])
#
# This macro detects how to include the SpiderMonkey header files, and gives you
# the necessary CPPFLAGS in $sim_ac_spidermonkey_cppflags, and also sets the 
# config.h define HAVE_SPIDERMONKEY_H if one of them is found.

AC_DEFUN([SIM_AC_CHECK_HEADER_SPIDERMONKEY],
[sim_ac_spidermonkey_header_avail=false
AC_MSG_CHECKING([how to include spidermonkey's jsapi.h])
if test x"$with_spidermonkey" != x"no"; then
  sim_ac_spidermonkey_save_CPPFLAGS=$CPPFLAGS

  if test x"$with_spidermonkey" != xyes && test x"$with_spidermonkey" != x""; then
    sim_ac_spidermonkey_cppflags="-I${with_spidermonkey}/include -I${with_spidermonkey}/include/smjs -DXP_UNIX=1"
  fi

  CPPFLAGS="$CPPFLAGS $sim_ac_spidermonkey_cppflags -DCROSS_COMPILE=1"

  SIM_AC_CHECK_HEADER_SILENT([smjs/jsapi.h], [
    sim_ac_spidermonkey_header_avail=true
    sim_ac_spidermonkey_header=jsapi.h
    AC_DEFINE([HAVE_SPIDERMONKEY_H], 1, [define that the Spidermonkey header is available])
  ])

  CPPFLAGS="$sim_ac_spidermonkey_save_CPPFLAGS"
  if $sim_ac_spidermonkey_header_avail; then
    if test x"$sim_ac_spidermonkey_cppflags" = x""; then
      AC_MSG_RESULT([@%:@include <$sim_ac_spidermonkey_header>])
    else
      AC_MSG_RESULT([$sim_ac_spidermonkey_cppflags, @%:@include <$sim_ac_spidermonkey_header>])
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
])# SIM_AC_CHECK_HEADER_SPIDERMONKEY


# **************************************************************************
# SIM_AC_HAVE_SPIDERMONKEY_IFELSE( IF-FOUND, IF-NOT-FOUND )
#
#  Try to find the Spidermonkey development system. If it is found, these
#  shell variables are set:
#
#    $sim_ac_spidermonkey_cppflags (extra flags the compiler needs for spidermonkey)
#    $sim_ac_spidermonkey_ldflags  (extra flags the linker needs for spidermonkey)
#    $sim_ac_spidermonkey_libs     (link libraries the linker needs for spidermonkey)
#
#  The CPPFLAGS, LDFLAGS and LIBS flags will also be modified accordingly.
#  In addition, the variable $sim_ac_spidermonkey_avail is set to "yes" if the
#  spidermonkey development system is found.
#
#  Download SpiderMonkey from www.mozilla.org/js/spidermonkey
#
# Authors:
#   Øystein Handegard <handegar@sim.no> (heavily based on Tamer Fahmy's Fontconfig.m4 script)
#

AC_DEFUN([SIM_AC_HAVE_SPIDERMONKEY_IFELSE],
[: ${sim_ac_have_spidermonkey=false}
AC_ARG_WITH(
  [spidermonkey],
  [AC_HELP_STRING([--with-spidermonkey=PATH], [enable/disable Spidermonkey support])],
  [case $withval in
  yes | "") sim_ac_want_spidermonkey=true ;;
  no)       sim_ac_want_spidermonkey=false ;;
  *)        sim_ac_want_spidermonkey=true
            sim_ac_spidermonkey_path=$withval ;;
  esac],
  [sim_ac_want_spidermonkey=true])
case $sim_ac_want_spidermonkey in
true)
  $sim_ac_have_spidermonkey && break
  sim_ac_spidermonkey_save_CPPFLAGS=$CPPFLAGS
  sim_ac_spidermonkey_save_LDFLAGS=$LDFLAGS
  sim_ac_spidermonkey_save_LIBS=$LIBS

  sim_ac_spidermonkey_debug=false
  test -n "`echo -- $CPPFLAGS $CFLAGS $CXXFLAGS | grep -- '-g\\>'`" &&
    sim_ac_spidermonkey_debug=true

  sim_ac_spidermonkey_name=smjs
  sim_ac_spidermonkey_libs="-l$sim_ac_spidermonkey_name"

  if test -n "$sim_ac_spidermonkey_path"; then
    for sim_ac_spidermonkey_candidate in \
      `( ls $sim_ac_spidermonkey_path/lib/smjs*.lib;
         ls $sim_ac_spidermonkey_path/lib/smjs*d.lib; 
         ls $sim_ac_spidermonkey_path/lib/js*.lib;     
         ls $sim_ac_spidermonkey_path/lib/js*d.lib;     
         ls $sim_ac_spidermonkey_path/lib/libsmjs*.lib; 
         ls $sim_ac_spidermonkey_path/lib/libsmjs*d.lib 
         ls $sim_ac_spidermonkey_path/lib/libjs*.lib; 
         ls $sim_ac_spidermonkey_path/lib/libjs*d.lib; ) 2>/dev/null`
    do
      case $sim_ac_spidermonkey_candidate in
      *d.lib)
        $sim_ac_spidermonkey_debug &&
          sim_ac_spidermonkey_name=`basename $sim_ac_spidermonkey_candidate .lib` ;;
      *.lib)
        sim_ac_spidermonkey_name=`basename $sim_ac_spidermonkey_candidate .lib` ;;
      esac
    done
    sim_ac_spidermonkey_cppflags="$sim_ac_spidermonkey_cppflags -I$sim_ac_spidermonkey_path/include"
    CPPFLAGS="$CPPFLAGS $sim_ac_spidermonkey_cppflags"
    sim_ac_spidermonkey_ldflags="-L$sim_ac_spidermonkey_path/lib"
    LDFLAGS="$LDFLAGS $sim_ac_spidermonkey_ldflags"
    sim_ac_spidermonkey_libs="-l$sim_ac_spidermonkey_name"
    # unset sim_ac_spidermonkey_candidate
    # unset sim_ac_spidermonkey_path
  fi

  SIM_AC_CHECK_HEADER_SPIDERMONKEY([CPPFLAGS="$CPPFLAGS $sim_ac_spidermonkey_cppflags"])

  AC_MSG_CHECKING([for Spidermonkey])
  LIBS="$sim_ac_spidermonkey_libs $LIBS"
  AC_TRY_LINK(
    [#define CROSS_COMPILE 1
     #include <smjs/jsapi.h>],
    [JSVersion ver = JS_GetVersion((void *) 0);],
    [sim_ac_have_spidermonkey=true])

  CPPFLAGS=$sim_ac_spidermonkey_save_CPPFLAGS
  LDFLAGS=$sim_ac_spidermonkey_save_LDFLAGS
  LIBS=$sim_ac_spidermonkey_save_LIBS
  # unset sim_ac_spidermonkey_debug
  # unset sim_ac_spidermonkey_name
  # unset sim_ac_spidermonkey_save_CPPFLAGS
  # unset sim_ac_spidermonkey_save_LDFLAGS
  # unset sim_ac_spidermonkey_save_LIBS
  ;;
esac
if $sim_ac_want_spidermonkey; then
  if $sim_ac_have_spidermonkey; then
    AC_MSG_RESULT([success ($sim_ac_spidermonkey_libs)])
    $1
  else
    AC_MSG_RESULT([failure])
    $2
  fi
else
  AC_MSG_RESULT([disabled])
  $2
fi
# unset sim_ac_want_spidermonkey
])
