#ifndef ANEMOMETRE_H
#define ANEMOMETRE_H
#include <stdint.h>

#define ANEMOMETRE_CONFIG_RESET 0x1
#define ANEMOMETRE_CONFIG_CONTINU 0x4
#define ANEMOMETRE_CONFIG_START_STOP 0x2

int anemometre_get_wind_speed(void *base);
void anemometre_set_config(void *base, uint32_t config);
uint32_t anemometre_get_config(void *base);

#endif 