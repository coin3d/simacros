############################################################################
# Usage:
#   SIM_AC_COMPILER_CPLUSPLUS_FATAL_ERRORS
#
# Description:
#   Check for the known causes that would make the current C++ compiler
#   unusable for building Coin or Coin-related projects.
#
#   Exits the configure script if any of them fail.
#

AC_DEFUN([SIM_AC_COMPILER_CPLUSPLUS_FATAL_ERRORS], [
  SIM_AC_COMPILER_CPLUSPLUS_ENV_OK
  SIM_AC_COMPILER_INLINE_FOR
  SIM_AC_COMPILER_SWITCH_IN_VIRTUAL_DESTRUCTOR
  SIM_AC_COMPILER_CRAZY_GCC296_BUG
  SIM_AC_COMPILER_BUILTIN_EXPECT
])


############################################################################
# Usage:
#     SIM_AC_COMPILER_CPLUSPLUS_ENV_OK
#
# Description:
#   Checks that the C++ compiler environment can compile, link and run an
#   executable. We do this before the other checks, so we can smoke out
#   a fubar environment before trying anything else, because otherwise the
#   error message from the failing check would be bogus.
#
#   (I.e. we've had reports from people that the GCC 2.96 crazy-bug checks
#   hits, even though they didn't have GCC 2.96. Upon closer inspection,
#   the reason for failure was simply that some other part of the compiler
#   environment was fubar.)

AC_DEFUN([SIM_AC_COMPILER_CPLUSPLUS_ENV_OK], [
AC_LANG_PUSH(C++)

AC_CACHE_CHECK(
  [if the C++ compiler environment is ok],
  sim_cv_c_compiler_env_fubar,
  [AC_TRY_RUN([
// Just any old C++ source code. It might be useful
// to try to add in more standard C++ features that
// we depend on, like classes using templates (or
// even multiple templates), etc etc.  -mortene.

#include <stdio.h>

class myclass {
public:
  myclass(void) { value = 0.0f; }
  float value;
};

int
main(void)
{
  myclass proj;
  (void)printf(stdout, "%f\n", proj.value);
  return 0;
}
],
  [sim_cv_c_compiler_env_fubar=false],
  [sim_cv_c_compiler_env_fubar=true],
  [sim_cv_c_compiler_env_fubar=false
   AC_MSG_WARN([can't check for fully working C++ environment when cross-compiling, assuming it's ok])])
])

AC_LANG_POP

if $sim_cv_c_compiler_env_fubar; then
  SIM_AC_ERROR(c--fubarenvironment)
fi
])


############################################################################
# Usage:
#   SIM_AC_COMPILER_INLINE_FOR( [ACTION-IF-OK [, ACTION-IF-FAILS ] ] )
#
# Description:
#   Check if the compiler supports for(;;){} loops inside inlined
#   constructors.
#
#   This smokes out the useless HPUX 10.20 CC compiler.
#

AC_DEFUN([SIM_AC_COMPILER_INLINE_FOR], [

AC_LANG_PUSH(C++)
AC_CACHE_CHECK(
  [if the compiler handles for() loops in inlined constructors],
  sim_cv_c_inlinefor,
  [AC_TRY_COMPILE([
class TestClass {
public:
  TestClass(int);
};

inline TestClass::TestClass(int) { for (int i=0; i<1; i++) i=0; }
],
                 [TestClass t(0);],
                 [sim_cv_c_inlinefor=yes],
                 [sim_cv_c_inlinefor=no])
])
AC_LANG_POP

if test x"$sim_cv_c_inlinefor" = x"yes"; then
  ifelse([$1], , :, [$1])
else
  SIM_AC_ERROR([c--inlinefor])
  $2
fi
])


############################################################################
# Usage:
#   SIM_AC_COMPILER_SWITCH_IN_VIRTUAL_DESTRUCTOR( [ACTION-IF-OK [, ACTION-IF-FAILS ] ] )
#
# Description:
#   Check if the compiler crashes on switch() statements inside virtual
#   destructors.
#
#   This smokes out a particular patch-level version of the CC compiler
#   for Sun WorkShop 6 (update 1 C++ 5.2 Patch 109508-01 2001/01/31).
#

