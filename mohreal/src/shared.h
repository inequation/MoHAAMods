#ifndef SHARED_H
#define SHARED_H

// shared.h - definitions shared by both client and server game libs

#include <stdlib.h>

#define MOHREAL_VERSION_MAJOR		0
#define MOHREAL_VERSION_MINOR		3
#define MOHREAL_VERSION_S			"0.3 BETA"

#define IRONSIGHT_SWITCH_TIME		200	// ms
#define IRONSIGHT_1_SWITCH_TIME		0.005	// 1 / IRONSIGHT_SWITCH_TIME

#define SUPPRESS_TIME				6000	// ms
#define SUPPRESS_1_TIME				0.00016666666666666667	// 1 / SUPPRESS_TIME

#if (defined(_WIN32) || defined(__WIN32__)) && !defined(WIN32)
    #define WIN32
#endif // _WIN32

#ifdef WIN32
    #define DLL_EXPORT __declspec(dllexport)
	#define QDECL __cdecl
    #include <windows.h>
#else
    #define DLL_EXPORT
	#define QDECL

	#include <dlfcn.h>
	#include <sys/types.h>
	#include <unistd.h>
#endif // WIN32

#ifdef __GNUC__
	#define _attribute(x) __attribute__(x)
#else
	#define _attribute(x)
#endif

#ifndef MAX_PATH
	#define MAX_PATH	256
#endif

// parameters to the main Error routine
typedef enum {
	ERR_FATAL,					// exit the entire game with a popup window
	ERR_DROP,					// print to console and disconnect from game
	ERR_DISCONNECT,				// don't kill server
	ERR_NEED_CD					// pop up the need-cd dialog
} errorParm_t;

#define MAX_CLIENTS 64

// CONSTANTS FROM THE FAKK SDK AND REVERSE ENGINEERING
#define	CVAR_ARCHIVE		1	// set to cause it to be saved to vars.rc
								      // used for system variables, not for player
								      // specific configurations
#define	CVAR_USERINFO		2	// sent to server on connect or change
#define	CVAR_SERVERINFO	4	// sent in response to front end requests
#define	CVAR_SYSTEMINFO	8	// these cvars will be duplicated on all clients
#define	CVAR_INIT			16	// don't allow change from console at all,
								      // but can be set from the command line
#define	CVAR_LATCH			32	// will only change when C code next does
								      // a Cvar_Get(), so it can't be changed
								      // without proper initialization.  modified
								      // will be set, even though the value hasn't
								      // changed yet
#define	CVAR_ROM			   64	// display only, cannot be set by user at all
#define	CVAR_USER_CREATED	128	// created by a set command
#define	CVAR_TEMP			256	// can be set even when cheats are disabled, but is not archived
#define	CVAR_CHEAT			512	// can not be changed if cheats are disabled
#define	CVAR_NORESTART		1024	// do not clear when a cvar_restart is issued
#define	CVAR_RESETSTRING  2048  // force the cvar's reset string to be set
#define	CVAR_SOUND_LATCH	4096	// specifically for sound will only change
                                 // when C code next does a Cvar_Get(), so it
                                 // can't be changed without proper initialization.
                                 // modified will be set, even though the value hasn't
								         // changed yet

// the game guarantees that no string from the network will ever
// exceed MAX_STRING_CHARS
#define	MAX_STRING_CHARS	1024	// max length of a string passed to Cmd_TokenizeString
#define	MAX_STRING_TOKENS	256		// max tokens resulting from Cmd_TokenizeString
#define	MAX_TOKEN_CHARS		1024	// max length of an individual token

#define	MAX_INFO_STRING		1024
#define	MAX_INFO_KEY		1024
#define	MAX_INFO_VALUE		1024

#define BIG_INFO_STRING		8192	// used for system info key only
#define BIG_INFO_KEY		8192
#define BIG_INFO_VALUE		8192

#define	MAX_NAME_LENGTH		36

#define	GENTITYNUM_BITS		10		// don't need to send any more
#define	MAX_GENTITIES		(1<<GENTITYNUM_BITS)

