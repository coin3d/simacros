############################################################################
# Helper macros for the SIM_AC_CHECK_QT macro below.

# SIM_AC_WITH_QT
#
# Sets sim_ac_with_qt (from --with-qt=[true|false]) and
# sim_ac_qtdir (from either --with-qt=DIR or $QTDIR).

AC_DEFUN([SIM_AC_WITH_QT], [
sim_ac_qtdir=
AC_ARG_WITH(
  [qt],
  AC_HELP_STRING([--with-qt=[true|false|DIR]],
                 [specify if Qt should be used, and optionally the location of the Qt library [default=true]]),
  [case $withval in
  no | false ) sim_ac_with_qt=false ;;
  yes | true ) sim_ac_with_qt=true ;;
  *)
    sim_ac_with_qt=true
    sim_ac_qtdir=$withval
    ;;
  esac],
  [sim_ac_with_qt=true])

if $sim_ac_with_qt; then
  if test -z "$sim_ac_qtdir"; then
    # The Cygwin environment needs to invoke moc with a POSIX-style path.
    AC_PATH_PROG(sim_ac_qt_cygpath, cygpath, false)
    if test $sim_ac_qt_cygpath = "false"; then
      sim_ac_qtdir=$QTDIR
    else
      # Quote $QTDIR in case it's empty.
      sim_ac_qtdir=`$sim_ac_qt_cygpath -u "$QTDIR"`
    fi

    AC_MSG_CHECKING([value of the QTDIR environment variable])
    if test x"$sim_ac_qtdir" = x""; then
      AC_MSG_RESULT([empty])
    else
      AC_MSG_RESULT([$sim_ac_qtdir])

      # list contents of what's in the qt dev environment into config.log
      for i in "" bin lib; do
        echo "Listing contents of $sim_ac_qtdir/$i:" >&5
        ls -l $sim_ac_qtdir/$i >&5 2>&1
      done
    fi
  fi
fi
])

# SIM_AC_QT_PROG(VARIABLE, PROG-TO-CHECK-FOR)
#
# Substs VARIABLE to the path of the PROG-TO-CHECK-FOR, if found
# in either $PATH, $QTDIR/bin or the --with-qt=DIR directories.
#
# If not found, VARIABLE will be set to false.

AC_DEFUN([SIM_AC_QT_PROG], [
AC_REQUIRE([SIM_AC_WITH_QT])

if $sim_ac_with_qt; then

  sim_ac_path=$PATH
  if test -n "$sim_ac_qtdir"; then
    sim_ac_path=$sim_ac_qtdir/bin:$PATH
  fi

  AC_PATH_PROG([$1], $2, false, $sim_ac_path)
  if test x"$$1" = x"false"; then
    if test -z "$QTDIR"; then
      AC_MSG_WARN([QTDIR environment variable not set -- this might be an indication of a problem])
    fi
    AC_MSG_WARN([the ``$2'' Qt pre-processor tool not found])
  fi
else
  AC_SUBST([$1], [false])
fi
])

############################################################################
# Usage:
#  SIM_AC_QT_VERSION
#
# Find version number of the Qt library. sim_ac_qt_version will contain
# the full version number string, and sim_ac_qt_major_version will contain
# only the major version number.

AC_DEFUN([SIM_AC_QT_VERSION], [

AC_MSG_CHECKING([version of Qt library])

cat > conftest.c << EOF
#include <qglobal.h>
int VerQt = QT_VERSION;
EOF

# The " *"-parts of the last sed-expression on the next line are necessary
# because at least the Solaris/CC preprocessor adds extra spaces before and
# after the trailing semicolon.
sim_ac_qt_version=`$CXXCPP $CPPFLAGS conftest.c 2>/dev/null | grep '^int VerQt' | sed 's%^int VerQt = %%' | sed 's% *;.*$%%'`

case $sim_ac_qt_version in
0x* )
  sim_ac_qt_version=`echo $sim_ac_qt_version | sed -e 's/^0x.\(.\).\(.\).\(.\)/\1\2\3/;'`
  ;;
* )
  # nada
  ;;
esac
sim_ac_qt_major_version=`echo $sim_ac_qt_version | cut -c1`

rm -f conftest.c
AC_MSG_RESULT($sim_ac_qt_version)
])

