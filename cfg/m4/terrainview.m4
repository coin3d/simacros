# **************************************************************************
# SIM_AC_HAVE_TERRAINVIEW_IFELSE( IF-FOUND, IF-NOT-FOUND )
#
# Variables:
#   sim_ac_have_terrainview
#   sim_ac_terrainview_cppflags
#   sim_ac_terrainview_ldflags
#   sim_ac_terrainview_libs
#
# Authors:
#   Peder Blekken <pederb@coin3d.org>, based on check_zlib.m4

# Todo:
# - use AS_UNSET to unset internal variables to avoid polluting the environment
#

# **************************************************************************

AC_DEFUN([SIM_AC_HAVE_TERRAINVIEW_IFELSE],
[: ${sim_ac_have_terrainview=false}
AC_MSG_CHECKING([for TerrainView])
AC_ARG_WITH(
  [terrainview],
  [AC_HELP_STRING([--with-terrainview=PATH], [enable/disable TerrainView support])],
  [case $withval in
  yes | "") sim_ac_want_terrainview=true ;;
  no)       sim_ac_want_terrainview=false ;;
  *)        sim_ac_want_terrainview=true
            sim_ac_terrainview_path=$withval ;;
  esac],
  [sim_ac_want_terrainview=true])
case $sim_ac_want_terrainview in
true)
  $sim_ac_have_terrainview && break
  sim_ac_terrainview_save_CPPFLAGS=$CPPFLAGS
  sim_ac_terrainview_save_LDFLAGS=$LDFLAGS
  sim_ac_terrainview_save_LIBS=$LIBS
  sim_ac_terrainview_debug=false
  test -n "`echo -- $CPPFLAGS $CFLAGS $CXXFLAGS | grep -- '-g\\>'`" &&
    sim_ac_terrainview_debug=true
  # test -z "$sim_ac_terrainview_path" -a x"$prefix" != xNONE &&
  #   sim_ac_terrainview_path=$prefix
  sim_ac_terrainview_name=TerrainView
  if test -n "$sim_ac_terrainview_path"; then
    for sim_ac_terrainview_candidate in \
      `( ls $sim_ac_terrainview_path/lib/TerrainView*.lib;
         ls $sim_ac_terrainview_path/lib/TerrainView*d.lib ) 2>/dev/null`
    do
      case $sim_ac_terrainview_candidate in
      *d.lib)
        $sim_ac_terrainview_debug &&
          sim_ac_terrainview_name=`basename $sim_ac_terrainview_candidate .lib` ;;
      *.lib)
        sim_ac_terrainview_name=`basename $sim_ac_terrainview_candidate .lib` ;;
      esac
    done
    sim_ac_terrainview_cppflags="-I$sim_ac_terrainview_path/include"
    CPPFLAGS="$CPPFLAGS $sim_ac_terrainview_cppflags"
    sim_ac_terrainview_ldflags="-L$sim_ac_terrainview_path/lib"
    LDFLAGS="$LDFLAGS $sim_ac_terrainview_ldflags"
    # unset sim_ac_terrainview_candidate
    # unset sim_ac_terrainview_path
  fi
  sim_ac_terrainview_libs="-l$sim_ac_terrainview_name"
  LIBS="$sim_ac_terrainview_libs $LIBS"
  AC_TRY_LINK(
    [#include <TerrainView/clodapi.h>],
    [clod_init();],
    [sim_ac_have_terrainview=true])
  CPPFLAGS=$sim_ac_terrainview_save_CPPFLAGS
  LDFLAGS=$sim_ac_terrainview_save_LDFLAGS
  LIBS=$sim_ac_terrainview_save_LIBS
  # unset sim_ac_terrainview_debug
  # unset sim_ac_terrainview_name
  # unset sim_ac_terrainview_save_CPPFLAGS
  # unset sim_ac_terrainview_save_LDFLAGS
  # unset sim_ac_terrainview_save_LIBS
  ;;
esac
if $sim_ac_want_terrainview; then
  if $sim_ac_have_terrainview; then
    AC_MSG_RESULT([success ($sim_ac_terrainview_libs)])
    $1
  else
    AC_MSG_RESULT([failure])
    $2
  fi
else
  AC_MSG_RESULT([disabled])
  $2
fi
# unset sim_ac_want_terrainview
])

# EOF **********************************************************************
