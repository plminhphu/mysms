<?php

class MBot extends Database
{
  public function getFirstBot($phone)
  {
    $sql = "SELECT * FROM `tbl_bot` WHERE `bot_phone`='$phone'";
    return $this->select($sql)[0] ?? null;
  }
  public function getLastBot($net)
  {
    $time=time()-30;
    $sql = "SELECT * FROM `tbl_bot` WHERE (`bot_net` = '$net' OR `bot_net` = 'All') AND `bot_loged` > $time ORDER BY `bot_updated` ASC";
    return $this->select($sql)[0] ?? null;
  }
  public function createBot($phone,$net)
  {
    $time=time();
    $sql = "INSERT INTO `tbl_bot`(`bot_phone`, `bot_net`, `bot_loged`, `bot_sended`, `bot_created`, `bot_updated`) VALUES ('$phone','$net','$time','0','$time','$time')";
    return $this->query($sql) ?? null;
  }
  public function loginBot($phone,$net)
  {
    $time=time();
    $sql = "UPDATE `tbl_bot` SET `bot_loged`='$time',`bot_net`='$net' WHERE `bot_phone`='$phone'";
    return $this->query($sql) ?? null;
  }
  public function addNotifyBot($phone)
  {
    $time=time();
    $sql = "UPDATE `tbl_bot` SET `bot_sended`=(`bot_sended` + 1),`bot_loged`='$time',`bot_updated`='$time' WHERE `bot_phone`='$phone'";
    return $this->query($sql) ?? null;
  }
  public function getALLBot()
  {
    $sql = "SELECT * FROM `tbl_bot` ORDER BY `bot_created` ASC";
    return $this->select($sql) ?? null;
  }
}