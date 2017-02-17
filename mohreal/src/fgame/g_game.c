// PORTIONS OF THIS FILE HAVE BEEN REMOVED FOR THE 2017 RELEASE
// Most of the missing code can be claimed from any id Tech 3 game, e.g. Enemy Territory.
// https://github.com/id-Software/Enemy-Territory/

// game.c - main game library interaction

#include "g_main.h"
#include "g_game.h"
#include "../q_strings.h"
#include <string.h>
#include <math.h>

/*
"was killed by"
"was hunted down by"
"was pumped full of buckshot by"
"was bashed by"
"was clubbed by"
"was impaled by"
"was burned up by"
"was run over by"
"was machine-gunned by"
"was perforated by"
"'s SMG"
"was rifled by"
"was sniped by"
"was gunned down by"
"was shot by"
"was knocked out by"
"'s rocket right in the kisser"
"'s rocket in the face"
"took"
"was blown away by"
"'s grenade"
"tripped on"
"'s shrapnel out of his teeth"
"is picking"
"was pushed over the edge by"
"was telefragged by"
"was crushes by"
"shot himself in the"
"died"
"shot himself"
"rocketed himself"
"blew himself up"
"played catch with himself"
"tripped on his own grenade"
"cratered"
"was burned to a crisp"
"took himself out of commision"
"was shot in the"
"was shot"
"caught a rocket"
"blew up"
*/

typedef struct {
	char	*orig;
	char	*loc;
} localized_t;
localized_t	PVPobituaries[] = {
	{ "was killed by",					NULL },
	{ "was hunted down by",				NULL },
	{ "was pumped full of buckshot by",	NULL },
	{ "was bashed by",					NULL },
	{ "was clubbed by",					NULL },
	{ "was impaled by",					NULL },
	{ "was burned up by",				NULL },
	{ "was run over by",				NULL },
	{ "was machine-gunned by",			NULL },
	{ "was perforated by",				NULL },
	{ "was rifled by",					NULL },
	{ "was sniped by",					NULL },
	{ "was gunned down by",				NULL },
	{ "was shot by",					NULL },
	{ "was knocked out by",				NULL },
	{ "was blown away by",				NULL },
	{ "was pushed over the edge by",	NULL },
	{ "was telefragged by",				NULL },
	{ "was crushes by",					NULL },
	{ "was blown away by",				NULL },
	{ "took",							NULL },
	{ "tripped on",						NULL },
	{ "is picking",						NULL }
};
localized_t	headshot =
	{ "in the head",					NULL };

levelLocals_t	level;
gentity_t		*g_entities;

// movement speed faking
cvar_t	fake_sv_runspeed = {
	NULL,
	NULL,
	NULL,
	NULL,
	0,
	qfalse,
	0,
	240.f,
	240,
	NULL
};
cvar_t	fake_sv_walkspeed = {
	NULL,
	NULL,
	NULL,
	NULL,
	0,
	qfalse,
	0,
	110.f,
	110,
	NULL
};
cvar_t	fake_sv_crouchspeedmult = {
	NULL,
	NULL,
	NULL,
	NULL,
	0,
	qfalse,
	0,
	0.6,
	0,
	NULL
};
cvar_t	fake_sv_dmspeedmult = {
	NULL,
	NULL,
	NULL,
	NULL,
	0,
	qfalse,
	0,
	1.f,
	1,
	NULL
};
cvar_t	fakecvar;

void G_Cvars(void);

int ClientNumbersFromString( char *s, int *plist);
qboolean MatchOnePlayer(int *plist);
qboolean ValidateMap(const char *map);

cvar_t *G_Cvar(const char *var_name, const char *value, int flags) {
	if (!strcasecmp(var_name, "sv_runspeed")) {
        gi.Printf("mohrg: sv_runspeed detour active\\n");
        return &fake_sv_runspeed;
    } else if (!strcasecmp(var_name, "sv_walkspeed")) {
        gi.Printf("mohrg: sv_walkspeed detour active\\n");
        return &fake_sv_walkspeed;
    } else if (!strcasecmp(var_name, "sv_crouchspeedmult")) {
        gi.Printf("mohrg: sv_crouchspeedmult detour active\\n");
        return &fake_sv_crouchspeedmult;
    } else if (!strcasecmp(var_name, "sv_dmspeedmult")) {
        gi.Printf("mohrg: sv_dmspeedmult detour active\\n");
        return &fake_sv_dmspeedmult;
    } else if (!strcasecmp(var_name, "g_viewkick_dmmult") ||
		!strcasecmp(var_name, "g_viewkick_roll") ||
		!strcasecmp(var_name, "g_viewkick_yaw") ||
		!strcasecmp(var_name, "g_viewkick_pitch") ||
		!strcasecmp(var_name, "g_doWarmup") ||
		!strcasecmp(var_name, "g_warmup") ||
		!strcasecmp(var_name, "g_rankedserver") ||
		!strcasecmp(var_name, "flood_waitdelay") ||
		!strcasecmp(var_name, "flood_persecond") ||
		!strcasecmp(var_name, "flood_msgs") ||
		!strcasecmp(var_name, "nomonsters") /*||
		!strcasecmp(var_name, "filterban")*/) {
		gi.Printf("mohrg: filtering useless cvar %s to save up on cvar count\n", var_name);
		return &fakecvar;
	}
    return gi.cvar(var_name, value, flags);
}

