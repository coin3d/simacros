# **************************************************************************
# SIM_AC_CHECK_HEADER_SILENT([header], [if-found], [if-not-found], [includes])
# 
# This macro will not output any header checking information, nor will it
# cache the result, so it can be used multiple times on the same header,
# trying out different compiler options.

AC_DEFUN([SIM_AC_CHECK_HEADER_SILENT],
[AS_VAR_PUSHDEF([ac_Header], [ac_cv_header_$1])
m4_ifval([$4],
         [AC_COMPILE_IFELSE([AC_LANG_SOURCE([$4
@%:@include <$1>])],
                            [AS_VAR_SET(ac_Header, yes)],
                            [AS_VAR_SET(ac_Header, no)])],
         [AC_PREPROC_IFELSE([AC_LANG_SOURCE([@%:@include <$1>])],
                            [AS_VAR_SET(ac_Header, yes)],
                            [AS_VAR_SET(ac_Header, no)])])
AS_IF([test AS_VAR_GET(ac_Header) = yes], [$2], [$3])
AS_VAR_POPDEF([ac_Header])
])# SIM_AC_CHECK_HEADER_SILENT

# **************************************************************************
# SIM_AC_CHECK_HEADER_GL([IF-FOUND], [IF-NOT-FOUND])
#
# This macro detects how to include the GL header file, and gives you the
# necessary CPPFLAGS in $sim_ac_gl_cppflags, and also sets the config.h
# defines HAVE_GL_GL_H or HAVE_OPENGL_GL_H if one of them is found.

AC_DEFUN([SIM_AC_CHECK_HEADER_GL],
[sim_ac_gl_header_avail=false
AC_MSG_CHECKING([how to include gl.h])
if test x"$with_opengl" != x"no"; then
  sim_ac_gl_save_CPPFLAGS=$CPPFLAGS
  sim_ac_gl_cppflags=

  if test x"$with_opengl" != xyes && test x"$with_opengl" != x""; then
    sim_ac_gl_cppflags="-I${with_opengl}/include"
  else
    # On HP-UX platforms, OpenGL headers and libraries are usually installed
    # at this location.
    sim_ac_gl_hpux=/opt/graphics/OpenGL
    if test -d $sim_ac_gl_hpux; then
      sim_ac_gl_cppflags=-I$sim_ac_gl_hpux/include
    fi
  fi

  # On Mac OS X, GL is part of the optional X11 fraemwork
  case $host_os in
  darwin*)
    AC_REQUIRE([SIM_AC_CHECK_X11])
    if test x$sim_ac_enable_darwin_x11 = xtrue; then
      sim_ac_gl_darwin_x11=/usr/X11R6
      if test -d $sim_ac_gl_darwin_x11; then
        sim_ac_gl_cppflags=-I$sim_ac_gl_darwin_x11/include
      fi
    fi
    ;;
  esac

  CPPFLAGS="$CPPFLAGS $sim_ac_gl_cppflags"

  # Mac OS X framework (no X11, -framework OpenGL) 
  if test x$sim_ac_enable_darwin_x11 = xfalse; then
    SIM_AC_CHECK_HEADER_SILENT([OpenGL/gl.h], [
      sim_ac_gl_header_avail=true
      sim_ac_gl_header=OpenGL/gl.h
      AC_DEFINE([HAVE_OPENGL_GL_H], 1, [define if the GL header should be included as OpenGL/gl.h])
    ])
  else
    SIM_AC_CHECK_HEADER_SILENT([GL/gl.h], [
      sim_ac_gl_header_avail=true
      sim_ac_gl_header=GL/gl.h
      AC_DEFINE([HAVE_GL_GL_H], 1, [define if the GL header should be included as GL/gl.h])
    ])
  fi

  CPPFLAGS="$sim_ac_gl_save_CPPFLAGS"
  if $sim_ac_gl_header_avail; then
    if test x"$sim_ac_gl_cppflags" = x""; then
      AC_MSG_RESULT([@%:@include <$sim_ac_gl_header>])
    else
      AC_MSG_RESULT([$sim_ac_gl_cppflags, @%:@include <$sim_ac_gl_header>])
    fi
    $1
  else
    AC_MSG_RESULT([not found])
    $2
  fi
else
  AC_MSG_RESULT([disabled])
  $2
fi
])# SIM_AC_CHECK_HEADER_GL

