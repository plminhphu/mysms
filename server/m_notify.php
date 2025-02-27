<?php

class Notify extends Database
{
  public function getNotify($bot)
  {
    $sql = "SELECT * FROM `tbl_notify` WHERE `notify_stt`=0 AND `notify_bot` = '$bot' ORDER BY `notify_updated` DESC";
    return $this->select($sql)[0] ?? null;
  }
  public function createNotify($phone,$content,$bot)
  {
    $time=time();
    $sql = "INSERT INTO `tbl_notify`(`notify_stt`, `notify_phone`, `notify_bot`, `notify_content`, `notify_created`, `notify_updated`) VALUES ('0','$phone','$bot','$content','$time','$time')";
    return $this->query($sql) ?? null;
  }
  public function setSTTNotify($id,$stt,$time)
  {
    $sql = "UPDATE `tbl_notify` SET `notify_stt`='$stt',`notify_updated`='$time' WHERE `notify_id`=$id";
    return $this->query($sql) ?? null;
  }
  public function getALLNotify()
  {
    $sql = "SELECT * FROM `tbl_notify` ORDER BY `notify_created` DESC LIMIT 1000";
    return $this->select($sql) ?? null;
  }
  public function getNotifyByID($id)
  {
    $sql = "SELECT * FROM `tbl_notify` WHERE `notify_id`='$id' ORDER BY `notify_created` ASC LIMIT 1000";
    return $this->select($sql)[0] ?? null;
  }
  public function getLastNotify()
  {
    $sql = "SELECT * FROM `tbl_notify` WHERE `notify_stt_adm`='0' ORDER BY `notify_id` DESC LIMIT 1";
    return $this->select($sql)[0] ?? null;
  }
  public function setLastNotify($id)
  {
    $sql = "UPDATE `tbl_notify` SET `notify_stt_adm`='1' WHERE `notify_id`=$id";
    return $this->query($sql) ?? null;
  }
}