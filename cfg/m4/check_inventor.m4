############################################################################
# Usage:
#  SIM_CHECK_OIV_XT([ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND]])
#
#  Try to compile and link against the Xt GUI glue library for
#  the Open Inventor development system. Sets this shell
#  variable:
#
#    $sim_ac_oivxt_libs     (link libraries the linker needs for InventorXt)
#
#  The LIBS variable will also be modified accordingly. In addition,
#  the variable $sim_ac_oivxt_avail is set to "yes" if the Xt glue
#  library for the Open Inventor development system is found.
#
# Authors:
#   Morten Eriksen, <mortene@sim.no>.
#   Lars J. Aas, <larsa@sim.no>.
#

AC_DEFUN([SIM_CHECK_OIV_XT], [
sim_ac_oivxt_avail=no

sim_ac_oivxt_libs="-lInventorXt"
sim_ac_save_libs=$LIBS
LIBS="$sim_ac_oivxt_libs $LIBS"

AC_CACHE_CHECK([for Xt glue library in the Open Inventor developer kit],
  sim_cv_lib_oivxt_avail,
  [AC_TRY_LINK([#include <Inventor/Xt/SoXt.h>],
               [(void)SoXt::init(0L, 0L);],
               [sim_cv_lib_oivxt_avail=yes],
               [sim_cv_lib_oivxt_avail=no])])

if test x"$sim_cv_lib_oivxt_avail" = xyes; then
  sim_ac_oivxt_avail=yes
  $1
else
  LIBS=$sim_ac_save_libs
  $2
fi
])

# **************************************************************************
# SIM_AC_WITH_INVENTOR
# This macro just ensures the --with-inventor option is used.

AC_DEFUN([SIM_AC_WITH_INVENTOR], [
: ${sim_ac_want_inventor=false}
AC_ARG_WITH([inventor],
  AC_HELP_STRING([--with-inventor], [use another Open Inventor than Coin [[default=no]], with InventorXt])
AC_HELP_STRING([--with-inventor=PATH], [specify where Open Inventor and InventorXt resides]),
  [case "$withval" in
  no)  sim_ac_want_inventor=false ;;
  yes) sim_ac_want_inventor=true
       test -n "$OIVHOME" &&
         SIM_AC_DEBACKSLASH(sim_ac_inventor_path, "$OIVHOME") ;;
  *)   sim_ac_want_inventor=true; sim_ac_inventor_path="$withval" ;;
  esac])
]) # SIM_AC_WITH_INVENTOR

# **************************************************************************
# SIM_AC_HAVE_INVENTOR_IMAGE_IFELSE

AC_DEFUN([SIM_AC_HAVE_INVENTOR_IMAGE_IFELSE], [
AC_REQUIRE([SIM_AC_WITH_INVENTOR])

if $sim_ac_want_inventor; then
  sim_ac_inventor_image_save_CPPFLAGS="$CPPFLAGS"
  sim_ac_inventor_image_save_LDFLAGS="$LDFLAGS"
  sim_ac_inventor_image_save_LIBS="$LIBS"

  if test s${sim_ac_inventor_path+et} = set; then
    sim_ac_inventor_image_cppflags="-I${sim_ac_inventor_path}/include"
    sim_ac_inventor_image_ldflags="-L${sim_ac_inventor_path}/lib"
  fi
  sim_ac_inventor_image_libs="-limage"

  AC_CACHE_CHECK(
    [if linking with libimage is possible],
    sim_cv_have_inventor_image,
    [
    CPPFLAGS="$sim_ac_inventor_image_cppflags $CPPFLAGS"
    LDFLAGS="$sim_ac_inventor_image_ldflags $LDFLAGS"
    LIBS="$sim_ac_inventor_image_libs $LIBS"
    AC_TRY_LINK(
      [],
      [],
      [sim_cv_have_inventor_image=true],
      [sim_cv_have_inventor_image=false])
    CPPFLAGS="$sim_ac_inventor_image_save_CPPFLAGS"
    LDFLAGS="$sim_ac_inventor_image_save_LDFLAGS"
    LIBS="$sim_ac_inventor_image_save_LIBS"
    ])

  if $sim_cv_have_inventor_image; then
    ifelse([$1], , :, [$1])
  else
    ifelse([$2], , :, [$2])
  fi
else
  ifelse([$2], , :, [$2])
fi
]) # SIM_AC_HAVE_INVENTOR_IMAGE_IFELSE

