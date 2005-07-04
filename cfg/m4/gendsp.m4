 **************************************************************************
# gendsp.m4
#
# macros:
#   SIM_AC_MSVC_DSP_ENABLE_OPTION
#   SIM_AC_MSVC_DSP_SETUP(PROJECT, Project, project, extra-args)
#
# authors:
#   Lars J. Aas <larsa@coin3d.org>

# **************************************************************************
AC_DEFUN([SIM_AC_MSVC_DSP_ENABLE_OPTION], [
AC_ARG_ENABLE([msvcdsp],
  [AC_HELP_STRING([--enable-msvcdsp], [build .dsp, not library])],
  [case $enableval in
  no | false) sim_ac_make_dsp=false ;;
  *)          sim_ac_make_dsp=true ;;
  esac],
  [sim_ac_make_dsp=false])

if $sim_ac_make_dsp; then
  enable_dependency_tracking=no
  enable_libtool_lock=no
fi
]) # SIM_AC_MSVC_DSP_ENABLE_OPTION

# **************************************************************************
AC_DEFUN([SIM_AC_MSVC_DSP_SETUP], [
AC_REQUIRE([SIM_AC_MSVC_DSP_ENABLE_OPTION])
## Microsoft Developer Studio Project files
$1_DSP_LIBDIRS=
$1_DSP_LIBS=
$1_DSP_INCS=
$1_LIB_DSP_DEFS=
$1_DSP_DEFS=

if $sim_ac_make_dsp; then
  SIM_AC_CONFIGURATION_SETTING([$2 build type], [msvc .dsp])

  # -DHAVE_CONFIG_H is set up in $DEFS too late for us to use, and some
  # include directives are usually set up in the Makefile.am files
  for arg in -DHAVE_CONFIG_H $4 $CPPFLAGS $LDFLAGS $LIBS; do
    case $arg in
    -L* )
      libdir=`echo $arg | cut -c3-`
      $1_DSP_LIBDIRS="[$]$1_DSP_LIBDIRS $libdir"
      ;;
    -l* )
      libname=`echo $arg | cut -c3-`
      for libdir in [$]$1_DSP_LIBDIRS; do
        if test -f $libdir/$libname.lib; then
          # lib is not in any standard location - use full path
          libname=`cygpath -w "$libdir/$libname" 2>/dev/null || echo "$libdir/$libname"`
          break
        fi
      done
      if test x"[$]$1_DSP_LIBS" = x""; then
        $1_DSP_LIBS="$libname.lib"
      else
        $1_DSP_LIBS="[$]$1_DSP_LIBS $libname.lib"
      fi
      ;;
    -I* )
      incdir=`echo $arg | cut -c3-`
      incdir=`cygpath -w "$incdir" 2>/dev/null || echo "$incdir"`
      if test x"[$]$1_DSP_INCS" = x""; then
        $1_DSP_INCS="/I \"$incdir\""
      else
        $1_DSP_INCS="[$]$1_DSP_INCS /I \"$incdir\""
      fi
      ;;
    -D$1_DEBUG* | -DNDEBUG )
      # Defines that vary between release/debug configurations can't be
      # set up dynamically in <lib>_DSP_DEFS - they must be static in the
      # gendsp.sh script.  We therefore catch them here so we can ignore
      # checking for them below.
      ;;
    -D*=* | -D* )
      define=`echo $arg | cut -c3-`
      if test x"[$]$1_DSP_DEFS" = x""; then
        $1_DSP_DEFS="/D \"$define\""
      else
        $1_DSP_DEFS="[$]$1_DSP_DEFS /D \"$define\""
      fi
      if echo $define | grep _MAKE_DLL; then
        :
      else
        if test x"[$]$1_DSP_DEFS" = x""; then
          $1_LIB_DSP_DEFS="/D \"$define\""
        else
          $1_LIB_DSP_DEFS="[$]$1_LIB_DSP_DEFS /D \"$define\""
        fi
      fi
      ;;
    esac
  done

  CC=[$]$3_build_dir/cfg/gendsp.sh
  CXX=[$]$3_build_dir/cfg/gendsp.sh
  CXXLD=[$]$3_build_dir/cfg/gendsp.sh
  # Yes, this is totally bogus stuff, but don't worry about it.  As long
  # as gendsp.sh recognizes it...  20030219 larsa
  CPPFLAGS="$CPPFLAGS -Ddspfile=[$]$3_build_dir/$3[$]$1_MAJOR_VERSION.dsp"
  LDFLAGS="$LDFLAGS -Wl,-Ddspfile=[$]$3_build_dir/$3[$]$1_MAJOR_VERSION.dsp"
  LIBFLAGS="$LIBFLAGS -o $3[$]$1_MAJOR_VERSION.so.0"

  # this can't be set up at the point the libtool script is generated
  mv libtool libtool.bak
  sed -e "s%^CC=\"gcc\"%CC=\"[$]$3_build_dir/cfg/gendsp.sh\"%" \
      -e "s%^CC=\".*/wrapmsvc.exe\"%CC=\"[$]$3_build_dir/cfg/gendsp.sh\"%" \
      <libtool.bak >libtool
  rm -f libtool.bak
  chmod 755 libtool
fi

AC_SUBST([$1_DSP_LIBS])
AC_SUBST([$1_DSP_INCS])
AC_SUBST([$1_DSP_DEFS])
AC_SUBST([$1_LIB_DSP_DEFS])
])

