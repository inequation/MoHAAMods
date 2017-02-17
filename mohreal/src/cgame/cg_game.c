// PORTIONS OF THIS FILE HAVE BEEN REMOVED FOR THE 2017 RELEASE
// Most of the missing code can be claimed from any id Tech 3 game, e.g. Enemy Territory.
// https://github.com/id-Software/Enemy-Territory/

// MoHReal client game hook
// Written by Leszek "IneQuation" Godlewski
// Based on Wombat's cgame wrapper (credits below)

/*
* Medal of Honor: Allied Assault cgame wrapper
* Original code written by "Wombat" (wombat23@arcor.de) 2006
*
* This is replacement code for MOHAA's cgamex86.dll
* must be put in MOHAA\main but BACKUP the original file
* it uses the original cgamex86.dll file from MOHAA directory
* you should know this anyways if you want to use this code
*
* The code has partially been taken from Ritual Entertainment's
* "FAKKTools" but was modified by the author. It may be used
* by anyone as long as it stays clear who its authors are.
*/

#include "cg_game.h"
#include <math.h>

#define STG44_DEBUG

snapshot_t	dummySnap;
snapshot_t *snap = &dummySnap;

//glconfig_t	glconfig;
refdef_t	*cg_refdef;
cg_t		*cg = NULL;

qboolean	isDemo;

int         clientnum;

int			levelTime;
int			ironSightTime;
float		ironSightFrac;
qboolean	lastIronSightState = qfalse;
qboolean	g_realign = qfalse;

//cvars
cvar_t  *gunx;
cvar_t	*guny;
cvar_t	*gunz;
cvar_t	*rotx;
cvar_t	*roty;
cvar_t	*rotz;

cvar_t	*r_znear;
cvar_t	*ui_crosshair;

//	***fonts***
//  -facfont-20 (standard)
//  -courier-16
//  -courier-18
//  -courier-20
//  -handle-16
//  -handle-18
//  -handle-22
//  -handle-23
//  -marlett
//  -verdana-12
//  -verdana-14
fontHandle_t	*facfont20;

// colours
vec4_t		colorBlack		= {0, 0, 0, 1};
vec4_t		colorRed		= {1, 0, 0, 1};
vec4_t		colorGreen		= {0, 1, 0, 1};
vec4_t		colorBlue		= {0, 0, 1, 1};
vec4_t		colorDkRed		= {0.5, 0, 0, 1};
vec4_t		colorDkGreen	= {0, 0.5, 0, 1};
vec4_t		colorDkBlue		= {0, 0, 0.5, 1};
vec4_t		colorLtRed		= {1, 0.5, 0.5, 1};
vec4_t		colorLtGreen	= {0.5, 1, 0.5, 1};
vec4_t		colorLtBlue		= {0.5, 0.5, 1, 1};
vec4_t		colorAlBlue		= {0, 0, 1, 0.25};
vec4_t		colorAlRed		= {1, 0, 0, 0.25};
vec4_t		colorYellow		= {1, 1, 0, 1};
vec4_t		colorMagenta	= {1, 0, 1, 1};
vec4_t		colorCyan		= {0, 1, 1, 1};
vec4_t		colorWhite		= {1, 1, 1, 1};
vec4_t		colorLtWhite	= {1, 1, 1, 0.25};
vec4_t		colorLtGrey		= {0.75, 0.75, 0.75, 1};
vec4_t		colorMdGrey		= {0.5, 0.5, 0.5, 1};
vec4_t		colorDkGrey		= {0.25, 0.25, 0.25, 1};
vec4_t		alphaLight		= { 0, 0, 0, 0.25 };
vec4_t		alphaMid		= { 0, 0, 0, 0.5 };
vec4_t		alphaDark		= { 0, 0, 0, 0.75 };
vec4_t		colorTransRed	= { 1, 0, 0, 0.5 };
vec4_t		colorTransBlue	= { 0, 0, 1, 0.5 };

vec3_t	vec3_origin = { 0, 0, 0 }; // the beginning of the coord system

qhandle_t	handModels[128];
int			numHandModels = 0;

#ifdef STG44_DEBUG
int			stg44Handle = 0;
#endif

char		*weaponTable[] = {
	"Hi-Standard Silenced",
	"Colt 45",
	"M1 Garand",
	"Springfield '03 Sniper",
	"Thompson",
	"BAR",
	"Bazooka",
	"Shotgun",
	"Walther P38",
	"Mauser KAR 98K",
	"KAR98 - Sniper",
	"MP40",
	"StG 44",
	"Panzerschreck"
};

