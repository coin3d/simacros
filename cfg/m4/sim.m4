#
# SIM_AC_CHECK_SIMIAN_IFELSE( IF-SIMIAN, IF-NOT-SIMIAN )
#
# Sets $sim_ac_simian to true or false
#

AC_DEFUN([SIM_AC_CHECK_SIMIAN_IFELSE], [
AC_MSG_CHECKING([if user is simian])
case `hostname -d 2>/dev/null || domainname 2>/dev/null || hostname` in
*.sim.no | sim.no )
  sim_ac_simian=true
  ;;
* )
  if grep -ls "domain.*sim\\.no" /etc/resolv.conf >/dev/null; then
    sim_ac_simian=true
    :
  else
    sim_ac_simian=false
    :
  fi
  ;;
esac

if $sim_ac_simian; then
  AC_MSG_RESULT([probably])
  ifelse($1, [], :, $1)
else
  AC_MSG_RESULT([probably not])
  ifelse($2, [], :, $2)
fi])

