# Process this file with autoconf to produce a configure script.
AC_INIT
AC_CONFIG_AUX_DIR(cfg)

AM_INIT_AUTOMAKE(simacros, 1.0)
AM_CONFIG_HEADER(config.h)

# Checks for programs.
AC_PROG_CXX
AC_PROG_INSTALL
AC_PROG_CC
AC_PROG_AWK

# Checks for libraries.

# Checks for header files.
AC_HEADER_STDC
AC_CHECK_HEADERS([stdlib.h])

# Checks for typedefs, structures, and compiler characteristics.
AC_C_CONST
AC_C_INLINE

# Checks for library functions.
AC_FUNC_STAT
AC_FUNC_VPRINTF
AC_CHECK_FUNCS([strerror])

AC_CONFIG_FILES([Makefile bin/Makefile cfg/Makefile cfg/m4/Makefile])
AC_OUTPUT
