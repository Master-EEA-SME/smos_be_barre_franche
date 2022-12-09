#ifndef GESTION_COMMANDE_H
#define GESTION_COMMANDE_H

#include <stdint.h>

#define GESTION_COMMANDE_CONFIG_RESET 0x1

void gestion_commande_set_config(void *base, uint32_t config);
int gestion_commande_get_code_fonction(void *base);

#endif // GESTION_COMMANDE_H