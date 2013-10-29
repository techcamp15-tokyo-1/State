<?php

mb_language("uni");
mb_internal_encoding("utf-8");
mb_http_input("auto");
mb_http_output("utf-8");

require_once 'Push.php';
require_once 'Define.php';
require_once 'StateDBOperation.php';



if( !isset($_POST['json']) )
{
    StateDBOperation::echoResult("ERROR", "Injustice Access.");
    exit;
}

$post_data = json_decode($_POST['json'], 1);


if ($post_data['request'] !== 'createAccount'){
    
    $stateDBOperation = new StateDBOperation($post_data['user_id'], $post_data['password']);
    
    if (!$stateDBOperation->authentication()){
        StateDBOperation::echoResult("ERROR", "Authentication error.");
        exit();
    }
}
else {
    $stateDBOperation = new StateDBOperation(NULL, NULL);
}




switch ($post_data['request']){
    case 'sendPing':
        $device_token = $stateDBOperation->getDeviceToken($post_data['requestBody']['user_id']);
        if ($device_token){
            $myInfo = $stateDBOperation->getMyInfomation();
            push($device_token, $post_data['user_id'], $myInfo['name']);
            $result = array();
        }
        else{
            StateDBOperation::echoResult("ERROR", "sendPing error.");
            exit();
        }
        break;
    
    case 'authentication':
        $result = array();
        break;
        
    case 'findAccount':
        $result = $stateDBOperation->findAccount($post_data['requestBody']['user_id']);
        break;
        
    case 'getMyInfomation':
        $result = $stateDBOperation->getMyInfomation();
        break;
        
    case 'getMyState':
        $result = $stateDBOperation->getMyState();
        break;
        
    case 'getMyFriendInfomationList':
        $result = $stateDBOperation->getMyFriendInfomationList();
        break;
        
    case 'getMyFriendStateList':
        $result = $stateDBOperation->getMyFriendStateList();
        break;
        
    case 'getIcon':
        header("Content-Type: image/jpg");
        echo $stateDBOperation->getIcon($post_data['requestBody']['user_id']);
        exit();
        break;
        
    case 'updateDeviceToken':
        $result_flag = $stateDBOperation->updateDeviceToken($post_data['requestBody']['device_token']);
        if ($result_flag){
            $result = array();
        }
        else{
            StateDBOperation::echoResult("ERROR", "updateDeviceToken error.");
            exit();
        }
        break;
        
    case 'updateAccount':
        $result_flag = $stateDBOperation->updateAccount($post_data['requestBody']['user_id'], 
                                                        $post_data['requestBody']['password']);
        if ($result_flag){
            $result = array();
        }
        else{
            StateDBOperation::echoResult("ERROR", "updateAccount error.");
            exit();
        }
        break;
        
    case 'updateProfile':
        $result_flag = $stateDBOperation->updateProfile($post_data['requestBody']['name']);
        if ($result_flag){
            $result = array();
        }
        else{
            StateDBOperation::echoResult("ERROR", "updateProfile error.");
            exit();
        }
        break;
        
    case 'updateState':
        $result_flag = $stateDBOperation->updateState($post_data['requestBody']['state_text'],
                                                      $post_data['requestBody']['state']);
        if ($result_flag){
            $result = array();
        }
        else{
            StateDBOperation::echoResult("ERROR", "updateState error.");
            exit();
        }
        break;
        
    case 'updateIcon':
        if(!isset($_FILES['icon'])){
            StateDBOperation::echoResult("ERROR", "UploadFile error.");
            exit();
        }
        $result_flag = $stateDBOperation->updateIcon(file_get_contents($_FILES['icon']['tmp_name']));
        if ($result_flag){
            $result = array();
        }
        else{
            StateDBOperation::echoResult("ERROR", "updateIcon error.");
            exit();
        }
        break;
        
    case 'createAccount':
        if(!isset($_FILES['icon'])){
            StateDBOperation::echoResult("ERROR", "UploadFile error.");
            exit();
        }
        
        $stateDBOperation->beginTransaction();
        try{
            $stateDBOperation->setAccount($post_data['requestBody']['user_id'], $post_data['requestBody']['password']);
            $stateDBOperation->setProfile($post_data['requestBody']['user_id'], $post_data['requestBody']['name']);
            $stateDBOperation->setState($post_data['requestBody']['user_id'], $post_data['requestBody']['state_text'], $post_data['requestBody']['state']);
            $stateDBOperation->setIcon($post_data['requestBody']['user_id'], file_get_contents($_FILES['icon']['tmp_name']));
        
            $stateDBOperation->commit();
            $result = array();
        }
        catch (PDOException $e){
            $stateDBOperation->rollBack();
            StateDBOperation::echoResult("ERROR", "createAccount error.");
            exit();
        }
        break;
        
    case 'createFriendRelation':
        $result_flag = $stateDBOperation->setFriendRelation($post_data['requestBody']['friend_id']);
        if ($result_flag){
            $result = array();
        }
        else{
            StateDBOperation::echoResult("ERROR", "createFriendRelation error.");
            exit();
        }
        break;
        
    case 'deleteFriendRelation':
        $result_flag = $stateDBOperation->deleteFriendRelation($post_data['requestBody']['friend_id']);
        if ($result_flag){
            $result = array();
        }
        else{
            StateDBOperation::echoResult("ERROR", "deleteFriendRelation error.");
            exit();
        }
        break;
        
    default:
        StateDBOperation::echoResult("ERROR", "Request error.");
        exit();
}

StateDBOperation::echoResult("OK", $result);
exit;

