#include "girouette.h"
#include "io.h"

int girouette_get_wind_direction(void *base)
{
    uint32_t reg = IORD_32DIRECT(base, 4);
    return reg & 0x200 ? reg & 0x1FF : -1;
}

void girouette_set_config(void *base, uint32_t config)
{
    IOWR_32DIRECT(base, 0, config);
}
uint32_t girouette_get_config(void *base)
{
    return IORD_32DIRECT(base, 0);
}