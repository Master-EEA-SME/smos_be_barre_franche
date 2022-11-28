#include <stdio.h>
#include "sys/alt_stdio.h"
#include "io.h"
#include <unistd.h>

#include "system.h"
#include "anemometre/anemometre.h"
#include "pwm/pwm.h"

int main()
{
    alt_putstr("Hello from Nios II!\n");
    anemometre_set_config((void *)ANEMO_BASE, ANEMOMETRE_CONFIG_CONTINU | ANEMOMETRE_CONFIG_RESET);
    pwm_set_configuration((void *)PWM0_BASE, ~PWM_RESET);
    pwm_set_frequency((void *)PWM0_BASE, 100);
    pwm_set_duty((void *)PWM0_BASE, 50);
    /* Event loop never exits. */
    while (1)
    {
        printf("anemo_config = %02lX\n", anemometre_get_config((void *)ANEMO_BASE));
        printf("anemo = %d\n", anemometre_get_wind_speed((void *)ANEMO_BASE));
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