// entitynums are communicated with GENTITY_BITS, so any reserved
// values thatare going to be communcated over the net need to
// also be in this range
#define	ENTITYNUM_NONE		(MAX_GENTITIES-1)
#define	ENTITYNUM_WORLD		(MAX_GENTITIES-2)
#define	ENTITYNUM_MAX_NORMAL	(MAX_GENTITIES-2)

#define GT_SINGLEPLAYER     0
#define GT_FREEFORALL       1
#define GT_TEAMMATCH        2
#define GT_ROUNDBASEDMATCH  3
#define GT_OBJECTIVEMATCH   4

// IneQuation: portability
#ifdef WIN32
	#define strcasecmp stricmp
#endif

// IneQuation - defines for printing to the players' HUD through gi.SendServerCommand
// CHAT prints in white in the chat area
#define CHAT "print \"\x02 %s\""
// IPRINTLN prints below the compass in yellow without a click sound
#define IPRINTLN "hudprint \"%s\""
// IPRINTLNBOLD prints below the compass in white with a click sound
#define IPRINTLNBOLD "print \"\x03 %s\n\""
// OBITUARY prints in red in the chat area
#define OBITUARY "print \"\x04 %s\""

typedef enum {qfalse, qtrue}	qboolean;

#ifndef WIN32
typedef unsigned long DWORD;
typedef unsigned char byte;
#endif // WIN32

typedef int		qhandle_t;
typedef int		sfxHandle_t;
typedef int		fileHandle_t;
typedef int		clipHandle_t;

typedef struct cvar_s {
	char		*name;
	char		*string;
	char		*resetString;		// cvar_restart will reset to this value
	char		*latchedString;		// for CVAR_LATCH vars
	int			flags;
	qboolean	modified;			// set each time the cvar is changed
	int			modificationCount;	// incremented each time the cvar is changed
	float		value;				// atof( string )
	int			integer;			// atoi( string )
	struct cvar_s *next;
} cvar_t;

// IneQuation
typedef struct usercmd_s {
	int				serverTime;
    byte			msec;
	unsigned short	buttons;
	short			deltaAngles[3];

	signed char		forwardmove, rightmove, upmove;
} usercmd_t;

// IneQuation: usercmd_t->buttons flags
#define BUTTON_ATTACKPRIMARY    1
#define BUTTON_ATTACKSECONDARY  2
#define BUTTON_RUN              4
#define BUTTON_USE              8
#define BUTTON_LEANLEFT         16
#define BUTTON_LEANRIGHT        32

typedef float vec_t;
typedef vec_t vec2_t[2];
typedef vec_t vec3_t[3];
typedef vec_t vec4_t[4];
typedef vec_t vec5_t[5];

typedef struct {
	int		trTime;
	vec3_t	trDelta;			   // velocity, etc
} trajectory_t;

typedef struct {
	int		index;
	float	time;
	float	weight;
} frameInfo_t;

typedef struct entityState_s {
	int				number;			// entity index
	int				eType;			// entity index
	int				eFlags;
	trajectory_t	pos;			// for calculating position
	vec3_t			netorigin;		// these are the ones actually sent over
	vec3_t			origin;
	vec3_t			origin2;
	vec3_t			netangles;		// these are the ones actually sent over
	vec3_t			angles;
	int				constantLight;	// these are the ones actually sent over
	int				loopSound;		// constantly loop this sound
	float			loopSoundVolume;
	float			loopSoundMinDist;
	float			loopSoundMaxDist;
	float			loopSoundPitch;
	int				loopSoundFlags;
	int				parent;			// if this entity is attached, this is non-zero
	int				tag_num;		// if attached, the tag number it is attached to on the parent
	qboolean		attach_use_angles;
	vec3_t			attach_offset;
	int				beam_entnum;
	int				modelindex;
	int				usageIndex;
	int				skinNum;
	int				wasframe;
	frameInfo_t		frameInfo[16];
	float			actionWeight;
	int				bone_tag[5];
	vec3_t			bone_angles[5];
	vec4_t			bone_quat[5];
	unsigned char	surfaces[32];
	int				clientNum;
	int				groundEntityNum;
	int				solid;
	float			scale;
	float			alpha;
	int				renderfx;
	vec2_t			shader_data;
	float			shader_time;
	vec4_t			quat;
	vec3_t			eyeVector;
} entityState_t;

