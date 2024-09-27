var me={token:null,piece_color:null};
var game_status={};
var board={};
var last_update=new Date().getTime();
var timer=null;

$(function(){
    draw_empty_board();
    fill_board();
    $('#stratego_reset').click(reset_board);
    $('#stratego_login').click(login_to_game);
    $('#do_move').click( do_move);
    $('#move_div').hide();
    game_status_update();
    $('#the_move_src').change( update_moves_selector);
    $('#do_move2').click( do_move2);
});

function do_move() {
    var s = $('#the_move').val();

    var a = s.trim().split(/[ ]+/);
    if(a.length!=4) {
        alert('Must give 4 numbers');
        return;
    }
    $.ajax({url: "stratego.php/board/piece/"+a[0]+'/'+a[1],
        method: 'PUT',
        dataType: "json",
        contentType: 'application/json',
        data: JSON.stringify( {x: a[2], y: a[3]/*, token: me.token*/}),
        headers: {"X-Token": me.token},
        success: move_result,
        error: login_error});

}

function move_result(data){
    game_status_update();
    fill_board_by_data(data);
}

function draw_empty_board(p) {
    /*var t = '<table id="stratego_table">';
    for (var i = 10; i > 0; i--) {
        t += '<tr>';
        for (var j = 1; j < 11; j++) {
            t += '<td class="stratego_square" id="square_' + j + '_' + i + '">'
                + j + ',' + i + '</td>';
        }
        t+='</tr>';
    }
    t+='</table>';
    $('#stratego_board').html(t);*/

    //
    if(p!='B') {p='R';}
    var draw_init = {
        'B': {i1:10,i2:0,istep:-1,j1:1,j2:11,jstep:1},
        'R': {i1:1,i2:11,istep:1, j1:10,j2:0,jstep:-1}
    };
    var s=draw_init[p];
    var t='<table id="stratego_table">';
    for(var i=s.i1;i!=s.i2;i+=s.istep) {
        t += '<tr>';
        for(var j=s.j1;j!=s.j2;j+=s.jstep) {
            t += '<td class="stratego_square" id="square_'+j+'_'+i+'">' + j +','+i+'</td>';
        }
        t+='</tr>';
    }
    t+='</table>';

    $('#stratego_board').html(t);
    $('.stratego_square').click(click_on_piece);
    /*
        $('.chess_square').click(click_on_piece);
    */

}

function click_on_piece(e) {
    var o=e.target;
    if(o.tagName!='TD') {o=o.parentNode;}
    if(o.tagName!='TD') {return;}

    var id=o.id;
    var a=id.split(/_/);
    $('#the_move_src').val(a[1]+' ' +a[2]);
    update_moves_selector();
}

function update_moves_selector() {
    $('.stratego_square').removeClass('pmove').removeClass('tomove');
    var s = $('#the_move_src').val();
    var a = s.trim().split(/[ ]+/);
    $('#the_move_dest').html('');
    if(a.length!=2) {
        return;
    }
    var id = '#square_'+ a[0]+'_'+a[1];
    $(id).addClass('tomove');
    for(let i=0;i<board.length;i++) {
        if(board[i].x==a[0] && board[i].y==a[1] && board[i].moves && Array.isArray(board[i].moves)) {
            for(m=0;m<board[i].moves.length;m++) {
                $('#the_move_dest').append('<option value="'+board[i].moves[m].x+' '+board[i].moves[m].y+'">'+board[i].moves[m].x+' '+board[i].moves[m].y+'</option>');
                var id = '#square_'+ board[i].moves[m].x +'_' + board[i].moves[m].y;
                $(id).addClass('pmove');
            }
        }
    }
}

function do_move2() {
    $('#the_move').val($('#the_move_src').val() +' ' + $('#the_move_dest').val());
    $('.chess_square').removeClass('pmove').removeClass('tomove');
    do_move();
}

function fill_board(){
    $.ajax(
        {
            url: "stratego.php/board/",
            headers: {"X-Token": me.token},
            success: fill_board_by_data
        }
    );
}

function reset_board(){
    $.ajax(
        {
            url: "stratego.php/board/",
            headers: {"X-Token": me.token},
            method:'POST',
            success: fill_board_by_data
        }
    );
    $('#move_div').hide();
    $('#game_initializer').show(2000);
}



function fill_board_by_data(data) {

    for (var i = 0; i < data.length; i++) {
        board=data;
        var o = data[i];
        /*var p_color = o.piece_color;*/
        var id = '#square_' + o.x + '_' + o.y;
        var c = (o.piece != null && o.piece_color!=null)?o.piece.slice(0,3) : '';


        var im = (o.piece!=null)?'<img class="piece" src="images/'+c+'.jpg">':'';

        $(id).addClass(o.piece_color+'_piece').removeClass('null_piece').html(im);
        //function gia ta koutakia pou akoma exoun xrwma meta to reset button
        fixMiscolor();
    }
}

function login_to_game() {
    if($('#user_name').val()=='') {
        alert('You have to set a username');
        return;
    }
    var p_color = $('#pcolor').val();
    draw_empty_board(p_color);
    fill_board();

    $.ajax({url: "stratego.php/players/"+p_color,
        method: 'PUT',
        dataType: "json",
        headers: {"X-Token": me.token},
        contentType: 'application/json',
        data: JSON.stringify( {user_name: $('#user_name').val(), piece_color: p_color}),
        success: login_result,
        error: login_error});
}

function login_result(data) {
    me = data[0];
    /*if (me.piece_color==="R"){
        $('.B_piece img').hide();
    }
    else
        $('.R_piece img').hide();*/
    $('#game_initializer').hide();
    //$('.B_piece img').hide();
    update_info();
    game_status_update();
}

function login_error(data,y,z,c) {
    var x = data.responseJSON;
    alert(x.errormesg);
}

function update_info(){
    $('#game_info').html("I am Player: "+me.piece_color+", my name is "+me.user_name +'<br>Token='+me.token+'<br>Game state: '+game_status.status+', '+ game_status.p_turn+' must play now.');
}

function game_status_update() {

   /* clearTimeout(timer);*/
    $.ajax({url: "stratego.php/status/", success: update_status,headers: {"X-Token": me.token} });
}


function update_status(data) {
    last_update=new Date().getTime();
    var game_stat_old = game_status;
    game_status=data[0];
    update_info();
    /*clearTimeout(timer);*/
    if(game_status.p_turn==me.piece_color &&  me.piece_color!=null) {
        x=0;
        // do play
        if(game_stat_old.p_turn!=game_status.p_turn) {
            fill_board();
        }
        $('#move_div').show(1000);
        timer=setTimeout(function() { game_status_update();}, 15000);
    } else {
        // must wait for something
        $('#move_div').hide(1000);
        timer=setTimeout(function() { game_status_update();}, 4000);
    }

}

function fixMiscolor() {
    for (var i = 10; i > 0; i--) {
        for (var j = 1; j < 11; j++) {
            let checkpiece = document.getElementById('square_'+i+'_'+j);
            if((checkpiece.classList.contains("B_piece"))
                && checkpiece.childElementCount<=0){
                checkpiece.classList.remove("B_piece");
            }
            else if((checkpiece.classList.contains("R_piece"))
                && checkpiece.childElementCount<=0){
                checkpiece.classList.remove("R_piece");
            }
        }
    }
}

