// PORTIONS OF THIS FILE HAVE BEEN REMOVED FOR THE 2017 RELEASE
// Most of the missing code can be claimed from any id Tech 3 game, e.g. Enemy Territory.
// https://github.com/id-Software/Enemy-Territory/
// This file also performed the actual DLL hooking: loading the original game DLL and patching the function tables.

// main.c - handle all the system-level and most basic stuff; also some global functions

#ifdef WIN32
    #include <windows.h>
	HMODULE hmod;
#else
	#include <unistd.h>
	#include <dlfcn.h>
	#include <sys/types.h>
	void *hmod;
#endif
#include "g_main.h"
#include "g_game.h"
#include "../q_strings.h"

#ifdef WIN32
    #define MAIN_PATH       ".\\main\\"
#else
    #define MAIN_PATH       "./main/"
#endif

// cvars
cvar_t  *real_gamelib;

cvar_t  *mod_name;
cvar_t  *mod_url;
cvar_t  *mod_version;

// some server cvar bindings
cvar_t	*dedicated;
cvar_t  *mapname;
cvar_t	*sv_maxclients;
cvar_t  *g_gametype;
cvar_t	*g_mohr_zoomers;
cvar_t	*g_mohr_suppressed;
cvar_t	*g_mohr_addkills;
//cvar_t	*g_mohr_adddeaths;

cvar_t	*g_mohr_ironsights[14];

static regCvar_t	cvars[] = {
#ifdef WIN32
	{ &real_gamelib,		"real_gamelib",		"\\main\\gamex86mohaa.dll",		CVAR_ARCHIVE	},
#else
	{ &real_gamelib,		"real_gamelib",		"fgamemohaa.so",				CVAR_ARCHIVE	},
#endif // WIN32
	// a bit of advertising :P
	{ &mod_name,			"mod_name",			"mohreal",						CVAR_SERVERINFO | CVAR_ROM	},
	{ &mod_url,				"mod_url",			"http://map.planetmedalofhonor.gamespy.com/mohaa",	CVAR_SERVERINFO | CVAR_ROM	},
	{ &mod_version,			"mod_version",		MOHREAL_VERSION_S,				CVAR_SERVERINFO | CVAR_ROM	},

	{ &dedicated,			"dedicated",		"",								0				},
	{ &mapname,				"mapname",			"",								0				},
	{ &sv_maxclients,		"sv_maxclients",	"8",							0				},
	{ &g_gametype,			"g_gametype",		"1",							0				},

	{ &g_mohr_zoomers,		"g_mohr_zoomers",	"0000000000000000000000000000000000000000000000000000000000000000",	0	},
	{ &g_mohr_addkills,		"g_mohr_addkills",	"",								0				},
	{ &g_mohr_suppressed,	"g_mohr_suppressed",	"00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000",	0	},

	{ &g_mohr_ironsights[0],	"g_mohr_is_histandard",	"0 0 0 0 0 0 0 0",		0				},
	{ &g_mohr_ironsights[1],	"g_mohr_is_colt45",		"0 0 0 0 0 0 0 0",		0				},
	{ &g_mohr_ironsights[2],	"g_mohr_is_m1garand",	"1 1 -18 8.142 -28.67 6.2 -2.75 0",	0	},
	{ &g_mohr_ironsights[3],	"g_mohr_is_springfield",	"0 0 0 0 0 0 0 0",	0				},
	{ &g_mohr_ironsights[4],	"g_mohr_is_thompson",	"1 1 -13 7.615 -29.14 6.7 0.55 0",	0	},
	{ &g_mohr_ironsights[5],	"g_mohr_is_bar",		"0 1 -15 6.43 -28.8 5.1 -2 0",	0		},
	{ &g_mohr_ironsights[6],	"g_mohr_is_bazooka",	"0 1 -18 5.8 -33.65 2.5 -3 0",	0		},
	{ &g_mohr_ironsights[7],	"g_mohr_is_p38",		"0 0 0 0 0 0 0 0",		0				},
	{ &g_mohr_ironsights[8],	"g_mohr_is_shotgun",	"1 1 -12 10.1 -27.63 8.5 -0.5 0",	0	},
	{ &g_mohr_ironsights[9],	"g_mohr_is_kar98",		"1 1 -17 8.21 -27.2 8.5 -2.7 0",	0	},
	{ &g_mohr_ironsights[10],	"g_mohr_is_kar98sniper",	"0 0 0 0 0 0 0 0",	0				},
	{ &g_mohr_ironsights[11],	"g_mohr_is_mp40",		"1 1 -17 8.62 -28.59 8.1 0.3 0",	0	},
	{ &g_mohr_ironsights[12],	"g_mohr_is_stg44",		"0 1 -18 8.17 -30.85 6 1.2 0",	0		},
	{ &g_mohr_ironsights[13],	"g_mohr_is_panzerschreck",	"0 1 -18 2.8 -31.3 8.1 -1 0",	0	}
};

void InitCvars(void) {
    unsigned int	i;
	//char			suppName[64];
    for (i = 0; i < sizeof(cvars) / sizeof(cvars[0]); i++)
		*cvars[i].cvar = gi.cvar( cvars[i].name, cvars[i].value, cvars[i].flags);
	/*for (i = 0; i < MAX_CLIENTS; i++) {
		sprintf(suppName, "g_mohr_suppressed%d", i);
		g_mohr_suppressed[i] = gi.cvar(suppName, "-3600000", 0);
		sprintf(suppName, "g_mohr_addkills%d", i);
		g_mohr_addkills[i] = gi.cvar(suppName, "0", 0);
	}*/
}
