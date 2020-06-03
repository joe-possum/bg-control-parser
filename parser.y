/* parser for BG Control NCP */

%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <stdint.h>
  int yylex(void);
  void yyerror(const char *);
  struct {
    uint8_t dcdc, emu, gpio;
  } get;
  struct {
    uint8_t pa_mode, pa_input, tx_power;
  } set;
  struct {
    uint32_t pa_mode, pa_input, tx_power;
  } values;
%}

%union {
  double fp;
  int integer;
  uint8_t *get;
  struct {
    uint8_t *flag;
    uint32_t *value;
  } set;
}
%token GET SET STAY_CONNECTED EM2 EM4H EM4S OTA UNKNOWN
%token DCDC EMU GPIO
%token PA_MODE PA_INPUT TX_POWER EM2_DEBUG
%token <integer> INT
%token <fp> FLOAT
%token ENABLE DISABLE
%nterm <integer> binary_value
%nterm <integer> command
%nterm <get> peripheral
%nterm <set> parameter
%start line

%%

line :
  %empty
  | command line
  ;

command :
GET peripheral { *$2 = 1; }
| SET EM2_DEBUG binary_value { if($3) {} fprintf(stderr,""); exit(1); }
| SET parameter value { printf("got a SET\n"); }
;

peripheral :
DCDC { $$ = &get.dcdc; }
| EMU { $$ = &get.emu; }
| GPIO { $$ = &get.gpio; }
;

parameter :
PA_MODE { $$.flag = &set.pa_mode; $$.value = &values.pa_mode; }
| PA_INPUT { $$.flag = &set.pa_input; $$.value = &values.pa_input; }
| TX_POWER { $$.flag = &set.tx_power; $$.value = &values.tx_power; }
;

binary_value :
  INT { if (($1 < 0)||($1 > 1)) { fprintf(stderr,"illegal value\n",$1); $$ = $1; }}
| ENABLE { $$ = 1; }
| DISABLE { $$ = 0; }
  ;

value :
  INT
  | FLOAT
  ;

%%
