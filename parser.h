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
struct gpio_element {
  int port, pin, mode, value;
  struct gpio_element *next;
};
struct commands {
  struct {
    uint8_t dcdc, emu, gpio;
  } get;
  struct parameter pa_mode, pa_input, tx_power, em2_debug, sleep_clock_accuracy,
    connection_interval, adv_interval, adv_length,
    stay_connected, stay_em1, stay_em2, stay_em3, stay_em4h, stay_em4s, average_rssi, rssi_channel;
  uint8_t abort, ota;
  struct gpio_element *gpio;
};

extern struct commands commands;
