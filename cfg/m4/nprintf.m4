############################################################################
# Usage:
#  SIM_AC_CHECK_SNPRINTF
#
# Description:
#   Find out which of these "safe" and non-standard functions are
#   available on the system: snprintf(), vsnprintf(), _snprintf()
#   and _vsnprintf().
#
#   The variables sim_ac_snprintf_avail, sim_ac_vsnprintf_avail,
#   sim_ac__snprintf_avail and sim_ac__vsnprintf_avail are set to either
#   "yes" or "no" according to their availability, and HAVE_SNPRINTF
#   etc will be defined properly.
#
# Authors:
#   Morten Eriksen, <mortene@sim.no>.
#

AC_DEFUN([SIM_AC_CHECK_NPRINTF], [
AC_PREREQ([2.14])

sim_ac_snprintf_avail=no
sim_ac__snprintf_avail=no
sim_ac_vsnprintf_avail=no
sim_ac__vsnprintf_avail=no

AC_CACHE_CHECK(
  [whether snprintf() is available],
  sim_cv_func_snprintf,
  [AC_TRY_LINK([#include <stdio.h>],
               [char buf[128]; (void)snprintf(buf, 127, "%s", "tjo-bing");],
               [sim_cv_func_snprintf=yes],
               [sim_cv_func_snprintf=no])])

sim_ac_snprintf_avail=$sim_cv_func_snprintf


AC_CACHE_CHECK(
  [whether vsnprintf() is available],
  sim_cv_func_vsnprintf,
  [AC_TRY_LINK([
#include <stdio.h>
#include <stdarg.h>

void
hepp(int dummy, ...)
{
  va_list argptr;
  char buf[128];

  va_start(argptr, dummy);
  (void)vsnprintf(buf, 127, "%s %s", argptr);
  va_end(argptr);
}
], [
  hepp(0, "tjo-bing", "hepp");
],
               [sim_cv_func_vsnprintf=yes],
               [sim_cv_func_vsnprintf=no])])

sim_ac_vsnprintf_avail=$sim_cv_func_vsnprintf

# We're not interested in _snprintf() unless snprintf() is unavailable.
if test x"$sim_ac_snprintf_avail" = x"no"; then
  AC_CACHE_CHECK(
    [whether _snprintf() is available],
    sim_cv_func__snprintf,
    [AC_TRY_LINK([#include <stdio.h>],
                 [char buf[128]; (void)_snprintf(buf, 127, "%s", "tjo-bing");],
                 [sim_cv_func__snprintf=yes],
                 [sim_cv_func__snprintf=no])])
  sim_ac__snprintf_avail=$sim_cv_func__snprintf
fi

# We're not interested in _vsnprintf() unless vsnprintf() is unavailable.
if test x"$sim_ac_vsnprintf_avail" = xno; then
  AC_CACHE_CHECK(
    [whether _vsnprintf() is available],
    sim_cv_func__vsnprintf,
    [AC_TRY_LINK([
#include <stdio.h>
#include <stdarg.h>

void
hepp(int dummy, ...)
{
  va_list argptr;
  char buf[128];

  va_start(argptr, dummy);
  (void)_vsnprintf(buf, 127, "%s %s", argptr);
  va_end(argptr);
}
], [
  hepp(0, "tjo-bing", "hepp");
],
                 [sim_cv_func__vsnprintf=yes],
                 [sim_cv_func__vsnprintf=no])])
  sim_ac__vsnprintf_avail=$sim_cv_func__vsnprintf
fi

test x"$sim_ac_snprintf_avail" = x"yes" &&
  AC_DEFINE([HAVE_SNPRINTF],1,
    [define if snprintf() is available])
test x"$sim_ac_vsnprintf_avail" = x"yes" &&
  AC_DEFINE([HAVE_VSNPRINTF],1,
    [define if vsnprintf() is available])
test x"$sim_ac__snprintf_avail" = x"yes" &&
  AC_DEFINE([HAVE__SNPRINTF],1,
    [define if _snprintf() is available])
test x"$sim_ac__vsnprintf_avail" = x"yes" &&
  AC_DEFINE([HAVE__VSNPRINTF],1,
    [define if _vsnprintf() is available])
])

