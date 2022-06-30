/obj/projectile/
	name = "Projectile"

	appearance_flags = LONG_GLIDE | PIXEL_SCALE

	var/vel_x = 0 //X velocity, in pixels per decisecond
	var/vel_y = 0 //Y velocity in pixels per decisecond

	//Cosmsetic
	var/pixel_x_float = 0
	var/pixel_y_float = 0

	//Actual
	var/pixel_x_float_real = 0
	var/pixel_y_float_real = 0

	var/atom/owner //Who is the one who shot the weapon?
	var/atom/weapon //What weapon did the projectile come from?
	var/atom/blamed //Who should we blame for the damage?

	var/atom/previous_loc
	var/atom/current_loc

	var/last_loc_x = 0
	var/last_loc_y = 0

	var/shoot_x = 0
	var/shoot_y = 0

	var/inaccuracy_modifier = 1

	mouse_opacity = 0

	layer = LAYER_PROJECTILE

	plane = PLANE_EFFECT

	var/start_time = 0
	var/lifetime = SECONDS_TO_DECISECONDS(10) //Just in case.

	var/turf/start_turf
	var/turf/target_turf
	var/atom/target_atom

	var/hit_target_turf = FALSE
	var/hit_laying = FALSE

	collision_flags = FLAG_COLLISION_NONE
	collision_bullet_flags = FLAG_COLLISION_BULLET_NONE
	var/collision_flags_special = FLAG_COLLISION_NONE //If the projectile is actually a throw item.

	var/obj/effect/temp/impact/impact_effect_turf
	var/obj/effect/temp/impact/impact_effect_movable

	var/bullet_color = "#FFFFFF"

	var/steps_current = 0
	var/steps_allowed = 0

	var/damage_multiplier = 1

	var/obj/effect/temp/muzzleflash/muzzleflash_effect

	var/iff_tag
	var/loyalty_tag
	var/hostile = TRUE //Set to true if this is a hostile projectile. Set to false if it isn't.

	var/rotate_projectile = TRUE

	anchored = TRUE

	var/penetrations_left = 0 //Uwu
	var/list/projectile_blacklist = list()

	throwable = FALSE

	var/can_ricochet = TRUE

	var/debug = FALSE

/obj/projectile/Destroy()
	color = "#000000"
	owner = null
	weapon = null
	blamed = null
	target_atom = null
	target_turf = null
	start_turf = null
	previous_loc = null
	current_loc = null
	projectile_blacklist?.Cut()
	SSprojectiles.all_projectiles -= src
	. = ..()

/obj/projectile/New(var/desired_loc,var/atom/desired_owner,var/atom/desired_weapon,var/desired_vel_x,var/desired_vel_y,var/desired_shoot_x = 0,var/desired_shoot_y = 0, var/turf/desired_turf, var/desired_damage_type, var/desired_target, var/desired_color, var/desired_blamed, var/desired_damage_multiplier=1,var/desired_iff_tag,var/desired_loyalty_tag,var/desired_inaccuracy_modifier=1,var/desired_penetrations_left=0)

	if(!desired_owner)
		log_error("WARNING: PROJECTILE [src.get_debug_name()] DID NOT HAVE AN OWNER!")
		qdel(src)
		return FALSE

	owner = desired_owner
	weapon = desired_weapon
	blamed = desired_blamed ? desired_blamed : owner

	target_atom = desired_target
	target_turf = desired_turf

	if(desired_iff_tag) iff_tag = desired_iff_tag
	if(desired_loyalty_tag) loyalty_tag = desired_loyalty_tag
	if(desired_damage_type) damage_type = desired_damage_type
	if(desired_penetrations_left) penetrations_left = desired_penetrations_left

	damage_multiplier = desired_damage_multiplier

	//This is for the target doll.
	shoot_x = desired_shoot_x
	shoot_y = desired_shoot_y

	start_turf = loc //Used for damage falloff calculations.

	vel_x = desired_vel_x
	vel_y = desired_vel_y

	current_loc = loc
	previous_loc = loc

	last_loc_x = x
	last_loc_y = y

	pixel_x_float = pixel_x
	pixel_y_float = pixel_y

	pixel_x_float_real = pixel_x
	pixel_y_float_real = pixel_y

	bullet_color = desired_color

	color = bullet_color

	inaccuracy_modifier = desired_inaccuracy_modifier

	. = ..()


/obj/projectile/Initialize()

	//Calculate visual bullet offsets.
	var/normal_x = vel_x
	var/normal_y = vel_y
	var/bullet_offset = FLOOR(TILE_SIZE * 0.5, 1)
	if(vel_x || vel_y)
		normal_x *= 1/max(abs(vel_x),abs(vel_y))
		normal_y *= 1/max(abs(vel_x),abs(vel_y))
	pixel_x = (owner.pixel_x - initial(owner.pixel_x)) + (normal_x * bullet_offset)
	pixel_y = (owner.pixel_y - initial(owner.pixel_y)) + (normal_y * bullet_offset)
	pixel_z = owner.pixel_z - initial(owner.pixel_z)

	return ..()