typedef enum {
	TEAM_NONE,
	TEAM_SPECTATOR,
	TEAM_FREEFORALL,
	TEAM_ALLIES,
	TEAM_AXIS,
	TEAM_NUM_TEAMS
} team_t;

typedef struct client_persistant_s {
	char userinfo[1350];		// it's not MAX_INFO_STRING but a custom value
	char netname[32];
	char dm_playermodel[64];
	char dm_playergermanmodel[64];
	char dm_primaryWeapon[64];
	float enterTime;
	team_t teamnum;
	int round_kills;
} client_persistant_t;

typedef enum {
	PM_NORMAL,
	PM_DUMMY1,
	PM_SPECTATOR,
	PM_DEAD
} pmtype_t;

typedef struct cplane_s {
	vec3_t	normal;
	float	dist;
	byte	type;			// for fast side tests: 0,1,2 = axial, 3 = nonaxial
	byte	signbits;		// signx + (signy<<1) + (signz<<2), used as lookup during collision
	byte	pad[2];
} cplane_t;

// a trace is returned when a box is swept through the world
typedef struct {
	qboolean			allsolid;		// if true, plane is not valid
	qboolean			startsolid;		// if true, plane is not valid
	float				fraction;		// time completed, 1.0 = didn't hit anything
	vec3_t				endpos;			// final position
	cplane_t			plane;			// time completed, 1.0 = didn't hit anything
	int					surfaceFlags;	// surface hit
	int					shaderNum;
	int					contents;		// contents on other side of surface hit
	int					entityNum;		// surface hit
	int					location;
	struct gentity_s	*ent;			// Pointer to entity hit
} trace_t;

typedef struct playerState_s {
	int			commandTime;
	int			pm_type;
	int			bobCycle;
	int			pm_flags;
	int			pm_runtime;
	vec3_t		origin;
	vec3_t		velocity;
	int			gravity;
	int			speed;
	int			delta_angles[3];
	int			groundEntityNum;// ENTITYNUM_NONE = in air
	qboolean	walking;
	qboolean	groundPlane;
	int			feetfalling;
	vec3_t		falldir;
	trace_t		groundTrace;
	int			clientNum;
	vec3_t		viewangles;
	int			viewheight;
	float		fLeanAngle;
	int			iViewModelAnim;
	int			iViewModelAnimChanged;
	int			stats[32];
	int			activeItems[8];
	int			ammo_name_index[16];
	int			ammo_amount[16];
	int			max_ammo_amount[16];
	int			current_music_mood;
	int			fallback_music_mood;
	float		music_volume;
	float		music_volume_fade_time;
	int			reverb_type;
	float		reverb_level;
	vec4_t		blend;	// rgba full screen effect
	float		fov;
	vec3_t		camera_origin;
	vec3_t		camera_angles;
	float		camera_time;
	vec3_t		camera_offset;
	vec3_t		camera_posofs;
	int			camera_flags;
	vec3_t		damage_angles;
	int			ping;
	vec3_t		vEyePos;
} playerState_t;

// sound channels
typedef enum {
    CHAN_AUTO,
	CHAN_LOCAL,
    CHAN_WEAPON,
	CHAN_VOICE,
	CHAN_ITEM,
	CHAN_BODY,
    CHAN_DIALOG,
    CHAN_DIALOG_SECONDARY,
    CHAN_WEAPONIDLE,
    CHAN_MENU,
    CHAN_NUM_CHANNELS
} soundChannel_t;

#define WEAPON_NONE				0	//
#define WEAPON_PISTOL			1	// 2^0
#define WEAPON_RIFLE			2	// 2^1
#define WEAPON_SNIPER			2	// 2^1
#define WEAPON_SMG				4	// 2^2
#define WEAPON_MG				8	// 2^3
#define WEAPON_GRENADE			16	// 2^4
#define WEAPON_BAZOOKA			32	// 2^5
#define WEAPON_SHOTGUN			32	// 2^5
#define WEAPON_DUMMY1			64  // 2^6 UNKNOWN WEAPON TYPE - turret maybe?
#define WEAPON_DUMMY2			128 // 2^7 UNKNOWN WEAPON TYPE - turret maybe?
#define WEAPON_ITEM				256 // 2^8 item, e.g. binoculars

