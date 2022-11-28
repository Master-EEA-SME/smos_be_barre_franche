#include "anemometre.h"
#include "io.h"

int anemometre_get_wind_speed(void *base)
{
    uint32_t reg = IORD_32DIRECT(base, 4);
    return reg & 0x100 ? reg & 0xFF : -1;
}

void anemometre_set_config(void *base, uint32_t config)
{
    IOWR_32DIRECT(base, 0, config);
}
uint32_t anemometre_get_config(void *base)
{
    return IORD_32DIRECT(base, 0);
}