# **************************************************************************
# SIM_AM_CHANGES_ONLY
#
# This macro makes Automake only install headers that have changed since
# last installation.  This is useful to avoid massive recompilations for
# projects depending on libraries you just reinstalled because of some
# small change.

AC_DEFUN([SIM_AM_CHANGES_ONLY],
[AC_ARG_ENABLE(
  [changes-only],
  AC_HELP_STRING([--enable-changes-only],
                 [do not reinstall unchanged headers]),
  [INSTALL_CHANGES_ONLY=$enableval],
  [INSTALL_CHANGES_ONLY=no])
AM_CONDITIONAL(CHANGES_ONLY, test "$INSTALL_CHANGES_ONLY" = yes)
NOCHA=$CHANGES_ONLY_FALSE
CHA=$CHANGES_ONLY_TRUE
AC_SUBST(NOCHA)
AC_SUBST(CHA)
]) # SIM_AM_CHANGES_ONLY

