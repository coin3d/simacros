############################################################################
#
# This file contains misc "macro-containers" for stuff that is
# common between the various configure.ac files of the So* libraries.
#
# Note: none of the macros in this file is likely to be well designed
# and made for generic use in any project.
#
############################################################################

############################################################################
# Usage:
#   SIM_AC_SOGUI_SETUP_DOXYGEN( LIBRARY-NAME )
#
# Description:
#   Do the necessary configurations for setting up HTML and man-page
#   building by the Doxygen documentation system.
#
# Authors:
#   Morten Eriksen, <mortene@sim.no>
#   Lars Jørgen Aas, <larsa@sim.no>


AC_DEFUN([SIM_AC_SOGUI_SETUP_DOXYGEN],
[
AC_ARG_VAR([htmldir],
           [destination for HTML docs (default ${datadir}/$1/html)])

AC_ARG_ENABLE(html,
  AC_HELP_STRING([--enable-html], [build and install $1 HTML documentation]),
  [case $enableval in
    yes | true) want_html=yes ;;
    *)          want_html=no ;;
  esac],
  [want_html=no])

case $htmldir in
"")
  htmldir="$datadir/$1/html"
  ;;
/*)
  # do nothing - absolute path
  ;;
*)
  htmldir="\${prefix}/$htmldir"
  ;;
esac

AC_SUBST(htmldir)

AC_ARG_ENABLE(man,
  AC_HELP_STRING([--enable-man], [build and install $1 man pages]),
  [case $enableval in
    yes | true) want_man=yes ;;
    *)          want_man=no ;;
  esac],
  [want_man=no])

AC_ARG_VAR([htmlhelpdir],
           [destination for HTML-help docs (default ${datadir}/$1/htmlhelp)])

AC_ARG_ENABLE([html-help],
  AC_HELP_STRING([--enable-html-help], [build and install $1 HTML-help documentation]),
  [case $enableval in
    yes | true) want_html_help=yes ;;
    *)          want_html_help=no ;;
  esac],
  [want_html_help=no])

case $htmlhelpdir in
"")
  htmlhelpdir="$datadir/$1/htmlhelp"
  ;;
/*)
  # do nothing - absolute path
  ;;
*)
  htmlhelpdir="\${prefix}/$htmlhelpdir"
  ;;
esac

AC_SUBST(htmlhelpdir)

# We must turn on html-generation if html-help is turned on,
# but without affecting the setup of the BUILD_HTMLPAGES
# conditional, so HTML files aren't installed if you don't
# use --enable-html.  20031202 larsa
sogui_doc_html=`echo $want_html | tr '[a-z]' '[A-Z]'`
if test x"$want_html_help" = x"yes"; then
  sogui_doc_html=YES
fi

# Used in the Doxygen parameter file.
AC_SUBST([SOGUI_DOC_HTML], [$sogui_doc_html])
AC_SUBST([SOGUI_DOC_MAN], [`echo $want_man | tr '[a-z]' '[A-Z]'`])
AC_SUBST([SOGUI_DOC_HTML_HELP], [`echo $want_html_help | tr '[a-z]' '[A-Z]'`])

AC_SUBST([sogui_build_dir], [`pwd`])
AC_SUBST([sogui_src_dir], [`cd $srcdir; pwd`])
AC_SUBST([sogui_html_dir], [`pwd`/html])
AC_SUBST([sogui_html_help_dir], [`pwd`/htmlhelp])
AC_SUBST([sogui_man_dir], [`pwd`/man])

AM_CONDITIONAL(BUILD_MANPAGES, test x"$want_man" = x"yes")
AM_CONDITIONAL(BUILD_HTMLPAGES, test x"$want_html" = x"yes")
AM_CONDITIONAL(BUILD_HTMLHELP, test x"$want_html_help" = x"yes")

if test x"$want_man" = x"yes"; then
  SIM_AC_CONFIGURATION_SETTING([manpage installation], [$mandir])
fi

if test x"$want_html" = x"yes"; then
  SIM_AC_CONFIGURATION_SETTING([HTML installation], [$htmldir])
fi

sim_ac_hhc_exe=
case $host in
  *-cygwin) AC_PATH_PROG([sim_ac_hhc_exe], [hhc]) ;;
  *)        AC_SUBST([sim_ac_hhc_exe]) ;;
esac

if test x"$want_html_help" = x"yes"; then
  SIM_AC_CONFIGURATION_SETTING([HTML-help installation], [$htmlhelpdir])
  if test x"$sim_ac_hhc_exe" = x; then
    AC_MSG_WARN([Could not find the HTML Help Compiler (hhc) executable])
  fi
fi

if test x"$want_html" != xno -o x"$want_man" != xno -o x"$want_html_help" != xno; then
  SIM_AC_DOXYGEN_TOOL([], [SIM_AC_ERROR([no-doxygen])])

  AC_PATH_PROG(sim_ac_perl_exe, perl, false, $PATH)
  if test x"$sim_ac_perl_exe" = xfalse; then
    AC_MSG_WARN(Could not find the Perl executable)
  fi
fi

# path_tag is used to identify paths in docs/coin.doxygen that needs to be
# transformed using cygpath under cygwin.

case $host in
*-cygwin) path_tag="<PATH>" ;;
*)        path_tag= ;;
esac

AC_SUBST(path_tag)

]) # SIM_AC_SOGUI_SETUP_DOXYGEN()
