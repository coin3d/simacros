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

