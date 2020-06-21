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
%token STAY_CONNECTED STAY_EM1 STAY_EM2 STAY_EM3 STAY_EM4H STAY_EM4S
%token AVERAGE_RSSI RSSI_CHANNEL
%token OTA UNKNOWN
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
| SET help { printf("set <parameters> <value>:\n"
		    "parameters:\n"
		    "\tpa-mode pa-input tx-power em2-debug sleep-clock-accuracy\n"
		    "\tconnection-interval adv-interval adv-length\n"
		    "\tstay-connected em1 em2 em4h em4s rssi-channel\n"); }
| help { printf("Commands:\n"
		"\tota\n"
		"\taverage-rssi <seconds>\n"
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
| STAY_CONNECTED { $$ = &commands.stay_connected; }
| STAY_EM1 { $$ = &commands.stay_em1; }
| STAY_EM2 { $$ = &commands.stay_em2; }
| STAY_EM3 { $$ = &commands.stay_em3; }
| STAY_EM4H { $$ = &commands.stay_em4h; }
| STAY_EM4S { $$ = &commands.stay_em4s; }
| RSSI_CHANNEL { $$ = &commands.rssi_channel; }
;

value :
INT { $$ = create_integer($1); }
| FLOAT { $$ = create_float($1); }
| DISABLE { $$ = create_integer(0); $$->type = VALUE_TYPE_ENABLE; }
| ENABLE { $$ = create_integer(1); $$->type = VALUE_TYPE_ENABLE; }
| PA_INPUT_VBAT { $$ = create_integer(0); $$->type = VALUE_TYPE_PA_INPUT; }
| PA_INPUT_DCDC { $$ = create_integer(1); $$->type = VALUE_TYPE_PA_INPUT; }
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
