# SIM_AC_DYNLIB_EXT
# --------------------------------------------
# Find out what the shared library suffix is on this platform.
#
# (Consider this a hack -- the "shrext_cmds" variable from Libtool
# is undocumented and not guaranteed to stick around forever. We've
# already had to change this once (it used to be called "shrext")).
#
# Sets the sim_ac_shlibext variable to the extension name.

AC_DEFUN([SIM_AC_DYNLIB_EXT],
[
AC_MSG_CHECKING([for shared library suffix])
eval "sim_ac_shlibext=$shrext_cmds"
AC_MSG_RESULT($sim_ac_shlibext)
if test x"$sim_ac_shlibext" = x""; then
  AC_MSG_WARN([Could not figure out library suffix! (Has there been a change to the Libtool version used?)])
fi
])


# SIM_AC_CHECK_HEADER(HEADER-FILE, [ACTION-IF-FOUND], [ACTION-IF-NOT-FOUND])
# --------------------------------------------------------------------------
# Modified AC_CHECK_HEADER to use AC_TRY_COMPILE instead of AC_TRY_CPP,
# as we can get false positives and/or false negatives when running under
# Cygwin, using the Microsoft Visual C++ compiler (the configure script will
# pick the GCC preprocessor).

AC_DEFUN([SIM_AS_TR_CPP],
[m4_ifdef([AS_TR_CPP],[AS_TR_CPP([$1])],[AC_TR_CPP([$1])])])

