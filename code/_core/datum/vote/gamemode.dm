/vote/gamemode //Vote instance
	name = "Gamemode Vote" //The name of the vote. Usually the question.
	options = list() //Just a list of possible choices.
	time_limit = 60 //In seconds.

	var/list/gamemode_name_to_type = list()


/vote/gamemode/New()

	for(var/k in SSgamemode.all_gamemodes)
		var/gamemode/G = k
		var/game_name = initial(G.name)
		options += game_name
		gamemode_name_to_type[game_name] = G

	return ..()


/vote/gamemode/on_result(var/winner,var/list/results)

	if(winner)
		SSgamemode.set_active_gamemode(gamemode_name_to_type[winner])
	else
		broadcast_to_clients(span("danger","Vote failed! Defaulting to horde..."))

	return TRUE