void G_InitGame(int startTime, int randomSeed) {
	gi.Printf("mohrg: initializing server game library\n");
	//InitCvars(); // moved to GetGameAPI

	memset(&fakecvar, 0, sizeof(fakecvar));
	memset(level.clients, 0, sizeof(level.clients));

	globals_backup.Init(startTime, randomSeed);

    gi.Printf("mohrg: server game library successfully hooked (version %s)\n", MOHREAL_VERSION_S);
}

void G_Shutdown(void) {
	int	i;
    gi.Printf("mohrg: freeing stuff\n");
    for (i = 0; i < sizeof(PVPobituaries) / sizeof(PVPobituaries[0]); i++) {
    	if (PVPobituaries[i].loc)
			free(PVPobituaries[i].loc);
    }
    if (headshot.loc)
		free(headshot.loc);
    gi.Printf("mohrg: done\\n");
    globals_backup.Shutdown();
}

void G_Cleanup(void) {
	int	i;
	gi.Printf("mohrg: clearing level data\n");
    memset(&level, 0, sizeof(level));
    level.maxclients = sv_maxclients->integer;

    for (i = 0; i < sizeof(PVPobituaries) / sizeof(PVPobituaries[0]); i++) {
    	if (!PVPobituaries[i].loc)
			PVPobituaries[i].loc = strdup(gi.LV_ConvertString(PVPobituaries[i].orig));
	}
	if (!headshot.loc)
		headshot.loc = strdup(gi.LV_ConvertString(headshot.orig));

    gi.Printf("mohrg: done\n");
    globals_backup.Cleanup();
}

typedef char *playerSkin_t;
/*static playerSkin_t stockskins_allies[] = {
    "allied_airborne",
    "allied_manon",
    "allied_pilot",
    "allied_sas",
    "american_army",
    "american_ranger"
};
static playerSkin_t stockskins_axis[] = {
    "german_afrika_officer",
    "german_afrika_private",
    "german_elite_officer",
    "german_elite_sentry",
    "german_kradshutzen",
    "german_panzer_grenadier",
    "german_panzer_obershutze",
    "german_panzer_shutze",
    "german_panzer_tankcommander",
    "german_scientist",
    "german_waffenss_officer",
    "german_waffenss_shutze",
    "german_wehrmacht_officer",
    "german_wehrmacht_soldier",
    "german_winter_1",
    "german_winter_2",
    "german_worker"
};*/

// returns qfalse if this skin is likely to crash the server due to the _fps bug
// also forces team skins and MW skins instead of stock ones
qboolean G_ValidateSkin(int clientNum, const char *userinfo) {
    char	*skinallies/*[256]*/;
	char	*skinaxis/*[256]*/;
	char    *p;

    //strncpy(skinallies, Info_ValueForKey(userinfo,"dm_playermodel"), sizeof(skinallies));
	//strncpy(skinaxis, Info_ValueForKey(userinfo,"dm_playergermanmodel"), sizeof(skinaxis));
	skinallies = Info_ValueForKey(userinfo, "dm_playermodel");
	skinaxis = Info_ValueForKey(userinfo, "dm_playergermanmodel");

	// _fps bug vulnerability check
	p = skinallies + strlen(skinallies) - 4;
	if (!strncasecmp(p, "_fps", 4))
        return qfalse;
    p = skinaxis + strlen(skinaxis) - 4;
	if (!strncasecmp(p, "_fps", 4))
        return qfalse;
	
    return qtrue;
}

