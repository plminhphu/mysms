<?php

define('DB_HOST', 'localhost');
define('DB_USER', '');
define('DB_PASS', '');
define('DB_NAME', '');
define('DEFAULT_ACCESS_TOKEN', 'hpro24hcredit.vn');
define('DEFAULT_NET_LIST', 'Viettel,Mobiphone,Vinaphone,Vietnammobille,Gmobille');
define('LIST_VIETTEL', ['086','086','096','096','097','097','098','098','0169','039','0168','038','0167','037','0166','036','0165','035','0164','034','0163','033','0162','032']);
define('LIST_MOBIPHONE', ['0120','070','0121','079','0122','077','0126','076','0128','078','089','089','090','090','093','093']);
define('LIST_VINAPHONE', ['091','091','094','094','0128','088','0123','083','0124','084','0125','085','0127','081','0129','082']);
define('LIST_VIETNAMMOBILE', ['092','092','0182','052','0186','056','0188','058']);
define('LIST_GMOBILE', ['099','099','0199','059']);

$ACCESS_TOKEN= @$_SERVER['HTTP_ACCESS_TOKEN']??null;
$stdRes=new stdClass();
if($ACCESS_TOKEN==DEFAULT_ACCESS_TOKEN){
  include_once("database.php");
  if(@$_POST['action']=='createNotify'){
    $phone=@$_POST['phone'];
    $content=@$_POST['content'];
    $sub3=substr($phone,0,3);
    $sub4=substr($phone,0,4);
    $stdRes->phone=$phone;
    $stdRes->net='All';
    $stdRes->content=$content;
    if (in_array($sub3,LIST_VIETTEL)||in_array($sub4,LIST_VIETTEL)) {
      $stdRes->net='Viettel';
    }
    if (in_array($sub3,LIST_MOBIPHONE)||in_array($sub4,LIST_MOBIPHONE)) {
      $stdRes->net='Mobiphone';
    }
    if (in_array($sub3,LIST_VINAPHONE)||in_array($sub4,LIST_VINAPHONE)) {
      $stdRes->net='Vinaphone';
    }
    if (in_array($sub3,LIST_VIETNAMMOBILE)||in_array($sub4,LIST_VIETNAMMOBILE)) {
      $stdRes->net='Vietnammobille';
    }
    if (in_array($sub3,LIST_GMOBILE)||in_array($sub4,LIST_GMOBILE)) {
      $stdRes->net='Gmobille';
    }
    include_once("m_bot.php");
    $Mbot = new Mbot();
    $mybot = @$Mbot->getLastBot($stdRes->net) ?? null;
    if ($mybot['bot_phone']) {
      $stdRes->phone=$mybot['bot_phone'];
      include_once("m_notify.php");
      $Notify = new Notify();
      $res = @$Notify->createNotify($phone,$content,$mybot['bot_phone']) ?? false;
      $res2 =$res? @$Mbot->updateBot($mybot['bot_phone']):false;
      $stdRes->stt=$res2?'success':'error';
    }else{
      $stdRes->stt='null bot';
    }
    


  }else if(@$_POST['action']=='checkNotify'){ 
    $stdRes->netList=DEFAULT_NET_LIST;
    $BOT_PHONE = @$_SERVER['HTTP_BOT_PHONE']??null;
    $BOT_NET = @$_SERVER['HTTP_BOT_NET']??null;
    include_once("m_bot.php");
    $Mbot = new Mbot();
    $mybot = @$Mbot->getFirstBot(@$BOT_PHONE) ?? null;
    $stdRes->subNet=subNetList($BOT_NET);
    if (strlen($mybot['bot_phone'])>=10) {
      @$Mbot->loginBot(@$BOT_PHONE,$BOT_NET) ?? null;
      $stdRes->net=$mybot['bot_net'];
    } else if (strlen($BOT_PHONE)>=10){
      @$Mbot->createBot(@$BOT_PHONE,$BOT_NET) ?? null;
      $stdRes->net=$BOT_NET;
    } else{
      header("HTTP/1.1 300");
      $stdRes->mess='false';
    }
    include_once("m_notify.php");
    $Notify = new Notify();
    $notify = @$Notify->getNotify($BOT_PHONE) ?? null;
    if(@$notify['notify_id']){
      @$Notify->setSTTNotify($notify['notify_id'],'1',time());
      header("HTTP/1.1 200");
      $stdRes->id=$notify['notify_id'];
      $stdRes->phone=$notify['notify_phone'];
      $stdRes->content=$notify['notify_content'];
    }else{
      header("HTTP/1.1 200");
      $stdRes->mess='empty';
    }

    
  }else if(@$_POST['action']=='setNotify'){
    if (@$_POST['sttNotify']=='1'||@$_POST['sttNotify']=='0') {
      $BOT_PHONE = @$_SERVER['HTTP_BOT_PHONE']??null;
      $idNotify=@$_POST['idNotify'];
      $sttNotify=(@$_POST['sttNotify']=='1')?'2':'-1';
      include_once("m_notify.php");
      $Notify = new Notify();
      $notify=@$Notify->getNotifyByID($idNotify);
      if ($notify['notify_id'] && $notify['notify_stt']!=$sttNotify) {
        $res=@$Notify->setSTTNotify($idNotify,$sttNotify,time());
        if ($res && $sttNotify=='2') {
          include_once("m_bot.php");
          $Mbot = new Mbot();
          @$Mbot->addNotifyBot(@$BOT_PHONE) ?? null;
        } 
      } 
    } 
    
    

    
  }else if(@$_POST['action']=='getALLNotify'){
    include_once("m_notify.php");
    $Notify = new Notify();
    $stdRes->data=@$Notify->getALLNotify();
    

    
  }else if(@$_POST['action']=='getALLBot'){
    include_once("m_bot.php");
    $Mbot = new Mbot();
    $stdRes->data=@$Mbot->getALLBot();
    $stdRes->now=time();
    
    

    
  }else if(@$_POST['action']=='getLastNotify'){
    include_once("m_notify.php");
    $Notify = new Notify();
    $data=@$Notify->getLastNotify();
    if (@$data['notify_id']) {
      header("HTTP/1.1 200");
      $stdRes->notify_id=$data['notify_id'];
      $stdRes->notify_bot=$data['notify_bot'];
      $stdRes->notify_stt=$data['notify_stt'];
      $stdRes->notify_phone=$data['notify_phone'];
      $stdRes->notify_content=$data['notify_content'];
      @$Notify->setLastNotify(@$data['notify_id']);
    } else {
      header("HTTP/1.1 500");
    }
    

    

  }else if(@$_POST['action']=='checkServer'){
    header("HTTP/1.1 200");
    $stdRes->mess='server connected';

  }else{
    header("HTTP/1.1 200");
    $stdRes->mess='not method';
  }
}else{
  header("HTTP/1.1 500");
  $stdRes->mess='server connect fail';
}

//'Viettel,Mobiphone,Vinaphone,Vietnammobille,Gmobille'
function subNetList($net){
  $sub='Bạn sẽ được ưu tiên gửi các số có đầu số: ';
  if ($net=='Viettel') {
    $sub.=implode(',',LIST_VIETTEL);
  } else if ($net=='Mobiphone') {
    $sub.=implode(',',LIST_MOBIPHONE);
  } else if ($net=='Vinaphone') {
    $sub.=implode(',',LIST_VINAPHONE);
  } else if ($net=='Vietnammobille') {
    $sub.=implode(',',LIST_VIETNAMMOBILE);
  } else if ($net=='Gmobille') {
    $sub.=implode(',',LIST_GMOBILE);
  } else if ($net=='All') {
    $sub='Bạn được chỉ định gửi tất cả các số điện thoại';
  } else if ($net=='Stop') {
    $sub='Tạm thời bạn được nghĩ ngơi!!!';
  }
  return $sub;
}

echo json_encode($stdRes);exit;