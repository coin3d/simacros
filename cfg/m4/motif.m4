############################################################################
# Usage:
#  SIM_CHECK_MOTIF([ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND]])
#
#  Try to compile and link against the Motif library. Sets these
#  shell variables:
#
#    $sim_ac_motif_cppflags (extra flags the compiler needs for Motif)
#    $sim_ac_motif_ldflags  (extra flags the linker needs for Motif)
#    $sim_ac_motif_libs     (link libraries the linker needs for Motif)
#
#  The CPPFLAGS, LDFLAGS and LIBS flags will also be modified accordingly.
#  In addition, the variable $sim_ac_motif_avail is set to "yes" if
#  the Motif library development installation is ok.
#
# Author: Morten Eriksen, <mortene@sim.no>.
#

AC_DEFUN([SIM_CHECK_MOTIF], [
AC_PREREQ([2.14.1])

AC_ARG_WITH(
  [motif],
  AC_HELP_STRING([--with-motif=DIR],
                 [use the Motif library [default=yes]]),
  [],
  [with_motif=yes])

sim_ac_motif_avail=no

if test x"$with_motif" != xno; then
  if test x"$with_motif" != xyes; then
    sim_ac_motif_cppflags="-I${with_motif}/include"
    sim_ac_motif_ldflags="-L${with_motif}/lib"
  fi

  sim_ac_motif_libs="-lXm"

  sim_ac_save_cppflags=$CPPFLAGS
  sim_ac_save_ldflags=$LDFLAGS
  sim_ac_save_libs=$LIBS

  CPPFLAGS="$sim_ac_motif_cppflags $CPPFLAGS"
  LDFLAGS="$sim_ac_motif_ldflags $LDFLAGS"
  LIBS="$sim_ac_motif_libs $LIBS"

  AC_CACHE_CHECK(
    [for a Motif development environment],
    sim_cv_lib_motif_avail,
    [AC_TRY_LINK([#include <Xm/Xm.h>],
                 [XmUpdateDisplay(0L);],
                 [sim_cv_lib_motif_avail=yes],
                 [sim_cv_lib_motif_avail=no])])

  if test x"$sim_cv_lib_motif_avail" = xyes; then
    sim_ac_motif_avail=yes
    $1
  else
    CPPFLAGS=$sim_ac_save_cppflags
    LDFLAGS=$sim_ac_save_ldflags
    LIBS=$sim_ac_save_libs
    $2
  fi
fi
])

############################################################################
# Usage:
#  SIM_CHECK_XMEDRAWSHADOWS([ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND]])
#
#  Try to compile and link code with the XmeDrawShadows() function
#  from Motif 2.0 (which is used by the InventorXt library). Sets the
#  variable $sim_ac_xmedrawshadows_avail to either "yes" or "no".
#
#
# Author: Morten Eriksen, <mortene@sim.no>.
#

AC_DEFUN([SIM_CHECK_XMEDRAWSHADOWS], [
AC_PREREQ([2.14.1])

sim_ac_xmedrawshadows_avail=no

AC_CACHE_CHECK(
  [for XmeDrawShadows() function in Motif library],
  sim_cv_lib_xmedrawshadows_avail,
  [AC_TRY_LINK([#include <Xm/Xm.h>],
               [XmeDrawShadows(0L, 0L, 0L, 0L, 0, 0, 0, 0, 0, 0);],
               [sim_cv_lib_xmedrawshadows_avail=yes],
               [sim_cv_lib_xmedrawshadows_avail=no])])

if test x"$sim_cv_lib_xmedrawshadows_avail" = xyes; then
  sim_ac_xmedrawshadows_avail=yes
  $1
else
  ifelse([$2], , :, [$2])
fi
])

############################################################################
# Usage:
#   SIM_CHECK_MOTIF_GLWIDGET([ ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND ]])
#
# Description:
#   This macro checks for a GL widget that can be used with Xt/Motif.
#  
# Variables:
#   $sim_cv_motif_glwidget         (cached)  class + header + library
#   $sim_cv_motif_glwidget_hdrloc  (cached)  GL | X11/GLw
#
#   $sim_ac_motif_glwidget_class             glwMDrawingAreaWidgetClass |
#                                            glwDrawingAreaWidgetClass
#   $sim_ac_motif_glwidget_header            GLwDrawA.h | GLwMDrawA.h
#   $sim_ac_motif_glwidget_library           GLwM | GLw | MesaGLwM | MesaGLw
#  
#   $LIBS = -l$sim_ac_motif_glwidget_library $LIBS
#  
# Defines:
#   XT_GLWIDGET                              $sim_ac_motif_glwidget_class
#   HAVE_GL_GLWDRAWA_H                       #include <GL/GLwDrawA.h>
#   HAVE_GL_GLWMDRAWA_H                      #include <GL/GLwMDrawA.h>
#   HAVE_X11_GWL_GLWDRAWA_H                  #include <X11/GLw/GLwDrawA.h>
#   HAVE_X11_GWL_GLWMDRAWA_H                 #include <X11/GLw/GLwMDrawA.h>
#  
# Authors:
#   Lars J. Aas <larsa@sim.no>,
#   Loring Holden <lsh@cs.brown.edu>,
#   Morten Eriksen <mortene@sim.no>
#  

AC_DEFUN([SIM_CHECK_MOTIF_GLWIDGET], [

AC_CACHE_CHECK(
  [for a GL widget],
  sim_cv_motif_glwidget,
  [SAVELIBS=$LIBS
  sim_cv_motif_glwidget=UNKNOWN
  for lib in GLwM GLw MesaGLwM MesaGLw; do
    if test x"$sim_cv_motif_glwidget" = x"UNKNOWN"; then
      LIBS="-l$lib $SAVELIBS"
      AC_TRY_LINK(
        [#include <X11/Intrinsic.h>
        extern WidgetClass glwMDrawingAreaWidgetClass;],
        [Widget glxManager = NULL;
        Widget glxWidget = XtVaCreateManagedWidget("GLWidget",
          glwMDrawingAreaWidgetClass, glxManager, NULL);],
        [sim_cv_motif_glwidget="glwMDrawingAreaWidgetClass GLwMDrawA.h $lib"],
        [sim_cv_motif_glwidget=UNKNOWN])
    fi
    if test x"$sim_cv_motif_glwidget" = x"UNKNOWN"; then
      LIBS="-l$lib $SAVELIBS"
      AC_TRY_LINK(
        [#include <X11/Intrinsic.h>
        extern WidgetClass glwDrawingAreaWidgetClass;],
        [Widget glxManager = NULL;
        Widget glxWidget = XtVaCreateManagedWidget("GLWidget",
          glwDrawingAreaWidgetClass, glxManager, NULL);],
        [sim_cv_motif_glwidget="glwDrawingAreaWidgetClass GLwDrawA.h $lib"],
        [sim_cv_motif_glwidget=UNKNOWN])
    fi
  done
  LIBS=$SAVELIBS
  ])

if test "x$sim_cv_motif_glwidget" = "xUNKNOWN"; then
  ifelse([$2], , :, [$2])
else
  sim_ac_motif_glwidget_class=`echo $sim_cv_motif_glwidget | cut -d" " -f1`
  sim_ac_motif_glwidget_header=`echo $sim_cv_motif_glwidget | cut -d" " -f2`
  sim_ac_motif_glwidget_library=`echo $sim_cv_motif_glwidget | cut -d" " -f3`

  AC_CACHE_CHECK(
    [the $sim_ac_motif_glwidget_header header location],
    sim_cv_motif_glwidget_hdrloc,
    [sim_cv_motif_glwidget_hdrloc=UNKNOWN
    for location in X11/GLw GL; do
      if test "x$sim_cv_motif_glwidget_hdrloc" = "xUNKNOWN"; then
        AC_TRY_CPP(
          [#include <X11/Intrinsic.h>
          #include <$location/$sim_ac_motif_glwidget_header>],
          [sim_cv_motif_glwidget_hdrloc=$location],
          [sim_cv_motif_glwidget_hdrloc=UNKNOWN])
      fi
    done])

  if test "x$sim_cv_motif_glwidget_hdrloc" = "xUNKNOWN"; then
    ifelse([$2], , :, [$2])
  else
    if test "x$sim_ac_motif_glwidget_header" = "xGLwDrawA.h"; then
      if test "x$sim_cv_motif_glwidget_hdrloc" = "xGL"; then
        AC_DEFINE(HAVE_GL_GLWDRAWA_H, 1,
          [Define this to use OpenGL widget from <GL/GLwDrawA.h>])
      else
        AC_DEFINE(HAVE_X11_GLW_GLWDRAWA_H, 1,
          [Define this to use OpenGL widget from <X11/GLw/GLwDrawA.h>])
      fi
    else
      if test "x$sim_cv_motif_glwidget_hdrloc" = "xGL"; then
        AC_DEFINE(HAVE_GL_GLWMDRAWA_H, 1,
          [Define this to use OpenGL widget from <GL/GLwMDrawA.h>])
      else
        AC_DEFINE(HAVE_X11_GLW_GLWMDRAWA_H, 1,
          [Define this to use OpenGL widget from <X11/GLw/GLwMDrawA.h>])
      fi
    fi

    AC_DEFINE_UNQUOTED(XT_GLWIDGET, $sim_ac_motif_glwidget_class,
      [Define this to the Xt/Motif OpenGL widget class to use])

    LIBS="-l$sim_ac_motif_glwidget_library $LIBS"

    $1
  fi
fi
])