# **************************************************************************
# SIM_AC_CHECK_HEADER_GLU([IF-FOUND], [IF-NOT-FOUND])
#
# This macro detects how to include the GLU header file, and gives you the
# necessary CPPFLAGS in $sim_ac_glu_cppflags, and also sets the config.h
# defines HAVE_GL_GLU_H or HAVE_OPENGL_GLU_H if one of them is found.

AC_DEFUN([SIM_AC_CHECK_HEADER_GLU],
[sim_ac_glu_header_avail=false
AC_MSG_CHECKING([how to include glu.h])
if test x"$with_opengl" != x"no"; then
  sim_ac_glu_save_CPPFLAGS=$CPPFLAGS
  sim_ac_glu_cppflags=

  if test x"$with_opengl" != xyes && test x"$with_opengl" != x""; then
    sim_ac_glu_cppflags="-I${with_opengl}/include"
  else
    # On HP-UX platforms, OpenGL headers and libraries are usually installed
    # at this location.
    sim_ac_gl_hpux=/opt/graphics/OpenGL
    if test -d $sim_ac_gl_hpux; then
      sim_ac_glu_cppflags=-I$sim_ac_gl_hpux/include
    fi
  fi

  # On Mac OS X, GL is part of the optional X11 fraemwork
  case $host_os in
  darwin*)
    AC_REQUIRE([SIM_AC_CHECK_X11])
    if test x$sim_ac_enable_darwin_x11 = xtrue; then
      sim_ac_gl_darwin_x11=/usr/X11R6
      if test -d $sim_ac_gl_darwin_x11; then
        sim_ac_gl_cppflags=-I$sim_ac_gl_darwin_x11/include
      fi
    fi
    ;;
  esac

  CPPFLAGS="$CPPFLAGS $sim_ac_glu_cppflags"

  # Mac OS X framework (no X11, -framework OpenGL) 
  if test x$sim_ac_enable_darwin_x11 = xfalse; then
    SIM_AC_CHECK_HEADER_SILENT([OpenGL/glu.h], [
      sim_ac_glu_header_avail=true
      sim_ac_glu_header=OpenGL/glu.h
      AC_DEFINE([HAVE_OPENGL_GLU_H], 1, [define if the GLU header should be included as OpenGL/glu.h])
    ])
  else
    SIM_AC_CHECK_HEADER_SILENT([GL/glu.h], [
      sim_ac_glu_header_avail=true
      sim_ac_glu_header=GL/glu.h
      AC_DEFINE([HAVE_GL_GLU_H], 1, [define if the GLU header should be included as GL/glu.h])
    ])
  fi
 
  CPPFLAGS="$sim_ac_glu_save_CPPFLAGS"
  if $sim_ac_glu_header_avail; then
    if test x"$sim_ac_glu_cppflags" = x""; then
      AC_MSG_RESULT([@%:@include <$sim_ac_glu_header>])
    else
      AC_MSG_RESULT([$sim_ac_glu_cppflags, @%:@include <$sim_ac_glu_header>])
    fi
    $1
  else
    AC_MSG_RESULT([not found])
    $2
  fi
else
  AC_MSG_RESULT([disabled])
  $2
fi
])# SIM_AC_CHECK_HEADER_GLU

# **************************************************************************
# SIM_AC_CHECK_HEADER_GLEXT([IF-FOUND], [IF-NOT-FOUND])
#
# This macro detects how to include the GLEXT header file, and gives you the
# necessary CPPFLAGS in $sim_ac_glext_cppflags, and also sets the config.h
# defines HAVE_GL_GLEXT_H or HAVE_OPENGL_GLEXT_H if one of them is found.

