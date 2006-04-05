############################################################################
# Usage:
#   SIM_AC_DEBUGSYMBOLS
#
# Description:
#   Let the user decide if debug symbol information should be compiled
#   in. The compiled libraries/executables will use a lot less space
#   if stripped for their symbol information.
# 
#   Note: this macro must be placed after either AC_PROG_CC or AC_PROG_CXX
#   in the configure.in script.
# 
# Author: Morten Eriksen, <mortene@sim.no>.
# 

AC_DEFUN([SIM_AC_DEBUGSYMBOLS], [
AC_ARG_ENABLE(
  [symbols],
  AC_HELP_STRING([--enable-symbols],
                 [include symbol debug information [[default=yes]]]),
  [case "${enableval}" in
    yes) enable_symbols=yes ;;
    no)  enable_symbols=no ;;
    *) AC_MSG_ERROR(bad value "${enableval}" for --enable-symbols) ;;
  esac],
  [enable_symbols=yes])

# weird seds to don't mangle options like -fno-gnu-linker and -fvolatile-global
if test x"$enable_symbols" = x"no"; then
  CFLAGS="`echo $CFLAGS | sed 's/ -g / /g' | sed 's/^-g / /g' | sed 's/ -g$/ /g' | sed 's/^-g$/ /'`"
  CXXFLAGS="`echo $CXXFLAGS | sed 's/ -g / /g' | sed 's/^-g / /g' | sed 's/ -g$/ /g' | sed 's/^-g$/ /'`"
fi
]) # SIM_AC_DEBUGSYMBOLS

