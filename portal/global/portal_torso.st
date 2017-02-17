	// ======================================================= //
	// Action state machine for Mike Powell, the hero of MoH PC //
	// ======================================================= //

// Authored by Carl glave and Michael Boon, 5-23-2000

// The action state machine takes care of
// a) all torso-only animations which are layer on top of leg animations
// b) most full-body animations
// c) which states are to take their full-body animations from the leg state
//    machine.
// The states which control only torso animations have "movetype legs" and 
// animations under the token "action".  This allows the leg state to continue
// controlling the leg animations.  The states which control the whole body have
// movetype not legs and animations under the token "action". This overrides the
// leg state machine. States such as STAND, below, which have "none" specified
// as the torso animation, take the torso animation from the leg animaiton
// specified in the legs state machine.

//==============================================================================
//==============================================================================
//
// Stand (really means not doing an action)
//
//==============================================================================

state STAND
{
	movetype legs

	camera behind

	entrycommands
	{
		viewmodelanim idle
	}
	
	action
	{
		none : default // no torso animation
	}

	states
	{
		KILLED					: KILLED
		PAIN					: PAIN

		VEHICLE_START			: IS_USING_VEHICLE
		TURRET_START			: IS_USING_TURRET

		// if we're on a ladder, make sure we're climbing the ladder
		LADDER_IDLE_LEFT		: ON_LADDER

		// Some grab and hang stuff will be implemented in the final game, probably 
		// not all of this, but it's in here as a placeholder.
//		CLIMB_LADDER			: ONGROUND +FORWARD !BACKWARD AT_LADDER

//		CLIMB_LADDER_IMPACT		: !ONGROUND FORWARD !BACKWARD AT_LADDER	// For grabbing onto walls when
													// flying through the air
	
		// Using objects is dictated by the object being used.  The three objects 
		// here are for objects which trigger interactive actions when touched, 
		// for objects which the player uses (such as doors), and for when the 
		// player tries to use an object that is not usable.
//		USE_USEANIM				: ONGROUND TOUCHEDUSEANIM
//		USE_USEANIM				: ONGROUND USE AT_USEANIM
		USE_LADDER				: ONGROUND +USE AT_LADDER CHECK_HEIGHT "stand"
//		USE_LADDER				: ONGROUND AT_LADDER // this is full auto use of ladders
		// latch onto ladder in mid-air
		USE_LADDER				: +USE AT_LADDER CHECK_HEIGHT "stand" // can also latch onto a ladder in mid-air
		// auto use of ladder when at the bottom (AT_LADDER check is last because it does a trace)
		USE_LADDER				: ONGROUND FORWARD LOOKING_UP "35" !PUTAWAYMAIN !NEW_WEAPON !RELOAD !ATTACK_PRIMARY !ATTACK_SECONDARY AT_LADDER CHECK_HEIGHT "stand"
		// auto use of ladder when at the top (AT_LADDER check is last because it does a trace)
		USE_LADDER				: ONGROUND FORWARD !LOOKING_UP "-35" !PUTAWAYMAIN !NEW_WEAPON !RELOAD !ATTACK_PRIMARY !ATTACK_SECONDARY AT_LADDER CHECK_HEIGHT "stand"
//		GENERIC_USE				: ONGROUND +USE

		// This is not functional for the prototype, but is here as a placeholder for
		// future functionality.
		// While the player can only fire weapons with his right hand, he can switch them 
		// to his left if he wants to use an item with his left.  Gameplay-wise, this should 
		// be the same as putting the weapon away, but it will create a nice graphical "cool 
		// factor" which is always good in computer games.
		// When we have two items out, the game code will flag them both as putaway, and we 
		// need to put the right one away first, followed by the left.
		PUTAWAY_MAIN			: PUTAWAYMAIN	// Basic put weapon away move.
		RAISE_WEAPON			: NEW_WEAPON

		RELOAD_WEAPON			: RELOAD
	
		CHECK_PRIMARY_ATTACK_SEMIAUTO	: +ATTACK_PRIMARY IS_WEAPON_SEMIAUTO "mainhand" IS_WEAPON_READY_TO_FIRE "mainhand"
		CHECK_PRIMARY_ATTACK_FULLAUTO	: ATTACK_PRIMARY !IS_WEAPON_SEMIAUTO "mainhand" IS_WEAPON_READY_TO_FIRE "mainhand"
		CHECK_SECONDARY_ATTACK			: +ATTACK_SECONDARY
	}
}

//==============================================================================
//==============================================================================
//
// Primary Attacks - Full Auto
//
//==============================================================================

state CHECK_PRIMARY_ATTACK_FULLAUTO
{
	movetype legs

	action
	{
		none : default // stop torso animation
	}

	states
	{
		STAND					: KILLED
//		PAIN					: PAIN
	
		STAND					: NEW_WEAPON
		STAND					: RELOAD
		STAND					: !IS_WEAPON_READY_TO_FIRE "mainhand"
		
//		ATTACK_PISTOL_PRIMARY	: IS_WEAPONCLASS_READY_TO_FIRE "mainhand" "pistol"
//		ATTACK_RIFLE_PRIMARY	: IS_WEAPONCLASS_READY_TO_FIRE "mainhand" "rifle"
//		CHARGE_ATTACK_GRENADE	: IS_WEAPONCLASS_READY_TO_FIRE "mainhand" "grenade"
		ATTACK_SMG_PRIMARY		: IS_WEAPONCLASS_READY_TO_FIRE "mainhand" "smg"
		ATTACK_MG_PRIMARY		: IS_WEAPONCLASS_READY_TO_FIRE "mainhand" "mg"
//		ATTACK_ITEM_PRIMARY		: IS_WEAPONCLASS_READY_TO_FIRE "mainhand" "item"
		
//		STAND					: IS_WEAPON_ACTIVE "Error" // Generates an error if no appropriate
															// attack state is chosen
		STAND					: !ATTACK_PRIMARY
	}
}

state ATTACK_SMG_PRIMARY
{
	movetype legs

	entrycommands
	{
		viewmodelanim fire 1
	}

	action
	{
		mp40_stand_run_fire		: IS_WEAPON_ACTIVE "mainhand" "MP40" POSITION_TYPE "standing" MOVEMENT_TYPE "running"
		mp40_crouch_run_fire	: IS_WEAPON_ACTIVE "mainhand" "MP40" POSITION_TYPE "crouching" MOVEMENT_TYPE "running"
		mp40_crouch_fire		: IS_WEAPON_ACTIVE "mainhand" "MP40" POSITION_TYPE "crouching"
		mp40_stand_fire			: IS_WEAPON_ACTIVE "mainhand" "MP40"

		smg_stand_run_fire		: POSITION_TYPE "standing" MOVEMENT_TYPE "running"
		smg_crouch_run_fire		: POSITION_TYPE "crouching" MOVEMENT_TYPE "running"
		smg_crouch_fire			: POSITION_TYPE "crouching"
		smg_stand_fire			: default
	}

	states
	{
		STAND							: KILLED
//		PAIN							: PAIN

		STAND							: !ATTACK_PRIMARY ANIMDONE_TORSO 
		STAND							: ANIMDONE_TORSO !IS_WEAPON_READY_TO_FIRE "mainhand"
//		STAND							: RELOAD !ATTACK_PRIMARY IS_WEAPON_READY_TO_FIRE "mainhand"
		STAND							: RELOAD !ATTACK_PRIMARY
//		STAND							: RELOAD !HAS_AMMO_IN_CLIP "mainhand" IS_WEAPON_READY_TO_FIRE "mainhand"
		
		CHECK_PRIMARY_ATTACK_FULLAUTO	: ATTACK_PRIMARY +IS_WEAPON_READY_TO_FIRE "mainhand"
		CHECK_PRIMARY_ATTACK_FULLAUTO	: +ATTACK_PRIMARY IS_WEAPON_READY_TO_FIRE "mainhand"
	}
}

