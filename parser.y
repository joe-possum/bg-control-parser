/* parser for BG Control NCP */

%{
  #include <stdio.h>
  int yylex(void);
  void yyerror(const char *);
%}

%define api.value.type {int}
%token GET SET UNKNOWN
%token DCDC EMU GPIO

%%

input : line
;

line :
  %empty
| command line
  ;

command :
GET peripheral { printf("got a GET\n"); }
;

peripheral :
  DCDC
  | EMU
  | GPIO { printf("got GPIO\n"); }
;

%%
