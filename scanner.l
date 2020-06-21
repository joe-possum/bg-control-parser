%{
#include "parser.tab.h"
#include "parser.h"
%}

%%
"help"  { return HELP; }
"get"	{ return GET; }
"set"   { return SET; }
"measure" { return MEASURE; }
"measurement-mode" { return MEASUREMENT_MODE; }
"connected" { return CONNECTED; }
"em1"   { return EM1; }
"em2"   { return EM2; }
"em3"   { return EM3; }
"em4s"  { return EM4S; }
"em4h"  { return EM4H; }
"average-rssi" { return AVERAGE_RSSI; }
"rssi-channel" { return RSSI_CHANNEL; }
"ota"   { return OTA; }
"dcdc"  { return DCDC; }
"emu"   { return EMU; }
"gpio"  { return GPIO; }
"pa-mode" { return PA_MODE; }
"pa-input" { return PA_INPUT; }
"VBAT" { return  PA_INPUT_VBAT; }
"DCDC" { return PA_INPUT_DCDC; }
"tx-power" { return TX_POWER; }
"em2-debug" { return EM2_DEBUG; }
"connection-interval" { return CONNECTION_INTERVAL; }
"adv-interval" { return ADV_INTERVAL; }
"adv-length" { return ADV_LENGTH; }
"sleep-clock-accuracy" { return SLEEP_CLOCK_ACCURACY; }
"enable" { return ENABLE; }
"disable" { return DISABLE; }
"gpio-disabled" { return GPIO_DISABLED; }
"gpio-input" { return GPIO_INPUT; }
"gpio-inputpull" { return GPIO_INPUTPULL; }
"gpio-inputpullfilter" { return GPIO_INPUTPULLFILTER; }
"gpio-pushpull" { return GPIO_PUSHPULL; }
"gpio-wiredor" { return GPIO_WIREOR; }
"gpio-wiredand" { return GPIO_WIREDAND; }
"gpio-wiredandfilter" { return GPIO_WIREDANDFILTER; }
"gpio-wireandpullup" { return GPIO_WIREDANDPULLUP; }
"gpio-wireandpullupfilter" { return GPIO_WIREDANDPULLUPFILTER; }

p[a-k][01]?[0-9] {
  struct gpio_element *ptr = malloc(sizeof(struct gpio_element));
  ptr->port = yytext[1]-'a';
  ptr->value = 2;
  sscanf(yytext+2,"%d",&ptr->pin);
  yylval.gpio = ptr;
  printf("gpio pin: %s\n",yytext); return GPIO_PIN;
}

[+\-]?(([0-9]+\.[0-9]*)|([0-9]*\.[0-9]+))([eE][+\-]?[0-9]+)? { 
  sscanf(yytext,"%lf",&yylval.fp); 
  //printf("float: %s\n",yytext); 
  return FLOAT; 
}
[+\-]?[0-9]+ { 
  sscanf(yytext,"%d",&yylval.integer); 
  //printf("int: %s\n",yytext); 
  return INT; 
}
"0x"[0-9a-fA-F]+ { 
  sscanf(yytext,"%d",&yylval.integer); 
  return INT; 
}

"=" { return ASSIGN; }
"," { return COMMA; }

[ \t\r\n] /* skip whitespace */
.	{ fprintf(stderr,"Unknown character '%c'\n",yytext[0]); return UNKNOWN; }


%%

int yywrap(void) {
(void)input;
(void)yyunput;
return 1; 
}
