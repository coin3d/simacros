############################################################################
# CPP_AC_SEARCH_ORDER_FILTER( VARIABLE, LIST )
#
# This macro filters out system directories from a list. This macro was made
# to avoid passing -I options to the gcc3 compiler that are possibly already
# one of gcc3's system directories. This would cause the preprocessor to
# issue a "warning: changing search order for system directory ..." message
# that could break some configure scripts and produce annoying warning
# messages for every source file compiled.
#
# Authors:
#   Tamer Fahmy <tamer@tammura.at>
#

AC_DEFUN([CPP_AC_SEARCH_ORDER_FILTER], [
if test x"$GCC" = x"yes"; then
 sim_ac_save_cpp=$CPP
 CPP="cpp"
 case $host_os in
  darwin*) CPP="cpp3"
    ;;
  esac
  cpp_sys_dirs=`$CPP -v <<EOF 2>&1 | sed -n -e \
  '/#include <...> search starts here:/,/End of search list./{
    /#include <...> search starts here:/b
    /End of search list./b
    s/ /-I/
    p
  }'
  EOF`
  result=
  for inc_path in $2; do
    additem=true
    for sys_dir in $cpp_sys_dirs; do
      if test x$inc_path = x$sys_dir; then
        additem=false
        break
      fi
    done
    $additem && result="$result $inc_path"
  done
  $1=$result
  CPP=$sim_ac_save_cpp
fi
]) # CPP_AC_SEARCH_ORDER_FILTER

