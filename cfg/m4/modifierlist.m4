dnl ************************************************************************
dnl Usage:
dnl   SIM_AC_PARSE_MODIFIER_LIST( MODIFIER-LIST-STRING, MODIFIER-VARIABLES, 
dnl       MODIFIER-LIST, opt ACTION-ON-SUCCESS, opt ACTION-ON-FAILURE )
dnl
dnl Description:
dnl   This macro makes it easy to let macros have a MODIFIER-LIST argument
dnl   which can add some flexibility to the macro by letting the developer
dnl   configure some of the macro beaviour from the invocation in the
dnl   configure.in file.
dnl
dnl   Everything is handled on the m4-level, which means things are handled
dnl   at autoconf-run-time, not configure-run-time.  This lets you discover
dnl   problems at an earlier stage, which is nice.  It also lets you insert
dnl   the modifier values into e.g. help strings, something you can't do
dnl   on the shell level.
dnl
dnl   MODIFIER-LIST-STRING is the string of modifiers used in the
dnl   macro invocation.
dnl
dnl   MODIFIER-VARIABLES is a list of variables and their default values.
dnl   The variables and values are recognized as words matching [[^\s-]*]
dnl   separated by whitespace, and they must of course come in pairs.
dnl
dnl   MODIFIER-LIST is a description-list of all the valid modifiers that
dnl   can be used in the MODIFIER-LIST-STRING argument.  They must come in
dnl   tuples of three and three words (same word-definition as above) where
dnl   the first word is the modifier, the second word is the variable
dnl   that is to be set by the modifier, and last the value the modifier
dnl   variable should be set to.
dnl
dnl   ACTION-ON-SUCCESS is the expansion of the macro if all the modifiers
dnl   in MODIFIER-LIST-STRING pass through without problem.  The default
dnl   expansion is nothing.
dnl
dnl   ACTION-ON-FAILURE is the expansion of the macro if some of the
dnl   modifiers in MODIFIER-LIST-STRING doesn't pass through.  The default
dnl   expansion is nothing, but warnings are printed to stderr on the
dnl   modifiers causing the problem.
dnl
dnl Sample Usage:
dnl   [to come later]
dnl
dnl Authors:
dnl   Lars J. Aas <larsa@sim.no> (idea, design, coding)
dnl   Akim Demaille <akim@epita.fr> (hints, tips, corrections)
dnl
dnl TODO:
dnl * [larsa:20000222] more warnings on potential problems
dnl

define([m4_noquote],
[changequote(-=<{,}>=-)$1-=<{}>=-changequote([,])])

AC_DEFUN([SIM_AC_PML_WARNING],
[errprint([SIM_PARSE_MODIFIER_LIST: $1
  (file "]__file__[", line ]__line__[)
])])

define([TAB],[	])
define([LF],[
])

dnl * this is an unquoted string compaction - words in string must expand to
dnl * nothing before compaction starts...
AC_DEFUN([SIM_AC_PML_STRING_COMPACT],
[patsubst(patsubst([$1],m4_noquote([[TAB LF]+]),[ ]),[^ \| $],[])])

AC_DEFUN([SIM_AC_PML_STRING_WORDCOUNT_COMPACT],
[m4_eval((1+len(patsubst([$1],[[^ ]+],[_])))/2)])

AC_DEFUN([SIM_AC_PML_STRING_WORDCOUNT],
[SIM_AC_PML_STRING_WORDCOUNT_COMPACT([SIM_AC_PML_STRING_COMPACT([$1])])])

AC_DEFUN([SIM_AC_PML_DEFINE_VARIABLE],
[define([$1],[$2])])

AC_DEFUN([SIM_AC_PML_DEFINE_VARIABLES],
[ifelse(SIM_AC_PML_STRING_WORDCOUNT_COMPACT([$1]), 2,
        [patsubst([$1],[^\([^ ]+\) \([^ ]+\)],
                  [SIM_AC_PML_DEFINE_VARIABLE([\1],[\2])])],
        [patsubst([$1],[^\([^ ]+\) \([^ ]+\) \(.*\)],
                  [SIM_AC_PML_DEFINE_VARIABLE([\1],[\2])SIM_AC_PML_DEFINE_VARIABLES([\3])])])])

