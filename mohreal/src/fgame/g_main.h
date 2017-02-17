// PORTIONS OF THIS FILE HAVE BEEN REMOVED FOR THE 2017 RELEASE
// Most of the missing code can be claimed from any id Tech 3 game, e.g. Enemy Territory.
// https://github.com/id-Software/Enemy-Territory/

#ifndef MAIN_H
#define MAIN_H

#include "../shared.h"

#define GAME_DLL


typedef struct gentity_s gentity_t;
struct gentity_s {
	entityState_t		s;				// communicated by server to clients
	gclient_t			*client;		// NULL if not a player
	int					inuse;
	int					linked;			// qfalse if not in any good cluster
	int					linkcount;

	int					svflags;		// SVF_NOCLIENT, SVF_BROADCAST, etc
	int					singleClient;
	int					lastNetTime;

	int					bmodel;			// if false, assume an explicit mins / maxs bounding box
											// only set by gi.SetBrushModel

	vec3_t				mins;
	vec3_t				maxs;
	int					contents;		// CONTENTS_TRIGGER, CONTENTS_SOLID, CONTENTS_BODY, etc
											// a non-solid entity should set to 0

	vec3_t				absmin, absmax;	// derived from mins/maxs and origin + rotation

	float				radius;			// radius of object
	vec3_t				centroid;		// centroid, to be used with radius
	int					areanum;		// derived from mins/maxs and origin + rotation

	// currentOrigin will be used for all collision detection and world linking.
	// it will not necessarily be the same as the trajectory evaluation for the current
	// time, because each entity must be moved one at a time after time is advanced
	// to avoid simultanious collision issues
//	vec3_t				currentOrigin;
	vec3_t				currentAngles;

	int					ownerNum;		// objects never interact with their owners, to
											// prevent player missiles from immediately
											// colliding with their owner

	solid_t				solid;			// Added for FAKK2

	DWORD				dummy1;//struct dtiki_s *tiki;
	float				mat[3][3];

	// DO NOT MODIFY ANYTHING ABOVE THIS, THE SERVER
	// EXPECTS THE FIELDS IN THAT ORDER!

	//================================

	DWORD				dummy2;//Entity *entity;

	float				freetime;		// svs.time when the object was freed
	float				spawntime;		// svs.time when the object was spawned

	float				radius2;		// squared radius of object.  Used in findradius in g_utils.cpp

	char				entname[64];

	int					clipmask;

	gentity_t			*next;
	gentity_t			*prev;
};

// some server cvar bindings
extern cvar_t   *dedicated;
extern cvar_t   *mapname;
extern cvar_t	*sv_maxclients;
extern cvar_t   *g_gametype;
extern cvar_t	*g_mohr_zoomers;
extern cvar_t	*g_mohr_suppressed;
extern cvar_t	*g_mohr_addkills;
//extern cvar_t	*g_mohr_adddeaths;

extern cvar_t	*g_mohr_ironsights[14];

void InitCvars(void);

#endif // MAIN_H
