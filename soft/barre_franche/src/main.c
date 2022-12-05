#include <stdio.h>
#include "sys/alt_stdio.h"
#include "io.h"
#include <unistd.h>

#include "system.h"
#include "anemometre/anemometre.h"
#include "girouette/girouette.h"
#include "pwm/pwm.h"
#include "verin/verin.h"
int main()
{
    alt_putstr("Hello from Nios II!\n");
    anemometre_set_config((void *)ANEMO_BASE, ANEMOMETRE_CONFIG_CONTINU | ANEMOMETRE_CONFIG_RESET);
    girouette_set_config((void *)GIROUETTE_BASE, GIROUETTE_CONFIG_CONTINU | GIROUETTE_CONFIG_RESET);
    pwm_set_configuration((void *)PWM0_BASE, ~PWM_RESET);
    pwm_set_ton_toff((void *)PWM0_BASE, 25000, 10000);
    verin_set_config((void *)VERIN_BASE, VERIN_ENABLE_PWM | VERIN_SENS | VERIN_RESET);
    verin_set_butee_g((void *)VERIN_BASE, 1000);
    verin_set_butee_d((void *)VERIN_BASE, 3000);
    /* Event loop never exits. */
    while (1)
    {
        printf("anemo_config = %02lX\n", anemometre_get_config((void *)ANEMO_BASE));
        printf("anemo = %d\n", anemometre_get_wind_speed((void *)ANEMO_BASE));
        printf("giro_config = %02lX\n", girouette_get_config((void *)GIROUETTE_BASE));
        printf("giro = %d\n", girouette_get_wind_direction((void *)GIROUETTE_BASE));
        printf("verin_config = %02lX", verin_get_config((void *)VERIN_BASE));
        printf("verin_butee_g = %04lX", verin_get_butee_g((void *)VERIN_BASE));
        printf("verin_butee_d = %04lX", verin_get_butee_d((void *)VERIN_BASE));
        printf("verin_angle_barre = %04lX", verin_get_angle_barre((void *)VERIN_BASE));
        for (int i = 0; i < 8; i++)
        {
            IOWR_32DIRECT(LED_BASE, 0, 1 << i);
            usleep(100000);
        }
        for (int i = 0; i < 8; i++)
        {
            IOWR_32DIRECT(LED_BASE, 0, 0x80 >> i);
            usleep(100000);
        }
    }

    return 0;
}
