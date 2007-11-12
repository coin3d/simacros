# **************************************************************************
# SIM_AC_HAVE_BOOST_FILESYSTEM_IFELSE( IF-FOUND, IF-NOT-FOUND )
#
# Variables:
#   sim_ac_have_boost_filesystem
#   sim_ac_boost_filesystem_cppflags
#   sim_ac_boost_filesystem_ldflags
#   sim_ac_boost_filesystem_libs
#
# Authors:
#   Peder Blekken <pederb@coin3d.org>, based on check_zlib.m4

# Todo:
# - use AS_UNSET to unset internal variables to avoid polluting the environment
#

# **************************************************************************

AC_DEFUN([SIM_AC_HAVE_BOOST_FILESYSTEM_IFELSE],
[: ${sim_ac_have_boost_filesystem=false}
AC_MSG_CHECKING([for BOOST_FILESYSTEM])
AC_ARG_WITH(
  [boost_filesystem],
  [AC_HELP_STRING([--with-boost_filesystem=PATH], [enable/disable BOOST_FILESYSTEM support])],
  [case $withval in
  yes | "") sim_ac_want_boost_filesystem=true ;;
  no)       sim_ac_want_boost_filesystem=false ;;
  *)        sim_ac_want_boost_filesystem=true
            sim_ac_boost_filesystem_path=$withval ;;
  esac],
  [sim_ac_want_boost_filesystem=true])
case $sim_ac_want_boost_filesystem in
true)
  $sim_ac_have_boost_filesystem && break
  sim_ac_boost_filesystem_save_CPPFLAGS=$CPPFLAGS
  sim_ac_boost_filesystem_save_LDFLAGS=$LDFLAGS
  sim_ac_boost_filesystem_save_LIBS=$LIBS
  sim_ac_boost_filesystem_debug=false
  test -n "`echo -- $CPPFLAGS $CFLAGS $CXXFLAGS | grep -- '-g\\>'`" &&
    sim_ac_boost_filesystem_debug=true
  # test -z "$sim_ac_boost_filesystem_path" -a x"$prefix" != xNONE &&
  #   sim_ac_boost_filesystem_path=$prefix
  sim_ac_boost_filesystem_name=boost_filesystem
  if test -n "$sim_ac_boost_filesystem_path"; then
    for sim_ac_boost_filesystem_candidate in \
      `( ls $sim_ac_boost_filesystem_path/lib/boost_filesystem*.lib;
         ls $sim_ac_boost_filesystem_path/lib/boost_filesystem*d.lib ) 2>/dev/null`
    do
      case $sim_ac_boost_filesystem_candidate in
      *d.lib)
        $sim_ac_boost_filesystem_debug &&
          sim_ac_boost_filesystem_name=`basename $sim_ac_boost_filesystem_candidate .lib` ;;
      *.lib)
        sim_ac_boost_filesystem_name=`basename $sim_ac_boost_filesystem_candidate .lib` ;;
      esac
    done
    sim_ac_boost_filesystem_cppflags="-I$sim_ac_boost_filesystem_path/include"
    CPPFLAGS="$CPPFLAGS $sim_ac_boost_filesystem_cppflags"
    sim_ac_boost_filesystem_ldflags="-L$sim_ac_boost_filesystem_path/lib"
    LDFLAGS="$LDFLAGS $sim_ac_boost_filesystem_ldflags"
    # unset sim_ac_boost_filesystem_candidate
    # unset sim_ac_boost_filesystem_path
  fi
  sim_ac_boost_filesystem_libs="-l$sim_ac_boost_filesystem_name"
  LIBS="$sim_ac_boost_filesystem_libs $LIBS"
  AC_TRY_LINK(
    [#include <boost/filesystem/path.hpp>],
    [boost::filesystem::path path(".");],
    [sim_ac_have_boost_filesystem=true])
  CPPFLAGS=$sim_ac_boost_filesystem_save_CPPFLAGS
  LDFLAGS=$sim_ac_boost_filesystem_save_LDFLAGS
  LIBS=$sim_ac_boost_filesystem_save_LIBS
  # unset sim_ac_boost_filesystem_debug
  # unset sim_ac_boost_filesystem_name
  # unset sim_ac_boost_filesystem_save_CPPFLAGS
  # unset sim_ac_boost_filesystem_save_LDFLAGS
  # unset sim_ac_boost_filesystem_save_LIBS
  ;;
esac
if $sim_ac_want_boost_filesystem; then
  if $sim_ac_have_boost_filesystem; then
    AC_MSG_RESULT([success ($sim_ac_boost_filesystem_libs)])
    $1
  else
    AC_MSG_RESULT([failure])
    $2
  fi
else
  AC_MSG_RESULT([disabled])
  $2
fi
# unset sim_ac_want_boost_filesystem
])

# EOF **********************************************************************
