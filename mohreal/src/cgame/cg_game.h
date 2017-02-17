#ifndef CG_GAME_H
#define CG_GAME_H

#include "cg_main.h"

typedef struct ironSights_s {
	//const char	*itemName;			// the name of the item these settings are for

	qboolean	focus;				// whether to zoom in to a 60 degrees FOV or not

	qboolean	realign;			// whether or not to realign the weapon to use the model's iron sights
	vec3_t		pos;
	vec3_t		rot;
} ironSights_t;

extern cg_t		*cg;

void CG_Init(clientGameImport_t *imported, int serverMessageNum, int serverCommandSequence, int clientNum);
void CG_DrawActiveFrame(int serverTime, int dummy, stereoFrame_t stereoView, qboolean demoPlayback);
const char *CG_ConfigString(int index);

#endif // CG_GAME_H
