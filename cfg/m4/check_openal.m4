# **************************************************************************
# SIM_AC_CHECK_HEADER_AL([IF-FOUND], [IF-NOT-FOUND])
#
# This macro detects how to include the AL header file, and gives you
# the necessary CPPFLAGS in $sim_ac_al_cppflags, and also sets the 
# config.h defines HAVE_AL_AL_H or HAVE_OPENAL_AL_H if one of them is found.

AC_DEFUN([SIM_AC_CHECK_HEADER_AL],
[sim_ac_al_header_avail=false
AC_MSG_CHECKING([how to include al.h])
if test x"$with_openal" != x"no"; then
  sim_ac_al_save_CPPFLAGS=$CPPFLAGS
  sim_ac_al_cppflags=

  if test x"$with_openal" != xyes && test x"$with_openal" != x""; then
    sim_ac_al_cppflags="-I${with_openal}/include"
  fi

  CPPFLAGS="$CPPFLAGS $sim_ac_al_cppflags"

  SIM_AC_CHECK_HEADER_SILENT([AL/al.h], [
    sim_ac_al_header_avail=true
    sim_ac_al_header=AL/al.h
    AC_DEFINE([HAVE_AL_AL_H], 1, [define if the AL header should be
included as AL/al.h])
  ], [
    SIM_AC_CHECK_HEADER_SILENT([OpenAL/al.h], [
      sim_ac_al_header_avail=true
      sim_ac_al_header=OpenAL/al.h
      AC_DEFINE([HAVE_OPENAL_AL_H], 1, [define if the AL header should
be included as OpenAL/al.h])
    ])
  ])

  CPPFLAGS="$sim_ac_al_save_CPPFLAGS"
  if $sim_ac_al_header_avail; then
    if test x"$sim_ac_al_cppflags" = x""; then
      AC_MSG_RESULT([@%:@include <$sim_ac_al_header>])
    else
      AC_MSG_RESULT([$sim_ac_al_cppflags, @%:@include <$sim_ac_al_header>])
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
])# SIM_AC_CHECK_HEADER_AL


############################################################################
# Usage:
#  SIM_AC_HAVE_OPENAL_IFELSE ( IF-FOUND, IF-NOT-FOUND )
#
#  Try to find the OpenAL development system. If it is found, these
#  shell variables are set:
#
#    $sim_ac_openal_cppflags (extra flags the compiler needs for openal)
#    $sim_ac_openal_ldflags  (extra flags the linker needs for openal)
#    $sim_ac_openal_libs     (link libraries the linker needs for openal)
#
#  The CPPFLAGS, LDFLAGS and LIBS flags will also be modified accordingly.
#  In addition, the variable $sim_ac_openal_avail is set to "yes" if the
#  openal development system is found.
#
#  Download OpenAL from www.openal.org
#
# Authors: Thomas Hammer, <thammer@sim.no>
#          Peder Blekken, <pederb@sim.no>
#          Karin Kosina,  <kyrah@sim.no>

AC_DEFUN([SIM_AC_HAVE_OPENAL_IFELSE],
[: ${sim_ac_have_openal=false}
AC_ARG_WITH(
  [openal],
  [AC_HELP_STRING([--with-openal=PATH], [enable/disable OpenAL support])],
  [case $withval in
  yes | "") sim_ac_want_openal=true ;;
  no)       sim_ac_want_openal=false ;;
  *)        sim_ac_want_openal=true
            sim_ac_openal_path=$withval ;;
  esac],
  [sim_ac_want_openal=true])
case $sim_ac_want_openal in
true)
  $sim_ac_have_openal && break
  sim_ac_openal_save_CPPFLAGS=$CPPFLAGS
  sim_ac_openal_save_LDFLAGS=$LDFLAGS
  sim_ac_openal_save_LIBS=$LIBS

case $host_os in
darwin*)
  sim_ac_openal_libs="-Wl,-framework,OpenAL" 
;;
*)
  sim_ac_openal_debug=false
  test -n "`echo -- $CPPFLAGS $CFLAGS $CXXFLAGS | grep -- '-g\\>'`" &&
    sim_ac_openal_debug=true
  # test -z "$sim_ac_openal_path" -a x"$prefix" != xNONE &&
  #   sim_ac_openal_path=$prefix
  sim_ac_openal_name=openal
  sim_ac_openal_libs="-l$sim_ac_openal_name"
  if test -n "$sim_ac_openal_path"; then
    for sim_ac_openal_candidate in \
      `( ls $sim_ac_openal_path/lib/openal*.lib;
         ls $sim_ac_openal_path/lib/openal*d.lib ) 2>/dev/null`
    do
      case $sim_ac_openal_candidate in
      *d.lib)
        $sim_ac_openal_debug &&
          sim_ac_openal_name=`basename $sim_ac_openal_candidate .lib` ;;
      *.lib)
        sim_ac_openal_name=`basename $sim_ac_openal_candidate .lib` ;;
      esac
    done
    sim_ac_openal_cppflags="-I$sim_ac_openal_path/include"
    CPPFLAGS="$CPPFLAGS $sim_ac_openal_cppflags"
    sim_ac_openal_ldflags="-L$sim_ac_openal_path/lib"
    LDFLAGS="$LDFLAGS $sim_ac_openal_ldflags"
    sim_ac_openal_libs="-l$sim_ac_openal_name"
    # unset sim_ac_openal_candidate
    # unset sim_ac_openal_path
  fi
;;
esac 

  SIM_AC_CHECK_HEADER_AL([CPPFLAGS="$CPPFLAGS $sim_ac_al_cppflags"],
                         [AC_MSG_WARN([could not find al.h])])

  AC_MSG_CHECKING([for OpenAL])
  LIBS="$sim_ac_openal_libs $LIBS"
  AC_TRY_LINK(
    [#ifdef HAVE_AL_AL_H
     #include <AL/al.h>
     #endif
     #ifdef HAVE_OPENAL_AL_H
     #include <OpenAL/al.h>
     #endif],
    [(void)alGetError();],
    [sim_ac_have_openal=true],
    [sim_ac_openal_libs=])

  CPPFLAGS=$sim_ac_openal_save_CPPFLAGS
  LDFLAGS=$sim_ac_openal_save_LDFLAGS
  LIBS=$sim_ac_openal_save_LIBS
  # unset sim_ac_openal_debug
  # unset sim_ac_openal_name
  # unset sim_ac_openal_save_CPPFLAGS
  # unset sim_ac_openal_save_LDFLAGS
  # unset sim_ac_openal_save_LIBS
  ;;
esac
if $sim_ac_want_openal; then
  if $sim_ac_have_openal; then
    AC_MSG_RESULT([success ($sim_ac_openal_libs)])
    $1
  else
    AC_MSG_RESULT([failure])
    $2
  fi
else
  AC_MSG_RESULT([disabled])
  $2
fi
# unset sim_ac_want_openal
])


