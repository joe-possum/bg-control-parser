#include <stdio.h>
#include "y.tab.h"

int yyerror(const char *msg) {
  fprintf(stderr,"Wrong! (%s)\n",msg);
  return 0;
}

int main (int argc, char *const *argv) {
  while(1) {
    printf("yylex returns: %d\n", yylex());
  }
}
