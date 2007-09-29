# **************************************************************************
# SIM_AC_SETUP_MSVC_IFELSE( IF-FOUND, IF-NOT-FOUND )
#
# This macro invokes IF-FOUND if the wrapmsvc wrapper can be run, and
# IF-NOT-FOUND if not.
#
# Authors:
#   Morten Eriksen <mortene@coin3d.org>
#   Lars J. Aas <larsa@coin3d.org>

# **************************************************************************

AC_DEFUN([SIM_AC_MSVC_DISABLE_OPTION], [
AC_ARG_ENABLE([msvc],
  [AC_HELP_STRING([--disable-msvc], [don't require MS Visual C++ on Cygwin])],
  [case $enableval in
  no | false) sim_ac_try_msvc=false ;;
  *)          sim_ac_try_msvc=true ;;
  esac],
  [sim_ac_try_msvc=true])
])

# **************************************************************************
# Usage:
#  SIM_AC_MSC_VERSION
#
# Find version number of the Visual C++ compiler. sim_ac_msc_version will
# contain the full version number string, and sim_ac_msc_major_version
# will contain only the Visual C++ major version number and
# sim_ac_msc_minor_version will contain the minor version number.

AC_DEFUN([SIM_AC_MSC_VERSION], [

AC_MSG_CHECKING([version of Visual C++ compiler])

cat > conftest.c << EOF
int VerMSC = _MSC_VER;
EOF

# The " *"-parts of the last sed-expression on the next line are necessary
# because at least the Solaris/CC preprocessor adds extra spaces before and
# after the trailing semicolon.
sim_ac_msc_version=`$CXXCPP $CPPFLAGS conftest.c 2>/dev/null | grep '^int VerMSC' | sed 's%^int VerMSC = %%' | sed 's% *;.*$%%'`

sim_ac_msc_minor_version=0
if test $sim_ac_msc_version -ge 1400; then
  sim_ac_msc_major_version=8
elif test $sim_ac_msc_version -ge 1300; then
  sim_ac_msc_major_version=7
  if test $sim_ac_msc_version -ge 1310; then
    sim_ac_msc_minor_version=1
  fi
elif test $sim_ac_msc_version -ge 1200; then
  sim_ac_msc_major_version=6
elif test $sim_ac_msc_version -ge 1100; then
  sim_ac_msc_major_version=5
else
  sim_ac_msc_major_version=0
fi

# compatibility with old version of macro
sim_ac_msvc_version=$sim_ac_msc_major_version

rm -f conftest.c
AC_MSG_RESULT($sim_ac_msc_major_version.$sim_ac_msc_minor_version)
]) # SIM_AC_MSC_VERSION

# **************************************************************************
# Note: the SIM_AC_SETUP_MSVC_IFELSE macro has been OBSOLETED and
# replaced by the one below.
#
# If the Microsoft Visual C++ cl.exe compiler is available, set us up for
# compiling with it and to generate an MSWindows .dll file.

AC_DEFUN([SIM_AC_SETUP_MSVCPP_IFELSE],
[
AC_REQUIRE([SIM_AC_MSVC_DISABLE_OPTION])
AC_REQUIRE([SIM_AC_SPACE_IN_PATHS])

: ${BUILD_WITH_MSVC=false}
if $sim_ac_try_msvc; then
  if test -z "$CC" -a -z "$CXX"; then
    sim_ac_wrapmsvc=`cd $ac_aux_dir; pwd`/wrapmsvc.exe
    echo "$as_me:$LINENO: sim_ac_wrapmsvc=$sim_ac_wrapmsvc" >&AS_MESSAGE_LOG_FD
    AC_MSG_CHECKING([setup for wrapmsvc.exe])
    if $sim_ac_wrapmsvc >&AS_MESSAGE_LOG_FD 2>&AS_MESSAGE_LOG_FD; then
      m4_ifdef([$0_VISITED],
        [AC_FATAL([Macro $0 invoked multiple times])])
      m4_define([$0_VISITED], 1)
      CC=$sim_ac_wrapmsvc
      CXX=$sim_ac_wrapmsvc
      export CC CXX
      BUILD_WITH_MSVC=true
      AC_MSG_RESULT([working])

      # Robustness: we had multiple reports of Cygwin ''link'' getting in
      # the way of MSVC link.exe, so do a little sanity check for that.
      #
      # FIXME: a better fix would be to call link.exe with full path from
      # the wrapmsvc wrapper, to avoid any trouble with this -- I believe
      # that should be possible, using the dirname of the full cl.exe path.
      # 20050714 mortene.
      sim_ac_check_link=`type link`
      AC_MSG_CHECKING([whether Cygwin's /usr/bin/link shadows MSVC link.exe])
      case x"$sim_ac_check_link" in
      x"link is /usr/bin/link"* )
        AC_MSG_RESULT(yes)
        SIM_AC_ERROR([cygwin-link])
        ;;
      * )
        AC_MSG_RESULT(no)
        ;;
      esac

    else
      case $host in
      *-cygwin)
        AC_MSG_RESULT([not working])
        SIM_AC_ERROR([no-msvc++]) ;;
      *)
        AC_MSG_RESULT([not working (as expected)])
        ;;
      esac
    fi
  fi
fi
export BUILD_WITH_MSVC
AC_SUBST(BUILD_WITH_MSVC)

if $BUILD_WITH_MSVC; then
  ifelse([$1], , :, [$1])
else
  ifelse([$2], , :, [$2])
fi
]) # SIM_AC_SETUP_MSVC_IFELSE

