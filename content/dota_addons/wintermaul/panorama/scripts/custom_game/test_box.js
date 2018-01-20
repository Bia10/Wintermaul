
function SetWaveText(event_data)
{
	var currentNumber = event_data.roundData;
	var current = event_data.currentTitle;
	var next = event_data.nextTitle;
	var currentspecial = event_data.currentSpecial;
	var nextspecial = event_data.nextSpecial;

	var waveNumber = $( "#CurrentWaveNumber" );
	var nextwavetext = $( "#NextWaveText" );
	var currentwavetext = $("#CurrentWaveText");
	var nextwave = $("#NextWave");
	var currentwavetop = $("#CurrentWaveTop"); //Here if needed for later.
	var currentwavebot = $( "#CurrentWaveBot"); //Here if needed for later.

	//$.Msg(event_data.roundData);

//--------------- current wave ---------------
	waveNumber.text = currentNumber;

	if ( currentspecial == "#DOTA_Wintermaul_Round_Element_Air") //Air lvls
	{
		currentwavetext.style.color = "orange";
		//currentwavebot.style.color = "orange";

		currentwavetext.text = ("( Air )" + $.Localize( current ));
	}
	else if(currentspecial == "#DOTA_Wintermaul_Round_Element_Evasion") //Evasion lvls
	{
		currentwavetext.style.color = "teal";
		//currentwavebot.style.color = "blue";

		currentwavetext.text = ("( Evasion )" + $.Localize( current ));
	}
	else if(currentspecial == "#DOTA_Wintermaul_Round_Element_Splitter") //Splitter lvls
	{
		currentwavetext.style.color = "brown";
		//currentwavebot.style.color = "blue";

		currentwavetext.text = ("( Splitter )" + $.Localize( current ));
	}
	else if(currentspecial == "#DOTA_Wintermaul_Round_Element_Haste") //Haste lvls
	{
		currentwavetext.style.color = "blue";
		//currentwavebot.style.color = "blue";

		currentwavetext.text = ("( Haste )" + $.Localize( current ));
	}
	else if(currentspecial == "#DOTA_Wintermaul_Round_Element_Boss") //Boss lvls 
	{
		currentwavetext.style.color = "red";
		//currentwavebot.style.color = "red";

		currentwavetext.text = ("( Boss )" + $.Localize( current ));
	}
	else if(currentspecial == "#DOTA_Wintermaul_Round_Element_Bonus") //Bonus lvls
	{
		currentwavetext.style.color = "yellow";
		//currentwavebot.style.color = "yellow";

		currentwavetext.text = ("( Bonus )" + $.Localize( current ));
	}
	else //normal lvls
	{
		currentwavetext.style.color = "white";
		currentwavebot.style.color = "white";

		currentwavetext.text = $.Localize( current );
	}

//--------------- next wave ---------------
	if (nextspecial == "#DOTA_Wintermaul_Round_Element_Air") //Air lvls
	{
		nextwavetext.style.color = "orange";
		//nextwave.style.color = "orange";

		nextwavetext.text = ("( Air )" + $.Localize( next ));
	}
	else if(nextspecial == "#DOTA_Wintermaul_Round_Element_Evasion") //Evasion lvls
	{
		nextwavetext.style.color = "teal";
		//nextwave.style.color = "blue";

		nextwavetext.text = ("( Evasion )" + $.Localize( next ));
	}
	else if(nextspecial == "#DOTA_Wintermaul_Round_Element_Splitter") //Splitter lvls
	{
		nextwavetext.style.color = "brown";
		//nextwave.style.color = "blue";

		nextwavetext.text = ("( Splitter )" + $.Localize( next ));
	}
	else if(nextspecial == "#DOTA_Wintermaul_Round_Element_Haste") //Splitter lvls
	{
		nextwavetext.style.color = "blue";
		//nextwave.style.color = "blue";

		nextwavetext.text = ("( Haste )" + $.Localize( next ));
	}
	else if(nextspecial == "#DOTA_Wintermaul_Round_Element_Boss") //Boss lvls 
	{
		nextwavetext.style.color = "red";
		//nextwave.style.color = "red";

		nextwavetext.text = ("( Boss )" + $.Localize( next ));
	}
	else if(nextspecial == "#DOTA_Wintermaul_Round_Element_Bonus") //Bonus lvls
	{
		nextwavetext.style.color = "yellow";
		//nextwave.style.color = "yellow";

		nextwavetext.text = ("( Bonus )" + $.Localize( next ));
	}
	else //normal lvls
	{
		nextwavetext.style.color = "white";
		//nextwave.style.color = "white";	

		nextwavetext.text = $.Localize( next );
	}
}

function SetWaveTime(time_data)
{
	var timertext = $( "#TimerText" );
	var timertime = $( "#TimerTime" );
	
	timertext.text = "Next wave will spawn in: ";
	timertime.text = time_data.time_till_round_start;
}

function SetCreepsRemaining(creep_data)
{
	var timertext = $( "#TimerText" );
	var timertime = $( "#TimerTime" );
	
	timertext.text = "Creeps remaining: ";
	timertime.text = creep_data.enemiesremaining + " / " + creep_data.totalenemies;
}

function SetLivesLeft(life_data)
{
	var lifecolor;
	var lifetext = $( "#LifeNumber" );
	lifetext.text = life_data.lives;
	if (Number(lifetext.text) > 20)
	{
		lifecolor = "#ffe5e5";
	}
	else if (Number(lifetext.text) > 10)
	{
		lifecolor = "#ff6666";
	}
	else if (Number(lifetext.text) > 5)
	{
		lifecolor = "#ff3232";
	}
	else
	{
		lifecolor = "#7f0000";
	}
	lifetext.style.color = lifecolor;
}

GameEvents.Subscribe( "wave_creeps_remaining", SetCreepsRemaining);
GameEvents.Subscribe( "wave_time_update", SetWaveTime);
GameEvents.Subscribe( "wave_new_wave", SetWaveText);
GameEvents.Subscribe( "wave_life_update", SetLivesLeft);
GameEvents.Subscribe( "error_building_would_block_paths", function(data) {
	var eventData = { reason: 80, message: "error_building_would_block_paths" };
	GameEvents.SendEventClientSide("dota_hud_error_message", eventData);
});

GameEvents.Subscribe("error_building_site_is_blocked", function(data) {
	var eventData = { reason: 80, message: "error_building_site_is_blocked" };
	GameEvents.SendEventClientSide("dota_hud_error_message", eventData);
});

GameEvents.Subscribe("error_not_enough_gold", function(data) {
	var eventData = { reason: 80, message: "error_not_enough_gold" };
	GameEvents.SendEventClientSide("dota_hud_error_message", eventData);
});

GameEvents.Subscribe("error_minimum_height_condition_exceeded", function(data) {
	var eventData = { reason: 80, message: "error_minimum_height_condition_exceeded" };
	GameEvents.SendEventClientSide("dota_hud_error_message", eventData);
});