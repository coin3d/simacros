############################################################################
# Usage:
#  SIM_AC_DATE_ISO8601([variable])
#  SIM_AC_DATE_RFC822([variable])
#
# Description:
#   This macro sets the given variable to a strings representing
#   the current date in the ISO8601-compliant format "YYYYMMDD" or in
#   the RFC822-compliant format "Day, DD Mon YYYY HH:MM:SS +0X00".
#
# Authors:
#   Morten Eriksen <mortene@sim.no>
#   Lars J. Aas <larsa@sim.no>

AC_DEFUN([SIM_AC_DATE_ISO8601], [
  eval "$1=\"`date +%Y%m%d`\""
])

AC_DEFUN([SIM_AC_DATE_RFC822], [
  eval "$1=\"`date '+%a, %d %b %Y %X %z'`\""
  eval "$1_DAYSTRING=\"`date '+%a'`\""
  eval "$1_NODAYSTRING=\"`date '+%d %b %Y %X %z'`\""
])

# old alias
# AU_DEFUN([SIM_AC_ISO8601_DATE], [SIM_AC_DATE_ISO8601])
AC_DEFUN([SIM_AC_ISO8601_DATE], [SIM_AC_DATE_ISO8601([$1])])

