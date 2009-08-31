# **************************************************************************
# SIM_AC_HAVE_CGIMAGE_IFELSE( IF-FOUND, IF-NOT-FOUND )
#
# Variables:
#   sim_ac_have_coretext
#   sim_ac_coretext_libs
#
# Authors:
#   Tamer Fahmy <tamer@sim.no>

AC_DEFUN([SIM_AC_HAVE_CORETEXT_IFELSE],
[: ${sim_ac_have_coretext=false}
AC_MSG_CHECKING([for Coretext framework])
$sim_ac_have_coretext && break
sim_ac_coretext_save_LIBS=$LIBS
sim_ac_coretext_libs="-Wl,-framework,ApplicationServices"
LIBS="$sim_ac_coretext_libs $LIBS"
AC_TRY_LINK(
  [#include <ApplicationServices/ApplicationServices.h>],
  [CTFontRef times24Font = CTFontCreateWithName(CFSTR("Times"), 24.0, NULL);],
  [sim_ac_have_coretext=true])
LIBS=$sim_ac_coretext_save_LIBS
if $sim_ac_have_coretext; then
  AC_MSG_RESULT([success ($sim_ac_coretext_libs)])
  $1
else
  AC_MSG_RESULT([failure])
  $2
fi
])

# EOF **********************************************************************
