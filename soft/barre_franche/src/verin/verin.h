#ifndef VERIN_H
#define VERIN_H
#include <stdint.h>

#define VERIN_RESET 0x1
#define VERIN_ENABLE_PWM 0x2
#define VERIN_SENS 0x4
#define VERIN_FIN_COURSE_G 0x8
#define VERIN_FIN_COURSE_D 0x10

void verin_set_config(void *base, uint32_t config);
uint32_t verin_get_config(void *base);
void verin_set_pwm_frequency(void *base, uint32_t freq);
void verin_set_pwm_duty(void *base, uint32_t duty);
void verin_set_butee_g(void *base, uint32_t butee_g);
void verin_set_butee_d(void *base, uint32_t butee_d);
uint32_t verin_get_butee_g(void *base);
uint32_t verin_get_butee_d(void *base);
uint32_t verin_get_angle_barre(void *base);

#endif // VERIN_H