state ATTACK_MG_PRIMARY
{
	movetype legs

	entrycommands
	{
		viewmodelanim fire 1
	}

	action
	{
		mp44_stand_run_fire		: IS_WEAPON_ACTIVE "mainhand" "StG 44" POSITION_TYPE "standing" MOVEMENT_TYPE "running"
		mp44_crouch_run_fire	: IS_WEAPON_ACTIVE "mainhand" "StG 44" POSITION_TYPE "crouching" MOVEMENT_TYPE "running"
		mp44_crouch_fire		: IS_WEAPON_ACTIVE "mainhand" "StG 44" POSITION_TYPE "crouching"
		mp44_stand_fire			: IS_WEAPON_ACTIVE "mainhand" "StG 44"

		mg_stand_run_fire		: POSITION_TYPE "standing" MOVEMENT_TYPE "running"
		mg_crouch_run_fire		: POSITION_TYPE "crouching" MOVEMENT_TYPE "running"
		mg_crouch_fire			: POSITION_TYPE "crouching"
		mg_stand_fire			: default
	}

	states
	{
		STAND							: KILLED
//		PAIN							: PAIN

//		STAND							: !ATTACK_PRIMARY ANIMDONE_TORSO 
//		STAND							: RELOAD !ATTACK_PRIMARY IS_WEAPON_READY_TO_FIRE "mainhand"
	
		STAND							: !ATTACK_PRIMARY ANIMDONE_TORSO 
		STAND							: ANIMDONE_TORSO !IS_WEAPON_READY_TO_FIRE "mainhand"
//		STAND							: RELOAD !ATTACK_PRIMARY IS_WEAPON_READY_TO_FIRE "mainhand"
		STAND							: RELOAD !ATTACK_PRIMARY
//		STAND							: RELOAD !HAS_AMMO_IN_CLIP "mainhand" IS_WEAPON_READY_TO_FIRE "mainhand"
		
		CHECK_PRIMARY_ATTACK_FULLAUTO	: ATTACK_PRIMARY +IS_WEAPON_READY_TO_FIRE "mainhand"
		CHECK_PRIMARY_ATTACK_FULLAUTO	: +ATTACK_PRIMARY IS_WEAPON_READY_TO_FIRE "mainhand"
	}
}

//==============================================================================
//==============================================================================
//
// Primary Attacks - Semi-Auto
//
//==============================================================================

state CHECK_PRIMARY_ATTACK_SEMIAUTO
{
	movetype legs

	action
	{
		none : default // stop torso animation
	}

	states
	{
		STAND					: KILLED
//		PAIN					: PAIN
	
		STAND					: NEW_WEAPON
		STAND					: RELOAD
		STAND					: !IS_WEAPON_READY_TO_FIRE "mainhand"

		// IneQuation
		ATTACK_PORTAL_PRIMARY	: IS_WEAPONCLASS_READY_TO_FIRE "mainhand" "pistol" IS_WEAPON_ACTIVE "mainhand" "Hi-Standard Silenced"
		
		ATTACK_PISTOL_PRIMARY	: IS_WEAPONCLASS_READY_TO_FIRE "mainhand" "pistol"
		ATTACK_RIFLE_PRIMARY	: IS_WEAPONCLASS_READY_TO_FIRE "mainhand" "rifle"
		CHARGE_ATTACK_GRENADE	: IS_WEAPONCLASS_READY_TO_FIRE "mainhand" "grenade"
		ATTACK_ITEM_PRIMARY		: IS_WEAPONCLASS_READY_TO_FIRE "mainhand" "item"
		ATTACK_BAZOOKA_PRIMARY	: IS_WEAPON_ACTIVE "mainhand" "Bazooka"
		ATTACK_BAZOOKA_PRIMARY	: IS_WEAPON_ACTIVE "mainhand" "Panzerschreck"
		ATTACK_SHOTGUN_PRIMARY	: IS_WEAPON_ACTIVE "mainhand" "Shotgun"
	
//		STAND					: IS_WEAPON_ACTIVE "Error" // Generates an error if no appropriate
											// attack state is chosen
		STAND					: !ATTACK_PRIMARY
	}
}

state ATTACK_RIFLE_PRIMARY
{
	movetype legs

	entrycommands
	{
		viewmodelanim fire 1
	}

	action
	{
		// Fire from the hip when jogging,
		// from the shoulder when walking or standing
		rifle_stand_run_fire	: POSITION_TYPE "standing" MOVEMENT_TYPE "running"
		rifle_crouch_run_fire	: POSITION_TYPE "crouching" MOVEMENT_TYPE "running"
		rifle_stand_walk_fire	: POSITION_TYPE "standing" MOVEMENT_TYPE "walking"
		rifle_crouch_fire		: POSITION_TYPE "crouching"
		rifle_stand_fire		: default
	}

	states
	{
		STAND							: KILLED
//		PAIN							: PAIN

//		STAND							: !ATTACK_PRIMARY ANIMDONE_TORSO 
		ATTACK_SPRINGFIELD_RECHAMBER	: ANIMDONE_TORSO IS_WEAPON_ACTIVE "mainhand" "Springfield '03 Sniper"
		ATTACK_KAR98_RECHAMBER			: ANIMDONE_TORSO IS_WEAPON_ACTIVE "mainhand" "Mauser KAR 98K"
		ATTACK_KAR98_RECHAMBER			: ANIMDONE_TORSO IS_WEAPON_ACTIVE "mainhand" "KAR98 - Sniper"		
		STAND							: ANIMDONE_TORSO 
		CHECK_PRIMARY_ATTACK_SEMIAUTO	: +ATTACK_PRIMARY IS_WEAPON_READY_TO_FIRE "mainhand"
	}
}

state ATTACK_SPRINGFIELD_RECHAMBER
{
	movetype legs
	
	entrycommands
	{
		viewmodelanim rechamber
//		safezoom 0
	}
	
//	exitcommands
//	{
//		safezoom 1
//	}
	
	action
	{
		springfield_crouch_rechamber	: POSITION_TYPE "crouching"
		springfield_stand_rechamber		: default
	}
	
	states
	{
		STAND							: KILLED
//		PAIN							: PAIN
	
		STAND							: ANIMDONE_TORSO 
	}
}

state ATTACK_KAR98_RECHAMBER
{
	movetype legs
	
	entrycommands
	{
		viewmodelanim rechamber
//		safezoom 0
	}
	
//	exitcommands
//	{
//		safezoom 1
//	}
	
	action
	{
		kar98_crouch_rechamber	: POSITION_TYPE "crouching"
		kar98_stand_rechamber	: default
	}
	
	states
	{
		STAND						: KILLED
//		PAIN						: PAIN
	
		STAND						: ANIMDONE_TORSO 
	}
}

state ATTACK_PISTOL_PRIMARY
{
	movetype legs

	entrycommands
	{
		viewmodelanim fire 1
	}

	action
	{
		// Fire from the hip when jogging, from the shoulder when
		// walking, or standing

		pistol_silenced_stand_run_fire	: POSITION_TYPE "standing" MOVEMENT_TYPE "running" IS_WEAPON_ACTIVE "mainhand" "Hi-Standard Silenced"
		pistol_silenced_crouch_run_fire	: POSITION_TYPE "crouching" MOVEMENT_TYPE "running" IS_WEAPON_ACTIVE "mainhand" "Hi-Standard Silenced"
		pistol_silenced_crouch_fire		: POSITION_TYPE "crouching" IS_WEAPON_ACTIVE "mainhand" "Hi-Standard Silenced"
		pistol_silenced_stand_fire		: IS_WEAPON_ACTIVE "mainhand" "Hi-Standard Silenced"

		pistol_stand_run_fire	: POSITION_TYPE "standing" MOVEMENT_TYPE "running"
		pistol_crouch_run_fire	: POSITION_TYPE "crouching" MOVEMENT_TYPE "running"
		pistol_crouch_fire		: POSITION_TYPE "crouching"
		pistol_stand_fire		: default
	}

	states
	{
		STAND							: KILLED
//		PAIN							: PAIN

//		STAND							: !ATTACK_PRIMARY ANIMDONE_TORSO 
		STAND							: ANIMDONE_TORSO 
		CHECK_PRIMARY_ATTACK_SEMIAUTO	: +ATTACK_PRIMARY IS_WEAPON_READY_TO_FIRE "mainhand"

		// allow pistol whip immediatly after firing
		ATTACK_PISTOL_SECONDARY			: +ATTACK_SECONDARY IS_WEAPON_READY_TO_FIRE "mainhand"
	}
}

state ATTACK_ITEM_PRIMARY
{
	movetype legs

	entrycommands
	{
		weaponcommand mainhand anim fire
	}
	
	states
	{
		STAND							: KILLED
//		PAIN							: PAIN

		STAND							: !ATTACK_PRIMARY
		CHECK_PRIMARY_ATTACK_SEMIAUTO	: +ATTACK_PRIMARY IS_WEAPON_READY_TO_FIRE "mainhand"
	}
}

state ATTACK_BAZOOKA_PRIMARY
{
	movetype legs
	
	entrycommands
	{
		viewmodelanim fire 1
	}
	
	action
	{
		bazooka_stand_run_fire	: POSITION_TYPE "standing" MOVEMENT_TYPE "running"
		bazooka_crouch_run_fire	: POSITION_TYPE "crouching" MOVEMENT_TYPE "running"
		bazooka_crouch_fire		: POSITION_TYPE "crouching"
		bazooka_stand_fire		: default
	}
	
	states
	{
		STAND							: KILLED
//		PAIN							: PAIN

		STAND							: !ATTACK_PRIMARY ANIMDONE_TORSO 
		CHECK_PRIMARY_ATTACK_SEMIAUTO	: +ATTACK_PRIMARY IS_WEAPON_READY_TO_FIRE "mainhand"
	}
}

