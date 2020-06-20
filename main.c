#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "parser.tab.h"
#include <string.h>
#include "scanner.h"

YY_BUFFER_STATE yy_scan_string ( const char *yy_str  );

int yyerror(const char *msg) {
  fprintf(stderr,"Wrong! (%s)\n",msg);
  return 0;
}

int main (int argc, char *const *argv) {
  int arglen[argc];
  int len = 0;
  for(int i = 1; i < argc; i++) {
    arglen[i] = strlen(argv[i]);
    len += arglen[i];
  }
  len += argc;
  char *buf = malloc(len);
  len = 0;
  for(int i = 1; i < argc; i++) {
    len += sprintf(&buf[len],"%s%s",(i>1)?" ":"",argv[i]);
  }
  printf("buf: '%s'\n",buf);
  yy_scan_string(buf);
  while(1) {
    int rc = yyparse();
    printf("yyparse returns: %d\n", rc);
    if(!rc) return 0;
  }
}
