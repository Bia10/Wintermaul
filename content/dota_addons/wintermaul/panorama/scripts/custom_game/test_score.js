function ScoreUpdate( args){
	//Update info for everyone about kills
	$.Msg("Updating scoreboard:", Players.GetPlayerName(args.id), ": ", Players.GetLastHits(args.id));
	
	$("#"+String(args.id)).FindChildTraverse('PlayerKills').text = Players.GetLastHits(args.id);

}

function ScoreAdd( id ){
	//add new players to list
	var panel = $.CreatePanel('Panel', $('#ScoreBoard'), String(id.id));

	panel.BLoadLayout("file://{resources}/layout/custom_game/score_child.xml",false,false);
	$.Msg(id.id)
	$.Msg("adding ", Players.GetPlayerName(1), ", with color ", GameUI.CustomUIConfig().player_colors[ id.id ], " to scorelist.");

	panel.FindChildTraverse('PlayerName').text = Players.GetPlayerName(id.id);
	panel.FindChildTraverse('PlayerName').style.color = GameUI.CustomUIConfig().player_colors[ id.id ];
	panel.FindChildTraverse('PlayerKills').text = Players.GetLastHits(id.id);

	panel.name = Players.GetPlayerName(id.id);

	return panel;
}

GameEvents.Subscribe( "new_player", ScoreAdd);
GameEvents.Subscribe( "new_score", ScoreUpdate); 

var clicked = false 
function BoardVisibility(){
	//Slide in or out
	var btnbox = $("#btnText");
	if (clicked == false){
		$.GetContextPanel().style.transform = "translatex( 300px)";
		clicked = true;
		btnbox.text = "<";
	} else {
		$.GetContextPanel().style.transform = "translatex( 0px)";
		clicked = false;
		btnbox.text = ">";
	}
}