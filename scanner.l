%{
#include "parser.tab.h"
#include "parser.h"

#define RETURN(X) do { return X; } while(0)

%}

%%
"help"  { RETURN(HELP); }

"get"	{ RETURN(GET); }
"set"   { RETURN(SET); }
"ota"   { RETURN(OTA); }
"average-rssi" { RETURN(AVERAGE_RSSI); }
"measure" { RETURN(MEASURE); }
"gpio-disabled" { RETURN(GPIO_DISABLED); }
"gpio-input" { RETURN(GPIO_INPUT); }
"gpio-inputpull" { RETURN(GPIO_INPUTPULL); }
"gpio-inputpullfilter" { RETURN(GPIO_INPUTPULLFILTER); }
"gpio-pushpull" { RETURN(GPIO_PUSHPULL); }
"gpio-wiredor" { RETURN(GPIO_WIREOR); }
"gpio-wiredand" { RETURN(GPIO_WIREDAND); }
"gpio-wiredandfilter" { RETURN(GPIO_WIREDANDFILTER); }
"gpio-wireandpullup" { RETURN(GPIO_WIREDANDPULLUP); }
"gpio-wireandpullupfilter" { RETURN(GPIO_WIREDANDPULLUPFILTER); }

"measurement-mode" { RETURN(MEASUREMENT_MODE); }
"rssi-channel" { RETURN(RSSI_CHANNEL); }
"pa-mode" { RETURN(PA_MODE); }
"pa-input" { RETURN(PA_INPUT); }
"tx-power" { RETURN(TX_POWER); }
"em2-debug" { RETURN(EM2_DEBUG); }
"connection-interval" { RETURN(CONNECTION_INTERVAL); }
"adv-interval" { RETURN(ADV_INTERVAL); }
"adv-length" { RETURN(ADV_LENGTH); }
"sleep-clock-accuracy" { RETURN(SLEEP_CLOCK_ACCURACY); }

"connected" { RETURN(CONNECTED); }
"em1"   { RETURN(EM1); }
"em2"   { RETURN(EM2); }
"em3"   { RETURN(EM3); }
"em4s"  { RETURN(EM4S); }
"em4h"  { RETURN(EM4H); }

"dcdc"  { RETURN(DCDC); }
"emu"   { RETURN(EMU); }
"gpio"  { RETURN(GPIO); }

"VBAT" { RETURN( PA_INPUT_VBAT); }
"DCDC" { RETURN(PA_INPUT_DCDC); }

"enable" { RETURN(ENABLE); }
"disable" { RETURN(DISABLE); }

p[a-k][01]?[0-9] {
  struct gpio_element *ptr = malloc(sizeof(struct gpio_element));
  ptr->port = yytext[1]-'a';
  ptr->value = 2;
  sscanf(yytext+2,"%d",&ptr->pin);
  yylval.gpio = ptr;
  printf("gpio pin: %s\n",yytext); RETURN(GPIO_PIN);
}

[+\-]?(([0-9]+\.[0-9]*)|([0-9]*\.[0-9]+))([eE][+\-]?[0-9]+)? { 
  sscanf(yytext,"%lf",&yylval.fp); 
  //printf("float: %s\n",yytext); 
  RETURN(FLOAT); 
}
[+\-]?[0-9]+ { 
  sscanf(yytext,"%d",&yylval.integer); 
  //printf("int: %s\n",yytext); 
  RETURN(INT); 
}
"0x"[0-9a-fA-F]+ { 
  sscanf(yytext,"%d",&yylval.integer); 
  RETURN(INT); 
}

"=" { RETURN(ASSIGN); }
"," { RETURN(COMMA); }

[ \t\r\n] /* skip whitespace */
.	{ fprintf(stderr,"Unknown character '%c'\n",yytext[0]); RETURN(UNKNOWN); }


%%

int yywrap(void) {
(void)input;
(void)yyunput;
return 1; 
}
