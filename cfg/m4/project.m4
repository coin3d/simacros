#
# SIM_AC_CHECK_PROJECT_BETA_STATUS_IFELSE( IF-BETA, IF-BONA-FIDE )
#
# Sets sim_ac_source_release to true or false
#

AC_DEFUN([SIM_AC_CHECK_PROJECT_BETA_STATUS_IFELSE], [
AC_MSG_CHECKING([for project release status])
case $VERSION in
*[[a-z]]* )
  AC_MSG_RESULT([beta / inbetween releases])
  sim_ac_source_release=false
  ifelse($1, [], :, $1)
  ;;
* )
  AC_MSG_RESULT([release version])
  sim_ac_source_release=true
  ifelse($2, [], :, $2)
  ;;
esac
])

