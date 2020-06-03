#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "parser.tab.h"

int yyerror(const char *msg) {
  fprintf(stderr,"Wrong! (%s)\n",msg);
  return 0;
}

int main (int argc, char *const *argv) {
  while(1) {
    int rc = yyparse();
    printf("yyparse returns: %d\n", rc);
    if(!rc) return 0;
  }
}
