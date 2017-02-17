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
		none : default
	}

	states
	{
		KILLED					: KILLED
		PAIN					: PAIN

		VEHICLE_START			: IS_USING_VEHICLE
		TURRET_START			: IS_USING_TURRET

		// if we're on a ladder, make sure we're climbing the ladder
		LADDER_IDLE_LEFT		: ON_LADDER
	
		USE_LADDER				: ONGROUND +USE AT_LADDER CHECK_HEIGHT "stand"
		// latch onto ladder in mid-air
		USE_LADDER				: +USE AT_LADDER CHECK_HEIGHT "stand" // can also latch onto a ladder in mid-air
		// auto use of ladder when at the bottom (AT_LADDER check is last because it does a trace)
		USE_LADDER				: ONGROUND FORWARD LOOKING_UP "35" !PUTAWAYMAIN !NEW_WEAPON !RELOAD !ATTACK_PRIMARY !ATTACK_SECONDARY AT_LADDER CHECK_HEIGHT "stand"
		// auto use of ladder when at the top (AT_LADDER check is last because it does a trace)
		USE_LADDER				: ONGROUND FORWARD !LOOKING_UP "-35" !PUTAWAYMAIN !NEW_WEAPON !RELOAD !ATTACK_PRIMARY !ATTACK_SECONDARY AT_LADDER CHECK_HEIGHT "stand"

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
	
		FF_FIRE_CHECK			: +ATTACK_PRIMARY
		FF_FIRE_CHECK			: ATTACK_PRIMARY
	}
}

state FF_FIRE_CHECK
{
	movetype legs

	action
	{
		none : default // stop torso animation
	}

	states
	{
		STAND					: KILLED
		STAND					: NEW_WEAPON
		STAND					: !IS_WEAPON_READY_TO_FIRE "mainhand"
		STAND					: !ATTACK_PRIMARY

		FF_AIRSUPPORT				: IS_WEAPONCLASS_READY_TO_FIRE "mainhand" "item"
		FF_FIRE					: default
	}
}

state FF_FIRE
{
	movetype legs

	entrycommands
	{
		exec global/firefighters/input.scr "start"
	}

	exitcommands
	{
		exec global/firefighters/input.scr "stop"
	}
	
	action
	{
		shotgun_crouch_idle		: POSITION_TYPE "crouching"
		shotgun_stand_idle		: default
	}

	states
	{
		STAND							: KILLED
		STAND							: !ATTACK_PRIMARY
		STAND							: ANIMDONE_TORSO !IS_WEAPON_READY_TO_FIRE "mainhand"
	}
}

state FF_AIRSUPPORT
{
	movetype legs

	entrycommands
	{
		weaponcommand mainhand anim fire
		exec global/firefighters/airsupport.scr
	}
	
	states
	{
		STAND							: KILLED
		STAND							: !ATTACK_PRIMARY
		FF_FIRE_CHECK						: +ATTACK_PRIMARY IS_WEAPON_READY_TO_FIRE "mainhand"
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

state PUTAWAY_HEAVY
{
//	movetype legs
	
	action
	{
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
		RAISE_HEAVY			: IS_NEW_WEAPONCLASS "mainhand" "heavy"
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
		PAIN_SHOTGUN		: IS_WEAPON_ACTIVE "mainhand" "Shotgun"

		PAIN_PISTOL		: IS_WEAPONCLASS_ACTIVE "mainhand" "pistol"
		PAIN_RIFLE		: IS_WEAPONCLASS_ACTIVE "mainhand" "rifle"
		PAIN_SMG		: IS_WEAPONCLASS_ACTIVE "mainhand" "smg"
		PAIN_MG			: IS_WEAPONCLASS_ACTIVE "mainhand" "mg"
		PAIN_GRENADE		: IS_WEAPONCLASS_ACTIVE "mainhand" "grenade"
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
		FF_FIRE_CHECK	: +ATTACK_PRIMARY
		FF_FIRE_CHECK	: ATTACK_PRIMARY
		
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
		// make sure we take only fire-inflicted deaths into account
		FF_KILLED_FIRE		: !PAIN_TYPE "none" !PAIN_TYPE "suicide" !PAIN_TYPE "crush" !PAIN_TYPE "crush_every_frame" !PAIN_TYPE "telefrag" !PAIN_TYPE "lava" !PAIN_TYPE "slime" !PAIN_TYPE "falling" !PAIN_TYPE "last_self_inflicted" !PAIN_TYPE "explosion" !PAIN_TYPE "explodewall" !PAIN_TYPE "electric" !PAIN_TYPE "electricwater" !PAIN_TYPE "thrownobject" !PAIN_TYPE "grenade" !PAIN_TYPE "beam" !PAIN_TYPE "rocket" !PAIN_TYPE "impact" !PAIN_TYPE "bullet" !PAIN_TYPE "fast_bullet" !PAIN_TYPE "vehicle" !PAIN_TYPE "flashbang" !PAIN_TYPE "gib" !PAIN_TYPE "impale" !PAIN_TYPE "bash" !PAIN_TYPE "shotgun"
		KILLED_GENERIC		: default
	}
}

state FF_KILLED_FIRE
{
	entrycommands
	{
		exec global/firefighters/input.scr "burnkill"
	}

	states
	{
		KILLED_RUNNING		: FORWARD_VELOCITY "130"
		KILLED_CROUCHING	: POSITION_TYPE "crouching"
		KILLED_STANDING		: default
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

