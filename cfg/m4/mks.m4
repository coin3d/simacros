# **************************************************************************
# SIM_AC_SETUP_MKS
#
# This macro contains some customizations needed for being able to use
# the configure script in the MKS environment.
#
#   Lars J

AC_DEFUN([SIM_AC_SETUP_MKS],
[
case $build in
*-mks )
  AR=ar
  AC_PATH_PROG([sim_ac_mks_make], [gmake], [make])
  MAKE="$sim_ac_mks_make"
  SET_MAKE="MAKE=\"$sim_ac_mks_make\""
  export AR MAKE
  ;;
esac
])

