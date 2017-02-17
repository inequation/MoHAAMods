// PORTIONS OF THIS FILE HAVE BEEN REMOVED FOR THE 2017 RELEASE
// Most of the missing code can be claimed from any id Tech 3 game, e.g. Enemy Territory.
// https://github.com/id-Software/Enemy-Territory/

#ifndef CG_MAIN_H
#define CG_MAIN_H

#include "../shared.h"

typedef enum {
	STEREO_CENTER,
	STEREO_LEFT,
	STEREO_RIGHT
} stereoFrame_t;

typedef struct fontHandle_s {
	int	bla;
} fontHandle_t;

typedef struct {
	int		firstPoint;
	int		numPoints;
} markFragment_t;

typedef enum {
	RT_MODEL,
	RT_POLY,
	RT_SPRITE,
	RT_BEAM,
	RT_RAIL_CORE,
	RT_RAIL_RINGS,
	RT_LIGHTNING,
	RT_PORTALSURFACE,		// doesn't draw anything, just info for portals

	RT_MAX_REF_ENTITY_TYPE
} refEntityType_t;

typedef struct {
	refEntityType_t	reType;

	int				renderfx;

	qhandle_t		hModel;				// opaque type outside refresh
	qhandle_t		hOldModel;

	vec3_t			lightingOrigin;		// so multi-part models can be lit identically (RF_LIGHTING_ORIGIN)
	int				parentEntity;

	vec3_t			axis[3];			// rotation vectors
	qboolean		nonNormalizedAxes;	// axis are not normalized, i.e. they have scale
	vec3_t			origin;			// also used as MODEL_BEAM's "from"

	frameInfo_t		frameInfo[16];
	float			actionWeight;
	short int		wasframe;

	float			scale;
	vec3_t			oldorigin;

	int				skinNum;
	qhandle_t		customShader;
	unsigned char	shaderRGBA[4];
	float			shaderTexCoord[2];
	float			shaderTime;

	int				entityNumber;

	unsigned char	surfaces[32];
	float			shader_data[2];

	int				*bone_tag;
	float			(*bone_quat)[4];
	DWORD			dummy[3];
	//struct tikiFrame_s	*of;
	//struct tikiFrame_s	*nf;
	//struct dtiki_s	*tiki;
	int				bonestart;
	int				morphstart;
	qboolean		hasMorph;

	float			radius;
	float			rotation;
} refEntity_t;

#define	MAX_MAP_AREA_BYTES			32

typedef struct {
	int			x, y, width, height;
	float		fov_x, fov_y;
	vec3_t		vieworg;
	vec3_t		viewaxis[3];		// transformation matrix

	// time in milliseconds for shader effects and other time dependent rendering issues
	int			time;

	int			rdflags;			// RDF_NOWORLDMODEL, etc

	// 1 bits will prevent the associated area from rendering at all
	byte		areamask[MAX_MAP_AREA_BYTES];

	// text messages for deform text shaders
//	char		text[MAX_RENDER_STRINGS][MAX_RENDER_STRING_LENGTH];

   // fog stuff
   float       farplane_distance;
   vec3_t      farplane_color;
   qboolean    farplane_cull;

   // sky portal stuff
   qboolean    sky_portal;
   float       sky_alpha;
   vec3_t      sky_origin;
   vec3_t      sky_axis[ 3 ];

} refdef_t;

typedef struct {
	vec3_t		xyz;
	float		st[2];
	byte		modulate[4];
} polyVert_t;

#define	MAX_GAMESTATE_CHARS	32000
typedef struct {
	int			stringOffsets[MAX_CONFIGSTRINGS];
	char		stringData[MAX_GAMESTATE_CHARS];
	int			dataCount;
} gameState_t;

typedef struct {
	vec3_t origin;
	int entity_number;
	int channel;
	short sound_index;
	float volume;
	float min_dist;

	float	dummy1[2];

	qboolean stop_flag;

	DWORD	dummmy2;
} server_sound_t;


#define	MAX_ENTITIES_IN_SNAPSHOT	1024
#define MAX_SERVER_SOUNDS			64
// snapshots are a view of the server at a given time

// Snapshots are generated at regular time intervals by the server,
// but they may not be sent if a client's rate level is exceeded, or
// they may be dropped by the network.
typedef struct {
	int				snapFlags;			// SNAPFLAG_RATE_DELAYED, etc
	int				ping;

	int				serverTime;		// server time the message is valid for (in msec)

	byte				areamask[MAX_MAP_AREA_BYTES];		// portalarea visibility bits

	playerState_t	ps;						// complete information about the current player at this time

	int				numEntities;			// all of the entities that need to be presented
	entityState_t	entities[MAX_ENTITIES_IN_SNAPSHOT];	// at the time of this snapshot

	int				numServerCommands;		// text based server commands to execute when this
	int				serverCommandSequence;	// snapshot becomes current

	int				number_of_sounds;
	server_sound_t	sounds[ MAX_SERVER_SOUNDS ];
} snapshot_t;

