%{
#include "y.tab.h"
%}

%%
"get"	{ return GET; }
"set"   { return SET; }
"dcdc"  { return DCDC; }
"emu"   { return EMU; }
"gpio"  { return GPIO; }
[ \t\r\n] /* skip whitespace */
.	{ fprintf(stderr,"Unknown character '%c'\n",yytext[0]); return UNKNOWN; }

%%

int yywrap(void) { return 1; }