#define DEATHS(ent)	((int *)((ent)->dummy2) + 552)
#define KILLS(ent)	((int *)((ent)->dummy2) + 553)
#define ZOOM(ent)	((int *)(ent->dummy2 + 1784))
void G_RunFrame(int levelTime, int frameTime) {
	static int	ironsights_modcount[14] = {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1};
	int		i, suppTime, clips;
	char	*p;
    level.time = levelTime/* - level.startTime*/;
    level.frameTime = frameTime;

    globals_backup.RunFrame(levelTime, frameTime);
    for (i = 0; i < 14; i++) {
    	if (ironsights_modcount[i] != g_mohr_ironsights[i]->modificationCount) {
    		ironsights_modcount[i] = g_mohr_ironsights[i]->modificationCount;
			gi.setConfigstring(CS_MOHR_IRONSIGHTS + i, g_mohr_ironsights[i]->string);
    	}
    }
    for (i = 0; i < MAX_CLIENTS; i++) {
    	if (!level.clients[i].ent)
			continue;
    	if (g_mohr_zoomers->string[i] - '0') {
    		if (level.clients[i].ent->client->ps.activeItems[ITEMSTAT_WEAPONCLASS] == 3) {	// rifle
    			// don't show the crosshair on sniper rifles
    			p = gi.getConfigstring(CS_ITEMS + level.clients[i].ent->client->ps.activeItems[ITEMSTAT_ACTIVEITEM]);
    			if (p[0] != 'S'	// Springfield '03 Sniper
					&& p[0] != 'K')	// KAR98 - Sniper
					level.clients[i].ent->client->ps.stats[STAT_CROSSHAIR] = 1;
    		} else
				level.clients[i].ent->client->ps.stats[STAT_CROSSHAIR] = 1;
		} else
			level.clients[i].ent->client->ps.stats[STAT_CROSSHAIR] = 0;
		if (level.clients[i].ent->client->ps.stats[STAT_MAXAMMO]) {
			// if there's any ammo in the clip, make it display just 1 round
			if (level.clients[i].ent->client->ps.stats[STAT_CLIPAMMO])
				level.clients[i].ent->client->ps.stats[STAT_CLIPAMMO] = 1;
			clips = level.clients[i].ent->client->ps.stats[STAT_TOTALAMMO] / level.clients[i].ent->client->ps.stats[STAT_MAXAMMO];
			if (level.clients[i].ent->client->ps.stats[STAT_TOTALAMMO] % level.clients[i].ent->client->ps.stats[STAT_MAXAMMO])
				clips++;
			level.clients[i].ent->client->ps.stats[STAT_TOTALAMMO] = clips;
			level.clients[i].ent->client->ps.stats[STAT_MAXAMMO] = 1;
		}
		sscanf(g_mohr_suppressed->string + i * 9, "%x", &suppTime);
		if (suppTime == 0)
			continue;
		//gi.Printf("supptime: %d level time: %d start time: %d\n", suppTime, levelTime, level.startTime);
		suppTime = level.time - suppTime;
		if (suppTime < 0)
			suppTime = SUPPRESS_TIME + 1;
		if (suppTime <= SUPPRESS_TIME) {
			VectorClear(level.clients[i].ent->client->ps.blend);
			level.clients[i].ent->client->ps.blend[3] = 2.5 - (float)suppTime * SUPPRESS_1_TIME * 2.5;
			if (level.clients[i].ent->client->ps.blend[3] > 0.9)
				level.clients[i].ent->client->ps.blend[3] = 0.9;
		}
		/*if (g_mohr_adddeaths[i]->integer) {
			*(DEATHS(level.clients[i].ent)) += g_mohr_adddeaths[i]->integer;
			gi.cvar_set(g_mohr_adddeaths[i]->name, "0");
		}*/
    }
    if (g_mohr_addkills->string[0]) {
    	int		cl;
    	int		score;
    	char	*p = g_mohr_addkills->string, *end = g_mohr_addkills->string + strlen(g_mohr_addkills->string);
		while (p < end) {
			sscanf(p, "%d %x", &cl, &score);
			p += 11;	// 2 chars (2-digit decimal number) + 8 chars (32-bit hex number) + 1 char (a space)
			if (!level.clients[cl].ent)
				continue;
			*(KILLS(level.clients[cl].ent)) += score;
		}
		gi.cvar_set(g_mohr_addkills->name, "");
	}
}

void G_Restart(void) {

	globals_backup.Restart();

}

char *G_ClientConnect(int clientNum, qboolean firstTime) {
    char	userinfo[MAX_INFO_STRING];
	char	*reason;

    gi.getUserinfo(clientNum, userinfo, sizeof(userinfo));

    reason = globals_backup.ClientConnect(clientNum, firstTime);
	if (reason == NULL)
		level.numConnectedClients++;
	return reason;
}