############################################################################
# Usage:
#  SIM_AC_CHECK_QT([ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND]])
#
#  Try to find the Qt development system. If it is found, these
#  shell variables are set:
#
#    $sim_ac_qt_cppflags (extra flags the compiler needs for Qt lib)
#    $sim_ac_qt_ldflags  (extra flags the linker needs for Qt lib)
#    $sim_ac_qt_libs     (link libraries the linker needs for Qt lib)
#
#  The CPPFLAGS, LDFLAGS and LIBS flags will also be modified accordingly.
#  In addition, the variable $sim_ac_qt_avail is set to "yes" if
#  the Qt development system is found.
#
# Authors:
#   Morten Eriksen <mortene@sim.no>.
#   Lars J. Aas <larsa@sim.no>.

AC_DEFUN([SIM_AC_CHECK_QT], [

AC_REQUIRE([SIM_AC_WITH_QT])

AC_ARG_ENABLE(
  [qt-debug],
  AC_HELP_STRING([--enable-qt-debug], [win32: link with debug versions of Qt libraries]),
  [case $enableval in
  yes | true ) sim_ac_qt_debug=true ;;
  *) sim_ac_qt_debug=false ;;
  esac],
  [sim_ac_qt_debug=false])

sim_ac_qt_avail=no

if $sim_ac_with_qt; then

  sim_ac_save_cppflags=$CPPFLAGS
  sim_ac_save_ldflags=$LDFLAGS
  sim_ac_save_libs=$LIBS

  sim_ac_qt_libs=UNRESOLVED

  # Check for Mac OS framework installation
  if test -z "$QTDIR"; then
    sim_ac_qt_framework_dir=/Library/Frameworks
    # FIXME: Should we also look for the Qt framework in other
    # default framework locations (such as ~/Library/Frameworks)?
    # Or require the user to specify this explicitly, e.g. by
    # passing --with-qt-framework=xxx? 20050802 kyrah.
  else
    sim_ac_qt_framework_dir=$sim_ac_qtdir/lib
  fi

  SIM_AC_HAVE_QT_FRAMEWORK

  if $sim_ac_have_qt_framework; then
    sim_ac_qt_cppflags="-I$sim_ac_qt_framework_dir/QtCore.framework/Headers -I$sim_ac_qt_framework_dir/QtOpenGL.framework/Headers -I$sim_ac_qt_framework_dir/QtGui.framework/Headers -F$sim_ac_qt_framework_dir"
    sim_ac_qt_libs="-Wl,-F$sim_ac_qt_framework_dir -Wl,-framework,QtGui -Wl,-framework,QtOpenGL -Wl,-framework,QtCore -Wl,-framework,QtXml -Wl,-framework,QtNetwork -Wl,-framework,QtSql"
  else

    sim_ac_qglobal_unresolved=true

    sim_ac_QTDIR_cppflags=
    sim_ac_QTDIR_ldflags=
    if test -n "$sim_ac_qtdir"; then
      sim_ac_QTDIR_cppflags="-I$sim_ac_qtdir/include"
      sim_ac_QTDIR_ldflags="-L$sim_ac_qtdir/lib"
      CPPFLAGS="$sim_ac_QTDIR_cppflags $CPPFLAGS"
      LDFLAGS="$LDFLAGS $sim_ac_QTDIR_ldflags"
    fi

    # This should take care of detecting qglobal.h for Qt 3 if QTDIR was set,
    # or if Qt is in default locations, or if it is in any additional "-I..."
    # set up by the user with CPPFLAGS:
    sim_ac_temp="$CPPFLAGS"
    SIM_AC_CHECK_HEADER_SILENT([qglobal.h], [sim_ac_qglobal_unresolved=false])

    # If we're to use Qt 4 and QTDIR is set, this should be able to find it:
    if $sim_ac_qglobal_unresolved; then
      SIM_AC_CHECK_HEADER_SILENT([Qt/qglobal.h],
                                 [sim_ac_qglobal_unresolved=false])
      if $sim_ac_qglobal_unresolved; then
        :
      else
        if test -z "$sim_ac_QTDIR_cppflags"; then
          AC_MSG_ERROR([Qt/qglobal.h detected, but no QTDIR environment variable set. Do not know where the Qt include files are.])
        else
          sim_ac_QTDIR_cppflags="$sim_ac_QTDIR_cppflags $sim_ac_QTDIR_cppflags/Qt"
        fi
      fi
    fi
    CPPFLAGS="$sim_ac_temp"

    # Check for known default locations of Qt installation on various
    # systems:
    if $sim_ac_qglobal_unresolved; then
      sim_ac_temp="$CPPFLAGS"
      # /usr/include/qt: Debian-installations with Qt 3
      # /usr/include/qt4: Debian-installations with Qt 4
      # /sw/include/qt: Mac OS X Fink
      for i in "/usr/include/qt" "/usr/include/qt4" "/sw/include/qt"; do
        if $sim_ac_qglobal_unresolved; then
          CPPFLAGS="-I$i $sim_ac_temp"
          SIM_AC_CHECK_HEADER_SILENT([qglobal.h],
                                     [sim_ac_qglobal_unresolved=false
                                      sim_ac_QTDIR_cppflags="-I$i"
                                     ])
          if $sim_ac_qglobal_unresolved; then
            SIM_AC_CHECK_HEADER_SILENT([Qt/qglobal.h],
                                       [sim_ac_qglobal_unresolved=false
                                        sim_ac_QTDIR_cppflags="-I$i -I$i/Qt"
                                       ])
          fi
        fi
      done
      CPPFLAGS="$sim_ac_temp"
    fi

    # Mac OS X Darwin ports
    if $sim_ac_qglobal_unresolved; then
      sim_ac_temp="$CPPFLAGS"
      sim_ac_i="-I/opt/local/include/qt3"
      CPPFLAGS="$sim_ac_i $CPPFLAGS"
      SIM_AC_CHECK_HEADER_SILENT([qglobal.h],
                                 [sim_ac_qglobal_unresolved=false
                                  sim_ac_QTDIR_cppflags="$sim_ac_i"
                                  sim_ac_QTDIR_ldflags="-L/opt/local/lib"
                                 ])
      CPPFLAGS="$sim_ac_temp"
    fi

    if $sim_ac_qglobal_unresolved; then
      AC_MSG_WARN([header file qglobal.h not found, can not compile Qt code])
    else
      CPPFLAGS="$sim_ac_QTDIR_cppflags $CPPFLAGS"
      LDFLAGS="$LDFLAGS $sim_ac_QTDIR_ldflags"

      SIM_AC_QT_VERSION

      if test $sim_ac_qt_version -lt 200; then
        SIM_AC_ERROR([too-old-qt])
      fi

      # Too hard to feature-check for the Qt-on-Mac problems, as they involve
      # obscure behavior of the QGLWidget -- so we just resort to do platform
      # and version checking instead.
      case $host_os in
      darwin*)
        if test $sim_ac_qt_version -lt 302; then
          SIM_AC_CONFIGURATION_WARNING([The version of Qt you are using is known to contain some serious bugs on MacOS X. We strongly recommend you to upgrade. (See $srcdir/README.MAC for details.)])
        fi

        if $sim_ac_enable_darwin_x11; then
          # --enable-darwin-x11 specified but attempting Qt/Mac linkage
          AC_TRY_COMPILE([#include <qapplication.h>],
                      [#if defined(__APPLE__) && defined(Q_WS_MAC)
                       #error blah!
                       #endif],[],
                      [SIM_AC_ERROR([mac-qt-but-x11-requested])])
        else
          # Using Qt/X11 but option --enable-darwin-x11 not given
          AC_TRY_COMPILE([#include <qapplication.h>],
                    [#if defined(__APPLE__) && defined(Q_WS_X11)
                     #error blah!
                     #endif],[],
                    [SIM_AC_ERROR([x11-qt-but-no-x11-requested])])
        fi
        ;;
      esac

      # Known problems:
      #
      #   * Qt v3.0.1 has a bug where SHIFT-PRESS + CTRL-PRESS + CTRL-RELEASE
      #     results in the last key-event coming out completely wrong under X11.
      #     Known to be fixed in 3.0.3, unknown status in 3.0.2.  <mortene@sim.no>.
      #
      if test $sim_ac_qt_version -lt 303; then
        SIM_AC_CONFIGURATION_WARNING([The version of Qt you are compiling against is known to contain bugs which influences functionality in SoQt. We strongly recommend you to upgrade.])
      fi

      sim_ac_qt_cppflags=

      # Do not cache the result, as we might need to play tricks with
      # CPPFLAGS under MSWin.

      # It should be helpful to be able to override the libs-checking with
      # environment variables. Then people won't get completely stuck
      # when the check fails -- we can just take a look at the
      # config.log and give them advice on how to proceed with no updates
      # necessary.
      #
      # (Note also that this makes it possible to select whether to use the
      # mt-safe or the "standard" Qt library if both are installed on the
      # user's system.)
      #
      # mortene.

      if test x"$CONFIG_QTLIBS" != x""; then
        AC_MSG_CHECKING([for Qt linking with $CONFIG_QTLIBS])

        for sim_ac_qt_cppflags_loop in "" "-DQT_DLL"; do
          CPPFLAGS="$sim_ac_QTDIR_cppflags $sim_ac_qt_cppflags_loop $sim_ac_save_cppflags"
          LIBS="$CONFIG_QTLIBS $sim_ac_save_libs"
          AC_TRY_LINK([#include <qapplication.h>],
                      [
                       // FIXME: assignment to qApp does no longer work with Qt 4,
                       // should try to find another way to do the same thing. 20050629 mortene.
                       #if QT_VERSION < 0x040000
                       qApp = NULL; /* QT_DLL must be defined for assignment to global variables to work */
                       #endif
                       qApp->exit(0);],
                      [sim_ac_qt_libs="$CONFIG_QTLIBS"
                       sim_ac_qt_cppflags="$sim_ac_QTDIR_cppflags $sim_ac_qt_cppflags_loop"
                       sim_ac_qt_ldflags="$sim_ac_QTDIR_ldflags"
                      ])
        done

        if test "x$sim_ac_qt_libs" = "xUNRESOLVED"; then
          AC_MSG_RESULT([failed!])
        else
          AC_MSG_RESULT([ok])
        fi

      else
        AC_MSG_CHECKING([for Qt library devkit])

        ## Test all known possible combinations of linking against the
        ## Troll Tech Qt library:
        ##
        ## * "-lQtGui": Qt 4 on UNIX-like systems
        ##
        ## * "-lQtGui -lQtCore -luser32 -lole32 -limm32 -lcomdlg32 -lgdi32 -lwinspool -lwinmm -ladvapi32 -lws2_32 -lshell32"
        ##   Should cover static linking against Qt4 on win32
        ##
        ## * "-lqt-gl": links against the standard Debian version of the
        ##   Qt library with embedded QGL
        ##
        ## * "-lqt": should work for most UNIX(-derived) platforms on
        ##   dynamic and static linking with the non-mtsafe library
        ##
        ## * "-lqt-mt": should work for most UNIX(-derived) platforms on
        ##   dynamic and static linking with the mtsafe library
        ##
        ## * "-lqt{version} -lqtmain -lgdi32": w/QT_DLL defined should
        ##   cover dynamic Enterprise Edition linking on Win32 platforms
        ##
        ## * "-lqt -lqtmain -lgdi32": ...unless the {version} suffix is missing,
        ##   which we've had reports about
        ##
        ## * "-lqt-mt{version} -lqtmain -lgdi32": w/QT_DLL defined should
        ##   cover dynamic multi-thread Enterprise Edition linking on Win32
        ##   platforms
        ##
        ## * "-lqt-mt{version}nc -lqtmain -lgdi32": w/QT_DLL defined should
        ##   cover dynamic Non-Commercial Edition linking on Win32 platforms
        ##
        ## * "-lqt -luser32 -lole32 -limm32 -lcomdlg32 -lgdi32": should cover
        ##   static linking on Win32 platforms
        ##
        ## * "-lqt-mt -luser32 -lole32 -limm32 -lcomdlg32 -lgdi32 -lwinspool -lwinmm -ladvapi32 -lws2_32":
        ##   added for the benefit of the Qt 3.0.0 Evaluation Version
        ##   (update: "advapi32.lib" seems to be a new dependency for Qt 3.1.0)
        ##   (update: "ws2_32.lib" seems to be a new dependency for Qt 3.1.2)
        ##
        ## * "-lqt-mt-eval": the Qt/Mac evaluation version
        ##
        ## * "-lqt-mtnc{version}": the non-commercial Qt version that
        ##   comes on the CD with the book "C++ Gui Programming with Qt 3"
        ##   (version==321 there)

        ## FIXME: could probably improve check to not have to go through
        ## all of the above. See bug item #028 in SoQt/BUGS.txt.
        ## 20040805 mortene.

        sim_ac_qt_suffix=
        if $sim_ac_qt_debug; then
          sim_ac_qt_suffix=d
        fi

        # Note that we need to always check for -lqt-mt before -lqt, because
        # at least the most recent Debian platforms (as of 2003-02-20) comes
        # with a -lqt which is missing QGL support, while it also has a
        # -lqt-mt *with* QGL support. The reason for this is because the
        # default GL (Mesa) library on Debian is built in mt-safe mode,
        # so a non-mt-safe Qt can't use it.

        for sim_ac_qt_cppflags_loop in "" "-DQT_DLL"; do
          for sim_ac_qt_libcheck in \
              "-lQtGui${sim_ac_qt_suffix}${sim_ac_qt_major_version} -lQtCore${sim_ac_qt_suffix}${sim_ac_qt_major_version}" \
              "-lQtGui -lQtCore" \
              "-lQtGui${sim_ac_qt_suffix} -lQtCore${sim_ac_qt_suffix} -luser32 -lole32 -limm32 -lcomdlg32 -lgdi32 -lwinspool -lwinmm -ladvapi32 -lws2_32 -lshell32" \
              "-lqt-gl" \
              "-lqt-mt" \
              "-lqt" \
              "-lqt-mt -luser32 -lole32 -limm32 -lcomdlg32 -lgdi32 -lwinspool -lwinmm -ladvapi32 -lws2_32" \
              "-lqt-mt${sim_ac_qt_version}${sim_ac_qt_suffix} -lqtmain -lgdi32" \
              "-lqt-mt${sim_ac_qt_version}nc${sim_ac_qt_suffix} -lqtmain -lgdi32" \
              "-lqt-mtedu${sim_ac_qt_version}${sim_ac_qt_suffix} -lqtmain -lgdi32" \
              "-lqt -lqtmain -lgdi32" \
              "-lqt${sim_ac_qt_version}${sim_ac_qt_suffix} -lqtmain -lgdi32" \
              "-lqt -luser32 -lole32 -limm32 -lcomdlg32 -lgdi32" \
              "-lqt-mt-eval" \
              "-lqt-mteval${sim_ac_qt_version}" \
              "-lqt-mtnc${sim_ac_qt_version}"
          do
            if test "x$sim_ac_qt_libs" = "xUNRESOLVED"; then
              CPPFLAGS="$sim_ac_QTDIR_cppflags $sim_ac_qt_cppflags_loop $sim_ac_save_cppflags"
              LIBS="$sim_ac_qt_libcheck $sim_ac_save_libs"
              AC_TRY_LINK([#include <qapplication.h>],
                          [
                           // FIXME: assignment to qApp does no longer work with Qt 4,
                           // should try to find another way to do the same thing. 20050629 mortene.
                           #if QT_VERSION < 0x040000
                           qApp = NULL; /* QT_DLL must be defined for assignment to global variables to work */
                           #endif
                           qApp->exit(0);],
                          [sim_ac_qt_libs="$sim_ac_qt_libcheck"
                           sim_ac_qt_cppflags="$sim_ac_QTDIR_cppflags $sim_ac_qt_cppflags_loop"
                           sim_ac_qt_ldflags="$sim_ac_QTDIR_ldflags"
                          ])
            fi
          done
        done

        AC_MSG_RESULT($sim_ac_qt_cppflags $sim_ac_QTDIR_ldflags $sim_ac_qt_libs)
      fi

    fi # sim_ac_qglobal_unresolved = false

  fi # sim_ac_have_qt_framework

  # We should only *test* availability, not mutate the LIBS/CPPFLAGS
  # variables ourselves inside this macro. 20041021 larsa
  CPPFLAGS=$sim_ac_save_cppflags
  LDFLAGS=$sim_ac_save_ldflags
  LIBS=$sim_ac_save_libs
  if test ! x"$sim_ac_qt_libs" = xUNRESOLVED; then
    sim_ac_qt_avail=yes
    $1

    sim_ac_qt_install=`cd $sim_ac_qtdir; pwd`/bin/install
    AC_MSG_CHECKING([whether Qt's install tool shadows the system install])
    case $INSTALL in
    "${sim_ac_qt_install}"* )
      AC_MSG_RESULT(yes)
      echo "\$INSTALL is '$INSTALL', which matches '$QTDIR/bin/install*'." >&5
      echo "\$QTDIR part is '$QTDIR'." >&5
      SIM_AC_ERROR([qt-install])
      ;;
    * )
      AC_MSG_RESULT(no)
      ;;
    esac

  else
    if test -z "$QTDIR"; then
      AC_MSG_WARN([QTDIR environment variable not set -- this might be an indication of a problem])
    fi
    $2
  fi
fi
])

############################################################################
# Usage:
#  SIM_AC_CHECK_QGL([ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND]])
#
#  Try to find the QGL widget for interfacing Qt with OpenGL. If it
#  is found, these shell variables are set:
#
#    $sim_ac_qgl_cppflags (extra flags the compiler needs for QGL lib)
#    $sim_ac_qgl_ldflags  (extra flags the linker needs for QGL lib)
#    $sim_ac_qgl_libs     (link libraries the linker needs for QGL lib)
#
#  The LIBS flag will also be modified accordingly. In addition, the
#  variable $sim_ac_qgl_avail is set to "yes" if the QGL extension
#  library is found.
#
# Note that all "modern" variants of Qt should come with QGL embedded.
# There's one important deviation: Debian comes with a -lqt which is
# missing QGL support, while it also has a -lqt-mt *with* QGL support.
# The reason for this is because the default GL (Mesa) library on Debian
# is built in mt-safe mode.
#
# Author: Morten Eriksen, <mortene@sim.no>.

AC_DEFUN([SIM_AC_CHECK_QGL], [

AC_REQUIRE([SIM_AC_WITH_QT])

sim_ac_qgl_avail=no
sim_ac_qgl_cppflags=
sim_ac_qgl_ldflags=
sim_ac_qgl_libs=

if $sim_ac_with_qt; then
  # first check if we can link with the QGL widget already
  AC_CACHE_CHECK(
    [whether the QGL widget is part of main Qt library],
    sim_cv_lib_qgl_integrated,
    [AC_TRY_LINK([#include <qgl.h>],
                 [QGLFormat * f = new QGLFormat; f->setDepth(true); ],
                 [sim_cv_lib_qgl_integrated=yes],
                 [sim_cv_lib_qgl_integrated=no])])

  if test x"$sim_cv_lib_qgl_integrated" = xyes; then
    sim_ac_qgl_avail=yes
    $1
  else
    sim_ac_save_LIBS=$LIBS
    LIBS="$sim_ac_qgl_libs $LIBS"

    AC_MSG_CHECKING([for the QGL extension library])

    sim_ac_qt_suffix=
    if $sim_ac_qt_debug; then
      sim_ac_qt_suffix=d
    fi

    sim_ac_qgl_libs=UNRESOLVED
    for sim_ac_qgl_libcheck in "-lQtOpenGL${sim_ac_qt_suffix}${sim_ac_qt_major_version}" "-lQtOpenGL${sim_ac_qt_suffix}" "-lqgl" "-lqgl -luser32"; do
      if test "x$sim_ac_qgl_libs" = "xUNRESOLVED"; then
        LIBS="$sim_ac_qgl_libcheck $sim_ac_save_LIBS"
        AC_TRY_LINK([#include <qgl.h>],
                    [QGLFormat * f = new QGLFormat; f->setDepth(true); ],
                    [sim_ac_qgl_libs="$sim_ac_qgl_libcheck"])
      fi
    done

    if test x"$sim_ac_qgl_libs" != xUNRESOLVED; then
      AC_MSG_RESULT($sim_ac_qgl_libs)
      sim_ac_qgl_avail=yes
      $1
    else
      AC_MSG_RESULT([unavailable])
      LIBS=$sim_ac_save_LIBS
      $2
    fi
  fi
fi
])

# SIM_AC_QGLWIDGET_SETAUTOBUFFERSWAP
# ----------------------------------
#
# Use the macro for its side-effect: it defines
#
#       HAVE_QGLWIDGET_SETAUTOBUFFERSWAP
#
# to 1 in config.h if QGLWidget::setAutoBufferSwap() is available.
#
# Author: Morten Eriksen, <mortene@sim.no>.

AC_DEFUN([SIM_AC_QGLWIDGET_SETAUTOBUFFERSWAP], [
AC_CACHE_CHECK(
  [whether the QGLWidget::setAutoBufferSwap() is available],
  sim_cv_func_qglwidget_setautobufferswap,
  [AC_TRY_LINK([#include <qgl.h>
class MyGLWidget : public QGLWidget {
public: MyGLWidget() {setAutoBufferSwap(FALSE);} };],
               [MyGLWidget * w = new MyGLWidget;],
               [sim_cv_func_qglwidget_setautobufferswap=yes],
               [sim_cv_func_qglwidget_setautobufferswap=no])])

if test x"$sim_cv_func_qglwidget_setautobufferswap" = xyes; then
  AC_DEFINE([HAVE_QGLWIDGET_SETAUTOBUFFERSWAP], 1,
    [Define this to 1 if QGLWidget::setAutoBufferSwap() is available])
fi
])


# SIM_AC_QGLFORMAT_SETOVERLAY
# ---------------------------
#
# Use the macro for its side-effect: it defines
#
#       HAVE_QGLFORMAT_SETOVERLAY
#
# to 1 in config.h if QGLFormat::setOverlay() is available.
#
# Author: Morten Eriksen, <mortene@sim.no>.

AC_DEFUN([SIM_AC_QGLFORMAT_SETOVERLAY], [
AC_CACHE_CHECK(
  [whether QGLFormat::setOverlay() is available],
  sim_cv_func_qglformat_setoverlay,
  [AC_TRY_LINK([#include <qgl.h>],
               [/* The basics: */
                QGLFormat f; f.setOverlay(TRUE);
                /* We've had a bug report about soqt.dll linking fail due
                   to missing the QGLWidget::overlayContext() symbol: */
                QGLWidget * w = NULL; (void)w->overlayContext();
               ],
               [sim_cv_func_qglformat_setoverlay=yes],
               [sim_cv_func_qglformat_setoverlay=no])])

if test x"$sim_cv_func_qglformat_setoverlay" = xyes; then
  AC_DEFINE([HAVE_QGLFORMAT_SETOVERLAY], 1,
    [Define this to 1 if QGLFormat::setOverlay() is available])
fi
])


# SIM_AC_QGLFORMAT_EQ_OP
# ----------------------
#
# Use the macro for its side-effect: it defines
#
#       HAVE_QGLFORMAT_EQ_OP
#
# to 1 in config.h if operator==(QGLFormat&, QGLFormat&) is available.
# (For Qt v2.2.2 at least, Troll Tech forgot to include this method
# in the publicly exported API for MSWindows DLLs.)
#
# Author: Morten Eriksen, <mortene@sim.no>.

AC_DEFUN([SIM_AC_QGLFORMAT_EQ_OP], [
AC_CACHE_CHECK(
  [whether operator==(QGLFormat&,QGLFormat&) is available],
  sim_cv_func_qglformat_eq_op,
  [AC_TRY_LINK([#include <qgl.h>],
               [QGLFormat f; if (f == f) f.setDepth(true);],
               [sim_cv_func_qglformat_eq_op=true],
               [sim_cv_func_qglformat_eq_op=false])])

if $sim_cv_func_qglformat_eq_op; then
  AC_DEFINE([HAVE_QGLFORMAT_EQ_OP], 1,
    [Define this to 1 if operator==(QGLFormat&, QGLFormat&) is available])
fi
])


# SIM_AC_QWIDGET_SHOWFULLSCREEN
# -----------------------------
#
# Use the macro for its side-effect: it defines HAVE_QWIDGET_SHOWFULLSCREEN
# to 1 in config.h if QWidget::showFullScreen() is available (that
# function wasn't introduced in Qt until version 2.1.0).
#
# Author: Morten Eriksen, <mortene@sim.no>.

AC_DEFUN([SIM_AC_QWIDGET_SHOWFULLSCREEN], [
AC_CACHE_CHECK(
  [whether QWidget::showFullScreen() is available],
  sim_cv_def_qwidget_showfullscreen,
  [AC_TRY_LINK([#include <qwidget.h>],
               [QWidget * w = new QWidget(); w->showFullScreen();],
               [sim_cv_def_qwidget_showfullscreen=true],
               [sim_cv_def_qwidget_showfullscreen=false])])

if $sim_cv_def_qwidget_showfullscreen; then
  AC_DEFINE([HAVE_QWIDGET_SHOWFULLSCREEN], 1,
            [Define this if QWidget::showFullScreen() is available])
fi
]) # SIM_AC_QWIDGET_SHOWFULLSCREEN

# SIM_AC_QAPPLICATION_HASPENDINGEVENTS
# -----------------------------
#
# Use the macro for its side-effect: it defines
# HAVE_QAPPLICATION_HASPENDINGEVENTS to 1 in config.h if
# QApplication::hasPendingEvents() is available (that
# function wasn't introduced in Qt until version 3.0).
#
# Author: Peder Blekken <pederb@sim.no>.

AC_DEFUN([SIM_AC_QAPPLICATION_HASPENDINGEVENTS], [
AC_CACHE_CHECK(
  [whether QApplication::hasPendingEvents() is available],
  sim_cv_def_qapplication_haspendingevents,
  [AC_TRY_LINK([#include <qapplication.h>],
               [int argc; char ** argv; QApplication app(argc, argv); (void) app.hasPendingEvents();],
               [sim_cv_def_qapplication_haspendingevents=true],
               [sim_cv_def_qapplication_haspendingevents=false])])

if $sim_cv_def_qapplication_haspendingevents; then
  AC_DEFINE([HAVE_QAPPLICATION_HASPENDINGEVENTS], 1,
            [Define this if QApplication::hasPendingEvents() is available])
fi
]) # SIM_AC_QAPPLICATION_HASPENDINGEVENTS


# SIM_AC_QT_KEYPAD_DEFINE
# -----------------------
#
# Use the macro for its side-effect: it defines HAVE_QT_KEYPAD_DEFINE
# to 1 in config.h if Qt::Keypad is available.
#
# Author: Morten Eriksen, <mortene@sim.no>.

AC_DEFUN([SIM_AC_QT_KEYPAD_DEFINE], [
AC_CACHE_CHECK(
  [whether Qt::Keypad is defined],
  sim_cv_def_qt_keypad,
  [AC_TRY_LINK([#include <qkeycode.h>],
               [Qt::ButtonState s = Qt::Keypad;],
               [sim_cv_def_qt_keypad=true],
               [sim_cv_def_qt_keypad=false])])

if $sim_cv_def_qt_keypad; then
  AC_DEFINE([HAVE_QT_KEYPAD_DEFINE], 1,
            [Define this if Qt::Keypad is available])
fi
]) # SIM_AC_QT_KEYPAD_DEFINE


# SIM_AC_QWIDGET_HASSETWINDOWSTATE
# --------------------------------
# QWidget->setWindowState() was added around Qt 3.3

AC_DEFUN([SIM_AC_QWIDGET_HASSETWINDOWSTATE], [
AC_CACHE_CHECK(
  [whether QWidget::setWindowState() exists],
  sim_cv_exists_qwidget_setwindowstate,

  [AC_TRY_LINK([#include <qwidget.h>],
               [QWidget * w = NULL; w->setWindowState(0);],
               [sim_cv_exists_qwidget_setwindowstate=true],
               [sim_cv_exists_qwidget_setwindowstate=false])])

if $sim_cv_exists_qwidget_setwindowstate; then
  AC_DEFINE([HAVE_QWIDGET_SETWINDOWSTATE], 1,
            [Define this if QWidget::setWindowState() is available])
fi
]) # SIM_AC_QWIDGET_HASSETWINDOWSTATE



# SIM_AC_QLINEEDIT_HASSETINPUTMASK
# --------------------------------
# QLineEdit->setInputMask() was added around Qt 3.3

AC_DEFUN([SIM_AC_QLINEEDIT_HASSETINPUTMASK], [
AC_CACHE_CHECK(
  [whether QLineEdit::setInputMask() exists],
  sim_cv_exists_qlineedit_setinputmask,

  [AC_TRY_LINK([#include <qlineedit.h>],
               [QLineEdit * le = NULL; le->setInputMask(0);],
               [sim_cv_exists_qlineedit_setinputmask=true],
               [sim_cv_exists_qlineedit_setinputmask=false])])

if $sim_cv_exists_qlineedit_setinputmask; then
  AC_DEFINE([HAVE_QLINEEDIT_SETINPUTMASK], 1,
            [Define this if QLineEdit::setInputMask() is available])
fi
]) # SIM_AC_QLINEEDIT_HASSETINPUTMASK



# SIM_AC_HAVE_QT_FRAMEWORK
# ----------------------
#
# Determine whether Qt is installed as a Mac OS X framework.
#
# Uses the variable $sim_ac_qt_framework_dir which should either
# point to /Library/Frameworks or $QTDIR/lib.
#
# Sets sim_ac_have_qt_framework to true if Qt is installed as
# a framework, and to false otherwise.
#
# Author: Karin Kosina, <kyrah@sim.no>.

AC_DEFUN([SIM_AC_HAVE_QT_FRAMEWORK], [
case $host_os in
  darwin*)
    # First check if framework exists in the specified location, then
    # try to actually link against the framework. This precaution is
    # needed to catch the case where Qt-4 is installed in the default
    # location /Library/Frameworks, but the user wants to override it
    # by setting QTDIR to point to a non-framework install.
    if test -d $sim_ac_qt_framework_dir/QtCore.framework; then
      sim_ac_save_ldflags_fw=$LDFLAGS
      LDFLAGS="$LDFLAGS -F$sim_ac_qt_framework_dir -framework QtCore"
      AC_CACHE_CHECK(
        [whether Qt is installed as a framework],
        sim_ac_have_qt_framework,
        [AC_TRY_LINK([#include <QtCore/qglobal.h>],
                 [],
                 [sim_ac_have_qt_framework=true],
                 [sim_ac_have_qt_framework=false])
        ])
        LDFLAGS=$sim_ac_save_ldflags_fw
    else
      sim_ac_have_qt_framework=false
    fi
    ;;
  *)
    sim_ac_have_qt_framework=false
    ;;
esac
])

