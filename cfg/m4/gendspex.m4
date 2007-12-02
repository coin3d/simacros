# **************************************************************************
# gendspex.m4
#
# macros:
#   SIM_AC_MSVC_DSPEX_ENABLE_OPTION
#   SIM_AC_MSVC_DSPEX_SETUP(Project, source dir, build dir,
#                           template suffix, substitutes, extra args)
#   SIM_AC_MSVC_DSPEX_PREPARE(source dir, dest dir)
#
# authors:
#   Thomas Hammer <thammer@sim.no>
#   Lars J. Aas <larsa@coin3d.org> (wrote the original gendsp.m4 script)
#
# **************************************************************************
AC_DEFUN([SIM_AC_MSVC_DSPEX_ENABLE_OPTION], [
AC_ARG_ENABLE([msvcdspex],
  [AC_HELP_STRING([--enable-msvcdspex], [build .dsp, not executables])],
  [case $enableval in
  no | false) sim_ac_make_dspex=false ;;
  *)          sim_ac_make_dspex=true ;;
  esac],
  [sim_ac_make_dspex=false])

if $sim_ac_make_dspex; then
  enable_dependency_tracking=no
  enable_libtool_lock=no
fi
]) # SIM_AC_MSVC_DSPEX_ENABLE_OPTION

# **************************************************************************
AC_DEFUN([SIM_AC_MSVC_DSPEX_SETUP], [
AC_REQUIRE([SIM_AC_MSVC_DSPEX_ENABLE_OPTION])

if $sim_ac_make_dspex; then
  SIM_AC_CONFIGURATION_SETTING([$1 build type], [msvc .dsp])

  CC=$2/cfg/gendspex.sh
  CXX=$2/cfg/gendspex.sh
  CXXLD=$2/cfg/gendspex.sh

  # Notes:
  # - these defines are picked up by gendspex.sh
  # - template basename = vc6 -> workspace_template_vc6.txt, etc
  # - $(DEFAULT_INCLUDES) and $(INCLUDES) are set by the generated
  #   Makefile scripts. Yes, this is a hack.
  # 2003-11-04 thammer
  LDFLAGS="-Dsourcedir=$2 -Dbuilddir=$3 -Dtemplatesuffix=$4 -Dsubstitutes=$5 $LDFLAGS $CPPFLAGS $6 \$(DEFAULT_INCLUDES) \$(INCLUDES)"
fi
])

# **************************************************************************
AC_DEFUN([SIM_AC_MSVC_DSPEX_PREPARE], [
AC_REQUIRE([SIM_AC_MSVC_DSPEX_ENABLE_OPTION])

if $sim_ac_make_dspex; then

  # copy all headerfiles from sourcedir to config dir
  if $sim_ac_make_dspex; then

    sim_ac_dspex_src_dir_length=`echo $1 | wc -c | sed -e "s% %%g"`
    sim_ac_dspex_headers=`find $1 -name "*.h" | cut -c$sim_ac_dspex_src_dir_length- | sed -e "s%^/%%"`

    for sim_ac_dspex_header in $sim_ac_dspex_headers; do
      sim_ac_dspex_justname=`echo $sim_ac_dspex_header | sed -e "s%.*/%%"`
      sim_ac_dspex_dirname=`echo $sim_ac_dspex_header | sed -e "s%[[^/]]*\.h%%"`
      if test -d "$2/$sim_ac_dspex_dirname"; then :; else
        mkdir -p "$2/$sim_ac_dspex_dirname"
      fi
      cp $1/$sim_ac_dspex_header \
         $2/$sim_ac_dspex_header
    done
  fi

fi
])


