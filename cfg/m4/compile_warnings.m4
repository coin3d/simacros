############################################################################
# Usage:
#   SIM_AC_COMPILER_WARNINGS
#
# Description:
#   Take care of making a sensible selection of warning messages
#   to turn on or off.
#
#   Note: this macro must be placed after either AC_PROG_CC or AC_PROG_CXX
#   in the configure.in script.
#
# Author: Morten Eriksen, <mortene@sim.no>.
#
# TODO:
#   * [mortene:19991114] find out how to get GCC's
#     -Werror-implicit-function-declaration option to work as expected
#
#   * [larsa:20010504] rename to SIM_AC_COMPILER_WARNINGS and clean up
#     the macro

AC_DEFUN([SIM_AC_COMPILER_WARNINGS], [
AC_ARG_ENABLE(
  [warnings],
  AC_HELP_STRING([--enable-warnings],
                 [turn on warnings when compiling [[default=yes]]]),
  [case "${enableval}" in
    yes) enable_warnings=yes ;;
    no)  enable_warnings=no ;;
    *) AC_MSG_ERROR([bad value "$enableval" for --enable-warnings]) ;;
  esac],
  [enable_warnings=yes])

if test x"$enable_warnings" = x"yes"; then

  for sim_ac_try_cc_warning_option in \
    "-W" "-Wall" "-Wno-unused" "-Wno-multichar"; do

    if test x"$GCC" = x"yes"; then
      SIM_AC_CC_COMPILER_OPTION([$sim_ac_try_cc_warning_option],
                                [CFLAGS="$CFLAGS $sim_ac_try_cc_warning_option"])
    fi
  done

  for sim_ac_try_cxx_warning_option in \
    "-W" "-Wall" "-Wno-unused" "-Wno-multichar" "-Woverloaded-virtual"; do
    if test x"$GXX" = x"yes"; then
      SIM_AC_CXX_COMPILER_OPTION([$sim_ac_try_cxx_warning_option],
                                 [CXXFLAGS="$CXXFLAGS $sim_ac_try_cxx_warning_option"])
    fi

  done

  case $host in
  *-*-irix*)
    ### Turn on all warnings ######################################
    # we try to catch settings like CC="CC -n32" too, even though the
    # -n32 option belongs to C[XX]FLAGS
    case $CC in
    cc | "cc "* | CC | "CC "* )
      SIM_AC_CC_COMPILER_OPTION([-fullwarn], [CFLAGS="$CFLAGS -fullwarn"])
      ;;
    esac
    case $CXX in
    CC | "CC "* )
      SIM_AC_CXX_COMPILER_OPTION([-fullwarn], [CXXFLAGS="$CXXFLAGS -fullwarn"])
      ;;
    esac

    ### Turn off specific (bogus) warnings ########################

    ### SGI MipsPro v?.?? (our compiler on IRIX 6.2) ##############
    ##
    ## 3115: ``type qualifiers are meaningless in this declaration''.
    ## 3262: unused variables.
    ##
    ### SGI MipsPro v7.30 #########################################
    ##
    ## 1174: "The function was declared but never referenced."
    ## 1209: "The controlling expression is constant." (kill warning on
    ##       if (0), assert(FALSE), etc).
    ## 1375: Non-virtual destructors in base classes.
    ## 3201: Unused argument to a function.
    ## 1110: "Statement is not reachable" (the Lex/Flex generated code in
    ##       Coin/src/engines has lots of shitty code which needs this).
    ## 1506: Implicit conversion from "unsigned long" to "long".
    ##       SbTime.h in SGI/TGS Inventor does this, so we need to kill
    ##       this warning to avoid all the output clutter when compiling
    ##       the SoQt, SoGtk or SoXt libraries on IRIX with SGI MIPSPro CC.
    ## 1169: External/internal linkage conflicts with a previous declaration.
    ##       We get this for the "friend operators" in SbString.h

    sim_ac_bogus_warnings="-woff 3115,3262,1174,1209,1375,3201,1110,1506,1169,1210"

    case $CC in
    cc | "cc "* | CC | "CC "* )
      SIM_AC_CC_COMPILER_OPTION([$sim_ac_bogus_warnings],
                                [CFLAGS="$CFLAGS $sim_ac_bogus_warnings"])
    esac
    case $CXX in
    CC | "CC "* )
      SIM_AC_CXX_COMPILER_OPTION([$sim_ac_bogus_warnings],
                                 [CXXFLAGS="$CXXFLAGS $sim_ac_bogus_warnings"])
      ;;
    esac
  ;;
  esac
fi
])

# **************************************************************************
#
# SIM_AC_DETECT_COMMON_COMPILER_FLAGS
#
# Sets sim_ac_compiler_CFLAGS and sim_ac_compiler_CXXFLAGS
#