state ATTACK_SHOTGUN_PRIMARY
{
	movetype legs
	
	entrycommands
	{
		viewmodelanim fire 1
	}
	
	action
	{
		shotgun_stand_run_fire	: POSITION_TYPE "standing" MOVEMENT_TYPE "running"
		shotgun_crouch_run_fire	: POSITION_TYPE "crouching" MOVEMENT_TYPE "running"
		shotgun_crouch_fire		: POSITION_TYPE "crouching"
		shotgun_stand_fire		: default
	}
	
	states
	{
		STAND							: KILLED
//		PAIN							: PAIN

		STAND							: !ATTACK_PRIMARY ANIMDONE_TORSO 
		CHECK_PRIMARY_ATTACK_SEMIAUTO	: +ATTACK_PRIMARY IS_WEAPON_READY_TO_FIRE "mainhand"
	}
}

//==============================================================================
//==============================================================================
//
// Secondary Attacks (Always Semi-Auto fire)
//
//==============================================================================
state CHECK_SECONDARY_ATTACK
{
	movetype legs

	action
	{
		none : default // no torso animation
	}

	states
	{
		STAND					: KILLED
//		PAIN					: PAIN
	
		STAND					: RELOAD

		// IneQuation
		ATTACK_PORTAL_SECONDARY			: IS_WEAPONCLASS_READY_TO_FIRE "mainhand" "pistol" "secondary" IS_WEAPON_ACTIVE "mainhand" "Hi-Standard Silenced"
		
		ATTACK_PISTOL_SECONDARY	: IS_WEAPONCLASS_READY_TO_FIRE "mainhand" "pistol" "secondary"
		
//		ATTACK_RIFLE_2NDARY		: IS_WEAPON_ACTIVE "mainhand" "M1_Garand"
//		ATTACK_GRENADE_2NDARY	: IS_WEAPON_ACTIVE "mainhand" "FragGrenade"
//		ATTACK_RIFLE_2NDARY		: IS_WEAPON_ACTIVE "mainhand" "MP40"

//		ATTACK_RIFLE_2NDARY		: IS_WEAPONCLASS_READY_TO_FIRE "mainhand" "rifle" "secondary"

		CHARGE_ATTACK_GRENADE_SECONDARY	: IS_WEAPONCLASS_READY_TO_FIRE "mainhand" "grenade" "secondary"

		PUT_AWAY_ITEM			: IS_WEAPON_ACTIVE "mainhand" "Spy Camera"
		PUT_AWAY_ITEM			: IS_WEAPON_ACTIVE "mainhand" "Binoculars"
	
//		STAND					: IS_WEAPON_ACTIVE "Error"
//		STAND					: !ATTACK_PRIMARY

		STAND					: default
	}
}

// Pistol whip for silent kills
state ATTACK_PISTOL_SECONDARY
{
	movetype legs

	entrycommands
	{
		viewmodelanim fire_secondary 1
	}

	action
	{
		pistol_butt	: default
	}
	
	states
	{
		STAND	 	: KILLED
		
		STAND	 	: ANIMDONE_TORSO
	}
}

// put away the item and pull out the last active weapon
state PUT_AWAY_ITEM
{
	entrycommands
	{
//		deactivateweapon righthand
		commanddelay 0.05 uselast
	}

	states
	{
		STAND		: default
	}
	
//	exitcommands
//	{
//		uselast
//	}
}


//==============================================================================
//==============================================================================
//
// Primary Charge Up Attacks (grenades)
//
//==============================================================================

state CHARGE_ATTACK_GRENADE
{
	movetype legs

	entrycommands
	{
		viewmodelanim charge
	}
	
	action
	{
		steilhandgranate_crouch_charge	: IS_WEAPON_ACTIVE "mainhand" "Stielhandgranate" POSITION_TYPE "crouching"
		steilhandgranate_stand_charge	: IS_WEAPON_ACTIVE "mainhand" "Stielhandgranate"
	
		grenade_crouch_charge			: POSITION_TYPE "crouching"
		grenade_stand_charge			: default
	}

	states
	{
//		RELEASE_ATTACK_GRENADE	: PAIN	// This would make the player 
										// drop a grenade when he gets hit
//		RELEASE_ATTACK_GRENADE	: KILLED
		RELEASE_KILLED_FRAG		: KILLED
		RELEASE_ATTACK_GRENADE	: !ATTACK_PRIMARY MIN_CHARGE_TIME_MET "mainhand"
	}
}

state RELEASE_ATTACK_GRENADE
{
	movetype legs

	entrycommands
	{
		viewmodelanim fire
	}

	action
	{
		steilhandgranate_crouch_fire	: IS_WEAPON_ACTIVE "mainhand" "Stielhandgranate" POSITION_TYPE "crouching"
		steilhandgranate_stand_fire		: IS_WEAPON_ACTIVE "mainhand" "Stielhandgranate"
	
		grenade_crouch_fire				: POSITION_TYPE "crouching"
		grenade_stand_fire				: default
	}

	states
	{
		RELEASE_KILLED_FRAG : KILLED MIN_CHARGE_TIME_MET "mainhand" // killed before the grenade was released
		STAND	 			: KILLED

		STAND 				: ANIMDONE_TORSO
	}
}

state CHARGE_ATTACK_GRENADE_SECONDARY
{
	movetype legs

	entrycommands
	{
		viewmodelanim charge
	}
	
	action
	{
		steilhandgranate_crouch_charge_secondary	: IS_WEAPON_ACTIVE "mainhand" "Stielhandgranate" POSITION_TYPE "crouching"
		steilhandgranate_stand_charge_secondary		: IS_WEAPON_ACTIVE "mainhand" "Stielhandgranate"
	
		grenade_crouch_charge_secondary				: POSITION_TYPE "crouching"
		grenade_stand_charge_secondary				: default
	}

	states
	{
//		RELEASE_ATTACK_GRENADE_SECONDARY		: PAIN	// This would make the player 
														// drop a grenade when he gets hit
//		RELEASE_ATTACK_GRENADE_SECONDARY		: KILLED
		RELEASE_KILLED_FRAG						: KILLED
		RELEASE_ATTACK_GRENADE_SECONDARY		: !ATTACK_SECONDARY MIN_CHARGE_TIME_MET "mainhand"
	}
}

state RELEASE_ATTACK_GRENADE_SECONDARY
{
	movetype legs

	entrycommands
	{
		viewmodelanim fire
	}

	action
	{
		steilhandgranate_crouch_fire_secondary	: IS_WEAPON_ACTIVE "mainhand" "Stielhandgranate" POSITION_TYPE "crouching"
		steilhandgranate_stand_fire_secondary	: IS_WEAPON_ACTIVE "mainhand" "Stielhandgranate"
	
		grenade_crouch_fire_secondary			: POSITION_TYPE "crouching"
		grenade_stand_fire_secondary			: default
	}

	states
	{
		RELEASE_KILLED_FRAG : KILLED MIN_CHARGE_TIME_MET "mainhand" // killed before the grenade was released
		STAND	 			: KILLED

		STAND 				: ANIMDONE_TORSO
	}
}

// killed while charging a frag grenade
state RELEASE_KILLED_FRAG
{
	entrycommands
	{
		charge mainhand secondary // prep to drop the grenade
		releasefire mainhand secondary // drop the grenade
	}
	
	states
	{
		STAND	: default
	}
}


//==============================================================================
//==============================================================================
//
// PUTAWAY
//
//==============================================================================

state PUTAWAY_MAIN
{
//	movetype legs

	entrycommands
	{
		zoomoff
		viewmodelanim putaway
	}

	states
	{
		// don't go through the putaway anim if 
		// we're switching to another weapon
		// only do if g_immediateswitch is set
		PUTAWAY_SKIPANIM	: IMMEDIATE_SWITCH NEW_WEAPON
	
		PUTAWAY_PISTOL		: IS_WEAPONCLASS_ACTIVE "mainhand" "pistol"
		PUTAWAY_RIFLE		: IS_WEAPONCLASS_ACTIVE "mainhand" "rifle"
		PUTAWAY_GRENADE		: IS_WEAPONCLASS_ACTIVE "mainhand" "grenade"
		PUTAWAY_SMG			: IS_WEAPONCLASS_ACTIVE "mainhand" "smg"
		PUTAWAY_MG			: IS_WEAPONCLASS_ACTIVE "mainhand" "mg"
//		PUTAWAY_PISTOL		: IS_WEAPONCLASS_ACTIVE "mainhand" "item" // hold all items like a pistol for now
		PUTAWAY_HEAVY		: IS_WEAPONCLASS_ACTIVE "mainhand" "heavy"

		// Catchall at the end		
//		PUTAWAY_RIFLE		: default
		PUTAWAY_NOANIM		: default
	}
}

// called when we want to skip the putaway anim
state PUTAWAY_SKIPANIM
{
	entrycommands
	{
		deactivateweapon righthand
	}
	
	states
	{
		RAISE_WEAPON	: default
	}
}

