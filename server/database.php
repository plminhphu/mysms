<?php

class Database {

    public static $connection = NULL;

    public function __construct() {
        try {
            if (!self::$connection) {
                self::$connection = mysqli_connect(DB_HOST, DB_USER, DB_PASS, DB_NAME) ?? false;
                if (self::$connection != false) {
                    mysqli_set_charset(self::$connection, 'utf8');
                } else {
                    echo 'connection false';
                    exit;
                }
            }
        } catch (Exception $e) {
            echo $e;
            exit;
        }
    }

    public function query($query) { 
        if(self::$connection!=null){
            return @mysqli_query(self::$connection, $query);
        }else{
            echo 'query null';
            exit;
        }
    }

    public function select($sql) {
        try {
            $data = $this->query($sql) ?? null;
            $rows = array();
            while ($row = @mysqli_fetch_assoc($data)) {
                $rows[] = $row;
            }
            return $rows;
        } catch (Exception $e) {
            echo 'select null';
            exit;
        }
    }
}
