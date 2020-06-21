#include "parser.h"
#include <stdio.h>
#include <math.h>
#include <stdlib.h>

struct commands commands = {
	    .abort = 0,
	    .ota = 0,
	    .gpio = NULL,
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
	    .sleep_clock_accuracy = {
				     .set = 0,
				     .min = 0,
				     .max = 500,
				     .type = VALUE_TYPE_INTEGER,
				     .name = "sleep-clock-accuracy",
				     .help = "set sleep-clock-accuracy <ppm>",
				     },
	    .stay_connected = {
			       .set = 0,
			       .min = 623,
			       .max = 0x7fffffff,
			       .type = VALUE_TYPE_FLOAT,
			       .conversion = 32768,
			       .name = "stay-connected",
			       .help = "set stay-connected <seconds>: duration to remain connected",
			       },
	    .stay_em1 = {
			       .set = 0,
			       .min = 623,
			       .max = 0x7fffffff,
			       .type = VALUE_TYPE_FLOAT,
			       .conversion = 32768,
			       .name = "stay-em1",
			       .help = "set stay-em1 <seconds>: duration to remain in EM1 before advertising",
			       },
	    .stay_em2 = {
			       .set = 0,
			       .min = 623,
			       .max = 0x7fffffff,
			       .type = VALUE_TYPE_FLOAT,
			       .conversion = 32768,
			       .name = "stay-em2",
			       .help = "set stay-em2 <seconds>: duration to remain in EM2 before advertising",
			       },
	    .stay_em3 = {
			       .set = 0,
			       .min = 623,
			       .max = 0x7fffffff,
			       .type = VALUE_TYPE_FLOAT,
			       .conversion = 32768,
			       .name = "stay-em3",
			       .help = "set stay-em3 <seconds>: duration to remain in EM3 before advertising",
			       },
	    .stay_em4h = {
			       .set = 0,
			       .min = 623,
			       .max = 0x7fffffff,
			       .type = VALUE_TYPE_FLOAT,
			       .conversion = 32768,
			       .name = "stay-em4",
			       .help = "set stay-em4h <seconds>: duration to remain in EM4H before advertising",
			       },
	    .stay_em4s = {
			       .set = 0,
			       .min = 623,
			       .max = 0x7fffffff,
			       .type = VALUE_TYPE_FLOAT,
			       .conversion = 32768,
			       .name = "stay-em4s",
			       .help = "set stay-em4s <seconds>: duration to remain in EM4S before advertising",
			       },
	    .average_rssi = {
			     .set = 0,
			     .min = 623,
			     .max = 0x7fffffff,
			     .type = VALUE_TYPE_FLOAT,
			     .conversion = 32768,
			     .name = "average-rssi",
			     .help = "average-rssi <seconds>: duration to average RSSI over",
			     },
	    .rssi_channel = {
			     .set = 0,
			     .min = 0,
			     .max = 2,
			     .type = VALUE_TYPE_INTEGER,
			     .name = "rssi-channel",
			     .help = "set rssi-channel <index>: channel to measure average RSSI.  0-2",
			     },
};

int set_parameter(struct parameter *parameter, struct value *value) {
  int integer;
  //printf("Setting %s to (%d / %lf) ... ",parameter->name,value->integer,value->fp);
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
  //printf("= 0x%x\n",parameter->value);
  if(parameter->value > parameter->max) {
    fprintf(stderr,"%s value too high\n",parameter->name);
    return 1;
  }
  if(parameter->value < parameter->min) {
    fprintf(stderr,"%s value too low\n",parameter->name);
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

void set_mode_and_attach(struct gpio_element *list, uint8_t mode) {
  for(struct gpio_element *ptr = list; ptr; ptr = ptr->next) {
    ptr->mode = mode;
  }
  if(!commands.gpio) {
    commands.gpio = list;
    return;
  }
  for(struct gpio_element *ptr = commands.gpio; ptr; ptr = ptr->next) {
    if(ptr->next) continue;
    ptr->next = list;
    return;
  }
}
