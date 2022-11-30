#ifndef GIROUETTE_H
#define GIROUETTE_H
#include <stdint.h>

#define GIROUETTE_CONFIG_RESET 0x1
#define GIROUETTE_CONFIG_CONTINU 0x4
#define GIROUETTE_CONFIG_START_STOP 0x2

int girouette_get_wind_direction(void *base);
void girouette_set_config(void *base, uint32_t config);
uint32_t girouette_get_config(void *base);

#endif // GIROUETTE_H