/*
** glconfig_t
**
** Contains variables specific to the OpenGL configuration
** being run right now.  These are constant once the OpenGL
** subsystem is initialized.
*/
typedef enum {
	TC_NONE,
	TC_S3TC
} textureCompression_t;

typedef enum {
	GLDRV_ICD,					// driver is integrated with window system
								// WARNING: there are tests that check for
								// > GLDRV_ICD for minidriverness, so this
								// should always be the lowest value in this
								// enum set
	GLDRV_STANDALONE,			// driver is a non-3Dfx standalone driver
	GLDRV_VOODOO				// driver is a 3Dfx standalone driver
} glDriverType_t;

typedef enum {
	GLHW_GENERIC,			// where everthing works the way it should
	GLHW_3DFX_2D3D,			// Voodoo Banshee or Voodoo3, relevant since if this is
							// the hardware type then there can NOT exist a secondary
							// display adapter
	GLHW_RIVA128,			// where you can't interpolate alpha
	GLHW_RAGEPRO,			// where you can't modulate alpha on alpha textures
	GLHW_PERMEDIA2			// where you don't have src*dst
} glHardwareType_t;

#define	MAX_STRING_CHARS	2048
typedef struct {
	char					renderer_string[ MAX_STRING_CHARS ];
	char					vendor_string[ MAX_STRING_CHARS ];
	char					version_string[ MAX_STRING_CHARS ];
	char					extensions_string[ MAX_STRING_CHARS * 2 ];

	int						maxTextureSize;			// queried from GL
	int						maxActiveTextures;		// multitexture ability

	int						colorBits, depthBits, stencilBits;

	glDriverType_t			driverType;
	glHardwareType_t		hardwareType;

	qboolean				deviceSupportsGamma;
	textureCompression_t	textureCompression;
	qboolean				textureEnvAddAvailable;

	int						vidWidth, vidHeight;
	// aspect is the screen's physical width / height, which may be different
	// than scrWidth / scrHeight if the pixels are non-square
	// normal screens should be 4/3, but wide aspect monitors may be 16/9
	float					windowAspect;

	int						displayFrequency;

	// synonymous with "does rendering consume the entire screen?", therefore
	// a Voodoo or Voodoo2 will have this set to TRUE, as will a Win32 ICD that
	// used CDS.
	qboolean				isFullscreen;
	qboolean				stereoEnabled;
	qboolean				smpActive;		// dual processor

	DWORD	dummy[4];

} glconfig_t;

typedef struct cg_s {
	int				clientFrame;
	int				clientNum;
	int				demoPlayback;
	int				levelShot;
	int				latestSnapshotNum;
	int				latestSnapshotTime;
	snapshot_t		*snap;
	snapshot_t		*nextSnap;
	snapshot_t		activeSnapshots[2];
	float			frameInterpolation;
	int				thisFrameTeleport;
	int				nextFrameTeleport;
	int				nextFrameCameraCut;
	int				frametime;
	int				time;
	int				physicsTime;
	int				renderingThirdPerson;
	int				hyperspace;
	playerState_t	predicted_player_state;
	int				validPPS;
	int				predictedErrorTime;
	vec3_t			predictedError;
	int				iWeaponCommand;
	int				iWeaponCommandSend;
	vec3_t			autoAngles;
	vec3_t			autoAxis[3];
	vec3_t			autoAnglesSlow;
	vec3_t			autoAxisSlow[3];
	vec3_t			autoAnglesFast;
	vec3_t			autoAxisFast[3];
	refdef_t		refdef;
	vec3_t			playerHeadPos;
	vec3_t			refdefViewAngles;
	vec3_t			currentViewPos;
	vec3_t			currentViewAngles;
	float			fCurrentViewHeight;
	float			fCurrentViewBobPhase;
	float			fCurrentViewBobAmp;
	//dtiki_t *pLastPlayerWorldModel;
	//dtiki_t *pPlayerFPSModel;
	DWORD			dummy1[2];
	int				hPlayerFPSModelHandle;
	int				bFPSModelLastFrame;
	int				bFPSOnGround;
	DWORD			dummy2;	//dtiki_t *pAlliedPlayerModel;
	int				hAlliedPlayerModelHandle;
	DWORD			dummy3;	//dtiki_t *pAxisPlayerModel;
	int				hAxisPlayerModelHandle;
	vec3_t			vOffsetViewAngles;
	vec3_t			vLastHeadAngles;
	vec3_t			vLastViewAngles;
	vec3_t			vEyeOffsetMax;
	float			fEyeOffsetFrac;
	vec3_t			SoundOrg;
	vec3_t			SoundAxis[3];
	vec3_t			camera_origin;
	vec3_t			camera_angles;
	float			camera_fov;
	float			zoomSensitivity;
	int				bIntermissionDisplay;
	int				scoresRequestTime;
	int				showScores;
	char			scoresMenuName[256];
	int				iInstaMessageMenu;
	int				centerPrintTime;
	int				centerPrintCharWidth;
	int				centerPrintY;
	char			centerPrint[1024];
	int				centerPrintLines;
	int				matchStartTime;
	refEntity_t		testModelEntity;
	char			testModelName[64];
	int				testGun;
	float			farplane_distance;
	vec3_t			farplane_color[3];
	int				farplane_cull;
	int				sky_portal;
	float			sky_alpha;
	vec3_t			sky_origin;
	vec3_t			sky_axis[3];
	vec2_t			viewkick[2];
	float			viewkickRecenter;
	float			viewkickMinDecay;
	float			viewkickMaxDecay;
	/*cobjective_t	Objectives[20];
	float			ObjectivesAlphaTime;
	float			ObjectivesBaseAlpha;
	float			ObjectivesDesiredAlpha;
	float			ObjectivesCurrentAlpha;
	crain_t			Rain;
	clientInfo_t	clientinfo[64];*/
} cg_t;