AC_DEFUN([SIM_AC_CHECK_HEADER_GLEXT],
[sim_ac_glext_header_avail=false
AC_MSG_CHECKING([how to include glext.h])
if test x"$with_opengl" != x"no"; then
  sim_ac_glext_save_CPPFLAGS=$CPPFLAGS
  sim_ac_glext_cppflags=

  if test x"$with_opengl" != xyes && test x"$with_opengl" != x""; then
    sim_ac_glext_cppflags="-I${with_opengl}/include"
  else
    # On HP-UX platforms, OpenGL headers and libraries are usually installed
    # at this location.
    sim_ac_gl_hpux=/opt/graphics/OpenGL
    if test -d $sim_ac_gl_hpux; then
      sim_ac_glext_cppflags=-I$sim_ac_gl_hpux/include
    fi
  fi

  # On Mac OS X, GL is part of the optional X11 fraemwork
  case $host_os in
  darwin*)
    AC_REQUIRE([SIM_AC_CHECK_X11])
    if test x$sim_ac_enable_darwin_x11 = xtrue; then
      sim_ac_gl_darwin_x11=/usr/X11R6
      if test -d $sim_ac_gl_darwin_x11; then
        sim_ac_gl_cppflags=-I$sim_ac_gl_darwin_x11/include
      fi
    fi
    ;;
  esac

  CPPFLAGS="$CPPFLAGS $sim_ac_glext_cppflags"

  # Mac OS X framework (no X11, -framework OpenGL) 
  if test x$sim_ac_enable_darwin_x11 = xfalse; then
    SIM_AC_CHECK_HEADER_SILENT([OpenGL/glext.h], [
      sim_ac_glext_header_avail=true
      sim_ac_glext_header=OpenGL/glext.h
      AC_DEFINE([HAVE_OPENGL_GLEXT_H], 1, [define if the GLEXT header should be included as OpenGL/glext.h])
    ])
  else
    SIM_AC_CHECK_HEADER_SILENT([GL/glext.h], [
      sim_ac_glext_header_avail=true
      sim_ac_glext_header=GL/glext.h
      AC_DEFINE([HAVE_GL_GLEXT_H], 1, [define if the GLEXT header should be included as GL/glext.h])
    ])
  fi

  CPPFLAGS="$sim_ac_glext_save_CPPFLAGS"
  if $sim_ac_glext_header_avail; then
    if test x"$sim_ac_glext_cppflags" = x""; then
      AC_MSG_RESULT([@%:@include <$sim_ac_glext_header>])
    else
      AC_MSG_RESULT([$sim_ac_glext_cppflags, @%:@include <$sim_ac_glext_header>])
    fi
    $1
  else
    AC_MSG_RESULT([not found])
    $2
  fi
else
  AC_MSG_RESULT([disabled])
  $2
fi
])# SIM_AC_CHECK_HEADER_GLEXT


# **************************************************************************
# SIM_AC_CHECK_OPENGL([IF-FOUND], [IF-NOT-FOUND])
#
# This macro detects whether or not it's possible to link against OpenGL
# (or Mesa), and gives you the necessary modifications to the
# pre-processor, compiler and linker environment in the envvars
#
#                $sim_ac_ogl_cppflags
#                $sim_ac_ogl_ldflags
#                $sim_ac_ogl_libs
#
# The necessary extra options are also automatically added to CPPFLAGS,
# LDFLAGS and LIBS.
#
# Authors: <larsa@sim.no>, <mortene@sim.no>.

