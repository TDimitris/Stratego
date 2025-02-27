<?php

require_once "../lib/game.php";
function handle_user($method, $b, $input){
    if($method=='GET'){
        show_user($b);
    } else if($method=='PUT'){
        set_user($b,$input);
    }
}

function show_user($b) {
    global $mysqli;
    $sql = 'select user_name,piece_color from players where piece_color=?';
    $st = $mysqli->prepare($sql);
    $st->bind_param('s',$b);
    $st->execute();
    $res = $st->get_result();
    header('Content-type: application/json');
    print json_encode($res->fetch_all(MYSQLI_ASSOC), JSON_PRETTY_PRINT);
}

function set_user($b,$input){
        //print_r($input);
        if(!isset($input['user_name']) || $input['user_name']=='') {
            header("HTTP/1.1 400 Bad Request");
            print json_encode(['errormesg'=>"No username given."]);
            exit;
        }
        $user_name=$input['user_name'];
        global $mysqli;

        $sql = 'select count(*) as c from players where piece_color=? and user_name is not null';
        $st = $mysqli->prepare($sql);
        $st->bind_param('s',$b);
        $st->execute();
        $res = $st->get_result();
        $r = $res->fetch_all(MYSQLI_ASSOC);
        if($r[0]['c']>0) {
            header("HTTP/1.1 400 Bad Request");
            print json_encode(['errormesg'=>"Player $b is already set. Please select another color."]);
            exit;
        }
        $sql = 'update players set user_name=?, token=md5(CONCAT( ?, NOW()))  where piece_color=?';
        $st2 = $mysqli->prepare($sql);
        $st2->bind_param('sss',$user_name,$user_name,$b);
        $st2->execute();



        update_game_status();
        $sql = 'select * from players where piece_color=?';
        $st = $mysqli->prepare($sql);
        $st->bind_param('s',$b);
        $st->execute();
        $res = $st->get_result();
        header('Content-type: application/json');
        print json_encode($res->fetch_all(MYSQLI_ASSOC), JSON_PRETTY_PRINT);



}

function current_color($token) {

    global $mysqli;
    if($token==null) {return(null);}
    $sql = 'select * from players where token=?';
    $st = $mysqli->prepare($sql);
    $st->bind_param('s',$token);
    $st->execute();
    $res = $st->get_result();
    if($row=$res->fetch_assoc()) {
        return($row['piece_color']);
    }
    return(null);
}

?>
