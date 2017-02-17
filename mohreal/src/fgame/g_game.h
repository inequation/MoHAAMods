#ifndef GAME_H
#define GAME_H
#include "g_main.h"

typedef struct clientCommand_s {
    char *cmd;
    void (*func)(gentity_t *ent);
} clientCommand_t;

typedef struct consoleCommand_s {
    char *cmd;
    void (*func)(void);
} consoleCommand_t;

typedef struct clientInfo_s {
	gentity_t		*ent;
	int				pmodFlags;
} clientInfo_t;

typedef struct levelLocals_s {
	int				numConnectedClients;
	int				maxclients;

	int				time;
	int				startTime;
	int				frameTime;

	clientInfo_t	clients[MAX_CLIENTS];
} levelLocals_t;

extern levelLocals_t	level;
extern gentity_t		*g_entities;

cvar_t *G_Cvar( const char *var_name, const char *value, int flags );

void G_InitGame(int startTime, int randomSeed);
void G_Shutdown(void);
void G_Cleanup(void);
void G_RunFrame(int levelTime, int frameTime);
char *G_ClientConnect(int clientNum, qboolean firstTime);
void G_ClientBegin(gentity_t *ent, usercmd_t *cmd);
void G_ClientDisconnect(gentity_t *ent);
void G_ClientCommand(gentity_t *ent);
void G_ClientUserinfoChanged(gentity_t *ent, const char *userinfo);
void G_ClientThink(gentity_t *ent, usercmd_t *ucmd);
qboolean G_ConsoleCommand(void);
int	G_ReadFile(const char *name, void **buf, qboolean quiet);
void G_FreeFile(void *buf);
void G_SendServerCommand(int clientnum, const char *fmt, int arg1, int arg2, int arg3, int arg4, int arg5, int arg6, int arg7, int arg8, int arg9, int arg10/*...*/);
void G_Restart(void);
char *G_ConvertString(const char *in);

void GetUserinfo(int index, char *buf, int bufSize);
void Cmd_Addbot_f(void);

#endif // GAME_H
