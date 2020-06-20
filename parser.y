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

  int run = 1;
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
%token GET SET HELP STAY_CONNECTED EM1 EM2 EM4H EM4S OTA UNKNOWN
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
GET peripheral { if($2) {*$2 = 1;} else run = 0; }
| SET EM2_DEBUG binary_value { if($3) {} fprintf(stderr,"error"); exit(1); }
| SET parameter value { printf("got a SET\n"); }
| SET HELP { printf("Parameters: pa-mode pa-input tx-power\n"); }
;

peripheral :
DCDC { $$ = &get.dcdc; }
| EMU { $$ = &get.emu; }
| GPIO { $$ = &get.gpio; }
| HELP { printf("Peripherals: DCDC EMU GPIO\n"); $$ = NULL; }
;

parameter :
PA_MODE { $$.flag = &set.pa_mode; $$.value = &values.pa_mode; }
| PA_INPUT { $$.flag = &set.pa_input; $$.value = &values.pa_input; }
| TX_POWER { $$.flag = &set.tx_power; $$.value = &values.tx_power; }
;

binary_value :
  INT { if (($1 < 0)||($1 > 1)) { fprintf(stderr,"illegal value %d\n",$1); $$ = $1; }}
| ENABLE { $$ = 1; }
| DISABLE { $$ = 0; }
  ;

value :
  INT
  | FLOAT
  ;

%%