state PUTAWAY_NOANIM
{
	entrycommands
	{
		deactivateweapon righthand
	}

	states
	{
		RAISE_WEAPON	: NEW_WEAPON
		STAND			: default
	}
}

state PUTAWAY_PISTOL
{
//	movetype legs
	
	action
	{
		pistol_crouch_lower	: POSITION_TYPE "crouching"
		pistol_stand_lower	: default
	}
	legs
	{
		pistol_stand_idle	: ON_LADDER
	}
	
	states
	{
		STAND	 			: KILLED
		
		GET_ON_LADDER		: ANIMDONE_TORSO ON_LADDER
		STAND	 			: ANIMDONE_TORSO
	}
}

state PUTAWAY_RIFLE
{
//	movetype legs
	
	action
	{
		rifle_crouch_lower	: POSITION_TYPE "crouching"
		rifle_stand_lower	: default
	}
	legs
	{
		rifle_stand_idle	: ON_LADDER
	}
	
	states
	{
		STAND	 			: KILLED
		
		GET_ON_LADDER		: ANIMDONE_TORSO ON_LADDER
		STAND	 			: ANIMDONE_TORSO
	}
}

state PUTAWAY_SMG
{
//	movetype legs
	
	action
	{
		mp40_crouch_lower	: IS_WEAPON_ACTIVE "mainhand" "MP40" POSITION_TYPE "crouching"
		mp40_stand_lower	: IS_WEAPON_ACTIVE "mainhand" "MP40"

		smg_crouch_lower	: POSITION_TYPE "crouching"
		smg_stand_lower		: default
	}
	legs
	{
		mp40_stand_idle		: IS_WEAPON_ACTIVE "mainhand" "MP40" ON_LADDER

		smg_stand_idle		: ON_LADDER
	}
	
	states
	{
		STAND	 			: KILLED
		
		GET_ON_LADDER		: ANIMDONE_TORSO ON_LADDER
		STAND	 			: ANIMDONE_TORSO
	}
}

state PUTAWAY_MG
{
//	movetype legs
	
	action
	{
		mp44_crouch_lower	: IS_WEAPON_ACTIVE "mainhand" "StG 44" POSITION_TYPE "crouching"
		mp44_stand_lower	: IS_WEAPON_ACTIVE "mainhand" "StG 44"

		mg_crouch_lower		: POSITION_TYPE "crouching"
		mg_stand_lower		: default
	}
	legs
	{
		mp44_stand_idle		: IS_WEAPON_ACTIVE "mainhand" "StG 44" ON_LADDER
	
		mg_stand_idle		: ON_LADDER
	}
	
	states
	{
		STAND	 			: KILLED
		
		GET_ON_LADDER		: ANIMDONE_TORSO ON_LADDER
		STAND	 			: ANIMDONE_TORSO
	}
}

state PUTAWAY_GRENADE
{
//	movetype legs
	
	action
	{
		steilhandgranate_crouch_lower	: IS_WEAPON_ACTIVE "mainhand" "Stielhandgranate" POSITION_TYPE "crouching"
		steilhandgranate_stand_lower	: IS_WEAPON_ACTIVE "mainhand" "Stielhandgranate"
	
		grenade_crouch_lower			: POSITION_TYPE "crouching"
		grenade_stand_lower				: default
	}
	legs
	{
		steilhandgranate_stand_idle		: IS_WEAPON_ACTIVE "mainhand" "Stielhandgranate"
		
		grenade_stand_idle				: ON_LADDER
	}
	
	states
	{
		STAND	 				: KILLED
		
		GET_ON_LADDER			: ANIMDONE_TORSO ON_LADDER
		STAND	 				: ANIMDONE_TORSO
	}
}

state PUTAWAY_HEAVY
{
//	movetype legs
	
	action
	{
//		shotgun_crouch_lower	: POSITION_TYPE "crouching" IS_WEAPON_ACTIVE "mainhand" "Shotgun"
//		shotgun_stand_lower		: IS_NEW_WEAPON "mainhand" "Shotgun"
		shotgun_crouch_lower	: POSITION_TYPE "crouching" IS_WEAPON_ACTIVE "mainhand" "Shotgun"
		shotgun_stand_lower		: IS_WEAPON_ACTIVE "mainhand" "Shotgun"
		
		bazooka_crouch_lower	: POSITION_TYPE "crouching"
		bazooka_stand_lower		: default
	}
	legs
	{
		shotgun_stand_idle		: ON_LADDER IS_WEAPON_ACTIVE "mainhand" "Shotgun"
		
		bazooka_stand_idle		: ON_LADDER
	}
	
	states
	{
		STAND	 				: KILLED
		
		GET_ON_LADDER			: ANIMDONE_TORSO ON_LADDER
		STAND	 				: ANIMDONE_TORSO
	}
}

//==============================================================================
//==============================================================================
//
// RAISE_WEAPON
//
//==============================================================================

state RAISE_WEAPON
{
	movetype legs

	entrycommands
	{
		viewmodelanim pullout

		// just to make sure nothing funky's 
		// attached that shouldn't be.
		correctweaponattachments
	}

	states
	{
		RAISE_PISTOL		: IS_NEW_WEAPONCLASS "mainhand" "pistol"
		RAISE_RIFLE			: IS_NEW_WEAPONCLASS "mainhand" "rifle"
		RAISE_GRENADE		: IS_NEW_WEAPONCLASS "mainhand" "grenade"
		RAISE_SMG			: IS_NEW_WEAPONCLASS "mainhand" "smg"
		RAISE_MG			: IS_NEW_WEAPONCLASS "mainhand" "mg"
//		RAISE_PISTOL		: IS_NEW_WEAPONCLASS "mainhand" "item" // hold all items like a pistol for now
		RAISE_HEAVY			: IS_NEW_WEAPONCLASS "mainhand" "heavy"
		RAISE_PAPERS		: IS_NEW_WEAPON "mainhand" "Papers"
		
//		RAISE_RIFLE			: default
		RAISE_NOANIM		: default
	}
}

state RAISE_NOANIM
{
	entrycommands
	{
		// delay the activation for a frame so that the player
		// spends at least one frame without a weapon, thus 
		// letting the legs state know that we've switched
		commanddelay 0.05 activatenewweapon
		commanddelay 0.05 forcetorsostate "STAND"
	}

//	states
//	{
//		STAND		: default
//	}
}

state RAISE_RIFLE
{
	movetype legs
	
	action
	{
		rifle_crouch_raise	: POSITION_TYPE "crouching"
		rifle_stand_raise	: default
	}
	
	states
	{
		STAND	 			: KILLED
		
		STAND	 			: ANIMDONE_TORSO
		
		// allow immediate switching to a different weapon instead
		RAISE_ABORT			: +NEW_WEAPON
	}
}

state RAISE_SMG
{
	movetype legs
	
	action
	{
		mp40_crouch_raise	: IS_NEW_WEAPON "mainhand" "MP40" POSITION_TYPE "crouching"
		mp40_stand_raise	: IS_NEW_WEAPON "mainhand" "MP40"

		smg_crouch_raise	: POSITION_TYPE "crouching"
		smg_stand_raise		: default
	}
	
	states
	{
		STAND	 			: KILLED
		
		STAND	 			: ANIMDONE_TORSO
		
		// allow immediate switching to a different weapon instead
		RAISE_ABORT			: +NEW_WEAPON
	}
}

state RAISE_MG
{
	movetype legs
	
	action
	{
		mp44_crouch_raise	: IS_NEW_WEAPON "mainhand" "StG 44" POSITION_TYPE "crouching"
		mp44_stand_raise	: IS_NEW_WEAPON "mainhand" "StG 44"

		mg_crouch_raise	: POSITION_TYPE "crouching"
		mg_stand_raise	: default
	}
	
	states
	{
		STAND	 			: KILLED
		
		STAND	 			: ANIMDONE_TORSO
		
		// allow immediate switching to a different weapon instead
		RAISE_ABORT			: +NEW_WEAPON
	}
}

state RAISE_PISTOL
{
	movetype legs
	
	action
	{
		pistol_crouch_raise	: POSITION_TYPE "crouching"
		pistol_stand_raise	: default
	}
	
	states
	{
		STAND	 			: KILLED
		
		STAND	 			: ANIMDONE_TORSO
		
		// allow immediate switching to a different weapon instead
		RAISE_ABORT			: +NEW_WEAPON
	}
}

state RAISE_GRENADE
{
	movetype legs
	
	action
	{
		steilhandgranate_crouch_raise	: IS_NEW_WEAPON "mainhand" "Stielhandgranate" POSITION_TYPE "crouching"
		steilhandgranate_stand_raise	: IS_NEW_WEAPON "mainhand" "Stielhandgranate"
	
		grenade_crouch_raise	: POSITION_TYPE "crouching"
		grenade_stand_raise		: default
	}
	
	states
	{
		STAND	 			: KILLED
		
		STAND	 			: ANIMDONE_TORSO
		
		// allow immediate switching to a different weapon instead
		RAISE_ABORT			: +NEW_WEAPON
	}
}