AC_DEFUN([SIM_AC_COMPILER_SWITCH_IN_VIRTUAL_DESTRUCTOR], [

AC_LANG_PUSH(C++)
AC_CACHE_CHECK(
  [if the compiler handles switch statements in virtual destructors],
  sim_cv_c_virtualdestrswitch,
  [AC_TRY_COMPILE([
class hepp { virtual ~hepp(); };
hepp::~hepp() { switch(0) { } }
],
[],
                  [sim_cv_c_virtualdestrswitch=yes],
                  [sim_cv_c_virtualdestrswitch=no])])
AC_LANG_POP

if test x"$sim_cv_c_virtualdestrswitch" = x"yes"; then
  ifelse([$1], , :, [$1])
else
  SIM_AC_ERROR([c--vdest])
  $2
fi
])


############################################################################
# Usage:
#     SIM_AC_COMPILER_CRAZY_GCC296_BUG([ACTION-IF-OK [, ACTION-IF-FAILS ]])
#
# Description:
#   Tries to smoke out some completely fubar bug in g++ of GCC 2.96
#   (at least) when -O2 (or higher, probably) optimization on. The reason
#   we check specifically for this bug is because this compiler version
#   is pretty well spread because it was part of a Red Hat Linux release.
#

AC_DEFUN([SIM_AC_COMPILER_CRAZY_GCC296_BUG], [

AC_LANG_PUSH(C++)
AC_CACHE_CHECK(
  [if this is a version of GCC with a known nasty optimization bug],
  sim_cv_c_gcctwonightysixbug,
  [AC_TRY_RUN([
#include <stdio.h>

class myclass {
public:
  float value;
  float & ref();
};

myclass
hepp(const float v0, const float v1)
{
  myclass proj;

  proj.ref() = 0.0f;
  proj.ref() = -(v1+v0);

  return proj;
}

float &
myclass::ref()
{
  return this->value;
}

int
main(void)
{
  myclass proj = hepp(2.0f, 4.0f);
  return (proj.ref() < 0.0f) ? 0 : 1;
}
],
  [sim_cv_c_gcctwonightysixbug=false],
  [sim_cv_c_gcctwonightysixbug=true],
  [sim_cv_c_gcctwonightysixbug=false
   AC_MSG_WARN([can't check for GCC bug when cross-compiling, assuming it's ok])])
])
AC_LANG_POP


if $sim_cv_c_gcctwonightysixbug; then
  SIM_AC_ERROR(c--gcc296bug)
  $2
else
  ifelse([$1], , :, [$1])
fi
])

# **************************************************************************
# SIM_AC_COMPILER_BUILTIN_EXPECT

AC_DEFUN([SIM_AC_COMPILER_BUILTIN_EXPECT], [
AC_LANG_PUSH(C++)
AC_MSG_CHECKING([for __builtin_expect()])
sim_ac_builtin_expect=false
AC_TRY_LINK([
  #include <assert.h>
], [
  if ( __builtin_expect(!!(1), 1) ? 1 : 0 ) {
    /* nada */
  }
], [sim_ac_builtin_expect=true])

sim_ac_assert_uses_builtin_expect=false
if $sim_ac_builtin_expect; then
  AC_MSG_RESULT([found])
  AC_DEFINE([HAVE___BUILTIN_EXPECT], 1, [Define if compiler has __builtin_expect() macro])

  AC_MSG_CHECKING([if assert() uses __builtin_expect()])
  cat <<EOF > conftest.c
#include <assert.h>

int main(int argc, char ** argv) {
  assert(argv);
}
EOF
  if test x"$CPP" = x; then
    AC_MSG_ERROR([cpp not detected - aborting.  notify maintainer at coin-support@coin3d.org.])
  fi
  echo "$CPP $CPPFLAGS conftest.c" >&AS_MESSAGE_LOG_FD
  sim_ac_builtin_expect_line=`$CPP $CPPFLAGS conftest.c 2>&AS_MESSAGE_LOG_FD | grep "__builtin_expect"`
  if test x"$sim_ac_builtin_expect_line" = x""; then
    AC_MSG_RESULT([no])
  else
    sim_ac_assert_uses_builtin_expect=true
    AC_MSG_RESULT([yes])
    AC_DEFINE([HAVE_ASSERT_WITH_BUILTIN_EXPECT], 1, [Define if assert() uses __builtin_expect()])
  fi
else
  AC_MSG_RESULT([not found])
fi

AC_LANG_POP
]) # SIM_AC_COMPILER_BUILTIN_EXPECT

