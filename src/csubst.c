/*
  csubst - windows exe alternative to the config.status acsubst functionality.

  To build:
       ./wrapmsvc.exe -o csubst.exe /MT -g /Fdcsubst.pdb csubst.c
    or gcc -nocygwin ...

  (Note: avoid cygwin-dependency at all cost)

  This executable reads in Makefile from the current directory to get an
  overview over the AC_SUBST variable substitution rules, and then performs
  substitution on the files given on the --file= command line option.
  It is used from the Visual Studio project files to avoid having to have
  pregenerated, duplicated files in the build directories since they easily
  get out of sync with the current "template" versions.  At least that's
  the idea - it hasn't been implemented yet on the Visual Studio project file
  side.

  /larsa@sim.no 2007-05-07

*/

#define MAX_LINELENGTH  4096
#define MAX_SUBSTVARS    511

#include <assert.h>
#include <stdio.h>
#include <stddef.h>
#include <string.h>

#ifndef FALSE
#define FALSE 0
#define TRUE (!FALSE)
#endif // !FALSE

#if 1 /* set to 1 to disable debug output */
#define DBG(arg) do { /*nada*/ } while (0)
#else
#define DBG(arg) do { arg } while (0)
#endif
static int numsubstvars = 0;
static char * substvars[MAX_SUBSTVARS+1];
static char * substvalues[MAX_SUBSTVARS+1];

int
read_rules(FILE * fp)
{
  int varnamelen, varvaluelen;
  char linebuf[MAX_LINELENGTH+1];
  int offset;
  char * eqsign;
  while (fgets(linebuf, MAX_LINELENGTH, fp)) {
    if (numsubstvars >= MAX_SUBSTVARS) return 1;
    if (linebuf[0] == '#') continue;
    if (linebuf[0] == '\n' || linebuf[0] == '\r') continue;

    eqsign = strchr(linebuf, '=');
    if (!eqsign) return 1; /* probably end of rules now */

    varnamelen = eqsign-linebuf-1;
    substvars[numsubstvars] = (char *) malloc(varnamelen+1);
    strncpy(substvars[numsubstvars], linebuf, varnamelen);
    substvars[numsubstvars][varnamelen] = '\0';
 
    varvaluelen = strlen(eqsign);
    eqsign += 2;
    varvaluelen -= 2; /* advance value start pointers */

    do {
      while ((varvaluelen > 0) &&
             (eqsign[varvaluelen-1] == '\r' ||
              eqsign[varvaluelen-1] == '\n')) {
        --varvaluelen;
        eqsign[varvaluelen] = '\0';
      }

      while (eqsign[varvaluelen-1] == '\\') {
        fgets(eqsign + varvaluelen - 1,
              MAX_LINELENGTH - (eqsign + varvaluelen - linebuf), fp);
        varvaluelen = strlen(eqsign);
        while (eqsign[varvaluelen-1] == '\r' || eqsign[varvaluelen-1] == '\n') {
          --varvaluelen;
          eqsign[varvaluelen] = '\0';
        }

      }
    } while ((varvaluelen > 0) &&
             (eqsign[varvaluelen-1] == '\r' ||
              eqsign[varvaluelen-1] == '\n' ||
              eqsign[varvaluelen-1] == '\\'));

    if (varvaluelen > 0) {
      substvalues[numsubstvars] = strdup(eqsign);
      DBG(fprintf(stdout, "dbug: var '%s' val '%s'\n", substvars[numsubstvars], substvalues[numsubstvars]););
      ++numsubstvars;
    } else {
      free(substvars[numsubstvars]);
      substvars[numsubstvars] = NULL;
    }
  }
  return (numsubstvars > 0);
}

const char *
get_value(const char * variable)
{
  int i;
  assert(variable);
  for (i = 0; i < numsubstvars; ++i) {
    if (strcmp(variable, substvars[i]) == 0) {
      return substvalues[i];
    }
  }
  return NULL;
}