/obj/projectile/Finalize()

	//Muzzleflash Effect
	if(muzzleflash_effect)
		var/obj/effect/temp/muzzleflash/M = new muzzleflash_effect(src.loc)
		M.pixel_x = pixel_x
		M.pixel_y = pixel_y
		M.pixel_z = pixel_z
		var/new_angle = ATAN2(vel_x,vel_y) - 90
		M.transform = turn(M.transform,-new_angle)
		INITIALIZE(M)
		FINALIZE(M)

	SSprojectiles.all_projectiles += src

	return ..()

/obj/projectile/proc/on_enter_tile(var/turf/old_loc,var/turf/new_loc)

	if(debug)
		var/obj/effect/temp/tile/TE = new(new_loc)
		TE.maptext = "[steps_current]"
		TE.alpha = 200

	if(!new_loc)
		log_error("Warning: Projectile didn't have a new loc.")
		on_projectile_hit(src.loc,old_loc,new_loc)
		return FALSE

	if(!old_loc)
		log_error("Warning: Projectile didn't have an old loc.")
		on_projectile_hit(src.loc,old_loc,new_loc)
		return FALSE

	steps_current += 1

	if(old_loc.projectile_should_collide(src,old_loc,new_loc) && on_projectile_hit(old_loc,old_loc,new_loc))
		penetrations_left--
		if(penetrations_left < 0)
			return FALSE

	if(new_loc.projectile_should_collide(src,old_loc,new_loc) && on_projectile_hit(new_loc,old_loc,new_loc))
		penetrations_left--
		if(penetrations_left < 0)
			return FALSE

	//Handle atoms in turf.
	//Take priority of existing targets on a turf before ones that existed before.
	for(var/k in new_loc.contents)
		var/atom/movable/A = k
		if(!A.density)
			continue
		if(A.projectile_should_collide(src,old_loc,new_loc) && on_projectile_hit(A,old_loc,new_loc))
			penetrations_left--
			if(penetrations_left < 0)
				return FALSE

	for(var/k in new_loc.old_living)
		var/mob/living/L = k
		if(!L.density)
			continue
		if(L.mouse_opacity <= 0 || L.dead || L.next_move <= 0 || get_dist(L,src) > 1) //Special exceptions.
			continue
		if(L.projectile_should_collide(src,old_loc,new_loc) && on_projectile_hit(L,old_loc,new_loc))
			penetrations_left--
			if(penetrations_left < 0)
				return FALSE

	if(steps_allowed && steps_allowed <= steps_current)
		on_projectile_hit(new_loc,old_loc,new_loc)
		return FALSE

	if(hit_target_turf && old_loc == target_turf)
		on_projectile_hit(old_loc,old_loc,new_loc)
		return FALSE

	return TRUE //No hits. Do not destroy.

/obj/projectile/proc/update_projectile(var/tick_rate=1)

	if(!isturf(src.loc) || (!vel_x && !vel_y) || lifetime && start_time >= lifetime)
		on_projectile_hit(current_loc ? current_loc : src.loc,null,null)
		return FALSE

	if(!start_time) //First time running.
		var/matrix/M = get_base_transform()
		var/new_angle = -ATAN2(vel_x,vel_y) + 90
		M.Turn(new_angle)
		transform = M
	else
		pixel_x_float += vel_x
		pixel_y_float += vel_y
		pixel_x_float_real += vel_x
		pixel_y_float_real += vel_y

	start_time += TICKS_TO_DECISECONDS(tick_rate)

	//Visual changes here only.
	var/rounded_x = CEILING(pixel_x_float,1)
	var/rounded_y = CEILING(pixel_y_float,1)
	if(pixel_x != rounded_x || pixel_y != rounded_y) //Big enough change to animate.
		if(world.tick_usage < 90 && max(abs(vel_x),abs(vel_y)) < TILE_SIZE*TICKS_TO_SECONDS(SSprojectiles.tick_rate))
			animate(src,pixel_x = rounded_x,pixel_y = rounded_y,time=tick_rate)
		else
			pixel_x = rounded_x
			pixel_y = rounded_y

	var/max_normal = max(abs(vel_x),abs(vel_y))
	var/x_normal = vel_x/max_normal
	var/y_normal = vel_y/max_normal
	var/current_loc_x = x + FLOOR(((TILE_SIZE/2) + pixel_x_float_real + x_normal*TILE_SIZE) / TILE_SIZE, 1) //DON'T REMOVE (TILE_SIZE/2). IT MAKES SENSE.
	var/current_loc_y = y + FLOOR(((TILE_SIZE/2) + pixel_y_float_real + y_normal*TILE_SIZE) / TILE_SIZE, 1) //DON'T REMOVE (TILE_SIZE/2). IT MAKES SENSE.
	if((last_loc_x != current_loc_x) || (last_loc_y != current_loc_y))
		//To coders better than me.
		//There is probably a legitimately better way to handle this.
		//I remember coding another method accidentally before but I don't remember it.
		//If you have any legitimate ideas, hit me up.
		if((last_loc_x != current_loc_x) && (last_loc_y != current_loc_y)) //If both changed at the same time, that's a problem as it is moving in a diaganol.
			if(prob(50)) //There is really no real way to do this.
				pixel_x_float_real -= vel_x
				current_loc_x = x + FLOOR(((TILE_SIZE/2) + pixel_x_float_real + x_normal*TILE_SIZE) / TILE_SIZE, 1) //Copy of above.
			else
				pixel_y_float_real -= vel_y
				current_loc_y = y + FLOOR(((TILE_SIZE/2) + pixel_y_float_real + y_normal*TILE_SIZE) / TILE_SIZE, 1) //Copy of above.
		current_loc = locate(current_loc_x,current_loc_y,z)
		if(!on_enter_tile(previous_loc,current_loc))
			return FALSE
		previous_loc = current_loc
		last_loc_x = current_loc_x
		last_loc_y = current_loc_y

	return TRUE

