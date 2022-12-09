#include "gestion_commande.h"
#include "io.h"

void gestion_commande_set_config(void *base, uint32_t config)
{
    IOWR_32DIRECT(base, 0, config);
}

int gestion_commande_get_code_fonction(void *base)
{
    return IORD_32DIRECT(base, 4);
}