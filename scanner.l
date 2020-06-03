%{
#include "y.tab.h"
%}

%%
"get"	{ return GET; }
"set"   { return SET; }
"stay-connected" { return STAY_CONNECTED; }
"em2"   { return EM2; }
"em4s"  { return EM4S; }
"em4h"  { return EM4H; }
"ota"   { return OTA; }
"dcdc"  { return DCDC; }
"emu"   { return EMU; }
"gpio"  { return GPIO; }
"pa-mode" { return PA_MODE; }
"pa-input" { return PA_INPUT; }
"em2-debug" { return EM2_DEBUG; }
"enable" { return ENABLE; }
"disable" { return DISABLE; }
[+\-]?(([0-9]+\.[0-9]*)|([0-9]*\.[0-9]+)) { sscanf(yytext,"%lf",&yylval.fp); printf("float: %s\n",yytext); return FLOAT; }
[+\-]?[0-9]+ { sscanf(yytext,"%d",&yylval.integer); printf("int: %s\n",yytext); return INT; }
"0x"[0-9a-fA-F]+ { sscanf(yytext,"%d",&yylval.integer); return INT; }

[ \t\r\n] /* skip whitespace */
.	{ fprintf(stderr,"Unknown character '%c'\n",yytext[0]); return UNKNOWN; }

%%

int yywrap(void) { return 1; }