// Rookie One: for ent->client->ps.stats
// source: ui/hud_*.urc + reverse engineering
#define STAT_HEALTH					0	// current player health
#define STAT_MAX_HEALTH				1	// max player health
#define STAT_WEAPONCLASSES			2
#define STAT_CURRENT_WEAPONCLASS	3
#define STAT_TOTALAMMO				4	// total ammo
#define STAT_MAXAMMO_SINGLE			5	// max ammo for single-round clip weapons (e.g. bazooka, grenade)
#define STAT_CLIPAMMO				6	// ammo in current clip
#define STAT_MAXAMMO				7	// max ammo amount a clip can hold
#define STAT_FOV					8   // actually, any non-zero value only makes the viewmodel disappear without any FOV change
#define STAT_CROSSHAIR				9
#define STAT_LASTPAINAMOUNT			10	// amount of the last taken damage
#define STAT_UNUSED					11
#define STAT_BOSSHEALTH				12
#define STAT_CINEMATIC				13  // whatever this means :S
#define STAT_ADDFADE				14
#define STAT_LETTERBOX				15  // letterbox/black screen over
#define STAT_NORTHYAW				16	// north direction for compass
#define STAT_OBJECTIVE_LEFTBALL		17	// position of the left ball on the compass objective indicator
#define STAT_OBJECTIVE_RIGHTBALL	18	// position of the right ball on the compass objective indicator
#define STAT_OBJECTIVE				19	// objective direction
#define STAT_LAST_TEAM				20  // last (current) team: 0 = none, 1 = spectator, 2 = free-for-all, 3 = allies, 4 = axis
#define STAT_SCORE					21	// own (team) score
#define STAT_DEATHS 				22	// number of deaths
#define STAT_UNUSED2 				23
#define STAT_UNUSED3    			24
#define STAT_HIGHEST_SCORE			25	// highest score
#define STAT_LAST_ATTACKER_ID		26  // # of the player who attacked us last
#define STAT_TEAMMATE_ID			27  // # of the teammate we're looking at
#define STAT_TEAMMATE_HEALTH		28  // health of the teammate we're looking at
#define STAT_DAMAGE_DIRECTION		29	// direction last damage was taken from
#define STAT_LAST_STAT				30
#define STAT_DUMMY					31
#define STAT_NUM_STATS				32

// IneQuation: playerState_t->activeItems
#define ITEMSTAT_WEAPONCLASS		0
#define ITEMSTAT_ACTIVEITEM			1	// weapon or item (binoculars, papers, etc.)
#define ITEMSTAT_DUMMY1				2
#define ITEMSTAT_DUMMY2				3
#define ITEMSTAT_DUMMY3				4
#define ITEMSTAT_DUMMY4				5
#define ITEMSTAT_DUMMY5				6
#define ITEMSTAT_DUMMY6				7
#define ITEMSTAT_NUM_STATS			8

// pmove->pm_flags
#define	PMF_DUCKED			1   // player is ducked
#define	PMF_TIME_LAND       2	// pm_time is time before rejump
#define	PMF_TIME_KNOCKBACK  4	// pm_time is an air-accelerate only time
#define	PMF_TIME_WATERJUMP	8	// pm_time is waterjump
#define PMF_TIME_TELEPORT   16  // pm_time is teleport
#define PMF_NO_PREDICTION   32  // no prediction
#define PMF_FROZEN          64  // player cannot move or look around
#define PMF_INTERMISSION    128 // intermission view
// extended pmove flags (used for server->client notification only)
// leave some space just in case, start at bit #15
#define PMF_SPRINTING       2048   // player is sprinting
#define PMF_EXERTED         4096   // player is tired

// configstrings
#define	MAX_MODELS		    384		// these are sent over the net as 8 bits
#define MAX_IMAGES          64       // so they cannot be blindly increased
#define MAX_ACTIVE_ITEMS    32
#define MAX_INVENTORY       32
#define MAX_AMMO            32
#define MAX_ITEMS           MAX_INVENTORY + MAX_AMMO
#define MAX_AMMOCOUNT       32
#define MAX_SOUNDS_BITS     8
#define	MAX_SOUNDS			(1<<MAX_SOUNDS_BITS)
#define MAX_LIGHTSTYLES     32
#define MAX_LOCATIONS		64

