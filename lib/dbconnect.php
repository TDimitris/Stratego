<?php
$host='localhost';
//$usershost='users.iee.ihu.gr';
$db = 'stratego';

require_once "db_upass.php";


$user = $DB_USER;
$pass = $DB_PASS;

$usersdb_user = $USERSDB_USER;
$usersdb_pass = $USERSDB_PASS;


if(gethostname()=='users.iee.ihu.gr') {
    $mysqli = new mysqli($host, $usersdb_user, $usersdb_pass, $db,null,'/home/student/it/2018/it185300/mysql/run/mysql.sock');
} else {
    $pass=null;
    $mysqli = new mysqli($host, $user, $pass, $db);

}

if ($mysqli->connect_errno) {
    echo "Failed to connect to MySQL: (" .
        $mysqli->connect_errno . ") " . $mysqli->connect_error;
}?>