void G_ClientBegin(gentity_t *ent, usercmd_t *cmd) {
	level.clients[ent->client->ps.clientNum].ent = ent;

	//BG_ProcessUserCmd(cmd, &ent->client->ps, &level.clients[ent->client->ps.clientNum].pmodFlags);

	globals_backup.ClientBegin(ent, cmd);

	/*if (level.clients[ent->client->ps.clientNum].pmodFlags & PMOD_ZOOM)
		ent->client->ps.stats[STAT_CROSSHAIR] = 1;
	else
		ent->client->ps.stats[STAT_CROSSHAIR] = 0;*/
}

void G_ClientDisconnect(gentity_t *ent) {
	level.clients[ent->client->ps.clientNum].ent = NULL;
	globals_backup.ClientDisconnect(ent);
}

void G_Say_f(gentity_t *ent) {
	char *cmd = gi.argv(0);
	if (!stricmp("dmmessage", cmd)) {
		cmd = gi.argv(2);
		if (strlen(cmd) == 3 && cmd[0] == '*'
			&& cmd[1] == '3' && cmd[1] == '3') {
			cmd++; // skip the *
			gi.cvar_set(cl_chan[ent->client->ps.clientNum]->name, cmd);
		}
	}
}

void G_TakeADump_f(gentity_t *ent) {
    int i;

    gi.Printf("------------ DUMP BEGIN ------------\nplayerstats:\n");
    for (i = 0; i < STAT_NUM_STATS; i++)
        gi.Printf("%d: %d\n", i, ent->client->ps.stats[i]);
	gi.Printf("itemstats:\n");
	for (i = 0; i < ITEMSTAT_NUM_STATS; i++)
        gi.Printf("%d: %d\n", i, ent->client->ps.activeItems[i]);
    /*gi.Printf("\npmflags: %d\n", ent->client->ps.pm_flags);
    gi.Printf("bobcycle: %d\n", ent->client->ps.bobCycle);
    gi.Printf("viewheight: %d\n", ent->client->ps.viewheight);
    gi.Printf("ping: %d\n", ent->client->ps.ping);
    gi.Printf("userinfo: %s\n", ent->client->pers.userinfo);
    gi.Printf("netname: %s\n", ent->client->pers.netname);
    gi.Printf("playermodel: %s\n", ent->client->pers.dm_playermodel);
    gi.Printf("playergermanmodel: %s\n", ent->client->pers.dm_playergermanmodel);
    gi.Printf("weapon: %s\n", ent->client->pers.dm_primaryWeapon);
    gi.Printf("team: %d\n", ent->client->pers.teamnum);
    gi.Printf("score: %d\n", ent->client->pers.round_kills - ent->client->ps.stats[STAT_DEATHS]);
    gi.Printf("\nconfigstrings:\n");
    for (i = 0; i < MAX_CONFIGSTRINGS; i++)
        gi.Printf("%d: %s\\n", i, gi.getConfigstring(i));*/
	gi.Printf("zoom: %d\n", *((int *)(ent->dummy2 + 1784)));
	gi.Printf("active item: %s\n", gi.getConfigstring(CS_ITEMS + ent->client->ps.activeItems[ITEMSTAT_ACTIVEITEM]));
    gi.Printf("------------ DUMP END ------------\n");
}

static clientCommand_t capturedClientCMDs[] = {
    { "dmmessage",  G_Say_f         },

    { "takeadump",  G_TakeADump_f   }
};

void G_ClientCommand(gentity_t *ent) {
    int i;
    char *cmd = gi.argv(0);
    for (i = 0; i < sizeof(capturedClientCMDs) / sizeof(capturedClientCMDs[0]); i++) {
        if (!strcasecmp(cmd, capturedClientCMDs[i].cmd)) {
            capturedClientCMDs[i].func(ent);
            // prevent the game lib from getting the command
            *gi.argv(0) = 0;
            return;
        }
    }
    //gi.Printf("mohrg: Received client command: \n%s %s\n", gi.argv(0), gi.args());
    globals_backup.ClientCommand(ent);
}

static consoleCommand_t capturedConsoleCMDs[] = {
    //{ "addbot",		Cmd_Addbot_f  }
};

