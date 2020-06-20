/* parser for BG Control NCP */

%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <stdint.h>
  #include <math.h>
  #include "parser.h"
  
  int yylex(void);
  void yyerror(const char *);

  struct value {
    enum value_types type;
    double fp;
    int integer;
  };

  int set_parameter(struct parameter *parameter, struct value *value) {
    int integer;
    printf("Setting %s to (%d / %lf) ... ",parameter->name,value->integer,value->fp);
    switch(parameter->type) {
    case VALUE_TYPE_INTEGER:
      switch(value->type) {
      case VALUE_TYPE_INTEGER:
	  parameter->value = value->integer;
	  break;
      case VALUE_TYPE_FLOAT:
	integer = value->fp;
	if(integer == value->fp) {
	  parameter->value = integer;
	  break;
	}
      default:
	fprintf(stderr,"%s value should be integer\n",parameter->name);
	return 1;
      }
      break;
    case VALUE_TYPE_FLOAT:
      switch(value->type) {
      case VALUE_TYPE_INTEGER:
	parameter->value = round(parameter->conversion * value->integer);
	break;
      case VALUE_TYPE_FLOAT:
	parameter->value = round(parameter->conversion * value->fp);
	break;
      default:
	fprintf(stderr,"%s value should be floating-point\n",parameter->name);
	return 1;
      }
      break;
    case VALUE_TYPE_ENABLE:
      switch(value->type) {
      case VALUE_TYPE_INTEGER:
      case VALUE_TYPE_ENABLE:
	parameter->value = value->integer;
	break;
      default:
	fprintf(stderr,"%s value should be one of: 0, 1, enable, disable\n",parameter->name);
	return 1;
      }
    case VALUE_TYPE_PA_INPUT:
      switch(value->type) {
      case VALUE_TYPE_INTEGER:
      case VALUE_TYPE_PA_INPUT:
	parameter->value = value->integer;
	break;
      default:
	fprintf(stderr,"%s value should be one of: 0, 1, VBAT, DCDC\n",parameter->name);
	return 1;
      }
    }
    printf("= 0x%x\n",parameter->value);
    if(parameter->value > parameter->max) {
      fprintf(stderr,"%s value to high\n",parameter->name);
      return 1;
    }
    if(parameter->value < parameter->min) {
      fprintf(stderr,"%s value to low\n",parameter->name);
      return 1;
    }
    parameter->set = 1;
    return 0;
  }

  struct value *create_integer(int value) {
    struct value *rc = malloc(sizeof(struct value));
    rc->type = VALUE_TYPE_INTEGER;
    rc->integer = value;
    return rc;
  }

  struct value *create_float(double value) {
    struct value *rc = malloc(sizeof(struct value));
    rc->type = VALUE_TYPE_FLOAT;
    rc->fp = value;
    return rc;
  }

%}

%union {
  struct value *value;
  double fp;
  int integer;
  uint8_t *get;
  struct parameter *set;
}
%token GET SET HELP STAY_CONNECTED STAY_EM1 STAY_EM2 STAY_EM3 STAY_EM4H STAY_EM4S OTA UNKNOWN
%token DCDC EMU GPIO PA_INPUT_VBAT PA_INPUT_DCDC
%token PA_MODE PA_INPUT TX_POWER EM2_DEBUG CONNECTION_INTERVAL ADV_INTERVAL ADV_LENGTH
%token <integer> INT
%token <fp> FLOAT
%token ENABLE DISABLE
%nterm <integer> command
%nterm <get> peripheral
%nterm <value> value
%nterm <set> parameter

%start line

%%

line :
  /* empty */
  | command line
  ;

command :
OTA { commands.ota = 1; }
| GET peripheral { if($2) {*$2 = 1;}  }
| SET parameter value { if(set_parameter($2,$3)) commands.abort = 1; free($3); }
| SET parameter help {printf("%s\n",$2->help); }
| SET help { printf("set <parameters> <value>:\n"
		    "parameters:\n"
		    "\tpa-mode pa-input tx-power em2-debug\n"
		    "\tconnection-interval adv-interval adv-length\n"
		    "\tstay-connected em1 em2 em4h em4s\n"); }
| help { printf("Commands:\n"
		"\tota\n"
		"\tget <peripheral>\n"
		"\tset <parameter> <value>\n"
		"  Specify 'help' as peripheral or parameter to get list of supported names\n"); }
;

peripheral :
DCDC { $$ = &commands.get.dcdc; }
| EMU { $$ = &commands.get.emu; }
| GPIO { $$ = &commands.get.gpio; }
| help { printf("Peripherals: DCDC EMU GPIO\n"); $$ = NULL; }
;

parameter :
PA_MODE { $$ = &commands.pa_mode; }
| PA_INPUT { $$ = &commands.pa_input; }
| TX_POWER { $$ = &commands.tx_power; }
| EM2_DEBUG { $$ = &commands.em2_debug; }
| CONNECTION_INTERVAL { $$ = &commands.connection_interval; }
| ADV_INTERVAL { $$ = &commands.adv_interval; }
| ADV_LENGTH { $$ = &commands.adv_length; }
| STAY_CONNECTED { $$ = &commands.stay_connected; }
| STAY_EM1 { $$ = &commands.stay_em1; }
| STAY_EM2 { $$ = &commands.stay_em2; }
| STAY_EM3 { $$ = &commands.stay_em3; }
| STAY_EM4H { $$ = &commands.stay_em4h; }
| STAY_EM4S { $$ = &commands.stay_em4s; }
;

value :
INT { $$ = create_integer($1); }
| FLOAT { $$ = create_float($1); }
| DISABLE { $$ = create_integer(0); $$->type = VALUE_TYPE_ENABLE; }
| ENABLE { $$ = create_integer(1); $$->type = VALUE_TYPE_ENABLE; }
| PA_INPUT_VBAT { $$ = create_integer(0); $$->type = VALUE_TYPE_PA_INPUT; }
| PA_INPUT_DCDC { $$ = create_integer(1); $$->type = VALUE_TYPE_PA_INPUT; }
;

help :
HELP { commands.abort = 1; }
;

%%
