#include <stdint.h>

enum value_types { VALUE_TYPE_INTEGER, VALUE_TYPE_FLOAT, VALUE_TYPE_ENABLE, VALUE_TYPE_PA_INPUT };
struct parameter {
  uint8_t set;
  int32_t value;
  int32_t min, max;
  double conversion;
  enum value_types type;
  const char *help, *name;
};
struct commands {
  struct {
    uint8_t dcdc, emu, gpio;
  } get;
  struct parameter pa_mode, pa_input, tx_power, em2_debug, connection_interval, adv_interval, adv_length,
    stay_connected, stay_em1, stay_em2, stay_em3, stay_em4h, stay_em4s;
  uint8_t abort, ota;
};

extern struct commands commands;