#define	MAX_CONFIGSTRINGS	2736

#define	CS_SERVERINFO		0		// an info string with all the serverinfo cvars
#define	CS_SYSTEMINFO		1		// an info string for server system to client system configuration (timescale, etc)
#define	CS_NAME     		2		// A descriptive name of the current level
#define	CS_SOUNDTRACK	    8
#define CS_FOGINFO  		9
#define CS_SKYINFO  		10
#define	CS_GAME_VERSION		11
#define	CS_LEVEL_START_TIME	12		// so the timer only shows the current level
#define	CS_MODELS			32
#define	CS_SOUNDS			(CS_MODELS+MAX_MODELS)
#define CS_IMAGES           (CS_SOUNDS+MAX_SOUNDS)
#define CS_LIGHTSTYLES	    (CS_IMAGES+MAX_IMAGES)
#define	CS_PLAYERS			1684
#define CS_ITEMS			(CS_PLAYERS+MAX_CLIENTS) // strings for item and ammo names
#define CS_LOCATIONS	    (CS_ITEMS+MAX_AMMO)

// IneQuation
#define CS_MOHR_IRONSIGHTS	(CS_LOCATIONS+128)

#define CS_MAX				(CS_MOHR_IRONSIGHTS+14)

#if (CS_MAX) > MAX_CONFIGSTRINGS
#error overflow: (CS_MAX) > MAX_CONFIGSTRINGS
#endif

// IneQuation: MoHReal pmove flags
#define PMOD_SPRINT				1
#define PMOD_WANTZOOM			2
#define PMOD_ZOOM				4
#define PMOD_SECONDARYPRESSED	8

// vector math borrowed from quake
#define VectorSubtract(a,b,c)	((c)[0]=(a)[0]-(b)[0],(c)[1]=(a)[1]-(b)[1],(c)[2]=(a)[2]-(b)[2])
#define VectorAdd(a,b,c)		((c)[0]=(a)[0]+(b)[0],(c)[1]=(a)[1]+(b)[1],(c)[2]=(a)[2]+(b)[2])
#define VectorCopy(a,b)			((b)[0]=(a)[0],(b)[1]=(a)[1],(b)[2]=(a)[2])
#define	VectorScale(v, s, o)	((o)[0]=(v)[0]*(s),(o)[1]=(v)[1]*(s),(o)[2]=(v)[2]*(s))
#define	VectorMA(v, s, b, o)	((o)[0]=(v)[0]+(b)[0]*(s),(o)[1]=(v)[1]+(b)[1]*(s),(o)[2]=(v)[2]+(b)[2]*(s))
#define VectorEqual(a,b)        ((a)[0] == (b)[0] && (a)[1] == (b)[1] && (a)[2] == (b)[2])
#define VectorLength(v)         (sqrt((v)[0] * (v)[0] + (v)[1] * (v)[1] + (v)[2] * (v)[2]))
#define VectorNegate(a,b)		((b)[0]=-(a)[0],(b)[1]=-(a)[1],(b)[2]=-(a)[2])
#define VectorSet(a, b, c, d)	((a)[0]=(b),(a)[1]=(c),(a)[2]=(d))
#define VectorClear(v)			((v)[0]=0.f,(v)[1]=0.f,(v)[2]=0.f)
#define DotProduct(x,y)			((x)[0]*(y)[0]+(x)[1]*(y)[1]+(x)[2]*(y)[2])

// short <-> vec3_t angles conversion - borrowed from quake as well
#define	ANGLE2SHORT(x)	((int)((x)*65536/360) & 65535)
#define	SHORT2ANGLE(x)	((x)*(360.0/65536))

#define min(a,b)                ((a)<(b)?(a):(b))
#define max(a,b)                ((a)>(b)?(a):(b))

#define random()	((rand () & 0x7fff) / ((float)0x7fff))
#define crandom()	(2.0 * (random() - 0.5))

void BG_ProcessUserCmd(usercmd_t *cmd, playerState_t *ps, int *flags);

#endif // SHARED_H
