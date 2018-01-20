function ScoreUpdate(args){
	//Update info for everyone about kills
}

function ScoreAdd( color, id){
	//add new players to list
	var panel = $.CreatePanel('Panel', $('#Players'), '');
	panel.BLoadLayoutSnippet("Player");
}

function BoardVisibility(){
	//Slide in or out
}

function debug(){
	$.Msg("Debug!"); 
	ScoreAdd();
}

debug(); 
//$.GetContextPanel().SetHasClass("Player", false);