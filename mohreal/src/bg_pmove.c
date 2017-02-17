#include "shared.h"

/*void BG_ProcessUserCmd(usercmd_t *cmd, playerState_t *ps, int *flags) {
	if (ps->pm_type != PM_NORMAL)
		return;
	if (!(cmd->buttons & BUTTON_RUN)) {
		cmd->buttons |= BUTTON_RUN;
		*flags |= PMOD_SPRINT;
		if (cmd->forwardmove > 0)	// can only sprint forward
			cmd->forwardmove *= 2;
		if (cmd->forwardmove >= 64)	// allow sprinting diagonally
			cmd->rightmove *= 2;
		*flags &= ~PMOD_ZOOM;
		return;
	} else
		*flags &= ~PMOD_SPRINT;
	if (cmd->buttons & BUTTON_ATTACKSECONDARY) {
		if (!(*flags & PMOD_SECONDARYPRESSED)
			&& ps->activeItems[ITEMSTAT_ACTIVEITEM]
			&& ps->activeItems[ITEMSTAT_ACTIVEITEM] != ITEM_BINOCULARS
			&& ps->activeItems[ITEMSTAT_ACTIVEITEM] != ITEM_COLT45
			&& ps->activeItems[ITEMSTAT_ACTIVEITEM] != ITEM_HISTANDARDSILENCED
			&& ps->activeItems[ITEMSTAT_ACTIVEITEM] != ITEM_KAR98SNIPER
			&& ps->activeItems[ITEMSTAT_ACTIVEITEM] != ITEM_M2FRAGGRENADE
			&& ps->activeItems[ITEMSTAT_ACTIVEITEM] != ITEM_SPRINGFIELD03
			&& ps->activeItems[ITEMSTAT_ACTIVEITEM] != ITEM_STIELHANDGRANATE
			&& ps->activeItems[ITEMSTAT_ACTIVEITEM] != ITEM_WALTHERP38) {
			*flags |= PMOD_SECONDARYPRESSED;
			*flags ^= PMOD_WANTZOOM;
		} else if (!(*flags & PMOD_SECONDARYPRESSED))
			*flags &= ~PMOD_WANTZOOM;
	} else
		*flags &= ~PMOD_SECONDARYPRESSED;
	if (*flags & PMOD_WANTZOOM) {
		*flags |= PMOD_ZOOM;
		if (cmd->buttons & BUTTON_RUN) {
			cmd->buttons &= ~BUTTON_RUN;
			//cmd->forwardmove /= 2;
		}
	} else
		*flags &= ~PMOD_ZOOM;
}*/
