#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "parser.tab.h"
#include <string.h>
#include "scanner.h"
#include "parser.h"

YY_BUFFER_STATE yy_scan_string ( const char *yy_str  );

int yyparse(void);

int yyerror(const char *msg) {
  fprintf(stderr,"Wrong! (%s)\n",msg);
  return 0;
}

int main (int argc, char *const *argv) {
  int arglen[argc];
  int len = 0;
  for(int i = 1; i < argc; i++) {
    arglen[i] = strlen(argv[i]);
    len += arglen[i];
  }
  len += argc;
  char *buf = malloc(len);
  len = 0;
  for(int i = 1; i < argc; i++) {
    len += sprintf(&buf[len],"%s%s",(i>1)?" ":"",argv[i]);
  }
  yy_scan_string(buf);
  int rc = yyparse();
  if(rc) {
    printf("yyparse returns: %d\n", rc);
    return 1;
  }
  if(commands.abort) {
    fprintf(stderr,"Abort\n");
    return 1;
  }
  if(commands.ota) {
    fprintf(stderr,"Target will OTA\n");
    return 0;
  }
#define S(X) if(commands.X.set) printf("set " #X " to %d\n",commands.X.value)
  if(commands.average_rssi.set) {
    printf("NCP will average RSSI on channel %d from device for %0.1lf seconds\n",
	   commands.rssi_channel.value,
	   commands.average_rssi.value/32768.);
    return 0;
  }
  if(commands.average_rssi.set) {
    printf("NCP will average RSSI on channel %d from device for %0.1lf seconds\n",
	   commands.rssi_channel.value,
	   commands.average_rssi.value/32768.);
    return 0;
  }
  S(pa_mode);
  S(pa_input);
  S(tx_power);
  S(em2_debug);
  S(connection_interval);
  S(adv_interval);
  S(adv_length);
  S(sleep_clock_accuracy);
  for(struct gpio_element *ptr = commands.gpio; ptr; ptr = ptr->next) {
    printf("p%c%d: set mode: %d, set value: %d\n",'a'+ptr->port,ptr->pin,ptr->mode,1&ptr->value);
  }
  if(commands.measurement_mode.set) {
    printf("DUT will remain in mode %d for %f seconds\n",
	   commands.measurement_mode.value,
	   commands.measurement_duration.value/32768.);
    return 0;
  }
}
