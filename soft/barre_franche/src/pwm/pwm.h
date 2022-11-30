#ifndef PWM_H
#define PWM_H
#include <stdint.h>
#define PWM_RESET 0x1
void pwm_set_configuration(void *base, uint32_t config);
void pwm_set_frequency(void *base, uint32_t freq);
void pwm_set_duty(void *base, uint32_t duty);
void pwm_set_ton_toff(void *base, uint32_t ton_us, uint32_t toff_us);
#endif // PWM_H