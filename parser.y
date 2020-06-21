/* parser for BG Control NCP */

%{
  #include <stdio.h>
  #include <stdint.h>
  #include "parser.h"
  
  int yylex(void);
  void yyerror(const char *);

  int set_parameter(struct parameter *parameter, struct value *value);
  struct value *create_integer(int value);
  struct value *create_float(double value);
  void set_mode_and_attach(struct gpio_element *list, uint8_t mode);
%}

%union {
  struct value *value;
  struct gpio_element *gpio;
  double fp;
  int integer;
  uint8_t *get;
  struct parameter *set;
}
%token GET SET HELP
%token CONNECTED EM1 EM2 EM3 EM4H EM4S
%token AVERAGE_RSSI RSSI_CHANNEL
%token OTA MEASURE MEASUREMENT_MODE UNKNOWN
%token DCDC EMU GPIO PA_INPUT_VBAT PA_INPUT_DCDC
%token PA_MODE PA_INPUT TX_POWER EM2_DEBUG CONNECTION_INTERVAL ADV_INTERVAL ADV_LENGTH SLEEP_CLOCK_ACCURACY
%token COMMA ASSIGN
%token GPIO_DISABLED GPIO_INPUT GPIO_INPUTPULL GPIO_INPUTPULLFILTER GPIO_PUSHPULL
%token GPIO_WIREOR GPIO_WIREDAND GPIO_WIREDANDFILTER GPIO_WIREDANDPULLUP GPIO_WIREDANDPULLUPFILTER
%token <integer> INT
%token <fp> FLOAT
%token <gpio> GPIO_PIN GPIO_PIN_ASSIGNMENT 
%token ENABLE DISABLE
%nterm <integer> command
%nterm <get> peripheral
%nterm <value> value gpio_pin_value
%nterm <gpio> gpio_pin_assignment gpio_pin_list_element gpio_pin_list
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
| AVERAGE_RSSI value { if(set_parameter(&commands.average_rssi,$2)) commands.abort = 1; free($2); }
| MEASURE value value {
  if(set_parameter(&commands.measurement_mode,$2)) commands.abort = 1; free($2);
  if(set_parameter(&commands.measurement_duration,$3)) commands.abort = 1; free($3);
}
| MEASURE help { printf("measure <mode> <duration>:\n"
			"\tmode: connected em1 em2 em3 em4h em4s\n"
			"\tduration: time in seconds to remain in specified mode before\n"
			"\t\tadvertising as bg-control peripheral\n"); }
| SET help { printf("set <parameters> <value>:\n"
		    "parameters:\n"
		    "\tpa-mode pa-input tx-power em2-debug sleep-clock-accuracy\n"
		    "\tconnection-interval adv-interval adv-length\n"
		    "\tstay-connected em1 em2 em4h em4s rssi-channel\n"); }
| help { printf("Commands:\n"
		"\tota\n"
		"\taverage-rssi <seconds>\n"
		"\tmeasure <mode> <seconds>\n"
		"\tget <peripheral>\n"
		"\tset <parameter> <value>\n"
		"  Specify 'help' as peripheral or parameter to get list of supported names\n"); }
| GPIO_DISABLED gpio_pin_list { set_mode_and_attach($2,0); }
| GPIO_PUSHPULL gpio_pin_list { set_mode_and_attach($2,4); }
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
| SLEEP_CLOCK_ACCURACY { $$ = &commands.sleep_clock_accuracy; }
| RSSI_CHANNEL { $$ = &commands.rssi_channel; }
;

value :
INT { $$ = create_integer($1); }
| FLOAT { $$ = create_float($1); }
| DISABLE { $$ = create_integer(0); $$->type = VALUE_TYPE_ENABLE; }
| ENABLE { $$ = create_integer(1); $$->type = VALUE_TYPE_ENABLE; }
| PA_INPUT_VBAT { $$ = create_integer(0); $$->type = VALUE_TYPE_PA_INPUT; }
| PA_INPUT_DCDC { $$ = create_integer(1); $$->type = VALUE_TYPE_PA_INPUT; }
| CONNECTED { $$ = create_integer(CONNECTED); $$->type = VALUE_TYPE_MEASUREMENT_MODE; }
| EM1 { $$ = create_integer(EM1); $$->type = VALUE_TYPE_MEASUREMENT_MODE; }
| EM2 { $$ = create_integer(EM2); $$->type = VALUE_TYPE_MEASUREMENT_MODE; }
| EM3 { $$ = create_integer(EM3); $$->type = VALUE_TYPE_MEASUREMENT_MODE; }
| EM4H { $$ = create_integer(EM4H); $$->type = VALUE_TYPE_MEASUREMENT_MODE; }
| EM4S { $$ = create_integer(EM4S); $$->type = VALUE_TYPE_MEASUREMENT_MODE; }
;

gpio_pin_list :
gpio_pin_list_element { $$ = $1; $$->next = NULL; }
| gpio_pin_list_element COMMA gpio_pin_list { $$ = $1; $1->next = $3; }
;

gpio_pin_list_element :
GPIO_PIN { $$ = $1; }
| gpio_pin_assignment { $$ = $1; }
;

gpio_pin_assignment :
GPIO_PIN ASSIGN gpio_pin_value { $$ = $1; $$->value = $3->integer; free($3); }

gpio_pin_value :
INT { $$ = create_integer($1); }
;

help :
HELP { commands.abort = 1; }
;

%%
