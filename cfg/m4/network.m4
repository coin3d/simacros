############################################################################
# Usage:
#  SIM_AC_BYTEORDER_CONVERSION([ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND]])
#
# Description:
#
#   Set variable sim_ac_byteorder_conversion_libs to the lib(s) we
#   need to link with to get at the network byteorder conversion
#   functions htonl(), htons(), ntohl() and ntohs(). The libs are also
#   added to the LIBS variable.
#
#   If the functions are found, sim_ac_byteorder_conversion is also
#   set to ``true'', otherwise it is set to ``false''.
#
# Author: Morten Eriksen, <mortene@sim.no>.

AC_DEFUN(SIM_AC_BYTEORDER_CONVERSION, [
sim_ac_save_libs=$LIBS
AC_CACHE_CHECK(
  [network byteorder conversion],
  sim_cv_byteorder_conversion_libs,
  [sim_cv_byteorder_conversion_libs=UNRESOLVED
  for sim_ac_byc_libcheck in "" -lws2_32 -lwsock32; do
    if test "x$sim_cv_byteorder_conversion_libs" = "xUNRESOLVED"; then
      LIBS="$sim_ac_byc_libcheck $sim_ac_save_libs"
      AC_TRY_LINK([
#ifdef HAVE_WINSOCK2_H
#include <winsock2.h> /* MSWindows htonl() etc */
#endif /* HAVE_WINSOCK2_H */
#ifdef HAVE_SYS_PARAM_H
#include <sys/param.h> /* FreeBSD htonl() etc */
#endif /* HAVE_SYS_PARAM_H */
#ifdef HAVE_SYS_TYPES_H
/* According to Coin user Ralf Corsepius, at least SunOS4 needs
   to include sys/types.h before netinet/in.h. There have also
   been a problem report for FreeBSD which seems to indicate
   the same dependency on that platform aswell. */
#include <sys/types.h>
#endif /* HAVE_SYS_TYPES_H */
#ifdef HAVE_NETINET_IN_H
#include <netinet/in.h> /* Linux htonl() etc */
#endif /* HAVE_NETINET_IN_H */
],
                  [
(void)htonl(0x42); (void)htons(0x42); (void)ntohl(0x42); (void)ntohs(0x42);
],
                  [sim_cv_byteorder_conversion_libs="$sim_ac_byc_libcheck"])
    fi
  done
])

LIBS=$sim_ac_save_libs

if test "x$sim_cv_byteorder_conversion_libs" != "xUNRESOLVED"; then
  sim_ac_byteorder_conversion_libs="$sim_cv_byteorder_conversion_libs"
  LIBS="$sim_ac_byteorder_conversion_libs $LIBS"
  sim_ac_byteorder_conversion=true
  $1
else
  sim_ac_byteorder_conversion=false
  $2
fi
])
