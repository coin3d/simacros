# SIM_AC_STRIP_EXIT_DECLARATION
#
# Autoconf adds a declaration of exit() to confdefs.h, which causes
# configure tests to fail later on when configuring for Visual C++
# compilers.  This macro edits out the exit-declaration (which we
# really don't need anyway) from the confdefs.h file.
#
# Typically, it should be inserted as early as possible, but after
# AC_PROG_CXX / AC_PROG_CXXCPP.
#
# 2007-05-30 larsa

AC_DEFUN([SIM_AC_STRIP_EXIT_DECLARATION], [
mv confdefs.h confdefs.old
egrep -v "void.*exit" confdefs.old >confdefs.h
rm -f confdefs.old
])

