# **************************************************************************
# CHECK_LINUX.M4
# ==============
# This file contains macros for detecting miscellaneous APIs originating
# from Linux.

# **************************************************************************
# SIM_AC_CHECK_JOYSTICK_LINUX( SUCCESS-ACTION, FAILURE-ACTION )
#
# This macro checks wether the system has the Linux Joystick driver or not.
#
# Authors:
#   Lars J. Aas <larsa@sim.no>

AC_DEFUN([SIM_AC_CHECK_JOYSTICK_LINUX], [

AC_CACHE_CHECK(
  [Linux Joystick device driver],
  [sim_cv_joystick_linux],
  [AC_TRY_CPP(
    [#include <linux/joystick.h>],
    [sim_cv_joystick_linux=true],
    [sim_cv_joystick_linux=false])])

sim_ac_joystick_linux_avail=$sim_cv_joystick_linux
if $sim_cv_joystick_linux; then
  AC_ARG_WITH(
    [linux-joystick-device],
    AC_HELP_STRING([--with-linux-joystick-device=DEV],
                   [default joystick device to something other than /dev/js0]),
    [sim_cv_joystick_linux_device=$with_linux_joystick_device],
    [: ${sim_cv_joystick_linux_device=/dev/js0}])
  AC_CACHE_CHECK(
    [Linux Joystick device handle],
    [sim_cv_joystick_linux_device])
  sim_ac_joystick_linux_device=$sim_cv_joystick_linux_device
  $1
else
  ifelse([$2], [], :, [$2])
fi
])

