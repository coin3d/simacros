############################################################################
# Usage:
#   SIM_AC_HAVE_SOCKLEN_T
#
# Description:
#   Define HAVE_SOCKLEN_T if the socklen_t type is available.
#
# Author:
#   Morten Eriksen, <mortene@sim.no>
#

AC_DEFUN([SIM_AC_HAVE_SOCKLEN_T],
[AC_CACHE_CHECK(
  [for socklen_t type],
  [sim_cv_socklen_t],
  [AC_COMPILE_IFELSE([AC_LANG_PROGRAM([#include <sys/socket.h>],
                                      [socklen_t length;
                                       (void)recvfrom(0,0L,0,0,0L,&length);])],
                     [sim_cv_socklen_t=true],
                     [sim_cv_socklen_t=false])])
if $sim_cv_socklen_t; then
  AC_DEFINE(HAVE_SOCKLEN_T, 1,
            [Define if <sys/socket.h> defines socklen_t.])
fi
])# SIM_AC_HAVE_SOCKLEN_T