state RAISE_HEAVY
{
	movetype legs
	
	action
	{
		shotgun_crouch_raise	: POSITION_TYPE "crouching" IS_NEW_WEAPON "mainhand" "Shotgun"
		shotgun_stand_raise		: IS_NEW_WEAPON "mainhand" "Shotgun"
		
		bazooka_crouch_raise	: POSITION_TYPE "crouching"
		bazooka_stand_raise		: default
	}
	
	states
	{
		STAND	 			: KILLED
		
		STAND	 			: ANIMDONE_TORSO
		
		// allow immediate switching to a different weapon instead
		RAISE_ABORT			: +NEW_WEAPON
	}
}

state RAISE_PAPERS
{
	movetype legs
	
	action
	{
		show_papers	: default
	}
	
	states
	{
		STAND		: KILLED
		
		STAND		: ANIMDONE_TORSO
		
		// allow immediate switching to a different weapon instead
		RAISE_ABORT			: +NEW_WEAPON
	}
}

// This state allows the player to abort the raising 
// of a weapon in favor of a different new weapon.
state RAISE_ABORT
{
	entrycommands
	{
		deactivateweapon righthand
	}
	
	states
	{
		RAISE_WEAPON	: default
	}
}

//==============================================================================
//==============================================================================
//
// Weapon Reloading
//
//==============================================================================

state RELOAD_WEAPON
{
	states
	{
		RELOAD_SPRINGFIELD	: IS_WEAPON_ACTIVE "mainhand" "Springfield '03 Sniper"
		RELOAD_SPRINGFIELD	: IS_WEAPON_ACTIVE "mainhand" "KAR98 - Sniper"
		RELOAD_SHOTGUN		: IS_WEAPON_ACTIVE "mainhand" "Shotgun"

		RELOAD_PISTOL		: IS_WEAPONCLASS_ACTIVE "mainhand" "pistol"
		RELOAD_RIFLE		: IS_WEAPONCLASS_ACTIVE "mainhand" "rifle"
		RELOAD_SMG			: IS_WEAPONCLASS_ACTIVE "mainhand" "smg"
		RELOAD_MG			: IS_WEAPONCLASS_ACTIVE "mainhand" "mg"
		RELOAD_GRENADE		: IS_WEAPONCLASS_ACTIVE "mainhand" "grenade"
//		RELOAD_PISTOL		: IS_WEAPONCLASS_ACTIVE "mainhand" "item" // hold all items like a pistol for now
		RELOAD_HEAVY		: IS_WEAPONCLASS_ACTIVE "mainhand" "heavy"

		RELOAD_RIFLE		: default	
	}
}

state RELOAD_RIFLE
{
	movetype legs

	entrycommands
	{
		zoomoff
		viewmodelanim reload
	}

	action
	{
		kar98_reload		: IS_WEAPON_ACTIVE "mainhand" "Mauser KAR 98K"
		rifle_reload		: default
	}

	states
	{
		STAND	 			: KILLED
		STAND				: ANIMDONE_TORSO
		RELOAD_INTERUPTED	: NEW_WEAPON
		
		RELOAD_INTERUPTED	: IS_USING_VEHICLE
		RELOAD_INTERUPTED	: IS_USING_TURRET
	}
}

state RELOAD_SMG
{
	movetype legs

	entrycommands
	{
		viewmodelanim reload
	}

	action
	{
		mp40_reload			: IS_WEAPON_ACTIVE "mainhand" "MP40"
		smg_reload			: default
	}

	states
	{
		STAND	 			: KILLED
		STAND				: ANIMDONE_TORSO
		RELOAD_INTERUPTED_CORRECT_ATTACHMENTS	: NEW_WEAPON
		
		RELOAD_INTERUPTED_CORRECT_ATTACHMENTS	: IS_USING_VEHICLE
		RELOAD_INTERUPTED_CORRECT_ATTACHMENTS	: IS_USING_TURRET
	}
}

state RELOAD_MG
{
	movetype legs

	entrycommands
	{
		viewmodelanim reload
	}

	action
	{
		mp44_reload			: IS_WEAPON_ACTIVE "mainhand" "StG 44"
		mg_reload			: default
	}

	states
	{
		STAND	 			: KILLED
		STAND				: ANIMDONE_TORSO
		RELOAD_INTERUPTED_CORRECT_ATTACHMENTS	: NEW_WEAPON
		
		RELOAD_INTERUPTED_CORRECT_ATTACHMENTS	: IS_USING_VEHICLE
		RELOAD_INTERUPTED_CORRECT_ATTACHMENTS	: IS_USING_TURRET
	}
}

state RELOAD_PISTOL
{
	movetype legs

	entrycommands
	{
		viewmodelanim reload
	}

	action
	{
		p38_reload			: IS_WEAPON_ACTIVE "mainhand" "Walther P38"
		histandard_reload	: IS_WEAPON_ACTIVE "mainhand" "Hi-Standard Silenced"
		pistol_reload		: default
	}

	states
	{
		STAND	 			: KILLED
		STAND				: ANIMDONE_TORSO
		RELOAD_INTERUPTED_CORRECT_ATTACHMENTS	: NEW_WEAPON
		
		RELOAD_INTERUPTED_CORRECT_ATTACHMENTS	: IS_USING_VEHICLE
		RELOAD_INTERUPTED_CORRECT_ATTACHMENTS	: IS_USING_TURRET
	}
}

state RELOAD_GRENADE
{
	movetype legs

	entrycommands
	{
		viewmodelanim reload
	}

	action
	{
		steilhandgranate_reload	: IS_WEAPON_ACTIVE "mainhand" "Stielhandgranate"
		grenade_reload			: default
	}

	states
	{
		STAND	 				: KILLED
		STAND					: ANIMDONE_TORSO
//		RELOAD_INTERUPTED		: NEW_WEAPON // so quick, don't bother with interupting it
	}
}

state RELOAD_HEAVY
{
	movetype legs

	entrycommands
	{
		viewmodelanim reload
	}

	action
	{
		panzerschreck_reload	: IS_WEAPON_ACTIVE "mainhand" "Panzerschreck"
		bazooka_reload			: default
	}

	states
	{
		STAND	 				: KILLED
		STAND					: ANIMDONE_TORSO
		RELOAD_INTERUPTED_CORRECT_ATTACHMENTS	: NEW_WEAPON
		
		RELOAD_INTERUPTED_CORRECT_ATTACHMENTS	: IS_USING_VEHICLE
		RELOAD_INTERUPTED_CORRECT_ATTACHMENTS	: IS_USING_TURRET
	}
}


// start of reloading the springfield
state RELOAD_SPRINGFIELD
{
	movetype legs

	entrycommands
	{
		zoomoff
		viewmodelanim reload
	}

	action
	{
		springfield_reload_start	: default
	}

	states
	{
		STAND	 					: KILLED
		RELOAD_SPRINGFIELD_SINGLE	: ANIMDONE_TORSO
		RELOAD_INTERUPTED			: NEW_WEAPON
		
		RELOAD_INTERUPTED	: IS_USING_VEHICLE
		RELOAD_INTERUPTED	: IS_USING_TURRET
	}
}

// loads in a single bullet
state RELOAD_SPRINGFIELD_SINGLE
{
	movetype legs
	
	entrycommands
	{
		viewmodelanim reload_single 1
	}
	
	action
	{
		springfield_reload_loop				: default
	}
	
	states
	{
		STAND	 							: KILLED
//		RELOAD_INTERUPTED					: NEW_WEAPON
		RELOAD_SPRINGFIELD_END				: NEW_WEAPON
		
		RELOAD_INTERUPTED_CORRECT_ATTACHMENTS	: IS_USING_VEHICLE
		RELOAD_INTERUPTED_CORRECT_ATTACHMENTS	: IS_USING_TURRET

		// allow early out
		RELOAD_SPRINGFIELD_END				: +ATTACK_PRIMARY HAS_AMMO_IN_CLIP "mainhand" !RELOAD
		RELOAD_SPRINGFIELD_END				: PUTAWAYMAIN

		RELOAD_SPRINGFIELD_CHECK_CONTINUE	: ANIMDONE_TORSO
	}
}

// this check to see if the springfield should continue reloading, or if it's done
state RELOAD_SPRINGFIELD_CHECK_CONTINUE
{
	movetype legs

	entrycommands
	{
		reload // this makes the weapon want to continue reloading if it can
	}
	
	action
	{
		none					: default
	}
	
	states
	{
//		RELOAD_INTERUPTED			: NEW_WEAPON

		RELOAD_SPRINGFIELD_SINGLE	: RELOAD
		RELOAD_SPRINGFIELD_END		: default
	}
}