// renderfx flags
#define	RF_THIRD_PERSON	   (1<<0)   	// don't draw through eyes, only mirrors (player bodies, chat sprites)
#define	RF_FIRST_PERSON	   (1<<1)		// only draw through eyes (view weapon, damage blood blob)
#define  RF_DEPTHHACK         (1<<2)      // hack the z-depth so that view weapons do not clip into walls
#define  RF_VIEWLENSFLARE     (1<<3)      // View dependent lensflare
#define	RF_FRAMELERP		   (1<<4)      // interpolate between current and next state
#define	RF_BEAM				   (1<<5)      // draw a beam between origin and origin2
#define  RF_DONTDRAW			   (1<<7)      // don't draw this entity but send it over
#define  RF_LENSFLARE         (1<<8)      // add a lens flare to this
#define  RF_EXTRALIGHT        (1<<9)      // use good lighting on this entity
#define  RF_DETAIL            (1<<10)     // Culls a model based on the distance away from you
#define  RF_SHADOW            (1<<11)     // whether or not to draw a shadow
#define	RF_PORTALSURFACE	   (1<<12)   	// don't draw, but use to set portal views
#define	RF_SKYORIGIN   	   (1<<13)   	// don't draw, but use to set sky portal origin and coordinate system
#define	RF_SKYENTITY   	   (1<<14)   	// this entity is only visible through a skyportal
#define	RF_LIGHTOFFSET   	   (1<<15)   	// this entity has a light offset
#define	RF_CUSTOMSHADERPASS  (1<<16)     // draw the custom shader on top of the base geometry
#define	RF_MINLIGHT			   (1<<17)		// allways have some light (viewmodel, some items)
#define	RF_FULLBRIGHT		   (1<<18)		// allways have full lighting
#define  RF_LIGHTING_ORIGIN	(1<<19)		// use refEntity->lightingOrigin instead of refEntity->origin
									               // for lighting.  This allows entities to sink into the floor
									               // with their origin going solid, and allows all parts of a
									               // player to get the same lighting
#define	RF_SHADOW_PLANE      (1<<20)		// use refEntity->shadowPlane
#define	RF_WRAP_FRAMES		   (1<<21)		// mod the model frames by the maxframes to allow continuous
									               // animation without needing to know the frame count
#define  RF_PORTALENTITY      (1<<22)     // this entity should only be drawn from a portal
#define  RF_DUALENTITY        (1<<23)     // this entity is drawn both in the portal and outside it.
#define  RF_ADDITIVE_DLIGHT   (1<<24)     // this entity has an additive dynamic light
#define  RF_LIGHTSTYLE_DLIGHT (1<<25)     // this entity has a dynamic light that uses a light style
#define  RF_SHADOW_PRECISE    (1<<26)     // this entity can have a precise shadow applied to it
#define  RF_INVISIBLE         (1<<27)     // This entity is invisible, and only negative lights will light it up

#define VectorEqual(a,b)        ((a)[0] == (b)[0] && (a)[1] == (b)[1] && (a)[2] == (b)[2])
#define VectorClear(a)          ((a)[0] = (a)[1] = (a)[2] = 0.f)

#endif // CG_MAIN_H