AC_DEFUN([SIM_AC_CHECK_HEADER],
[AC_VAR_PUSHDEF([ac_Header], [ac_cv_header_$1])
AC_ARG_VAR([CPPFLAGS], [C/C++ preprocessor flags, e.g. -I<include dir> if you have headers in a nonstandard directory <include dir>])
AC_CACHE_CHECK(
  [for $1],
  ac_Header,
  [AC_TRY_COMPILE([#include <$1>],
    [],
    [AC_VAR_SET([ac_Header], yes)],
    [AC_VAR_SET([ac_Header], no)])])
if test AC_VAR_GET(ac_Header) = yes; then
  ifelse([$2], , :, [$2])
else
  ifelse([$3], , :, [$3])
fi
AC_VAR_POPDEF([ac_Header])
])# SIM_AC_CHECK_HEADER


# SIM_AC_CHECK_HEADERS(HEADER-FILE...
#                  [ACTION-IF-FOUND], [ACTION-IF-NOT-FOUND])
# ----------------------------------------------------------
AC_DEFUN([SIM_AC_CHECK_HEADERS],
[for ac_header in $1
do
SIM_AC_CHECK_HEADER(
  [$ac_header],
  [AC_DEFINE_UNQUOTED(SIM_AS_TR_CPP(HAVE_$ac_header)) $2],
  [$3])
done
])# SIM_AC_CHECK_HEADERS


# SIM_AC_CHECK_SIZEOF(TYPE, [INCLUDES])
# --------------------------------------------
AC_DEFUN([SIM_AC_CHECK_SIZEOF],
[
AC_CHECK_TYPE([$1], [
  _AC_COMPUTE_INT([sizeof ($1)],
                  [sim_ac_bytesize],
                  [AC_INCLUDES_DEFAULT([$2])])
], [sim_ac_bytesize=0], [$2])
])# SIM_AC_CHECK_SIZEOF


# SIM_AC_HAVE_BYTESIZE_TYPES_IFELSE(if-found, if-not-found, prefix
# --------------------
AC_DEFUN([SIM_AC_HAVE_BYTESIZE_TYPES_IFELSE],
[
m4_define([SIM_AC_DEF_PREFIX], ifelse([$3], [], [COIN], [$3]))
AC_CHECK_HEADERS([inttypes.h stdint.h sys/types.h stddef.h])
AC_MSG_CHECKING([standard bytesize typedefs])
AC_TRY_COMPILE([
#include <stdio.h>
#ifdef HAVE_INTTYPES_H
#include <inttypes.h>
#else /* !HAVE_INTTYPES_H */
#ifdef HAVE_STDINT_H
#include <stdint.h>
#endif /* HAVE_STDINT_H */
#endif /* !HAVE_INTTYPES_H */
#ifdef HAVE_SYS_TYPES_H
#include <sys/types.h>
#endif /* HAVE_SYS_TYPES_H */
#ifdef HAVE_STDDEF_H
#include <stddef.h>
#endif /* HAVE_STDDEF_H */
], [
  int8_t int8var;
  uint8_t uint8var;
  int16_t int16var;
  uint16_t uint16var;
  int32_t int32var;
  uint32_t uint32var;
  int64_t int64var;
  uint64_t uint64var;
  intptr_t intptrvar;
  uintptr_t uintptrvar;
],
[sim_ac_have_have_bytesize_types=true],
[sim_ac_have_have_bytesize_types=false])

if $sim_ac_have_have_bytesize_types; then
  AC_MSG_RESULT([available])
  AC_DEFINE_UNQUOTED([HAVE_INT8_T], [1], [define this if the type is available on the system])
  AC_DEFINE(SIM_AC_DEF_PREFIX[]_INT8_T, [int8_t], [define this to a type of the indicated bitwidth])
  AC_DEFINE_UNQUOTED([HAVE_UINT8_T], [1], [define this if the type is available on the system])
  AC_DEFINE(SIM_AC_DEF_PREFIX[]_UINT8_T, [uint8_t], [define this to a type of the indicated bitwidth])
  AC_DEFINE_UNQUOTED([HAVE_INT16_T], [1], [define this if the type is available on the system])
  AC_DEFINE(SIM_AC_DEF_PREFIX[]_INT16_T, [int16_t], [define this to a type of the indicated bitwidth])
  AC_DEFINE_UNQUOTED([HAVE_UINT16_T], [1], [define this if the type is available on the system])
  AC_DEFINE(SIM_AC_DEF_PREFIX[]_UINT16_T, [uint16_t], [define this to a type of the indicated bitwidth])
  AC_DEFINE_UNQUOTED([HAVE_INT32_T], [1], [define this if the type is available on the system])
  AC_DEFINE(SIM_AC_DEF_PREFIX[_INT32_T], [int32_t], [define this to a type of the indicated bitwidth])
  AC_DEFINE_UNQUOTED([HAVE_UINT32_T], [1], [define this if the type is available on the system])
  AC_DEFINE(SIM_AC_DEF_PREFIX[_UINT32_T], [uint32_t], [define this to a type of the indicated bitwidth])
  AC_DEFINE_UNQUOTED([HAVE_INT64_T], [1], [define this if the type is available on the system])
  AC_DEFINE(SIM_AC_DEF_PREFIX[_INT64_T], [int64_t], [define this to a type of the indicated bitwidth])
  AC_DEFINE_UNQUOTED([HAVE_UINT64_T], [1], [define this if the type is available on the system])
  AC_DEFINE(SIM_AC_DEF_PREFIX[_UINT64_T], [uint64_t], [define this to a type of the indicated bitwidth])
  AC_DEFINE_UNQUOTED([HAVE_INTPTR_T], [1], [define this if the type is available on the system])
  AC_DEFINE(SIM_AC_DEF_PREFIX[_INTPTR_T], [intptr_t], [define this to a type of the indicated bitwidth])
  AC_DEFINE_UNQUOTED([HAVE_UINTPTR_T], [1], [define this if the type is available on the system])
  AC_DEFINE_UNQUOTED(SIM_AC_DEF_PREFIX[_UINTPTR_T], [uintptr_t], [define this to a type of the indicated bitwidth])
  $1
else
  AC_MSG_RESULT([not available])
  $2
fi
])# SIM_AC_HAVE_BYTESIZE_TYPES_IFELSE

# SIM_AC_BYTESIZE_TYPE(TYPEDEFTYPE, BYTESIZE, ALTERNATE_TYPELIST,
#                     [ACTION-IF-FOUND], [ACTION-IF-NOT-FOUND])
# ----------------------------------------------------------
AC_DEFUN([SIM_AC_BYTESIZE_TYPE],
[sim_ac_searching=true
m4_define([SIM_AC_DEF_PREFIX], ifelse([$6], [], [COIN], [$6]))
AC_MSG_CHECKING([for $1 type or equivalent])
for sim_ac_type in $1 $3
do
  if $sim_ac_searching; then
    AC_TRY_COMPILE([
#include <stdio.h>
#ifdef HAVE_INTTYPES_H
#include <inttypes.h>
#else /* !HAVE_INTTYPES_H */
#ifdef HAVE_STDINT_H
#include <stdint.h>
#endif /* HAVE_STDINT_H */
#endif /* !HAVE_INTTYPES_H */
#ifdef HAVE_SYS_TYPES_H
#include <sys/types.h>
#endif /* HAVE_SYS_TYPES_H */
#ifdef HAVE_STDDEF_H
#include <stddef.h>
#endif /* HAVE_STDDEF_H */
], [
      /* establish that type '$1' is actually usable before trying to
         make a failure-dependend compilation test case using it. */
      $sim_ac_type variable = 0;
], [
      AC_TRY_COMPILE([
#include <stdio.h>
#ifdef HAVE_INTTYPES_H
#include <inttypes.h>
#else /* !HAVE_INTTYPES_H */
#ifdef HAVE_STDINT_H
#include <stdint.h>
#endif /* HAVE_STDINT_H */
#endif /* !HAVE_INTTYPES_H */
#ifdef HAVE_SYS_TYPES_H
#include <sys/types.h>
#endif /* HAVE_SYS_TYPES_H */
#ifdef HAVE_STDDEF_H
#include <stddef.h>
#endif /* HAVE_STDDEF_H */
], [
      int switchval = 0;
      /* trick compiler to abort with error if sizeof($1) equals $2 */
      switch ( switchval ) {
      case sizeof($sim_ac_type): break;
      case $2: break;
      }
], [
      # compile time success means we *haven't* found the type of right size
      :
], [
      # constructed switch became illegal C code - meaning we have found a
      # type that has desired size
      AC_MSG_RESULT([$sim_ac_type])
      sim_ac_searching=false
      if test "$sim_ac_type" = "$1"; then
        AC_DEFINE_UNQUOTED(SIM_AS_TR_CPP(have_$1), 1, [define this if the type is available on the system])
      fi
      AC_DEFINE_UNQUOTED(SIM_AC_DEF_PREFIX[]SIM_AS_TR_CPP(_$1), $sim_ac_type, [define this to a type of the indicated bitwidth])
])])
  fi
done

if $sim_ac_searching; then
  AC_MSG_RESULT([no type found])
  ifelse([$5], , :, [$5])
else
  # ac_msg_result invoked above
  ifelse([$4], , :, [$4])
fi
])# SIM_AC_BYTESIZE_TYPE

# SIM_AC_DEFINE_BYTESIZE_TYPES
# ----------------------------------------------------------
#
AC_DEFUN([SIM_AC_DEFINE_BYTESIZE_TYPES], [
SIM_AC_HAVE_BYTESIZE_TYPES_IFELSE([
], [
  SIM_AC_BYTESIZE_TYPE(int8_t, 1, [char], [], AC_MSG_ERROR([could not find 8-bit type]), $1)
  SIM_AC_BYTESIZE_TYPE(uint8_t, 1, [u_int8_t "unsigned char"], [], AC_MSG_ERROR([could not find unsigned 8-bit type]), $1)

  SIM_AC_BYTESIZE_TYPE(int16_t, 2, [short int], [], AC_MSG_ERROR([could not find 16-bit type]), $1)
  SIM_AC_BYTESIZE_TYPE(uint16_t, 2, [u_int16_t "unsigned short" "unsigned int"], [], AC_MSG_ERROR([could not find unsigned 16-bit type]), $1)

  SIM_AC_BYTESIZE_TYPE(int32_t, 4, [int long], [], AC_MSG_ERROR([could not find 32-bit type]), $1)
  SIM_AC_BYTESIZE_TYPE(uint32_t, 4, [u_int32_t "unsigned int" "unsigned long"], [], AC_MSG_ERROR([could not find unsigned 32-bit type]), $1)

  SIM_AC_BYTESIZE_TYPE(int64_t, 8, [long int "long long" __int64], [], AC_MSG_WARN([could not find 64-bit type]), $1)
  SIM_AC_BYTESIZE_TYPE(uint64_t, 8, [u_int64_t "unsigned long" "unsigned int" "unsigned long long" "unsigned __int64"], [], AC_MSG_WARN([could not find unsigned 64-bit type]), $1)

  SIM_AC_BYTESIZE_TYPE(intptr_t, sizeof(void *), [int long "long long" __int64], [], AC_MSG_WARN([could not find int-pointer type]), $1)
  SIM_AC_BYTESIZE_TYPE(uintptr_t, sizeof(void *), [u_intptr_t "_W64 unsigned int" "unsigned int" "unsigned long" u_int64_t "unsigned long long" "unsigned __int64"], [], AC_MSG_WARN([could not find unsigned int-pointer type]), $1)
], [$1])
])# SIM_AC_DEFINE_BYTESIZE_TYPES

#**************************************************************************
# SIM_AC_CHECK_TYPEOF_STRUCT_MEMBER(includes, struct name, member name, variable, if-error)

AC_DEFUN([SIM_AC_CHECK_TYPEOF_STRUCT_MEMBER], [
AC_MSG_CHECKING([type of $2::$3])
cat > conftest.cpp << _ACEOF
#include "confdefs.h"
$1
int main(int argc, char **argv) { return 0; }
_ACEOF
sim_ac_struct_contents="`$CXXCPP $CPPFLAGS conftest.cpp 2>/dev/null | sed -e '1,/struct[[ \t]]*$2/ d' | sed -e '/}/,\$ d'`"
rm conftest.cpp
# canonicalize contents:
sim_ac_struct_contents="`echo { \$sim_ac_struct_contents }`"
# extract type declaration type
sim_ac_member_type="`echo $sim_ac_struct_contents | sed -e 's/^.*[[{\\;]] *\\([[^{\\;]]*\\) $3 *;.*/\\1/'`"
if test -z "$sim_ac_member_type"; then
  AC_MSG_RESULT([<unknown type>])
  $5
else
  AC_MSG_RESULT([$sim_ac_member_type])
  AC_DEFINE_UNQUOTED([$4], [$sim_ac_member_type], [The type $2::$3 is declared as.])
fi
]) # SIM_AC_CHECK_TYPEOF_STRUCT_MEMBER
