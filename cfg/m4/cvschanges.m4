# **************************************************************************
# SIM_AC_CVS_CHANGES( SIM_AC_CVS_CHANGE-MACROS )
#
# This macro is just an envelope macro for SIM_AC_CVS_CHANGE invokations.
# It performs necessary initializations and finalizing.  All the
# SIM_AC_CVS_CHANGE invokations should be preformed inside the same
# SIM_AC_CVS_CHANGES macro.
#
# Authors:
#   Lars J. Aas <larsa@sim.no>
#

AC_DEFUN([SIM_AC_CVS_CHANGES], [
pushdef([sim_ac_cvs_changes], 1)
sim_ac_do_cvs_update=false
sim_ac_cvs_changed=false
sim_ac_cvs_problem=false
sim_ac_cvs_save_builddir=`pwd`
AC_ARG_ENABLE(
  [cvs-auto-update],
  AC_HELP_STRING([--enable-cvs-auto-update],
                 [auto-update CVS repository if possible]),
  [case "$enableval" in
  yes) sim_ac_do_cvs_update=true ;;
  no)  sim_ac_do_cvs_update=false ;;
  *)   AC_MSG_ERROR(["$enableval" given to --enable-cvs-update]) ;;
  esac])
if test -d $srcdir/CVS; then
  ifelse([$1], , :, [$1])
  if $sim_ac_cvs_problem; then
    cat <<"CVS_CHANGES_EOF"
To make the above listed procedure be executed automatically, run configure
again with "--enable-cvs-auto-update" added to the configure options.
CVS_CHANGES_EOF
  fi
fi
$sim_ac_cvs_problem && echo "" && echo "Aborting..." && exit 1
popdef([sim_ac_cvs_changes])
]) # SIM_AC_CVS_CHANGES

# **************************************************************************
# SIM_AC_CVS_CHANGE( UPDATE-PROCEDURE, UPDATE-TEST, UPDATE-TEST, ... )
#
# This macro is used to ensure that CVS source repository changes that need
# manual intervention on all the build systems are executed before the
# configure script is run.
#
# UPDATE-PROCEDURE is the procedure needed to update the source repository.
# UPDATE-TEST is a command that returns failure if the update procedure
# hasn't been executed, and success afterwards.  You can have as many test
# as you like.  All tests must pass for the macro to believe the source
# repository is up-to-date.
#
# All commands (the update procedure and the tests) are executed from the
# CVS repository root.
#
# SIM_AC_CVS_CHANGE must be invoked inside SIM_AC_CVS_CHANGES.
#
# Authors:
#   Lars J. Aas <larsa@sim.no>
#

AC_DEFUN([SIM_AC_CVS_CHANGE], [
ifdef([sim_ac_cvs_changes], ,
      [AC_MSG_ERROR([[SIM_AC_CVS_CHANGE invoked outside SIM_AC_CVS_CHANGES]])])
cd $srcdir;
m4_foreach([testcommand], [m4_shift($@)], [testcommand
if test $? -ne 0; then sim_ac_cvs_changed=true; fi
])
cd $sim_ac_cvs_save_builddir
if $sim_ac_cvs_changed; then
  if $sim_ac_do_cvs_update; then
    echo "Performing repository update:"
    cd $srcdir;
    ( set -x
$1 )
    sim_ac_cvs_unfixed=false
m4_foreach([testcommand], [m4_shift($@)],
[    testcommand
    if test $? -ne 0; then sim_ac_cvs_unfixed=true; fi
])
    cd $sim_ac_cvs_save_builddir
    if $sim_ac_cvs_unfixed; then
      cat <<"CVS_CHANGE_EOF"

The following update procedure does not seem to have produced the desired
effect:

$1

You should investigate what went wrong and alert the relevant software
developers about it.

Aborting...
CVS_CHANGE_EOF
      exit 1
    fi
  else
    $sim_ac_cvs_problem || {
    cat <<"CVS_CHANGE_EOF"

The configure script has detected source hierachy inconsistencies between
your source repository and the master source repository.  This needs to be
fixed before you can proceed.

The suggested update procedure is to execute the following set of commands
in the root source directory:
CVS_CHANGE_EOF
    }
    cat <<"CVS_CHANGE_EOF"
$1
CVS_CHANGE_EOF
    sim_ac_cvs_problem=true
  fi
fi
]) # SIM_AC_CVS_CHANGE

# EOF **********************************************************************