qboolean G_ConsoleCommand(void) {
    int i;
    char *cmd = gi.argv(0);
    for (i = 0; i < sizeof(capturedClientCMDs) / sizeof(capturedClientCMDs[0]); i++) {
        if (!strcasecmp(cmd, capturedClientCMDs[i].cmd)) {
            // if we're not running a dedicated server, assume player #0
            if (!dedicated->integer && g_entities != NULL)
                capturedClientCMDs[i].func(g_entities);
            // drop the command and prevent the game lib from getting it
            *gi.argv(0) = 0;
            return qtrue;
        }
    }
    for (i = 0; i < sizeof(capturedConsoleCMDs) / sizeof(capturedConsoleCMDs[0]); i++) {
        if (!strcasecmp(cmd, capturedConsoleCMDs[i].cmd)) {
            capturedConsoleCMDs[i].func();
            *gi.argv(0) = 0;
            return qtrue;
        }
    }
    return globals_backup.ConsoleCommand();
}

void G_ClientThink(gentity_t *ent, usercmd_t *ucmd) {
	//static usercmd_t usercmd;

	//usercmd = *ucmd;

	//memcpy(&usercmd, ucmd, sizeof(usercmd));

	if (g_mohr_zoomers->string[ent->client->ps.clientNum] - '0'
		|| *ZOOM(ent) != 0)
		/*usercmd.*/ucmd->buttons &= ~BUTTON_RUN;

	globals_backup.ClientThink(ent, /*&usercmd*/ucmd);

	/*if (zooming)
		ent->client->ps.stats[STAT_CROSSHAIR] = 1;
	else
		ent->client->ps.stats[STAT_CROSSHAIR] = 0;*/
}

void GetUserinfo(int index, char *buf, int bufSize) {
	gi.getUserinfo(index, buf, bufSize);
}

void G_SendServerCommand(int clientnum, const char *fmt, int arg1, int arg2, int arg3, int arg4, int arg5, int arg6, int arg7, int arg8, int arg9, int arg10/*...*/) {
	gi.Printf("servercmd: %s\n", fmt);
	if (!strncasecmp(fmt, OBITUARY, 8)) {	// do not print obituaries
		int			i;
		int			len, longest = 0;
		char		*obit, *att;
		int			victim = -1, attacker = -1;
		qboolean	hshot = qfalse;

		// find the victim first
		for (i = 0; i < MAX_CLIENTS; i++) {
			if (!level.clients[i].ent)
				continue;
			len = strlen(level.clients[i].ent->client->pers.netname);
			if (!strncmp((char *)arg1, level.clients[i].ent->client->pers.netname, len)) {
				if (len > longest) {
					longest = len;
					victim = i;
				}
			}
		}
		if (victim < 0) {
			gi.Printf("mohrg: ERROR: could not determine victim!\n");
			return;
		}
		obit = ((char *)arg1) + longest + 1;
		for (i = 0; i < sizeof(PVPobituaries) / sizeof(PVPobituaries[0]); i++) {
			len = strlen(PVPobituaries[i].loc);
			if (!strncmp(obit, PVPobituaries[i].loc, len)) {
				// find the attacker
				att = obit + len + 1;
				longest = 0;
				for (i = 0; i < MAX_CLIENTS; i++) {
					if (!level.clients[i].ent)
						continue;
					len = strlen(level.clients[i].ent->client->pers.netname);
					if (!strncmp(att, level.clients[i].ent->client->pers.netname, len)) {
						if (len > longest) {
							longest = len;
							attacker = i;
						}
					}
				}
				break;
			}
		}
		if (i >= sizeof(PVPobituaries) / sizeof(PVPobituaries[0]))
			return;	// not a PvP kill
		if (attacker < 0) {
			gi.Printf("mohrg: ERROR: could not determine attacker!\n");
			return;
		}
		if ((att + longest)[1]) {	// hit location follows
			obit = att + longest + 1;
			if (!strncmp(obit, headshot.loc, strlen(headshot.loc)))
				hshot = qtrue;
		}
		if (g_gametype->integer > 1 && level.clients[victim].ent->client->pers.teamnum == level.clients[attacker].ent->client->pers.teamnum) {
			*(KILLS(level.clients[attacker].ent)) -= 2;	// in addition to the game's own -1 punishment
			goto printanyway;
		}
		if (hshot)
			*(KILLS(level.clients[attacker].ent)) += 3;	// in addition to the game's own 1 point
		else
			*(KILLS(level.clients[attacker].ent)) += 2;	// in addition to the game's own 1 point
		return;
	}
	if (!strncasecmp(fmt, IPRINTLNBOLD, 8) && !strncasecmp((char *)arg1, "You killed ", 11))
		return;
printanyway:
	gi.SendServerCommand(clientnum, fmt, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10);
}