AC_DEFUN([SIM_AC_DETECT_COMMON_COMPILER_FLAGS], [

AC_REQUIRE([SIM_AC_CHECK_PROJECT_BETA_STATUS_IFELSE])
AC_REQUIRE([SIM_AC_CHECK_SIMIAN_IFELSE])

SIM_AC_COMPILE_DEBUG([
  if test x"$GCC" = x"yes"; then
    # no auto string.h-functions
    SIM_AC_CC_COMPILER_OPTION([-fno-builtin], [sim_ac_compiler_CFLAGS="$sim_ac_compiler_CFLAGS -fno-builtin"])
    SIM_AC_CXX_COMPILER_OPTION([-fno-builtin], [sim_ac_compiler_CXXFLAGS="$sim_ac_compiler_CXXFLAGS -fno-builtin"])

    # disallow non-standard scoping of for()-variables
    SIM_AC_CXX_COMPILER_OPTION([-fno-for-scoping], [sim_ac_compiler_CXXFLAGS="$sim_ac_compiler_CXXFLAGS -fno-for-scope"])

    SIM_AC_CC_COMPILER_OPTION([-finline-functions], [sim_ac_compiler_CFLAGS="$sim_ac_compiler_CFLAGS -finline-functions"])
    SIM_AC_CXX_COMPILER_OPTION([-finline-functions], [sim_ac_compiler_CXXFLAGS="$sim_ac_compiler_CXXFLAGS -finline-functions"])

    if $sim_ac_simian; then
      if $sim_ac_source_release; then :; else
      # break build on warnings, except for in official source code releases
        if test x"$enable_werror" = x"no"; then :; else
          SIM_AC_CC_COMPILER_OPTION([-Werror], [sim_ac_compiler_CFLAGS="$sim_ac_compiler_CFLAGS -Werror"])
          SIM_AC_CXX_COMPILER_OPTION([-Werror], [sim_ac_compiler_CXXFLAGS="$sim_ac_compiler_CXXFLAGS -Werror"])
        fi
      fi
    fi

    # warn on missing return-value
    SIM_AC_CC_COMPILER_OPTION([-Wreturn-type], [sim_ac_compiler_CFLAGS="$sim_ac_compiler_CFLAGS -Wreturn-type"])
    SIM_AC_CXX_COMPILER_OPTION([-Wreturn-type], [sim_ac_compiler_CXXFLAGS="$sim_ac_compiler_CXXFLAGS -Wreturn-type"])

    SIM_AC_CC_COMPILER_OPTION([-Wchar-subscripts], [sim_ac_compiler_CFLAGS="$sim_ac_compiler_CFLAGS -Wchar-subscripts"])
    SIM_AC_CXX_COMPILER_OPTION([-Wchar-subscripts], [sim_ac_compiler_CXXFLAGS="$sim_ac_compiler_CXXFLAGS -Wchar-subscripts"])

    SIM_AC_CC_COMPILER_OPTION([-Wparentheses], [sim_ac_compiler_CFLAGS="$sim_ac_compiler_CFLAGS -Wparentheses"])
    SIM_AC_CXX_COMPILER_OPTION([-Wparentheses], [sim_ac_compiler_CXXFLAGS="$sim_ac_compiler_CXXFLAGS -Wparentheses"])

  else
    case $CXX in
    *wrapmsvc* )
      if $sim_ac_simian; then
        if $sim_ac_source_release; then :; else
          # break build on warnings, except for in official source code releases
          SIM_AC_CC_COMPILER_OPTION([/WX], [sim_ac_compiler_CFLAGS="$sim_ac_compiler_CFLAGS /WX"])
          SIM_AC_CXX_COMPILER_OPTION([/WX], [sim_ac_compiler_CXXFLAGS="$sim_ac_compiler_CXXFLAGS /WX"])
        fi
      fi

      # warning level 3
      SIM_AC_CC_COMPILER_OPTION([/W3], [sim_ac_compiler_CFLAGS="$sim_ac_compiler_CFLAGS /W3"])
      SIM_AC_CXX_COMPILER_OPTION([/W3], [sim_ac_compiler_CXXFLAGS="$sim_ac_compiler_CXXFLAGS /W3"])
      ;;
    esac
  fi
])

ifelse($1, [], :, $1)

])

AC_DEFUN([SIM_AC_COMPILER_NOBOOL], [
sim_ac_nobool_CXXFLAGS=
sim_ac_have_nobool=false
AC_MSG_CHECKING([whether $CXX accepts /noBool])
SIM_AC_CXX_COMPILER_BEHAVIOR_OPTION_QUIET(
  [/noBool],
  [int temp],
  [SIM_AC_CXX_COMPILER_BEHAVIOR_OPTION_QUIET(
    [/noBool],
    [bool res = true],
    [],
    [sim_ac_have_nobool=true])])
 
if $sim_ac_have_nobool; then
  sim_ac_nobool_CXXFLAGS="/noBool"
  AC_MSG_RESULT([yes])
  ifelse([$1], , :, [$1])
else
  AC_MSG_RESULT([no])
  ifelse([$2], , :, [$2])
fi
])

