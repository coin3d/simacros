# **************************************************************************
# SIM_AC_MAC_CPP_ADJUSTMENTS
#
# Add --no-cpp-precomp if necessary. Without this option, the
# Apple preprocessor is used on Mac OS X platforms, and it is
# known to be very buggy.  It's better to use this option, so
# the GNU preprocessor is preferred.
#


AC_DEFUN([SIM_AC_MAC_CPP_ADJUSTMENTS],
[case $host_os in
darwin*)
  if test x"$GCC" = x"yes"; then
    # FIXME: create a SIM_AC_CPP_OPTION macro
    SIM_AC_CC_COMPILER_OPTION([-no-cpp-precomp], [CPPFLAGS="$CPPFLAGS -no-cpp-precomp"])
  fi
  ;;
esac
]) # SIM_AC_MAC_CPP_ADJUSTMENTS


# **************************************************************************
# This macro sets up the MAC_FRAMEWORK automake conditional, depending on
# the host OS and whether $sim_ac_prefer_framework has been overridden or
# not.

AC_DEFUN([SIM_AC_MAC_FRAMEWORK],
[case $host_os in
darwin*)
  : ${sim_ac_prefer_framework=true}
  ;;
esac
: ${sim_ac_prefer_framework=false}
# This AM_CONDITIONAL can be used to make Mac OS X specific make-rules
# related to installing proper Frameworks instead.
AM_CONDITIONAL([MAC_FRAMEWORK], [$sim_ac_prefer_framework])

if $sim_ac_prefer_framework; then
  ifelse([$1], , :, [$1])
else
  ifelse([$2], , :, [$2])
fi
]) # SIM_AC_MAC_FRAMEWORK


############################################################################
# Usage:
#  SIM_AC_UNIVERSAL_BINARIES([ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND]])
#
#  Determine whether we should build Universal Binaries. If yes, these
#  shell variables are set:
#
#    $sim_ac_enable_universal (true if we are building Universal Binaries)
#    $sim_ac_universal_flags (extra flags needed for Universal Binaries)
#
#  The CFLAGS and CXXFLAGS variables will also be modified accordingly.
#
#  Note that when building Universal Binaries, dependency tracking will
#  be turned off.
#
#  Important: This macro must be called _before_ AM_INIT_AUTOMAKE.
#
# Author: Karin Kosina <kyrah@sim.no>.

AC_DEFUN([SIM_AC_UNIVERSAL_BINARIES], [

sim_ac_enable_universal=false


case $host_os in
  darwin* )
    AC_ARG_ENABLE(
      [universal],
      AC_HELP_STRING([--enable-universal], [build Universal Binaries]), [
        case $enableval in
          yes | true) sim_ac_enable_universal=true ;;
          *) ;;
        esac])

    AC_MSG_CHECKING([whether we should build Universal Binaries])
    if $sim_ac_enable_universal; then
      AC_MSG_RESULT([yes])
      SIM_AC_CONFIGURATION_SETTING([Build Universal Binaries], [Yes])

      # need to build against Universal Binary SDK on PPC
      if test x"$host_cpu" = x"powerpc"; then
        sim_ac_universal_sdk_flags="-isysroot /Developer/SDKs/MacOSX10.4u.sdk"
      fi

      sim_ac_universal_flags="-arch i386 -arch ppc $sim_ac_universal_sdk_flags"

      CFLAGS="$sim_ac_universal_flags $CFLAGS"
      CXXFLAGS="$sim_ac_universal_flags $CXXFLAGS"

      # disable dependency tracking since we can't use -MD when cross-compiling
      enable_dependency_tracking=no
    else
      AC_MSG_RESULT([no])
      SIM_AC_CONFIGURATION_SETTING([Build Universal Binaries], [No (default)])
    fi
esac
]) # SIM_AC_UNIVERSAL_BINARIES
