############################################################################
# Usage:
#   SIM_AC_CHECK_MACRO_QUOTE([ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND]])
#
# Description:
#   Find out how to quote strings within macros.
#
#   The variable sim_ac_quote_hash will be set to "yes" if we
#   can do ANSI C string quoting within macros using the hash
#   symbol.
#
#   The variable sim_ac_quote_apostrophes will be set to "yes"
#   if we can do string quoting within macros using apostrophes.
#   Note that the string quoting check with apostrophes will
#   not be performed if the hash quoting works.
#
#   ACTION-IF-FOUND will be performed if any method works,
#   otherwise ACTION-IF-NOT-FOUND will be run.
#
# Author: Morten Eriksen, <mortene@sim.no>.
#

AC_DEFUN([SIM_AC_CHECK_MACRO_QUOTE], [

sim_ac_quote_hash=no
sim_ac_quote_apostrophes=
AC_CACHE_CHECK(
  [whether quoting in macros can be done with hash symbol],
  sim_cv_quote_hash,
  [AC_TRY_RUN([#include <string.h>
               #define TEST_QUOTE(str) #str
               int main(void) { return strcmp("sim", TEST_QUOTE(sim)); }],
              [sim_cv_quote_hash=yes],
              [sim_cv_quote_hash=no],
              [AC_MSG_WARN([can't check macroquoting when crosscompiling, assumes ANSI C])
              sim_cv_quote_hash=yes])])

if test x"$sim_cv_quote_hash" = x"yes"; then
  sim_ac_quote_hash=yes
  $1
else
  AC_CACHE_CHECK(
    [whether quoting in macros can be done with apostrophes],
    sim_cv_quote_apostrophes,
    [AC_TRY_RUN([#include <string.h>
                 #define TEST_QUOTE(str) "str"
                 int main(void) { return strcmp("sim", TEST_QUOTE(sim)); }],
                [sim_cv_quote_apostrophes=yes],
                [sim_cv_quote_apostrophes=no],
                [sim_cv_quote_apostrophes=yes])])
  if test x"$sim_cv_quote_apostrophes" = x"yes"; then
    sim_ac_quote_apostrophes=yes
    $1
  else
    sim_ac_quote_apostrophes=no
    $2
  fi
fi
])
