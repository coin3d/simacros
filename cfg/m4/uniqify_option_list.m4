# **************************************************************************
# SIM_AC_UNIQIFY_OPTION_LIST( VARIABLE, LIST )
#
# This macro filters out redundant commandline options. It is heavily based
# on the SIM_AC_UNIQIFY_LIST macro, but has been extended to support
# spaces (i.e. for instance "-framework OpenGL" as needed on Mac OS X).
#
# Authors:
#   Lars J. Aas <larsa@sim.no>
#   Karin Kosina <kyrah@sim.no>
#   Tamer Fahmy <tamer@tammura.at>

AC_DEFUN([SIM_AC_UNIQIFY_OPTION_LIST], [
sim_ac_save_prefix=$prefix
sim_ac_save_exec_prefix=$exec_prefix
test x"$prefix" = xNONE && prefix=/usr/local
test x"$exec_prefix" = xNONE && exec_prefix='${prefix}'
sim_ac_uniqued_list=
eval paramlist='"$2"'
sim_ac_sed_expr="[s,\(-[_a-zA-Z0-9][%_a-zA-Z0-9]*\) [ ]*\([_a-zA-Z0-9][_a-zA-Z0-9]*\),\1%%%%%\2,g]"
paramlist="`echo $paramlist | sed \"$sim_ac_sed_expr\"`"
while test x"$paramlist" != x"`echo $paramlist | sed \"$sim_ac_sed_expr\"`"; do
  paramlist="`echo $paramlist | sed \"$sim_ac_sed_expr\"`"
done
for sim_ac_item in $paramlist; do
  eval sim_ac_eval_item="$sim_ac_item"
  eval sim_ac_eval_item="$sim_ac_eval_item"
  if test x"$sim_ac_uniqued_list" = x; then
    sim_ac_uniqued_list="$sim_ac_item"
  else
    sim_ac_unique=true
    for sim_ac_uniq in $sim_ac_uniqued_list; do
      eval sim_ac_eval_uniq="$sim_ac_uniq"
      eval sim_ac_eval_uniq="$sim_ac_eval_uniq"
      test x"$sim_ac_eval_item" = x"$sim_ac_eval_uniq" && sim_ac_unique=false
    done
    $sim_ac_unique && sim_ac_uniqued_list="$sim_ac_uniqued_list $sim_ac_item"
  fi
done
$1=`echo $sim_ac_uniqued_list | sed 's/%%%%%/ /g'`
prefix=$sim_ac_save_prefix
exec_prefix=$sim_ac_save_exec_prefix
# unset sim_ac_save_prefix
# unset sim_ac_save_exec_prefix
# unset sim_ac_eval_item
# unset sim_ac_eval_uniq
]) # SIM_AC_UNIQIFY_OPTION_LIST

