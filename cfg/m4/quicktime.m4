# **************************************************************************
# SIM_AC_HAVE_QUICKTIME_IFELSE( IF-FOUND, IF-NOT-FOUND )
#
# Variables:
#   sim_ac_have_quicktime
#   sim_ac_quicktime_libs
#
# Authors:
#   Karin Kosina <kyrah@sim.no>

AC_DEFUN([SIM_AC_HAVE_QUICKTIME_IFELSE],
[: ${sim_ac_have_quicktime=false}
AC_MSG_CHECKING([for QuickTime framework])
$sim_ac_have_quicktime && break
sim_ac_quicktime_save_LIBS=$LIBS
sim_ac_quicktime_libs="-Wl,-framework,QuickTime -Wl,-framework,CoreServices -Wl,-framework,ApplicationServices"
LIBS="$sim_ac_quicktime_libs $LIBS"
AC_TRY_LINK(
  [#include <QuickTime/QuickTimeComponents.h>],
  [Component c;
  ComponentDescription cd;
  FindNextComponent (c, &cd);],
  [sim_ac_have_quicktime=true])
LIBS=$sim_ac_quicktime_save_LIBS
if $sim_ac_have_quicktime; then
  AC_MSG_RESULT([success ($sim_ac_quicktime_libs)])
  $1
else
  AC_MSG_RESULT([failure])
  $2
fi
])

# EOF **********************************************************************
