#include "pwm.h"
#include "io.h"
#include "system.h"

#define PWM_SET_DUTY(base, value) IOWR_32DIRECT(base, 8, value)
#define PWM_SET_FREQUENCY(base, value) IOWR_32DIRECT(base, 12, value)
#define PWM_GET_DUTY(base) IORD_32DIRECT(base, 8)
#define PWM_GET_FREQUENCY(base) IORD_32DIRECT(base, 12)

void pwm_set_configuration(void *base, uint32_t config)
{
    IOWR_32DIRECT(base, 0, config);
}

void pwm_set_frequency(void *base, uint32_t freq)
{
    uint32_t value = NIOS2_CPU_FREQ / freq;
    PWM_SET_FREQUENCY(base, value);
}

void pwm_set_duty(void *base, uint8_t duty)
{
    uint32_t value, freq;
    freq = PWM_GET_FREQUENCY(base);
    value = (freq * duty) / 100;
    PWM_SET_DUTY(base, value);
}
