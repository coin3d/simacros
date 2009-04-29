# **************************************************************************
# SIM_AC_HAVE_CGIMAGE_IFELSE( IF-FOUND, IF-NOT-FOUND )
#
# Variables:
#   sim_ac_have_cgimage
#   sim_ac_cgimage_libs
#
# Authors:
#   Marius Kintel <kintel@sim.no>

AC_DEFUN([SIM_AC_HAVE_CGIMAGE_IFELSE],
[: ${sim_ac_have_cgimage=false}
AC_MSG_CHECKING([for CGImage framework])
$sim_ac_have_cgimage && break
sim_ac_cgimage_save_LIBS=$LIBS
sim_ac_cgimage_libs="-Wl,-framework,CoreFoundation -Wl,-framework,ApplicationServices"
LIBS="$sim_ac_cgimage_libs $LIBS"
AC_TRY_LINK(
  [#include <CoreFoundation/CoreFoundation.h>
   #include <ApplicationServices/ApplicationServices.h>],
  [CFStringRef cfname = CFStringCreateWithCString(kCFAllocatorDefault, 
                                                "filename.png", 
                                                kCFStringEncodingUTF8);
  CFURLRef texture_url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                                       cfname,
                                                       kCFURLPOSIXPathStyle,
                                                       false);
  CGImageSourceRef image_source = CGImageSourceCreateWithURL(texture_url, NULL);],
  [sim_ac_have_cgimage=true])
LIBS=$sim_ac_cgimage_save_LIBS
if $sim_ac_have_cgimage; then
  AC_MSG_RESULT([success ($sim_ac_cgimage_libs)])
  $1
else
  AC_MSG_RESULT([failure])
  $2
fi
])

# EOF **********************************************************************