// this is the end of the shotgun reload sequence
state RELOAD_SPRINGFIELD_END
{
	movetype legs
	
	entrycommands
	{
		viewmodelanim reload_end

		// just in case we interupted a shell reload
//		correctweaponattachments
	}
	
	action
	{
		springfield_reload_end	: default
	}

	states
	{
		STAND	 				: KILLED
		STAND	 				: ANIMDONE_TORSO
//		RELOAD_INTERUPTED		: NEW_WEAPON
	}
}


// start of reloading the shotgun
state RELOAD_SHOTGUN
{
	movetype legs

	entrycommands
	{
		viewmodelanim reload
	}

	action
	{
		shotgun_reload_start	: default
	}

	states
	{
		STAND	 				: KILLED
		RELOAD_SHOTGUN_SINGLE	: ANIMDONE_TORSO
		RELOAD_INTERUPTED		: NEW_WEAPON
		
		RELOAD_INTERUPTED	: IS_USING_VEHICLE
		RELOAD_INTERUPTED	: IS_USING_TURRET
	}
}

// loads in a single shotgun shell
state RELOAD_SHOTGUN_SINGLE
{
	movetype legs
	
	entrycommands
	{
		viewmodelanim reload_single 1
	}
	
	action
	{
		shotgun_reload_loop				: default
	}
	
	states
	{
		STAND	 						: KILLED
//		RELOAD_INTERUPTED				: NEW_WEAPON
		RELOAD_SHOTGUN_END				: NEW_WEAPON
		
		RELOAD_INTERUPTED_CORRECT_ATTACHMENTS	: IS_USING_VEHICLE
		RELOAD_INTERUPTED_CORRECT_ATTACHMENTS	: IS_USING_TURRET

		// allow early out
		RELOAD_SHOTGUN_END				: +ATTACK_PRIMARY HAS_AMMO_IN_CLIP "mainhand" !RELOAD
		RELOAD_SHOTGUN_END				: PUTAWAYMAIN
		
		RELOAD_SHOTGUN_CHECK_CONTINUE	: ANIMDONE_TORSO
	}
}

// this check to see if the shotgun should continue reloading, or if it's done
state RELOAD_SHOTGUN_CHECK_CONTINUE
{
	movetype legs

	entrycommands
	{
		reload // this makes the weapon want to continue reloading if it can
	}
	
	action
	{
		none					: default
	}
	
	states
	{
		RELOAD_SHOTGUN_SINGLE	: RELOAD

//		RELOAD_INTERUPTED		: NEW_WEAPON
		
		RELOAD_SHOTGUN_END		: default
	}
}

// this is the end of the shotgun reload sequence
state RELOAD_SHOTGUN_END
{
	movetype legs
	
	entrycommands
	{
		viewmodelanim reload_end
		
		// just in case we interupted a shell reload
//		correctweaponattachments
	}
	
	action
	{
		shotgun_reload_end	: default
	}

	states
	{
		STAND	 			: KILLED
		STAND	 			: ANIMDONE_TORSO
//		RELOAD_INTERUPTED	: NEW_WEAPON
	}
}

state RELOAD_INTERUPTED
{
	states
	{
		STAND	: default
	}
}

state RELOAD_INTERUPTED_CORRECT_ATTACHMENTS
{
	entrycommands
	{
		correctweaponattachments
	}
	
	states
	{
		STAND	: default
	}
}

//==============================================================================
//==============================================================================
//
// Pain
//
//==============================================================================

state PAIN
{
	movetype legs

 	entrycommands
	{
		// clear the pain out
		nextpaintime 0.05
	}

	states
	{
		PAIN_SHOTGUN	: IS_WEAPON_ACTIVE "mainhand" "Shotgun"

		PAIN_PISTOL		: IS_WEAPONCLASS_ACTIVE "mainhand" "pistol"
		PAIN_RIFLE		: IS_WEAPONCLASS_ACTIVE "mainhand" "rifle"
		PAIN_SMG		: IS_WEAPONCLASS_ACTIVE "mainhand" "smg"
		PAIN_MG			: IS_WEAPONCLASS_ACTIVE "mainhand" "mg"
		PAIN_GRENADE	: IS_WEAPONCLASS_ACTIVE "mainhand" "grenade"
		PAIN_HEAVY		: IS_WEAPONCLASS_ACTIVE "mainhand" "heavy"

		PAIN_RIFLE		: default	
	}
}

state PAIN_SHOTGUN
{
	action
	{
		shotgun_pain_ducked		: POSITION_TYPE "crouching"
		shotgun_pain			: default
	}

	states
	{
		PAIN_WAIT_TILL_DONE		: default
	}

}

state PAIN_PISTOL
{
	action
	{
		pistol_pain_ducked		: POSITION_TYPE "crouching"
		pistol_pain				: default
	}

	states
	{
		PAIN_WAIT_TILL_DONE		: default
	}
}

state PAIN_RIFLE
{
	action
	{
		rifle_pain_ducked		: POSITION_TYPE "crouching"
		rifle_pain				: default
	}

	states
	{
		PAIN_WAIT_TILL_DONE		: default
	}
}

state PAIN_SMG
{
	action
	{
		smg_pain_ducked			: POSITION_TYPE "crouching"
		smg_pain				: default
	}

	states
	{
		PAIN_WAIT_TILL_DONE		: default
	}
}

state PAIN_MG
{
	action
	{
		mg_pain_ducked		: POSITION_TYPE "crouching"
		mg_pain				: default
	}

	states
	{
		PAIN_WAIT_TILL_DONE		: default
	}
}

state PAIN_GRENADE
{
	action
	{
		mg_pain_ducked		: POSITION_TYPE "crouching"
		mg_pain				: default
	}

	states
	{
		PAIN_WAIT_TILL_DONE		: default
	}
}

state PAIN_HEAVY
{
	action
	{
		mg_pain_ducked		: POSITION_TYPE "crouching"
		mg_pain				: default
	}

	states
	{
		PAIN_WAIT_TILL_DONE		: default
	}
}

state PAIN_WAIT_TILL_DONE
{
	states
	{
		KILLED							: KILLED
		PAIN							: PAIN

		// allow the player to interupt a pain animation with an attack
		CHECK_PRIMARY_ATTACK_SEMIAUTO	: +ATTACK_PRIMARY IS_WEAPON_SEMIAUTO "mainhand" IS_WEAPON_READY_TO_FIRE "mainhand"
		CHECK_PRIMARY_ATTACK_FULLAUTO	: ATTACK_PRIMARY !IS_WEAPON_SEMIAUTO "mainhand" IS_WEAPON_READY_TO_FIRE "mainhand"
		CHECK_SECONDARY_ATTACK			: +ATTACK_SECONDARY
		
		STAND							: ANIMDONE_TORSO
	}
}

//==============================================================================
//
// Death
//
//==============================================================================

state KILLED
{
	movetype anim

	entrycommands
	{
		nextpaintime -1 // allow all pain calls to work properly for death anim selection
	}

	states
	{
		EXPLOSION_KILLED	: PAIN_TYPE "explosion"
		EXPLOSION_KILLED	: PAIN_TYPE "grenade"
		EXPLOSION_KILLED	: PAIN_TYPE "rocket"
		KILLED_GENERIC		: default
	}
}

state KILLED_GENERIC
{
	states
	{
		KILLED_RUNNING		: FORWARD_VELOCITY "130"
		KILLED_CROUCHING	: POSITION_TYPE "crouching"
		KILLED_STANDING		: default
	}
}

state KILLED_RUNNING
{
	action
	{
		death_knockedup		: PAIN_DIRECTION "front" PAIN_THRESHOLD "50" CHANCE "30"
		death_chest			: PAIN_DIRECTION "front" PAIN_THRESHOLD "50"
		death_run			: default
	}
	
	states
	{
		KILLED_WAIT_FOR_DONE	: default
	}
}

state KILLED_CROUCHING
{
	action
	{
		death_frontcrouch	: PAIN_DIRECTION "rear"
		rifle_pain_kneestodeath : default
	}

	states
	{
		KILLED_WAIT_FOR_DONE	: default
	}
}

state KILLED_STANDING
{
	states
	{
		KILLED_LOWER_TORSO	: PAIN_LOCATION "pelvis"
		KILLED_LOWER_TORSO	: PAIN_LOCATION "torso_lower"
		KILLED_UPPER_TORSO	: PAIN_LOCATION "torso_mid"
		KILLED_UPPER_TORSO	: PAIN_LOCATION "torso_upper"
		KILLED_NECK			: PAIN_LOCATION "neck"
		KILLED_HEAD			: PAIN_LOCATION "head"
		KILLED_HEAD			: PAIN_LOCATION "helmet"
		KILLED_RIGHT_ARM	: PAIN_LOCATION "r_arm_upper"
		KILLED_RIGHT_ARM	: PAIN_LOCATION "r_arm_lower"
		KILLED_RIGHT_ARM	: PAIN_LOCATION "r_hand"
		KILLED_LEFT_ARM		: PAIN_LOCATION "l_arm_upper"
		KILLED_LEFT_ARM		: PAIN_LOCATION "l_arm_lower"
		KILLED_LEFT_ARM		: PAIN_LOCATION "l_hand"
		KILLED_LEG			: PAIN_LOCATION "r_leg_upper"
		KILLED_LEG			: PAIN_LOCATION "r_leg_lower"
		KILLED_LEG			: PAIN_LOCATION "r_foot"
		KILLED_LEG			: PAIN_LOCATION "l_leg_upper"
		KILLED_LEG			: PAIN_LOCATION "l_leg_lower"
		KILLED_LEG			: PAIN_LOCATION "l_foot"

		KILLED_UPPER_TORSO	: default
	}
}

