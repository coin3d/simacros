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
  SIM_AC_COMPILER_INLINE_FOR
  SIM_AC_COMPILER_SWITCH_IN_VIRTUAL_DESTRUCTOR
  SIM_AC_COMPILER_CRAZY_GCC296_BUG
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


if $sim_cv_c_gcctwonightysixbug; then
  SIM_AC_ERROR(c--gcc296bug)
  $2
else
  ifelse([$1], , :, [$1])
fi
])
