############################################################################
# Usage:
#  SIM_AC_PACKAGEMAKER_APP([ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND]])
#
# Description:
#   This macro locates the PackageMaker app bundle (Mac OS X).
#   If found, the variable $sim_ac_packagemaker_app is set to the full
#   path- and app bundle name.
#   If not found, it is set to "false".
#
# Author: Marius Kintel, <kintel@sim.no>

AC_DEFUN(SIM_AC_PACKAGEMAKER_APP, [
sim_ac_packagemaker_app=false
if test -d /Developer/Applications/PackageMaker.app; then
  sim_ac_packagemaker_app=/Developer/Applications/PackageMaker.app
elif test -d /Developer/Applications/Utilities/PackageMaker.app; then
  sim_ac_packagemaker_app=/Developer/Applications/Utilities/PackageMaker.app
fi
])