state KILLED_LOWER_TORSO
{
	action
	{
		death_back			: PAIN_DIRECTION "front" CHANCE "60"
		death_knockedup		: PAIN_DIRECTION "rear" CHANCE "35"
		death_run			: PAIN_DIRECTION "rear" CHANCE "70"
		death_crotch		: CHANCE "60"
		death_chest			: default
	}

	states
	{
		KILLED_WAIT_FOR_DONE	: default
	}
}

state KILLED_UPPER_TORSO
{
	action
	{
		death_knockedup		: PAIN_DIRECTION "front" CHANCE "20"
		death_back			: PAIN_DIRECTION "front" CHANCE "60"
		death_run			: PAIN_DIRECTION "rear" CHANCE "40"
		death_frontchoke	: CHANCE "30"
		death_shoot			: CHANCE "60"
		death_chest			: default
	}

	states
	{
		KILLED_WAIT_FOR_DONE	: default
	}
}

state KILLED_NECK
{
	action
	{
		death_frontchoke	: CHANCE "50"
		death_choke			: default
	}

	states
	{
		KILLED_WAIT_FOR_DONE	: default
	}
}

state KILLED_HEAD
{
	action
	{
		death_back			: PAIN_DIRECTION "front" CHANCE "50"
		death_head_flyforward : PAIN_DIRECTION "rear" CHANCE "30"
		death_headpistol	: CHANCE "20"
		death_twist			: CHANCE "25"
		death_shoot			: CHANCE "33"
		death_fall_to_knees	: CHANCE "50"
		death_collapse		: default
	}

	states
	{
		KILLED_WAIT_FOR_DONE	: default
	}
}

state KILLED_RIGHT_ARM
{
	action
	{
		death_twist			: PAIN_DIRECTION "rear" CHANCE "50"
		death_fall_back		: CHANCE "30"
		death_shoot			: CHANCE "50"
		death_chest			: default
	}

	states
	{
		KILLED_WAIT_FOR_DONE	: default
	}
}

state KILLED_LEFT_ARM
{
	action
	{
		death_twist			: PAIN_DIRECTION "front" CHANCE "50"
		death_fall_back		: CHANCE "30"
		death_shoot			: CHANCE "50"
		death_chest			: default
	}

	states
	{
		KILLED_WAIT_FOR_DONE	: default
	}
}

state KILLED_LEG
{
	action
	{
		death_knockedup	: PAIN_DIRECTION "rear" CHANCE "50"
		death_fall_back		: CHANCE "25"
		death_shoot			: CHANCE "33"
		death_fall_to_knees	: CHANCE "50"
		death_chest			: default
	}

	states
	{
		KILLED_WAIT_FOR_DONE	: default
	}
}














//state KILLED_GENERIC
//{
//	action
//	{
//		death_crouch	: POSITION_TYPE "crouching"
//		
//		death 			: default
//	}
//	
//	states
//	{
//		KILLED_WAIT_FOR_DONE	: default
//	}
//}

state EXPLOSION_KILLED
{
	action
	{
		death_explosion_large	: PAIN_THRESHOLD "150"
//		death_explosion_small	: PAIN_THRESHOLD "130"
		
		// directional death animations of in middle damage range
//		death_explosion_front	: PAIN_DIRECTION "rear"
		death_explosion_back	: PAIN_DIRECTION "front"
		death_explosion_left	: PAIN_DIRECTION "left"
		death_explosion_right	: PAIN_DIRECTION "right"
		
		death_explosion_small	: default // a just-in-case catch-all
	}
	
	states
	{
		KILLED_WAIT_FOR_DONE	: default
	}
}

state KILLED_WAIT_FOR_DONE
{
	states
	{
		KILLED_DONE		: ANIMDONE_TORSO
	}

	exitcommands
	{
		dead	// Frees up resources and tells everyone I'm dead.
	}
}

state KILLED_DONE
{
	movetype anim
}


//==============================================================================
//==============================================================================
//
// Ladder Climbing
//
//==============================================================================

state USE_LADDER
{
	movetype climbwall
	
	entrycommands
	{
		safeholster 1 // put our weapon away
		attachtoladder // gets the ladder we're going to be climbing
	}
	
//	action
//	{
//		none : default
//	}
	
	states 
	{
//		PUTAWAY_MAIN		: PUTAWAYMAIN
		LADDER_PUTAWAY		: PUTAWAYMAIN
		LATCH_ONTO_LADDER	: !ONGROUND 
		GET_ON_LADDER		: default
	}
}

state LADDER_PUTAWAY
{
	entrycommands
	{
		deactivateweapon righthand
	}
	
	states
	{
		LATCH_ONTO_LADDER	: !ONGROUND 
		GET_ON_LADDER		: default
	}
}

state GET_ON_LADDER
{
	movetype climbwall


	// these entry commands ensure that the player 
	// will be standing when he gets off the ladder
	entrycommands
	{
		modheight "stand"
		movementstealth "1.0"
		moveposflags "standing"
	}

	action
	{
		ladder_geton_top		: AT_TOP_OF_LADDER
		ladder_geton_bottom		: default
	}
	
	states
	{
//		STAND					: KILLED
		FINISHED_GET_OFF_LADDER	: KILLED
	
		// we go to LADDER_LEFT because the left hand will be up once we're on
		LADDER_IDLE_LEFT		: ANIMDONE_TORSO
	}
}

// This is for when the player grabs the ladder while not on the ground
state LATCH_ONTO_LADDER
{
	movetype climbwall

	// these entry commands ensure that the player 
	// will be standing when he gets off the ladder
	entrycommands
	{
		modheight "stand"
		movementstealth "1.0"
		moveposflags "standing"
		tweakladderpos // make sure we're positioned properly on the ladder
	}
	
	states
	{
//		LADDER_IDLE_LEFT		: default
		LADDER_DOWN_LEFT		: default
	}
}

state GET_OFF_LADDER_TOP
{
	movetype climbwall
	
	action
	{
		ladder_getoff_top		: default
	}
	
	states
	{
		FINISHED_GET_OFF_LADDER	: KILLED
		
		FINISHED_GET_OFF_LADDER	: ANIMDONE_TORSO
	}
}

state GET_OFF_LADDER_BOTTOM
{
	movetype climbwall
	
	action
	{
		ladder_getoff_bottom	: default
	}
	
	states
	{
		FINISHED_GET_OFF_LADDER	: KILLED
	
		FINISHED_GET_OFF_LADDER	: ANIMDONE_TORSO
	}
}

state FINISHED_GET_OFF_LADDER
{
	movetype legs
	
	entrycommands
	{
		unattachfromladder
		safeholster 0 // pull weapon back out if we put it away to get on the ladder
	}

	states
	{
		STAND					: default
	}
}

// same as FINISHED_GET_OFF_LADDER, except that the player is jumping off
state JUMP_OFF_LADDER
{
	movetype legs
	
	entrycommands
	{
		unattachfromladder
		safeholster 0 // pull weapon back out if we put it away to get on the ladder
		jumpxy -70 0 150
	}

	states
	{
		STAND			: default
	}
}

// idling on a ladder with the left hand high
state LADDER_IDLE_LEFT
{
	movetype climbwall

	entrycommands
	{
//		viewmodelanim idle
		tweakladderpos // make sure we're positioned properly on the ladder
	}
	
	action
	{
		ladder_idle_left		: default
	}

	states
	{
//		STAND					: KILLED
		FINISHED_GET_OFF_LADDER	: KILLED
		
		// check for emergency getaway
		JUMP_OFF_LADDER			: +JUMP
		
		PUTAWAY_MAIN			: PUTAWAYMAIN	// just in case the weapon isn't put away yet
		
		// check for getting off top of the ladder
		GET_OFF_LADDER_TOP		: FORWARD LOOKING_UP "-30" CAN_GET_OFF_LADDER_TOP
		GET_OFF_LADDER_TOP		: BACKWARD !LOOKING_UP "-30" CAN_GET_OFF_LADDER_TOP

		// check for getting off bottom of the ladder
		GET_OFF_LADDER_BOTTOM	: FORWARD !LOOKING_UP "-30" CAN_GET_OFF_LADDER_BOTTOM
		GET_OFF_LADDER_BOTTOM	: BACKWARD LOOKING_UP "-30" CAN_GET_OFF_LADDER_BOTTOM
		
		LADDER_UP_RIGHT			: FORWARD LOOKING_UP "-30" CAN_CLIMB_UP_LADDER
		LADDER_UP_RIGHT			: BACKWARD !LOOKING_UP "-30" CAN_CLIMB_UP_LADDER
		
		LADDER_DOWN_LEFT		: FORWARD !LOOKING_UP "-30" CAN_CLIMB_DOWN_LADDER
		LADDER_DOWN_LEFT		: BACKWARD LOOKING_UP "-30" CAN_CLIMB_DOWN_LADDER
		
//		LADDER_SLIDE			: CROUCH
		
//		GET_OFF_LADDER			: +USE
	}
}

