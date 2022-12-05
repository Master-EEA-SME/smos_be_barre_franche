#include "verin.h"
#include "io.h"
#include "../pwm/pwm.h"

void verin_set_config(void *base, uint32_t config)
{
    IOWR_32DIRECT(base, 16, config);
}
uint32_t verin_get_config(void *base)
{
    return IORD_32DIRECT(base, 16);
}

void verin_set_pwm_frequency(void *base, uint32_t freq)
{
    pwm_set_frequency((base - 4), freq);
}

void verin_set_pwm_duty(void *base, uint32_t duty)
{
    pwm_set_duty((base + 4), duty);
}

void verin_set_butee_g(void *base, uint32_t butee_g)
{
    IOWR_32DIRECT(base, 8, butee_g);
}
void verin_set_butee_d(void *base, uint32_t butee_d)
{
    IOWR_32DIRECT(base, 12, butee_d);
}
uint32_t verin_get_butee_g(void *base)
{
    return IORD_32DIRECT(base, 8);
}
uint32_t verin_get_butee_d(void *base)
{
    return IORD_32DIRECT(base, 12);
}
uint32_t verin_get_angle_barre(void *base)
{
    return IORD_32DIRECT(base, 20);
}