ironSights_t		ironSightTable[14]; /*= {
	// weapon			focus (60deg fov)
	{ "M1 Garand",		qtrue,	qtrue,
		{-18.f,	8.142,	-28.67},
		{6.2,	-2.75,	0.f},
	},
	{ "Thompson",		qtrue,	qtrue,
		{-13.f,	7.615,	-29.14},
		{6.7,	0.55,	0.f},
	},
	{ "BAR",			qfalse,	qtrue,
		{-15.f,	6.43,	-28.8},
		{5.1,	-2.f,	0.f},
	},
	{ "Bazooka",		qfalse,	qtrue,
		{-18.f,	5.8,	-33.65},
		{2.5,	-3.f,	0.f},
	},
	{ "Shotgun",		qtrue,	qtrue,
		{-12.f,	10.1,	-27.63},
		{8.5,	-0.5,	0.f},
	},
	{ "Mauser KAR 98K",	qtrue,	qtrue,
		{-17.f,	8.21,	-27.2},
		{8.5,	-2.7,	0.f},
	},
	{ "MP40",			qtrue,	qtrue,
		{-17.f,	8.62,	-28.59},
		{8.1,	0.3,	0.f},
	},
	{ "StG 44",			qfalse,	qtrue,
		{-18.f,	8.17,	-30.85},
		{6.f,	1.2,	0.f},
	},
	{ "Panzerschreck",	qfalse,	qtrue,
		{-18.f,	2.8,	-31.3},
		{8.1,	-1.f,	0.f},
	},
	{ "Springfield '03 Sniper",	qfalse,	qfalse,
		{0,		0,		0},
		{0,		0,		0},
	},
	{ "KAR98 - Sniper", qfalse,	qfalse,
		{0,		0,		0},
		{0,		0,		0},
	}
};*/

// these are used to interpolate nicely from non-ironsight to ironsight
vec3_t	standardStand[2] = {
	{-12.5, 3.f, -31.5},
	{7.9, 0.f, 0.f},
};
vec3_t	standardCrouch[2] = {
	{-15.6, 7.3, -29.6},
	{8.f, 0.f, 0.f},
};

gameState_t	*gs = NULL;

void GetGameState(gameState_t *gamestate) {
	int	i;
	gs = gamestate;
	cgi.GetGameState(gamestate);
	for (i = 0; i < 14; i++) {
		sscanf(CG_ConfigString(CS_MOHR_IRONSIGHTS + i), "%d %d %f %f %f %f %f %f",
			&ironSightTable[i].focus, &ironSightTable[i].realign,
			&ironSightTable[i].pos[0], &ironSightTable[i].pos[1], &ironSightTable[i].pos[2],
			&ironSightTable[i].rot[0], &ironSightTable[i].rot[1], &ironSightTable[i].rot[2]);
	}
}

const char *CG_ConfigString(int index) {
	if (index < 0 || index >= MAX_CONFIGSTRINGS) {
		cgi.Printf("mohrc: CG_ConfigString: bad index: %i", index);
		return "";
	}
	return gs->stringData + gs->stringOffsets[index];
}

int	GetSnapshot(int snapshotNumber, snapshot_t *snapshot){
	snap = snapshot;
	return cgi.GetSnapshot(snapshotNumber, snapshot);
}

void R_RenderScene(refdef_t *fd) {
	char	*itemname;
	int		i;
	if (cg == NULL) {
		cg = (cg_t *)(((char *)fd) - 315474);
		//cgi.Printf("Refdef offset: %d\n", (long)(&((cg_t *)0)->refdef));
	}
	cg_refdef = fd;
	if (ironSightFrac != 0.f) {
		itemname = CG_ConfigString(CS_ITEMS + snap->ps.activeItems[ITEMSTAT_ACTIVEITEM]);
		for (i = 0; i < 14; i++) {
			if (!strcasecmp(itemname, weaponTable[i]))
				break;
		}
		if (i < 14 && ironSightTable[i].focus) {
			fd->fov_x = 80.f - 20.f * ironSightFrac;
			fd->fov_y = atan2(fd->height, fd->width / tan(fd->fov_x / 360 * M_PI)) * 360 / M_PI;
		}
	}
	// HACK HACK HACK!!!
	// don't do this at home!
	//ui_crosshair->integer = 0;	// make sure crosshair is off at all times
	cgi.R_RenderScene(fd);
}