AC_DEFUN(SIM_AC_CHECK_OPENGL, [

sim_ac_ogl_cppflags=
sim_ac_ogl_ldflags=
sim_ac_ogl_libs=

AC_ARG_WITH(
  [mesa],
  AC_HELP_STRING([--with-mesa],
                 [prefer MesaGL (if found) over OpenGL [[default=yes]]]),
  [],
  [with_mesa=yes])

## Mac OS X uses some weird "framework" options.

## It's usually libGL.so on UNIX systems and opengl32.lib on MSWindows.
sim_ac_ogl_glnames="-lGL -lopengl32"
sim_ac_ogl_mesaglnames=-lMesaGL

if test "x$with_mesa" = "xyes"; then
  sim_ac_ogl_first=$sim_ac_ogl_mesaglnames
  sim_ac_ogl_second=$sim_ac_ogl_glnames
else
  sim_ac_ogl_first=$sim_ac_ogl_glnames
  sim_ac_ogl_second=$sim_ac_ogl_mesaglnames
fi

AC_ARG_WITH(
  [opengl],
  AC_HELP_STRING([--with-opengl=DIR],
                 [OpenGL/Mesa installation directory]),
  [],
  [with_opengl=yes])

if test x"$with_opengl" != xno; then

  if test x"$with_opengl" != xyes && test x"$with_opengl" != x""; then
    sim_ac_ogl_ldflags=-L$with_opengl/lib
    # $sim_ac_ogl_cppflags is set up in the SIM_AC_CHECK_HEADER_GL
    # invocation further below.
  else
    # On HP-UX platforms, OpenGL headers and libraries are usually installed
    # at this location.
    sim_ac_gl_hpux=/opt/graphics/OpenGL
    if test -d $sim_ac_gl_hpux; then
      sim_ac_ogl_ldflags=-L$sim_ac_gl_hpux/lib
    fi
  fi

  sim_ac_use_framework_option=false;
  case $host_os in
  darwin*)
    AC_REQUIRE([SIM_AC_CHECK_X11])
    if test x"$GCC" = x"yes" -a x$sim_ac_enable_darwin_x11 = xfalse; then
      SIM_AC_CC_COMPILER_OPTION([-framework OpenGL], [sim_ac_use_framework_option=true])
    else
      # On Mac OS X, OpenGL is installed as part of the optional X11 SDK.
      sim_ac_gl_darwin_x11=/usr/X11R6
      if test -d $sim_ac_gl_darwin_x11; then
        sim_ac_ogl_cppflags=-I$sim_ac_gl_darwin_x11/include
        sim_ac_ogl_ldflags=-L$sim_ac_gl_darwin_x11/lib
      fi
    fi
    ;;
  esac

  if $sim_ac_use_framework_option; then
    # hopefully, this is the default behavior and not needed. 20011005 larsa
    # sim_ac_ogl_cppflags="-F/System/Library/Frameworks/OpenGL.framework/"
    sim_ac_ogl_ldflags="-Wl,-framework,OpenGL"
  fi

  sim_ac_save_cppflags=$CPPFLAGS
  sim_ac_save_ldflags=$LDFLAGS
  sim_ac_save_libs=$LIBS

  CPPFLAGS="$CPPFLAGS $sim_ac_ogl_cppflags"
  LDFLAGS="$LDFLAGS $sim_ac_ogl_ldflags"

  SIM_AC_CHECK_HEADER_GL([CPPFLAGS="$CPPFLAGS $sim_ac_gl_cppflags"],
                         [AC_MSG_WARN([could not find gl.h])])

  sim_ac_glchk_hit=false
  for sim_ac_tmp_outerloop in barebones withpthreads; do
    if $sim_ac_glchk_hit; then :; else

      sim_ac_oglchk_pthreadslib=""
      if test "$sim_ac_tmp_outerloop" = "withpthreads"; then
        AC_MSG_WARN([couldn't compile or link with OpenGL library -- trying with pthread library in place...])
        LIBS="$sim_ac_save_libs"
        SIM_AC_CHECK_PTHREAD([
          sim_ac_ogl_cppflags="$sim_ac_ogl_cppflags $sim_ac_pthread_cppflags"
          sim_ac_ogl_ldflags="$sim_ac_ogl_ldflags $sim_ac_pthread_ldflags"
          sim_ac_oglchk_pthreadslib="$sim_ac_pthread_libs"
          ],
          [AC_MSG_WARN([couldn't compile or link with pthread library])
          ])
      fi

      AC_MSG_CHECKING([for OpenGL library dev-kit])
      # Mac OS X uses nada (only LDFLAGS), which is why "" was set first
      for sim_ac_ogl_libcheck in "" $sim_ac_ogl_first $sim_ac_ogl_second; do
        if $sim_ac_glchk_hit; then :; else
          LIBS="$sim_ac_ogl_libcheck $sim_ac_oglchk_pthreadslib $sim_ac_save_libs"
          AC_TRY_LINK(
            [#ifdef HAVE_WINDOWS_H
             #include <windows.h>
             #endif
             #ifdef HAVE_GL_GL_H
             #include <GL/gl.h>
             #endif
             #ifdef HAVE_OPENGL_GL_H
             /* Mac OS X */
             #include <OpenGL/gl.h>
             #endif
            ],
            [glPointSize(1.0f);],
            [
             sim_ac_glchk_hit=true
             sim_ac_ogl_libs="$sim_ac_ogl_libcheck $sim_ac_oglchk_pthreadslib"
            ]
          )
        fi
      done
      if $sim_ac_glchk_hit; then
        AC_MSG_RESULT($sim_ac_ogl_cppflags $sim_ac_ogl_ldflags $sim_ac_ogl_libs)
      else
        AC_MSG_RESULT([unresolved])
      fi
    fi
  done

  if $sim_ac_glchk_hit; then
    LIBS="$sim_ac_ogl_libs $sim_ac_save_libs"
    $1
  else
    CPPFLAGS="$sim_ac_save_cppflags"
    LDFLAGS="$sim_ac_save_ldflags"
    LIBS="$sim_ac_save_libs"
    $2
  fi
fi
])


# **************************************************************************
# SIM_AC_GLU_READY_IFELSE( [ACTION-IF-TRUE], [ACTION-IF-FALSE] )

AC_DEFUN([SIM_AC_GLU_READY_IFELSE], [
sim_ac_glu_save_CPPFLAGS=$CPPFLAGS
SIM_AC_CHECK_HEADER_GLU(, [AC_MSG_WARN([could not find glu.h])])
if test x"$sim_ac_gl_cppflags" != x"$sim_ac_glu_cppflags"; then
  CPPFLAGS="$CPPFLAGS $sim_ac_gl_cppflags $sim_ac_glu_cppflags"
fi
AC_CACHE_CHECK(
  [if GLU is available as part of GL library],
  [sim_cv_glu_ready],
  [AC_TRY_LINK(
    [
#ifdef HAVE_WINDOWS_H
#include <windows.h>
#endif /* HAVE_WINDOWS_H */
#ifdef HAVE_GL_GL_H
#include <GL/gl.h>
#else
#ifdef HAVE_OPENGL_GL_H
#include <OpenGL/gl.h>
#endif
#endif
#ifdef HAVE_GL_GLU_H
#include <GL/glu.h>
#else
#ifdef HAVE_OPENGL_GLU_H
#include <OpenGL/glu.h>
#endif
#endif
],
    [
gluSphere(0L, 1.0, 1, 1);
/* Defect JAGad01283 of HP's aCC compiler causes a link failure unless
   there is at least one "pure" OpenGL call along with GLU calls. */
glEnd();
],
    [sim_cv_glu_ready=true],
    [sim_cv_glu_ready=false])])

if $sim_cv_glu_ready; then
  ifelse([$1], , :, [$1])
else
  ifelse([$2], , :, [$2])
fi
]) # SIM_AC_GLU_READY_IFELSE()

############################################################################
# Usage:
#  SIM_AC_CHECK_GLU([ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND]])
#
#  Try to use the OpenGL utility library; GLU. If it is found,
#  these shell variables are set:
#
#    $sim_ac_glu_cppflags (extra flags the compiler needs for GLU)
#    $sim_ac_glu_ldflags  (extra flags the linker needs for GLU)
#    $sim_ac_glu_libs     (link libraries the linker needs for GLU)
#
#  The CPPFLAGS, LDFLAGS and LIBS flags will also be modified accordingly.
#  In addition, the variable $sim_ac_glu_avail is set to "yes" if GLU
#  is found.
#
#
# Author: Morten Eriksen, <mortene@sim.no>.

AC_DEFUN([SIM_AC_CHECK_GLU], [
sim_ac_glu_save_CPPFLAGS=$CPPFLAGS
SIM_AC_CHECK_HEADER_GLU(, [AC_MSG_WARN([could not find glu.h])])
if test x"$sim_ac_gl_cppflags" != x"$sim_ac_glu_cppflags"; then
  CPPFLAGS="$CPPFLAGS $sim_ac_gl_cppflags $sim_ac_glu_cppflags"
fi
sim_ac_glu_avail=no

# It's usually libGLU.so on UNIX systems and glu32.lib on MSWindows.
sim_ac_glu_names="-lGLU -lglu32"
sim_ac_glu_mesanames=-lMesaGLU

# with_mesa is set from the SIM_AC_CHECK_OPENGL macro.
if test "x$with_mesa" = "xyes"; then
  sim_ac_glu_first=$sim_ac_glu_mesanames
  sim_ac_glu_second=$sim_ac_glu_names
else
  sim_ac_glu_first=$sim_ac_glu_names
  sim_ac_glu_second=$sim_ac_glu_mesanames
fi

AC_ARG_WITH(
  [glu],
  AC_HELP_STRING([--with-glu=DIR],
                 [use the OpenGL utility library [[default=yes]]]),
  [],
  [with_glu=yes])

if test x"$with_glu" != xno; then
  if test x"$with_glu" != xyes; then
    # sim_ac_glu_cppflags="-I${with_glu}/include"
    sim_ac_glu_ldflags="-L${with_glu}/lib"
  fi

  sim_ac_save_cppflags=$CPPFLAGS
  sim_ac_save_ldflags=$LDFLAGS
  sim_ac_save_libs=$LIBS

  CPPFLAGS="$CPPFLAGS $sim_ac_glu_cppflags"
  LDFLAGS="$LDFLAGS $sim_ac_glu_ldflags"

  AC_CACHE_CHECK(
    [whether GLU is available],
    sim_cv_lib_glu,
    [sim_cv_lib_glu=UNRESOLVED

    # Some platforms (like BeOS) have the GLU functionality in the GL
    # library (and no GLU library present).
    for sim_ac_glu_libcheck in "" $sim_ac_glu_first $sim_ac_glu_second; do
      if test "x$sim_cv_lib_glu" = "xUNRESOLVED"; then
        LIBS="$sim_ac_glu_libcheck $sim_ac_save_libs"
        AC_TRY_LINK([
#ifdef HAVE_WINDOWS_H
#include <windows.h>
#endif /* HAVE_WINDOWS_H */
#ifdef HAVE_GL_GL_H
#include <GL/gl.h>
#else
#ifdef HAVE_OPENGL_GL_H
#include <OpenGL/gl.h>
#endif
#endif
#ifdef HAVE_GL_GLU_H
#include <GL/glu.h>
#else
#ifdef HAVE_OPENGL_GLU_H
#include <OpenGL/glu.h>
#endif
#endif
],
                    [
gluSphere(0L, 1.0, 1, 1);
/* Defect JAGad01283 of HP's aCC compiler causes a link failure unless
   there is at least one "pure" OpenGL call along with GLU calls. */
glEnd();
],
                    [sim_cv_lib_glu="$sim_ac_glu_libcheck"])
      fi
    done
    if test x"$sim_cv_lib_glu" = x"" &&
       test x`echo $LDFLAGS | grep -c -- "-Wl,-framework,OpenGL"` = x1; then
      # just for the visual representation on Mac OS X
      sim_cv_lib_glu="-Wl,-framework,OpenGL"
    fi
  ])

  LIBS="$sim_ac_save_libs"

  CPPFLAGS=$sim_ac_glu_save_CPPFLAGS
  if test "x$sim_cv_lib_glu" != "xUNRESOLVED"; then
    if test x"$sim_cv_lib_glu" = x"-Wl,-framework,OpenGL"; then
      sim_ac_glu_libs=""
    else
      sim_ac_glu_libs="$sim_cv_lib_glu"
    fi
    LIBS="$sim_ac_glu_libs $sim_ac_save_libs"
    sim_ac_glu_avail=yes
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
#  SIM_AC_GLU_NURBSOBJECT([ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND]])
#
#  Try to find out whether the interface struct against the GLU
#  library NURBS functions is called "GLUnurbs" or "GLUnurbsObj".
#  (This seems to have changed somewhere between release 1.1 and
#  release 1.3 of GLU).
#
#  The variable $sim_ac_glu_nurbsobject is set to the correct name
#  if the nurbs structure is found.
#
# Author: Morten Eriksen, <mortene@sim.no>.

AC_DEFUN(SIM_AC_GLU_NURBSOBJECT, [
AC_CACHE_CHECK(
  [what structure to use in the GLU NURBS interface],
  sim_cv_func_glu_nurbsobject,
  [sim_cv_func_glu_nurbsobject=NONE
   for sim_ac_glu_structname in GLUnurbs GLUnurbsObj; do
    if test "$sim_cv_func_glu_nurbsobject" = NONE; then
      AC_TRY_LINK([
#ifdef HAVE_WINDOWS_H
#include <windows.h>
#endif /* HAVE_WINDOWS_H */
#ifdef HAVE_GL_GL_H
#include <GL/gl.h>
#else
#ifdef HAVE_OPENGL_GL_H
#include <OpenGL/gl.h>
#endif
#endif
#ifdef HAVE_GL_GLU_H
#include <GL/glu.h>
#else
#ifdef HAVE_OPENGL_GLU_H
#include <OpenGL/glu.h>
#endif
#endif
],
                  [
$sim_ac_glu_structname * hepp = gluNewNurbsRenderer();
gluDeleteNurbsRenderer(hepp);
/* Defect JAGad01283 of HP's aCC compiler causes a link failure unless
   there is at least one "pure" OpenGL call along with GLU calls. */
glEnd();
],
                  [sim_cv_func_glu_nurbsobject=$sim_ac_glu_structname])
    fi
  done
])

if test $sim_cv_func_glu_nurbsobject = NONE; then
  sim_ac_glu_nurbsobject=
  $2
else
  sim_ac_glu_nurbsobject=$sim_cv_func_glu_nurbsobject
  $1
fi
])

# **************************************************************************
# SIM_AC_HAVE_GLXGETCURRENTDISPLAY_IFELSE( IF-FOUND, IF-NOT-FOUND )
#
# Check whether the OpenGL implementation includes the method
# glXGetCurrentDisplay().

AC_DEFUN([SIM_AC_HAVE_GLXGETCURRENTDISPLAY_IFELSE], [
AC_CACHE_CHECK(
  [whether glXGetCurrentDisplay() is available],
  sim_cv_have_glxgetcurrentdisplay,
  AC_TRY_LINK([
#include <GL/gl.h>
#include <GL/glx.h>
],
[(void)glXGetCurrentDisplay();],
[sim_cv_have_glxgetcurrentdisplay=true],
[sim_cv_have_glxgetcurrentdisplay=false]))

if ${sim_cv_have_glxgetcurrentdisplay}; then
  ifelse([$1], , :, [$1])
else
  ifelse([$2], , :, [$2])
fi
]) # SIM_AC_HAVE_GLXGETCURRENTDISPLAY_IFELSE()

# **************************************************************************
# SIM_AC_HAVE_GLX_IFELSE( IF-FOUND, IF-NOT-FOUND )
#
# Check whether GLX is on the system.

AC_DEFUN([SIM_AC_HAVE_GLX_IFELSE], [
AC_CACHE_CHECK(
  [whether GLX is on the system],
  sim_cv_have_glx,
  AC_TRY_LINK(
    [
#include <GL/glx.h>
#include <GL/gl.h>
],
    [
(void)glXChooseVisual(0L, 0, 0L);
/* Defect JAGad01283 of HP's aCC compiler causes a link failure unless
   there is at least one "pure" OpenGL call along with GLU calls. */
glEnd();
],
    [sim_cv_have_glx=true],
    [sim_cv_have_glx=false]))

if ${sim_cv_have_glx=false}; then
  ifelse([$1], , :, [$1])
else
  ifelse([$2], , :, [$2])
fi
]) # SIM_AC_HAVE_GLX_IFELSE()

# **************************************************************************
# SIM_AC_HAVE_GLXGETPROCADDRESSARB_IFELSE( IF-FOUND, IF-NOT-FOUND )
#
# Check for glXGetProcAddressARB() function.

AC_DEFUN([SIM_AC_HAVE_GLXGETPROCADDRESSARB_IFELSE], [
AC_CACHE_CHECK(
  [for glXGetProcAddressARB() function],
  sim_cv_have_glxgetprocaddressarb,
  AC_TRY_LINK(
    [
#include <GL/glx.h>
#include <GL/gl.h>
],
    [
      glXGetProcAddressARB((const GLubyte *)"glClearColor");
/* Defect JAGad01283 of HP's aCC compiler causes a link failure unless
   there is at least one "pure" OpenGL call along with GLU calls. */
      glEnd();
],
    [sim_cv_have_glxgetprocaddressarb=true],
    [sim_cv_have_glxgetprocaddressarb=false]))

if ${sim_cv_have_glxgetprocaddressarb=false}; then
  ifelse([$1], , :, [$1])
else
  ifelse([$2], , :, [$2])
fi
]) # SIM_AC_HAVE_GLXGETPROCADDRESSARB_IFELSE()


# **************************************************************************
# SIM_AC_HAVE_WGL_IFELSE( IF-FOUND, IF-NOT-FOUND )
#
# Check whether WGL is on the system.
#
# This macro has one important side-effect: the variable
# sim_ac_wgl_libs will be set to the list of libraries
# needed to link with wgl*() functions.

AC_DEFUN([SIM_AC_HAVE_WGL_IFELSE], [
sim_ac_save_libs=$LIBS
## Not directly needed by the wgl*() calls, but to create a
## context we need functions from this library.
sim_ac_wgl_libs="-lgdi32"
LIBS="$LIBS $sim_ac_wgl_libs"

AC_CACHE_CHECK(
  [whether WGL is on the system],
  sim_cv_have_wgl,
  AC_TRY_LINK(
    [
#include <windows.h>
#include <GL/gl.h>
],
    [(void)wglCreateContext(0L);],
    [sim_cv_have_wgl=true],
    [sim_cv_have_wgl=false]))

LIBS=$sim_ac_save_libs
if ${sim_cv_have_wgl=false}; then
  ifelse([$1], , :, [$1])
else
  ifelse([$2], , :, [$2])
fi
]) # SIM_AC_HAVE_WGL_IFELSE()

# **************************************************************************
# SIM_AC_HAVE_AGL_IFELSE( IF-FOUND, IF-NOT-FOUND )
#
# Check whether AGL is on the system.

AC_DEFUN([SIM_AC_HAVE_AGL_IFELSE], [
sim_ac_save_ldflags=$LDFLAGS
sim_ac_agl_ldflags="-Wl,-framework,ApplicationServices -Wl,-framework,AGL"

LDFLAGS="$LDFLAGS $sim_ac_agl_ldflags"

AC_CACHE_CHECK(
  [whether AGL is on the system],
  sim_cv_have_agl,
  AC_TRY_LINK(
    [#include <AGL/agl.h>
#include <Carbon/Carbon.h>],
    [aglGetCurrentContext();],
    [sim_cv_have_agl=true],
    [sim_cv_have_agl=false]))

LDFLAGS=$sim_ac_save_ldflags
if ${sim_cv_have_agl=false}; then
  ifelse([$1], , :, [$1])
else
  ifelse([$2], , :, [$2])
fi
]) # SIM_AC_HAVE_AGL_IFELSE()
 

AC_DEFUN([SIM_AC_HAVE_AGL_PBUFFER], [
  AC_CACHE_CHECK([whether we can use AGL pBuffers],
    sim_cv_agl_pbuffer_avail,
    [AC_TRY_LINK([ #include <AGL/agl.h> ],
                 [AGLPbuffer pbuffer;],
                 [sim_cv_agl_pbuffer_avail=yes],
                 [sim_cv_agl_pbuffer_avail=no])])
  
  if test x"$sim_cv_agl_pbuffer_avail" = xyes; then
    ifelse([$1], , :, [$1])
  else
    ifelse([$2], , :, [$2])
  fi
])

