function ScoreUpdate(args){
	//Update info for everyone about kills
}

function ScoreAdd( color, id){
	//add new players to list
	var panel = $.CreatePanel('Panel', $('#Players'), '');
	panel.BLoadLayoutSnippet("Player");
}

var clicked = false 
function BoardVisibility(){
	//Slide in or out
	if (clicked == false){
		$.GetContextPanel().style.transform = "translatex( 300px)";
		clicked = true;
	} else {
		$.GetContextPanel().style.transform = "translatex( 0px)";
		clicked = false;
	}
}

function debug(){
	$.Msg("Debug!"); 
	ScoreAdd();
}

debug(); 
//$.GetContextPanel().SetHasClass("Player", false);