# **************************************************************************
# SIM_AC_HAVE_INVENTOR_IFELSE( [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND] ] )
#
# Defines $sim_ac_inventor_cppflags, $sim_ac_inventor_ldflags and
# $sim_ac_inventor_libs.

AC_DEFUN([SIM_AC_HAVE_INVENTOR_IFELSE], [
AC_REQUIRE([SIM_AC_WITH_INVENTOR])

if $sim_ac_want_inventor; then
  sim_ac_save_CPPFLAGS="$CPPFLAGS"
  sim_ac_save_LDFLAGS="$LDFLAGS"
  sim_ac_save_LIBS="$LIBS"

  SIM_AC_HAVE_INVENTOR_IMAGE_IFELSE([
    sim_ac_inventor_cppflags="$sim_ac_inventor_image_cppflags"
    sim_ac_inventor_ldflags="$sim_ac_inventor_image_ldflags"
  ], [
    if test s${sim_ac_inventor_path+et} = set; then
      sim_ac_inventor_cppflags="-I${sim_ac_inventor_path}/include"
      sim_ac_inventor_ldflags="-L${sim_ac_inventor_path}/lib"
    fi
    sim_ac_inventor_image_libs=
  ])

  # Let's at least test for "libInventor".
  sim_ac_inventor_chk_libs="-lInventor"
  sim_ac_inventor_libs=UNRESOLVED

  CPPFLAGS="$sim_ac_inventor_cppflags $CPPFLAGS"

  AC_CHECK_HEADER([Inventor/SbBasic.h],
                  [sim_ac_sbbasic=true],
                  [AC_MSG_WARN([header file Inventor/SbBasic.h not found])
                   sim_ac_sbbasic=false])

  if $sim_ac_sbbasic; then
  AC_MSG_CHECKING([the Open Inventor version])
  # See if we can get the TGS_VERSION number for including a
  # check for inv{ver}.lib.
  # TGS did not include TGS_VERSION before 2.6, so this may have to be
  # back-ported to SO_VERSION+SO_REVISION usage.  larsa 2001-07-25
    cat <<EOF > conftest.c
#include <Inventor/SbBasic.h>
#ifdef __COIN__
#error Testing for original Open Inventor, but found Coin...
#endif
PeekInventorVersion: TGS_VERSION
EOF
  if test x"$CPP" = x; then
    AC_MSG_ERROR([cpp not detected - aborting.  notify maintainer at coin-support@coin3d.org.])
  fi
  echo "$CPP $CPPFLAGS conftest.c" >&AS_MESSAGE_LOG_FD
  tgs_version_line=`$CPP $CPPFLAGS conftest.c 2>&AS_MESSAGE_LOG_FD | grep "^PeekInventorVersion"`
  if test x"$tgs_version_line" = x; then
    echo "second try..." >&AS_MESSAGE_LOG_FD
    echo "$CPP -DWIN32 $CPPFLAGS conftest.c" >&AS_MESSAGE_LOG_FD
    tgs_version_line=`$CPP -DWIN32 $CPPFLAGS conftest.c 2>&AS_MESSAGE_LOG_FD | grep "^PeekInventorVersion"`
  fi
  rm -f conftest.c
  tgs_version=`echo $tgs_version_line | cut -c22-24`
  tgs_suffix=
  if test x"${enable_inventor_debug+set}" = xset &&
     test x"${enable_inventor_debug}" = xyes; then
    tgs_suffix=d
  fi
  if test x"$tgs_version" != xTGS; then
    sim_ac_inventor_chk_libs="$sim_ac_inventor_chk_libs -linv$tgs_version$tgs_suffix"
    tgs_version_string=`echo $tgs_version | sed 's/\(.\)\(.\)\(.\)/\1.\2.\3/g'`
    AC_MSG_RESULT([TGS Open Inventor v$tgs_version_string])
  else
    AC_MSG_RESULT([probably SGI or older TGS Open Inventor])
  fi

  AC_MSG_CHECKING([for Open Inventor library])

  for sim_ac_iv_cppflags_loop in "" "-DWIN32"; do
    # Trying with no libraries first, as TGS Inventor uses pragmas in
    # a header file to notify MSVC of what to link with.
    for sim_ac_iv_libcheck in "" $sim_ac_inventor_chk_libs; do
      if test "x$sim_ac_inventor_libs" = "xUNRESOLVED"; then
        CPPFLAGS="$sim_ac_iv_cppflags_loop $sim_ac_inventor_cppflags $sim_ac_save_CPPFLAGS"
        LDFLAGS="$sim_ac_inventor_ldflags $sim_ac_save_LDFLAGS"
        LIBS="$sim_ac_iv_libcheck $sim_ac_inventor_image_libs $sim_ac_save_LIBS"
        AC_TRY_LINK([#include <Inventor/SoDB.h>],
                    [SoDB::init();],
                    [sim_ac_inventor_libs="$sim_ac_iv_libcheck $sim_ac_inventor_image_libs"
                     sim_ac_inventor_cppflags="$sim_ac_iv_cppflags_loop $sim_ac_inventor_cppflags"])
      fi
    done
  done

  if test "x$sim_ac_inventor_libs" != "xUNRESOLVED"; then
    AC_MSG_RESULT($sim_ac_inventor_cppflags $sim_ac_inventor_ldflags $sim_ac_inventor_libs)
  else
    AC_MSG_RESULT([unavailable])
  fi

  fi # sim_ac_sbbasic = TRUE

  CPPFLAGS="$sim_ac_save_CPPFLAGS"
  LDFLAGS="$sim_ac_save_LDFLAGS"
  LIBS="$sim_ac_save_LIBS"

  if test "x$sim_ac_inventor_libs" != "xUNRESOLVED"; then
    :
    $1
  else
    :
    $2
  fi
else
  ifelse([$2], , :, [$2])
fi
]) # SIM_AC_HAVE_INVENTOR_IFELSE

# **************************************************************************

# utility macros:
AC_DEFUN([AC_TOUPPER], [translit([$1], [[a-z]], [[A-Z]])])
AC_DEFUN([AC_TOLOWER], [translit([$1], [[A-Z]], [[a-z]])])

# **************************************************************************
# SIM_AC_HAVE_INVENTOR_NODE( NODE, [ACTION-IF-FOUND] [, ACTION-IF-NOT-FOUND])
#
# Check whether or not the given NODE is available in the Open Inventor
# development system.  If so, the HAVE_<NODE> define is set.
#
# Authors:
#   Lars J. Aas  <larsa@sim.no>
#   Morten Eriksen  <mortene@sim.no>

AC_DEFUN([SIM_AC_HAVE_INVENTOR_NODE], 
[m4_do([pushdef([cache_variable], sim_cv_have_oiv_[]AC_TOLOWER([$1])_node)],
       [pushdef([DEFINE_VARIABLE], HAVE_[]AC_TOUPPER([$1]))])
AC_CACHE_CHECK(
  [if the Open Inventor $1 node is available],
  cache_variable,
  [AC_TRY_LINK(
    [#include <Inventor/nodes/$1.h>],
    [$1 * p = new $1;],
    cache_variable=true,
    cache_variable=false)])

if $cache_variable; then
  AC_DEFINE(DEFINE_VARIABLE, 1, [Define to enable use of the Open Inventor $1 node])
  $2
else
  ifelse([$3], , :, [$3])
fi
m4_do([popdef([cache_variable])],
      [popdef([DEFINE_VARIABLE])])
]) # SIM_AC_HAVE_INVENTOR_NODE

# **************************************************************************
# SIM_AC_HAVE_INVENTOR_VRMLNODE( VRLMNODE, [ACTION-IF-FOUND] [, ACTION-IF-NOT-FOUND])
#
# Check whether or not the given VRMLNODE is available in the Open Inventor
# development system.  If so, the HAVE_<VRMLNODE> define is set.
#
# Authors:
#   Lars J. Aas  <larsa@sim.no>
#   Morten Eriksen  <mortene@sim.no>

AC_DEFUN([SIM_AC_HAVE_INVENTOR_VRMLNODE], 
[m4_do([pushdef([cache_variable], sim_cv_have_oiv_[]AC_TOLOWER([$1])_vrmlnode)],
       [pushdef([DEFINE_VARIABLE], HAVE_[]AC_TOUPPER([$1]))])
AC_CACHE_CHECK(
  [if the Open Inventor $1 VRML node is available],
  cache_variable,
  [AC_TRY_LINK(
    [#include <Inventor/VRMLnodes/$1.h>],
    [$1 * p = new $1;],
    cache_variable=true,
    cache_variable=false)])

if $cache_variable; then
  AC_DEFINE(DEFINE_VARIABLE, 1, [Define to enable use of the Open Inventor $1 VRML node])
  $2
else
  ifelse([$3], , :, [$3])
fi
m4_do([popdef([cache_variable])],
      [popdef([DEFINE_VARIABLE])])
]) # SIM_AC_HAVE_INVENTOR_VRMLNODE

# **************************************************************************
# SIM_AC_HAVE_INVENTOR_FEATURE(MESSAGE, HEADERS, BODY, DEFINE
#                              [, ACTION-IF-FOUND[, ACTION-IF-NOT-FOUND]])
#
# Authors:
#   Morten Eriksen <mortene@sim.no>

AC_DEFUN([SIM_AC_HAVE_INVENTOR_FEATURE],
[m4_do([pushdef([cache_variable], sim_cv_have_oiv_[]AC_TOLOWER([$4]))],
       [pushdef([DEFINE_VARIABLE], AC_TOUPPER([$4]))])
AC_CACHE_CHECK(
  [$1],
  cache_variable,
  [AC_TRY_LINK(
    [$2],
    [$3],
    cache_variable=true,
    cache_variable=false)])

if $cache_variable; then
  AC_DEFINE(DEFINE_VARIABLE, 1, [Define to enable use of Inventor feature])
  $5
else
  ifelse([$6], , :, [$6])
fi
m4_do([popdef([cache_variable])],
      [popdef([DEFINE_VARIABLE])])
]) # SIM_AC_HAVE_INVENTOR_FEATURE

# **************************************************************************
# SIM_AC_INVENTOR_EXTENSIONS( ACTION )
#
# This macro adds an "--with-iv-extensions=..." option to configure, that
# enabes the configurer to enable extensions in third-party libraries to
# be initialized by the library by default.  The configure-option argument
# must be a comma-separated list of link library path options, link library
# options and class-names.
#
# Sample usage is
#   ./configure --with-iv-extension=-L/tmp/mynodes,-lmynodes,MyNode1,MyNode2
#
# TODO:
#   * check if __declspec(dllimport) is needed on Cygwin

AC_DEFUN([SIM_AC_INVENTOR_EXTENSIONS],
[
AC_ARG_WITH(
  [iv-extensions],
  [AC_HELP_STRING([--with-iv-extensions=extensions], [enable extra open inventor extensions])],
  [sim_ac_iv_try_extensions=$withval])

sim_ac_iv_extension_save_LIBS=$LIBS

sim_ac_iv_extension_LIBS=
sim_ac_iv_extension_LDFLAGS=
sim_ac_iv_extension_decarations=
sim_ac_iv_extension_initializations=

sim_ac_iv_extensions=
while test x"${sim_ac_iv_try_extensions}" != x""; do
  sim_ac_iv_extension=`echo ,$sim_ac_iv_try_extensions | cut -d, -f2`
  sim_ac_iv_try_extensions=`echo ,$sim_ac_iv_try_extensions | cut -d, -f3-`
  case $sim_ac_iv_extension in
  sim_ac_dummy ) # ignore
    ;;
  -L* ) # extension library path hint
    sim_ac_iv_extension_LDFLAGS="$sim_ac_iv_extension_LDFLAGS $sim_ac_iv_extension"
    ;;
  -l* ) # extension library hint
    LIBS="$sim_ac_iv_extension_save_LIBS $sim_ac_iv_extension_LIBS $sim_ac_iv_extension"
    AC_MSG_CHECKING([for Open Inventor extension library $sim_ac_iv_extension])
    AC_TRY_LINK([#include <Inventor/SoDB.h>], [SoDB::init();],
      [sim_ac_iv_extension_LIBS="$sim_ac_iv_extension_LIBS $sim_ac_iv_extension"
       AC_MSG_RESULT([linkable])],
      [AC_MSG_RESULT([unlinkable - discarded])])
    ;;
  * )
    AC_MSG_CHECKING([for Open Inventor extension $sim_ac_iv_extension])
    AC_TRY_LINK(
[#include <Inventor/SoDB.h>
// hack up a declaration and see if the mangled name is found by the linker
class $sim_ac_iv_extension {
public:
static void initClass(void);
};], [
  SoDB::init();
  $sim_ac_iv_extension::initClass();
], [
  AC_MSG_RESULT([found])
  sim_ac_iv_extensions="$sim_ac_iv_extensions COIN_IV_EXTENSION($sim_ac_iv_extension)"
], [
  AC_MSG_RESULT([not found])
])
    ;;
  esac
done

AC_DEFINE_UNQUOTED([COIN_IV_EXTENSIONS], [$sim_ac_iv_extensions], [Open Inventor extensions])

LIBS=$sim_ac_iv_extension_save_LIBS

ifelse([$1], , :, [$1])

]) # SIM_AC_INVENTOR_EXTENSIONS

