#ifndef CAP_H
#define CAP_H
#include <stdint.h>

#define CAP_CONFIG_RESET 0x1
#define CAP_CONFIG_CONTINU 0x4
#define CAP_CONFIG_START_STOP 0x2

int cap_get_direction(void *base);
void cap_set_config(void *base, uint32_t config);
uint32_t cap_get_config(void *base);

#endif // CAP_H