AC_DEFUN([SIM_AC_PML_PUSHDEF_MODIFIER],
[ifelse(defn([$2]), [],
        [SIM_AC_PML_ERROR([invalid variable in argument 3: "$2"])],
        [pushdef([$1],[define([$2],[$3])])])])

AC_DEFUN([SIM_AC_PML_PUSHDEF_MODIFIERS],
[ifelse(SIM_AC_PML_STRING_WORDCOUNT_COMPACT([$1]), 3,
        [patsubst([$1],[^\([^ ]+\) \([^ ]+\) \([^ ]+\)],
                  [SIM_AC_PML_PUSHDEF_MODIFIER([\1],[\2],[\3])])],
        [patsubst([$1],[^\([^ ]+\) \([^ ]+\) \([^ ]+\) \(.*\)],
                  [SIM_AC_PML_PUSHDEF_MODIFIER([\1],[\2],[\3])SIM_AC_PML_PUSHDEF_MODIFIERS([\4])])])])

AC_DEFUN([SIM_AC_PML_POPDEF_MODIFIER],
[popdef([$1])])

AC_DEFUN([SIM_AC_PML_POPDEF_MODIFIERS],
[ifelse(SIM_AC_PML_STRING_WORDCOUNT_COMPACT([$1]), 3,
        [patsubst([$1],[^\([^ ]+\) \([^ ]+\) \([^ ]+\)],
                  [SIM_AC_PML_POPDEF_MODIFIER([\1])])],
        [patsubst([$1],[^\([^ ]+\) \([^ ]+\) \([^ ]+\) \(.*\)],
                  [SIM_AC_PML_POPDEF_MODIFIER([\1])SIM_AC_PML_POPDEF_MODIFIERS([\4])])])])

AC_DEFUN([SIM_AC_PML_PARSE_MODIFIER_LIST],
[pushdef([wordcount],SIM_AC_PML_STRING_WORDCOUNT([$2]))]dnl
[ifelse(m4_eval(((wordcount % 2) == 0) && (wordcount > 0)), 1,
        [],
        [SIM_AC_PML_WARNING([invalid word count ]wordcount[ for argument 2: "]SIM_AC_PML_STRING_COMPACT([$2])")])]dnl
[popdef([wordcount])]dnl
[pushdef([wordcount],SIM_AC_PML_STRING_WORDCOUNT([$3]))]dnl
[ifelse(m4_eval(((wordcount % 3) == 0) && (wordcount > 0)), 1,
        [],
        [SIM_AC_PML_WARNING([invalid word count ]wordcount[ for argument 3: "$3"])])]dnl
[popdef([wordcount])]dnl
[SIM_AC_PML_DEFINE_VARIABLES([$2])]dnl
[SIM_AC_PML_PUSHDEF_MODIFIERS([$3])]dnl
[ifelse(SIM_AC_PML_STRING_COMPACT([$1]), [],
        [ifelse([$4], [], [], [$4])],
        [ifelse([$5], [],
                [SIM_AC_PML_WARNING([modifier(s) parse error: "]SIM_AC_PML_STRING_COMPACT([$1])")],
                [$5])])]dnl
[SIM_AC_PML_POPDEF_MODIFIERS([$3])])

AC_DEFUN([SIM_AC_PARSE_MODIFIER_LIST],
[SIM_AC_PML_PARSE_MODIFIER_LIST(
        SIM_AC_PML_STRING_COMPACT([$1]),
        SIM_AC_PML_STRING_COMPACT([$2]),
        SIM_AC_PML_STRING_COMPACT([$3]),
        [$4],
        [$5])])

dnl * to be deleted after migrating dependant macros to ac_sim_...
AC_DEFUN([SIM_PARSE_MODIFIER_LIST],
[SIM_AC_PML_PARSE_MODIFIER_LIST(
        SIM_AC_PML_STRING_COMPACT([$1]),
        SIM_AC_PML_STRING_COMPACT([$2]),
        SIM_AC_PML_STRING_COMPACT([$3]),
        [$4],
        [$5])])