qhandle_t R_RegisterModel(const char *name) {
	if (!strncasecmp(name, "models/player/", 14) || !strncasecmp(name, "player/", 7)) {
		char	*p = name + strlen(name) - 8;
		if (!strcasecmp(p, "_fps.tik") || !strcasecmp(p + 4, "_fps")) {
			cgi.Printf("mohrc: detected hand model %s\n", name);
			handModels[numHandModels] = cgi.R_RegisterModel(name);
			return handModels[numHandModels++];
		}
	}
	return cgi.R_RegisterModel(name);
}

refEntity_t *R_GetRenderEntity(int entityNumber) {
	if (g_realign && ironSightFrac != 0.f && entityNumber == clientnum)
		return cgi.R_GetRenderEntity(/*ENTITYNUM_MAX_NORMAL*/2048);
	return cgi.R_GetRenderEntity(entityNumber);
}

void IntegrateRotations(const vec3_t a[3], const vec3_t b[3], vec3_t result[3]) {
	result[0][0] = a[0][0] * b[0][0] + a[0][1] * -b[1][0] +
				a[0][2] * b[2][0];
	result[0][1] = a[0][0] * b[0][1] + a[0][1] * -b[1][1] +
				a[0][2] * b[2][1];
	result[0][2] = a[0][0] * b[0][2] + a[0][1] * -b[1][2] +
				a[0][2] * b[2][2];
	result[1][0] = -(-a[1][0] * b[0][0] + -a[1][1] * -b[1][0] +
				-a[1][2] * b[2][0]);
	result[1][1] = -(-a[1][0] * b[0][1] + -a[1][1] * -b[1][1] +
				-a[1][2] * b[2][1]);
	result[1][2] = -(-a[1][0] * b[0][2] + -a[1][1] * -b[1][2] +
				-a[1][2] * b[2][2]);
	result[2][0] = a[2][0] * b[0][0] + a[2][1] * -b[1][0] +
				a[2][2] * b[2][0];
	result[2][1] = a[2][0] * b[0][1] + a[2][1] * -b[1][1] +
				a[2][2] * b[2][1];
	result[2][2] = a[2][0] * b[0][2] + a[2][1] * -b[1][2] +
				a[2][2] * b[2][2];
}

void R_AddRefEntityToScene(refEntity_t *ent) {
	static vec3_t			matrix[3];
	static int				i;
	vec3_t					dummy1, dummy2;
	float					*pos, *rot, *soPos, *soRot;
	char					*itemname;

	if (ironSightFrac != 0.f && ent->renderfx & RF_DEPTHHACK) {
#ifdef STG44_DEBUG
		if (ent->hModel == stg44Handle)
			cgi.Printf("mohrc: stg44: parentEntity: %d entitynumber: %d\n", ent->parentEntity, ent->entityNumber);
#endif
		for (i = 0; i < numHandModels; i++) {
			if (ent->hModel == handModels[i])
				break;
		}
		if (i < numHandModels) {
			itemname = CG_ConfigString(CS_ITEMS + snap->ps.activeItems[ITEMSTAT_ACTIVEITEM]);
			for (i = 0; i < 14; i++) {
				if (!strcasecmp(itemname, weaponTable[i]))
					break;
			}
			if (i < 14) {
				if (!ironSightTable[i].realign) {
					ent->entityNumber = clientnum;	// in case we fragged it up previously
					g_realign = qfalse;
					goto skip_realignment;
				}
				pos = ironSightTable[i].pos;
				rot = ironSightTable[i].rot;
			} else {
				VectorSet(dummy1, gunx->value, guny->value, gunz->value);
				VectorSet(dummy2, rotx->value, roty->value, rotz->value);
				pos = dummy1;
				rot = dummy2;
			}
			g_realign = qtrue;
			if (snap->ps.pm_flags & PMF_DUCKED) {
				soPos = standardCrouch[0];
				soRot = standardCrouch[1];
			} else {
				soPos = standardStand[0];
				soRot = standardStand[1];
			}
			ent->entityNumber = /*ENTITYNUM_MAX_NORMAL*/2048;
			for (i = 0; i < 4; i++) {
				if (ent->bone_quat[i]) {
					VectorClear(ent->bone_quat[i]);
					ent->bone_quat[i][3] = 1.f;
				}
			}
			VectorMA(cg_refdef->vieworg, soPos[0] + (pos[0] - soPos[0]) * ironSightFrac, cg_refdef->viewaxis[0], ent->origin);
			VectorMA(ent->origin, soPos[1] + (pos[1] - soPos[1]) * ironSightFrac, cg_refdef->viewaxis[1], ent->origin);
			VectorMA(ent->origin, soPos[2] + (pos[2] - soPos[2]) * ironSightFrac, cg_refdef->viewaxis[2], ent->origin);
			dummy1[0] = soRot[0] + (rot[0] - soRot[0]) * ironSightFrac;
			dummy1[1] = soRot[1] + (rot[1] - soRot[1]) * ironSightFrac;
			dummy1[2] = soRot[2] + (rot[2] - soRot[2]) * ironSightFrac;
			AngleVectors(dummy1, matrix[0], matrix[1], matrix[2]);
			IntegrateRotations(matrix, cg_refdef->viewaxis, ent->axis);
		}
#ifdef STG44_DEBUG
		else {
			//ent->parentEntity = 2048/*ENTITYNUM_MAX_NORMAL*/;
			//cgi.Printf("mohrc: handle: %d stghandle: %d parentEntity: %d entitynumber: %d\n", ent->hModel, stg44Handle, ent->parentEntity, ent->entityNumber);
		}
#endif
	}
skip_realignment:
	cgi.R_AddRefEntityToScene(ent);
}