// idling on a ladder with the right hand high
state LADDER_IDLE_RIGHT
{
	movetype climbwall
	
	entrycommands
	{
//		viewmodelanim idle
		tweakladderpos // make sure we're positioned properly on the ladder
	}
	
	action
	{
		ladder_idle_right		: default
	}
	
	states
	{
//		STAND					: KILLED
		FINISHED_GET_OFF_LADDER	: KILLED
	
		// check for emergency getaway
		JUMP_OFF_LADDER			: +JUMP
		
		PUTAWAY_MAIN			: PUTAWAYMAIN	// just in case the weapon isn't put away yet
		
		// check for getting off top of the ladder
		GET_OFF_LADDER_TOP		: FORWARD LOOKING_UP "-30" CAN_GET_OFF_LADDER_TOP
		GET_OFF_LADDER_TOP		: BACKWARD !LOOKING_UP "-30" CAN_GET_OFF_LADDER_TOP

		// check for getting off bottom of the ladder
		GET_OFF_LADDER_BOTTOM	: FORWARD !LOOKING_UP "-30" CAN_GET_OFF_LADDER_BOTTOM
		GET_OFF_LADDER_BOTTOM	: BACKWARD LOOKING_UP "-30" CAN_GET_OFF_LADDER_BOTTOM
		
		LADDER_UP_LEFT			: FORWARD LOOKING_UP "-30" CAN_CLIMB_UP_LADDER
		LADDER_UP_LEFT			: BACKWARD !LOOKING_UP "-30" CAN_CLIMB_UP_LADDER
		
		LADDER_DOWN_RIGHT		: FORWARD !LOOKING_UP "-30" CAN_CLIMB_DOWN_LADDER
		LADDER_DOWN_RIGHT		: BACKWARD LOOKING_UP "-30" CAN_CLIMB_DOWN_LADDER
		
//		LADDER_SLIDE			: CROUCH

//		GET_OFF_LADDER			: +USE
	}
}

state LADDER_UP_LEFT
{
	movetype climbwall
	
	entrycommands
	{
//		tweakladderpos // make sure we're positioned properly on the ladder
	}
	
	action
	{
		ladder_up_left			: default
	}
	
	states
	{
//		STAND					: KILLED
		FINISHED_GET_OFF_LADDER	: KILLED
		
//		LADDER_SLIDE			: CROUCH
		
		// check for emergency getaway
		JUMP_OFF_LADDER			: +JUMP
		
		LADDER_IDLE_LEFT		: ANIMDONE_TORSO
	}
}

state LADDER_UP_RIGHT
{
	movetype climbwall
	
	entrycommands
	{
//		tweakladderpos // make sure we're positioned properly on the ladder
	}
	
	action
	{
		ladder_up_right			: default
	}
	
	states
	{
//		STAND					: KILLED
		FINISHED_GET_OFF_LADDER	: KILLED
		
//		LADDER_SLIDE			: CROUCH
		
		// check for emergency getaway
		JUMP_OFF_LADDER			: +JUMP
		
		LADDER_IDLE_RIGHT		: ANIMDONE_TORSO
	}
}

state LADDER_DOWN_LEFT
{
	movetype climbwall
	
	entrycommands
	{
//		tweakladderpos // make sure we're positioned properly on the ladder
	}
	
	action
	{
		ladder_down_left		: default
	}
	
	states
	{
//		STAND					: KILLED
		FINISHED_GET_OFF_LADDER	: KILLED
		
//		LADDER_SLIDE			: CROUCH
		
		// check for emergency getaway
		JUMP_OFF_LADDER			: +JUMP
		
		LADDER_IDLE_RIGHT		: ANIMDONE_TORSO
	}
}

state LADDER_DOWN_RIGHT
{
	movetype climbwall
	
	entrycommands
	{
//		tweakladderpos // make sure we're positioned properly on the ladder
	}
	
	action
	{
		ladder_down_right		: default
	}
	
	states
	{
//		STAND					: KILLED
		FINISHED_GET_OFF_LADDER	: KILLED
		
//		LADDER_SLIDE			: CROUCH
		
		// check for emergency getaway
		JUMP_OFF_LADDER			: +JUMP
		
		LADDER_IDLE_LEFT		: ANIMDONE_TORSO
	}
}

state LADDER_SLIDE
{
	movetype climbwall
	
	action
	{
		ladder_slide			: default
	}
	
	states
	{
//		STAND					: KILLED
		FINISHED_GET_OFF_LADDER	: KILLED
		
		// check for emergency getaway
		FINISHED_GET_OFF_LADDER	: +JUMP
		
		FINISHED_GET_OFF_LADDER	: ONGROUND
		LADDER_IDLE_LEFT		: !CROUCH
	}
}

//==============================================================================
//==============================================================================
//
// Generic Use
//
//==============================================================================

state GENERIC_USE
{
	entrycommands
	{
		usestuff
	}

	states
	{
		STAND	: default
	}
}


//==============================================================================
//==============================================================================
//
// Vehicles
//
//==============================================================================

state VEHICLE_PUTAWAY
{
	entrycommands
	{
		deactivateweapon righthand
	}
	
	states
	{
		VEHICLE_IDLE	: default
	}
}

state VEHICLE_START
{
//	movetype anim
	
//	action
//	{
//		vehicle_idle			: default
//	}
	
	states
	{
		VEHICLE_PUTAWAY	: PUTAWAYMAIN	// Basic put weapon away move.
		VEHICLE_IDLE	: default
	}
}

state VEHICLE_IDLE
{
	movetype anim
	
	action
	{
		vehicle_idle	: default
	}
	
	states
	{
		VEHICLE_USE		: +USE
		STAND			: !IS_USING_VEHICLE
	}
}

state VEHICLE_USE
{
	movetype anim

//	entrycommands
//	{
//		usestuff
//	}

	action
	{
		vehicle_idle			: default
	}

	states
	{
		VEHICLE_IDLE	: default
	}
}


//==============================================================================
//==============================================================================
//
// Turrets
//
//==============================================================================

state TURRET_PUTAWAY
{
	entrycommands
	{
		deactivateweapon righthand
	}
	
	states
	{
		TURRET_IDLE		: default
	}
}

state TURRET_START
{
//	movetype anim
	
//	action
//	{
//		turret_idle		: default
//	}
	
	states
	{
		TURRET_PUTAWAY	: PUTAWAYMAIN	// Basic put weapon away move.
		TURRET_IDLE		: default
	}
}

state TURRET_IDLE
{
	movetype anim
	
	action
	{
		turret_idle		: default
	}
	
	states
	{
//		TURRET_USE		: +USE
//		GENERIC_USE		: +USE
		STAND			: !IS_USING_TURRET
	}
}

//state TURRET_USE
//{
//	movetype anim
//
//	entrycommands
//	{
//		usestuff
//	}
//
//	action
//	{
//		turret_idle		: default
//	}
//
//	states
//	{
//		TURRET_IDLE	: default
//	}
//}

// IneQuation: portal maker states
state ATTACK_PORTAL_PRIMARY
{
	movetype legs

	entrycommands
	{
		exec global/portal.scr "primary"
	}

	action
	{
		none				: default
	}

	states
	{
		STAND				: KILLED
		STAND				: ANIMDONE_TORSO
		CHECK_PRIMARY_ATTACK_SEMIAUTO	: +ATTACK_PRIMARY IS_WEAPON_READY_TO_FIRE "mainhand"

		// shortcut to yellow portal creation
		ATTACK_PORTAL_SECONDARY		: +ATTACK_SECONDARY IS_WEAPON_READY_TO_FIRE "mainhand"
	}
}

state ATTACK_PORTAL_SECONDARY
{
	movetype legs

	entrycommands
	{
		exec global/portal.scr "secondary"
	}

	action
	{
		none		: default
	}
	
	states
	{
		STAND	 		: KILLED
		STAND	 		: ANIMDONE_TORSO
		CHECK_SECONDARY_ATTACK	: +ATTACK_SECONDARY IS_WEAPON_READY_TO_FIRE "mainhand"

		// shortcut to blue portal creation
		ATTACK_PORTAL_PRIMARY	: +ATTACK_PRIMARY IS_WEAPON_READY_TO_FIRE "mainhand"
	}
}
