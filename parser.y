/* parser for BG Control NCP */

%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <stdint.h>
  #include <math.h>
  int yylex(void);
  void yyerror(const char *);
  enum value_types { VALUE_TYPE_INTEGER, VALUE_TYPE_FLOAT, VALUE_TYPE_ENABLE, VALUE_TYPE_PA_INPUT };
  struct parameter {
    uint8_t set;
    int32_t value;
    int32_t min, max;
    double conversion;
    enum value_types type;
    const char *help, *name;
  };
  struct {
    struct {
      uint8_t dcdc, emu, gpio;
    } get;
    struct parameter pa_mode, pa_input, tx_power, em2_debug, connection_interval, adv_interval, adv_length;
    uint8_t abort;
  } commands = {
		.abort = 0,
		.pa_mode = {
			    .set = 0,
			    .min = 0,
			    .max = 1,
			    .type = VALUE_TYPE_INTEGER,
			    .name = "pa-mode",
			    .help = "set pa-mode <pa>: 0 uses highest power PA, 1 next highest, etc.",
			    },
		.pa_input = {
			     .set = 0,
			     .min = 0,
			     .max = 1,
			     .type = VALUE_TYPE_PA_INPUT,
			     .name = "pa-input",
			     .help = "set pa-input <input>: 0, 1, VBAT or DCDC",
			     },
		.tx_power = {
			     .set = 0,
			     .min = -32768,
			     .max = 32767,
			     .type = VALUE_TYPE_FLOAT,
			     .conversion = 10.0,
			     .name = "tx-power",
			     .help  = "set tx-power <dBm>: requested TX power in dBm, useful range -27 to 20",
			     },
		.em2_debug = {
			      .set = 0,
			      .min = 0,
			      .max = 1,
			      .type = VALUE_TYPE_ENABLE,
			      .name = "em2-debug",
			      .help = "set em2-debug <enable>: 0, 1, disable or enable",
			      },
		.connection_interval = {
					.set = 0,
					.min = 6,
					.max = 3200,
					.type = VALUE_TYPE_FLOAT,
					.conversion = 0.8,
					.name = "connection-interval",
					.help = "set connection-interval <ms>: 7.5 to 4000",
					},
		.adv_interval = {
				 .set = 0,
				 .min = 0x20,
				 .max = 0xffff,
				 .type = VALUE_TYPE_FLOAT,
				 .conversion = 1.6,
				 .name = "adv-interval",
				 .help = "set adv-interval <ms>: 20 to 30000",
				 },
		.adv_length = {
			       .set = 0,
			       .min = 0,
			       .max = 31,
			       .type = VALUE_TYPE_INTEGER,
			       .name = "adv-length",
			       .help = "set adv-length <payload-size>: 0 to 31",
			       },
  };
  
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
	  parameter->set = 1;
	  break;
      case VALUE_TYPE_FLOAT:
	integer = value->fp;
	if(integer == value->fp) {
	  parameter->value = integer;
	  parameter->set = 1;
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
	parameter->set = 1;
	break;
      case VALUE_TYPE_FLOAT:
	parameter->value = round(parameter->conversion * value->fp);
	parameter->set = 1;
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
%token GET SET HELP STAY_CONNECTED EM1 EM2 EM4H EM4S OTA UNKNOWN
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
GET peripheral { if($2) {*$2 = 1;}  }
| SET parameter value { if(set_parameter($2,$3)) commands.abort = 1; free($3); }
| SET parameter help {printf("%s\n",$2->help); }
| SET help { printf("Parameters: pa-mode pa-input tx-power\n"); }
| help { printf("get <peripheral>\nset <parameter> <value>\nSpecify 'help' as peripheral or parameter to get list of supported names\n"); }
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