void CG_DrawActiveFrame(int serverTime, int dummy, stereoFrame_t stereoView, qboolean demoPlayback) {
	levelTime = serverTime;
	if (snap->ps.pm_type == PM_NORMAL) {
		if (lastIronSightState != snap->ps.stats[STAT_CROSSHAIR]) {
			ironSightTime = serverTime;
			lastIronSightState = snap->ps.stats[STAT_CROSSHAIR];
			ironSightFrac = (!snap->ps.stats[STAT_CROSSHAIR]);
		} else if (serverTime - ironSightTime > IRONSIGHT_SWITCH_TIME) {
			ironSightFrac = snap->ps.stats[STAT_CROSSHAIR];
		} else {
			ironSightFrac = ((float)(serverTime - ironSightTime) * IRONSIGHT_1_SWITCH_TIME);
			if (!snap->ps.stats[STAT_CROSSHAIR])
				ironSightFrac = 1.f - ironSightFrac;
		}
	} else
		ironSightFrac = 0.f;
	cge.CG_DrawActiveFrame(serverTime, dummy, stereoView, demoPlayback);
}

void CG_Init(clientGameImport_t *imported, int serverMessageNum, int serverCommandSequence, int clientNum) {
	memcpy(&cgi, imported, sizeof(cgi));
	memcpy(&cgi_patched, imported, sizeof(cgi_patched));

    gunx = cgi.Cvar_Get("gunx", "0", 0);
    guny = cgi.Cvar_Get("guny", "0", 0);
    gunz = cgi.Cvar_Get("gunz", "0", 0);
    rotx = cgi.Cvar_Get("rotx", "0", 0);
    roty = cgi.Cvar_Get("roty", "0", 0);
    rotz = cgi.Cvar_Get("rotz", "0", 0);

    r_znear = cgi.Cvar_Get("r_znear", "0.1", 0);
    // HACK HACK HACK!!!
    // don't do this at home
    if (r_znear->value > 0.1)
		r_znear->value = 0.1;
	ui_crosshair = cgi.Cvar_Get("ui_crosshair", "0", 0);

	//patches
	//cgi_patched.CM_BoxTrace				= CM_BoxTrace;
	cgi_patched.GetSnapshot				= GetSnapshot;
	cgi_patched.GetGameState			= GetGameState;
	cgi_patched.R_RenderScene			= R_RenderScene;
	cgi_patched.R_AddRefEntityToScene	= R_AddRefEntityToScene;
	cgi_patched.R_RegisterModel			= R_RegisterModel;
	cgi_patched.R_GetRenderEntity		= R_GetRenderEntity;

	cge.CG_Init(&cgi_patched, serverMessageNum, serverCommandSequence, clientNum);

	//fonts
	//facfont20 = cgi.R_RegisterFont("facfont-20");

	clientnum = clientNum;

	lastIronSightState = qfalse;

#ifdef STG44_DEBUG
	stg44Handle = cgi.R_RegisterModel("models/weapons/mp44.tik");
#endif

	cgi.Printf("mohrc: client game library successfully hooked (version %s)\n", MOHREAL_VERSION_S);
}
