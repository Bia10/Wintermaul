function InitScoreboard() {
    var player_ids = Game.GetAllPlayerIDs();
    
    for (var i = 0; i < player_ids.length; i++) {
        ScoreAdd(player_ids[i])
    }
    ScoreUpdate()
}

function ScoreAdd(id) {
    //add new players to list
    var panel = $.CreatePanel('Panel', $('#ScoreBoard'), String(id));
    panel.BLoadLayout("file://{resources}/layout/custom_game/score_child.xml", false, false);
    return panel;
}

function ScoreUpdate() {
    var player_stats = [];
    var player_ids = Game.GetAllPlayerIDs();
    for (var player_id in player_ids) {
        int_player_id = parseInt(player_id);
        player_stats.push({
            id: player_id,
            name: Players.GetPlayerName(int_player_id),
            score: Players.GetLastHits(int_player_id)
        })
    }

    for (var key in player_stats) {
        player = player_stats[key]
        $("#" + player.id).FindChildTraverse('PlayerName').text = player.name;
        $("#" + player.id).FindChildTraverse('PlayerName').style.color = GameUI.CustomUIConfig().player_colors[ player.id ];
        $("#" + player.id).FindChildTraverse('PlayerKills').text = player.score;
    }

    player_stats.sort(function (obj1, obj2) {return obj2.score - obj1.score;});
    //we might have to reload the entire list, dont know if we can just rearrange items
}

var clicked = false

function BoardVisibility() {
    //Slide in or out
    var btnbox = $("#btnText");
    if (clicked == false) {
        $.GetContextPanel().style.transform = "translatex( 300px)";
        clicked = true;
        btnbox.text = "<";
    } else {
        $.GetContextPanel().style.transform = "translatex( 0px)";
        clicked = false;
        btnbox.text = ">";
    }

}

(function () {
    InitScoreboard()
})();

GameEvents.Subscribe("new_score", ScoreUpdate);
