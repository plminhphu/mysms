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
}