/*
  substitute the first valid subst-keyword in origbuffer, filling
  newbuffer with the substitution result.  Returns TRUE if substitution
  was done, and FALSE otherwise.  When FALSE is returned, newbuffer is
  untouched.
*/
int
subst_line(const char * origbuffer, char * newbuffer)
{
  const char * atptr1, * atptr2, * substval;
  char varname[MAX_LINELENGTH];
  int varnamelen, varoffset, substvarlen;

  atptr1 = strchr(origbuffer, '@');
  if (!atptr1) return FALSE;

  do {
    atptr2 = strchr(atptr1+1, '@');
    if (!atptr2) return FALSE;

    varnamelen = atptr2 - atptr1 - 1;
    strncpy(varname, atptr1+1, varnamelen);
    varname[varnamelen] = '\0';

    DBG(fprintf(stdout, "dbg: subst name '%s'\n", varname););

    substval = get_value(varname);
    if (substval) {
      varoffset = atptr1 - origbuffer;
      substvarlen = strlen(substval);
      memcpy(newbuffer, origbuffer, varoffset);
      memcpy(newbuffer + varoffset, substval, substvarlen);
      strcpy(newbuffer + varoffset + substvarlen, atptr2 + 1);
      return TRUE;
    }

    atptr1 = atptr2;
  } while (TRUE);
  /* notreached */
}

int
subst_file(FILE * in, FILE * out)
{
  char linebuf1[MAX_LINELENGTH+1];
  char linebuf2[MAX_LINELENGTH+1];
  char * origline, * newline, * tmpptr;

  char * atptr, * nextptr;
  char * varname, * value;
  int dump;
  while (fgets(linebuf1, MAX_LINELENGTH, in)) {
    origline = linebuf1;
    newline = linebuf2;
    while (subst_line(origline, newline)) {
      tmpptr = origline;
      origline = newline;
      newline = tmpptr;
    }
    /* origline contains final version */
    fprintf(out, "%s", origline);
  }
  return 1;
}

void
print_help(FILE * fp)
{
  fprintf(fp, "csubst --file=<in-file>:<out-file>\n");
}

int
main(int argc, char ** argv)
{
  const char * infileptr, * templatenameptr;
  char * infilename;
  const char * outfileptr;
  char * outfilename;
  FILE * makefile, * infile, * outfile;
  const char * srcdir ;

  if (argc == 1) {
    print_help(stdout);
    return 0;
  }

  if (argc != 2 || strncmp(argv[1], "--file=", 7) != 0) {
    print_help(stderr);
    return -1;
  }

  infileptr = argv[1] + 7;
  outfileptr = strchr(infileptr, ':');
  if (!outfileptr) {
    print_help(stderr);
    return -1;
  }
  ++outfileptr;

  infilename = (char *) malloc(outfileptr - infileptr + 1);
  strncpy(infilename, infileptr, outfileptr - infileptr - 1);
  infilename[outfileptr - infileptr - 1] = '\0';

  templatenameptr = strrchr(infilename, '\\');
  if (templatenameptr == NULL) templatenameptr = infilename;
  else templatenameptr++;

  outfilename = strdup(outfileptr);

  // "fake" the builtin @configure_input@ substitution
  substvars[numsubstvars] = strdup("configure_input");
  substvalues[numsubstvars] = (char *) malloc(512);
  sprintf(substvalues[numsubstvars], "%s.  Generated from %s by configure.",
          outfileptr, templatenameptr);
  numsubstvars++;

  makefile = fopen("Makefile", "r");
  if (!makefile) {
    fprintf(stderr, "csubst: error: couldn't find a Makefile for reading the rues\n");
    return -1;
  }

  if (!read_rules(makefile)) {
    fprintf(stderr, "csubst: error: not able to read Makefile rules.\n");
    fclose(makefile);
    return -1;
  }
  fclose(makefile);
  DBG(fprintf(stdout, "dbg: read in %d substitution rules\n", numsubstvars););

  srcdir = get_value("srcdir");
  if (!srcdir) {
    fprintf(stderr, "csubst: error: did not find a @srcdir@ substitution when reading from Makefile.\n");
    return -1;
  }
  DBG(fprintf(stdout, "dbg: srcdir = '%s'\n", srcdir););

  DBG(fprintf(stdout, "dbg: input file '%s'\n", infilename););
  /* FIXME: add @srcdir@/ to front of infile name */
  infile = fopen(infilename, "r");
  if (!infile) {
    fprintf(stderr, "csubst: error: no input file '%s'\n", infilename);
    free(infilename);
    return -1;
  }

  DBG(fprintf(stdout, "dbg: output file '%s'\n", outfilename););
  outfile = fopen(outfilename, "wb");
  if (!outfile) {
    fprintf(stderr, "csubst: error: not able to open output file '%s' for writing.\n", outfilename);
    fclose(infile);
    free(infilename);
    free(outfilename);
    return -1;
  }

  if (!subst_file(infile, outfile)) {
    fprintf(stderr, "csubst: error: during substitution.\n");
    fclose(infile);
    fclose(outfile);
    free(infilename);
    free(outfilename);
    return -1;
  }
  free(infilename);
  free(outfilename);
  fclose(infile);
  fclose(outfile);

  return 0;
} // main()