/obj/projectile/on_projectile_hit(var/atom/hit_atom,var/turf/old_loc,var/turf/new_loc)

	if(projectile_blacklist[hit_atom])
		return FALSE

	projectile_blacklist[hit_atom] = TRUE //Can't damage the same thing twice.

	. = TRUE

	//Richochet code is hard. Spelling it correctly is even harder.
	if(hit_atom && can_ricochet)
		var/list/face_of_impact = get_directional_offsets(old_loc,new_loc)
		var/turf/T = get_turf(hit_atom)
		if(T)
			can_ricochet = FALSE
			start_turf = T
			previous_loc = T
			current_loc = T
			pixel_x_float_real += vel_x
			pixel_y_float_real += vel_y
			vel_x *= 1 - abs(face_of_impact[1])*2
			vel_y *= 1 - abs(face_of_impact[2])*2
			var/max_normal = max(abs(vel_x),abs(vel_y))
			var/x_normal = vel_x/max_normal
			var/y_normal = vel_y/max_normal
			pixel_x_float_real -= x_normal*TILE_SIZE
			pixel_y_float_real -= y_normal*TILE_SIZE
			pixel_x_float = pixel_x_float_real //Resync
			pixel_y_float = pixel_x_float_real //Resync
			pixel_x = CEILING(pixel_x_float,1) //Resync
			pixel_y = CEILING(pixel_y_float,1) //Resync
			if(vel_x <= 0 && vel_y <= 0)
				return FALSE
			var/matrix/M = get_base_transform()
			var/new_angle = -ATAN2(vel_x,vel_y) + 90
			M.Turn(new_angle)
			transform = M
			. = FALSE

	if(damage_type && all_damage_types[damage_type])
		var/damagetype/DT = all_damage_types[damage_type]
		if(owner && !owner.qdeleting && hit_atom.can_be_attacked(owner,weapon,null,DT))
			var/list/params = list()
			params[PARAM_ICON_X] = num2text(shoot_x)
			params[PARAM_ICON_Y] = num2text(shoot_y)

			var/precise = FALSE
			if(is_living(hit_atom))
				var/mob/living/L = hit_atom
				if(L.ai && L.ai.alert_level <= ALERT_LEVEL_NOISE)
					precise = TRUE

			var/atom/object_to_damage = hit_atom.get_object_to_damage(owner,src,damage_type,params,precise,precise,inaccuracy_modifier)

			if(!object_to_damage)
				DT.perform_miss(null,hit_atom,weapon)
				return FALSE

			if(DT.falloff > 0)
				damage_multiplier *= clamp(1 - ((get_dist(hit_atom,start_turf) - DT.falloff)/DT.falloff),0.1,1)

			if(damage_multiplier > 0)
				DT.process_damage(owner,hit_atom,weapon,object_to_damage,blamed,damage_multiplier)
	else
		log_error("Warning: [damage_type] is an invalid damagetype!.")

	if(impact_effect_turf && isturf(hit_atom))
		new impact_effect_turf(hit_atom,SECONDS_TO_DECISECONDS(60),rand(-8,8),rand(-8,8),bullet_color)

	else if(impact_effect_movable && ismovable(hit_atom))
		new impact_effect_movable(get_turf(hit_atom),SECONDS_TO_DECISECONDS(5),0,0,bullet_color)

	weapon.on_projectile_hit(src,hit_atom,old_loc,new_loc)

	return .

/obj/projectile/get_inaccuracy(var/atom/source,var/atom/target,var/inaccuracy_modifier=1)
	if(inaccuracy_modifier <= 0)
		return 0
	if(is_living(source))
		var/mob/living/L = source
		return (1 - L.get_skill_power(SKILL_PRECISION,0,0.5,1))*inaccuracy_modifier*8
	return 0