# **************************************************************************
# SIM_AC_SETUP_MSVCRT
#
# This macro sets up compiler flags for the MS Visual C++ C library of
# choice.

AC_DEFUN([SIM_AC_SETUP_MSVCRT],
[sim_ac_msvcrt_LDFLAGS=""
sim_ac_msvcrt_LIBS=""

AC_ARG_WITH([msvcrt],
  [AC_HELP_STRING([--with-msvcrt=<crt>],
                  [set which C run-time library to build against])],
  [case `echo "$withval" | tr "[A-Z]" "[a-z]"` in
  default | singlethread-static | ml | /ml | libc | libc\.lib )
    sim_ac_msvcrt=singlethread-static
    sim_ac_msvcrt_CFLAGS="/ML"
    sim_ac_msvcrt_CXXFLAGS="/ML"
    ;;
  default-debug | singlethread-static-debug | mld | /mld | libcd | libcd\.lib )
    sim_ac_msvcrt=singlethread-static-debug
    sim_ac_msvcrt_CFLAGS="/MLd"
    sim_ac_msvcrt_CXXFLAGS="/MLd"
    ;;
  multithread-static | mt | /mt | libcmt | libcmt\.lib )
    sim_ac_msvcrt=multithread-static
    sim_ac_msvcrt_CFLAGS="/MT"
    sim_ac_msvcrt_CXXFLAGS="/MT"
    ;;
  multithread-static-debug | mtd | /mtd | libcmtd | libcmtd\.lib )
    sim_ac_msvcrt=multithread-static-debug
    sim_ac_msvcrt_CFLAGS="/MTd"
    sim_ac_msvcrt_CXXFLAGS="/MTd"
    ;;
  multithread-dynamic | md | /md | msvcrt | msvcrt\.lib )
    sim_ac_msvcrt=multithread-dynamic
    sim_ac_msvcrt_CFLAGS="/MD"
    sim_ac_msvcrt_CXXFLAGS="/MD"
    ;;
  multithread-dynamic-debug | mdd | /mdd | msvcrtd | msvcrtd\.lib )
    sim_ac_msvcrt=multithread-dynamic-debug
    sim_ac_msvcrt_CFLAGS="/MDd"
    sim_ac_msvcrt_CXXFLAGS="/MDd"
    ;;
  *)
    SIM_AC_ERROR([invalid-msvcrt])
    ;;
  esac],
  [sim_ac_msvcrt=singlethread-static])

AC_MSG_CHECKING([MSVC++ C library choice])
AC_MSG_RESULT([$sim_ac_msvcrt])

$1
]) # SIM_AC_SETUP_MSVCRT

# **************************************************************************
# SIM_AC_SPACE_IN_PATHS

AC_DEFUN([SIM_AC_SPACE_IN_PATHS], [
sim_ac_full_builddir=`pwd`
sim_ac_full_srcdir=`cd $srcdir; pwd`
if test -z "`echo $sim_ac_full_srcdir | tr -cd ' '`"; then :; else
  AC_MSG_WARN([Detected space character in the path leading up to the Coin source directory - this will probably cause random problems later. You are advised to move the Coin source directory to another location.])
  SIM_AC_CONFIGURATION_WARNING([Detected space character in the path leading up to the Coin source directory - this will probably cause random problems later. You are advised to move the Coin source directory to another location.])
fi
if test -z "`echo $sim_ac_full_builddir | tr -cd ' '`"; then :; else
  AC_MSG_WARN([Detected space character in the path leading up to the Coin build directory - this will probably cause random problems later. You are advised to move the Coin build directory to another location.])
  SIM_AC_CONFIGURATION_WARNING([Detected space character in the path leading up to the Coin build directory - this will probably cause random problems later. You are advised to move the Coin build directory to another location.])
fi
]) # SIM_AC_SPACE_IN_PATHS

# EOF **********************************************************************
