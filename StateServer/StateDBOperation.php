<?php
require_once 'Define.php';

Class StateDBOperation {
    
    private $userID;
    private $password;
    private $dbh;
    
    function __construct($user_id, $pass){
        $this->userID = $user_id;
        $this->password = $pass;
       
        try {
            $dbh = new PDO(MYSQL_DATABASE_HOST, 
                           MYSQL_USER, 
                           MYSQL_PASSWORD, 
                           array(PDO::MYSQL_ATTR_INIT_COMMAND => "SET CHARACTER SET `utf8`"));
            $dbh->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            $this->dbh = $dbh;
        } catch (PDOException $e) {
            StateDBOperation::echoResult("ERROR", "Database connection error.");
            exit;
        }
    }
    
    public static function echoResult($result, $result_body){
        $json_hash = array('result' => $result, 'resultBody' => $result_body);
        echo json_encode($json_hash, JSON_FORCE_OBJECT);
    }
    
    public  function beginTransaction(){
        $this->dbh->beginTransaction();
    }
    
    public  function commit(){
        $this->dbh->commit();
    }
    
    public function rollBack(){
        $this->dbh->rollBack();
    }
    
    public function authentication(){
        $stmt = $this->dbh->prepare('select user_id from user_data where user_id = :user and password = :pass');
        $stmt->bindValue(':user', $this->userID, PDO::PARAM_STR);
        $stmt->bindValue(':pass', $this->password, PDO::PARAM_STR);
        $stmt->execute();
        
        if (count($stmt->fetchAll()) !== 1){
            return false;
        }
        return true;
    }
    
    public function findAccount($user_id){
        $stmt = $this->dbh->prepare('select name from user_profile where user_id = :user');
        $stmt->bindValue(':user', $user_id, PDO::PARAM_STR);
        $stmt->execute();
        
        $result = $stmt->fetchAll();
        
        if (count($result) === 1){
            $friend = 0;
            $relation = 0;
            
            $stmt = $this->dbh->prepare('select * from friend_relations where user_id = :user and friend_id = :friend');
            $stmt->bindValue(':user', $this->userID, PDO::PARAM_STR);
            $stmt->bindValue(':friend', $user_id, PDO::PARAM_STR);
            $stmt->execute();
            
            $relation = count($stmt->fetchAll());
            
            $stmt = $this->dbh->prepare('select * from user_friends where user_id = :user and friend_id = :friend');
            $stmt->bindValue(':user', $this->userID, PDO::PARAM_STR);
            $stmt->bindValue(':friend', $user_id, PDO::PARAM_STR);
            $stmt->execute();
            
            $friend = count($stmt->fetchAll());
            
            return array('result' => 1, 'user_id' => $user_id, 'name' => $result[0]['name'], 'relation' => $friend + $relation );
        }
        
        return array('result' => 0);
    }
    
    public function getDeviceToken($user_id){
        $stmt = $this->dbh->prepare('select device_token from user_data where user_id = :user');
        $stmt->bindValue(':user', $user_id, PDO::PARAM_STR);
        $stmt->execute();
        
        $result = $stmt->fetchAll();
        
        if (count($result) !== 1){
            return false;
        }
        return $result[0]['device_token'];
    }
    
    public function getMyInfomation(){
        $stmt = $this->dbh->prepare('select name from user_profile where user_id = :user');
        $stmt->bindValue(':user', $this->userID, PDO::PARAM_STR);
        $stmt->execute();
        
        $result = $stmt->fetchAll();
        
        return array('name' => $result[0]['name']);
    }
    
    public function  getMyState(){
        $stmt = $this->dbh->prepare('select state_text, state from user_state where user_id = :user');
        $stmt->bindValue(':user', $this->userID, PDO::PARAM_STR);
        $stmt->execute();
        
        $result = $stmt->fetchAll();
        
        return array('state_text' => $result[0]['state_text'],
                          'state' => $result[0]['state']);
    }
    
    public function getMyFriendInfomationList(){
        $stmt1 = $this->dbh->prepare('select friend_id from user_friends where user_id = :user');
        $stmt1->bindValue(':user', $this->userID, PDO::PARAM_STR);
        $stmt1->execute();
        
        $myFriendInfomationList = array();
        while($result1 = $stmt1->fetch(PDO::FETCH_ASSOC)){
            $stmt2 = $this->dbh->prepare('select name from user_profile where user_id = :user');
            $stmt2->bindValue(':user', $result1['friend_id'], PDO::PARAM_STR);
            $stmt2->execute();
            
            $result2 = $stmt2->fetch(PDO::FETCH_ASSOC);
            $myFriendInfomationList[ $result1['friend_id'] ] = array('name' => $result2['name']);
        }
        
        return $myFriendInfomationList;
    }
    
    public function getMyFriendStateList(){
        $stmt1 = $this->dbh->prepare('select friend_id from user_friends where user_id = :user');
        $stmt1->bindValue(':user', $this->userID, PDO::PARAM_STR);
        $stmt1->execute();
        
        $myFriendStateList = array();
        while($result1 = $stmt1->fetch(PDO::FETCH_ASSOC)){
            $stmt2 = $this->dbh->prepare('select state_text, state from user_state where user_id = :user');
            $stmt2->bindValue(':user', $result1['friend_id'], PDO::PARAM_STR);
            $stmt2->execute();
        
            $result2 = $stmt2->fetch(PDO::FETCH_ASSOC);
            $myFriendStateList[ $result1['friend_id'] ] = array('state_text' => $result2['state_text'], 
                                                                     'state' => $result2['state']);
        }
        
        return $myFriendStateList;
    }
    
    public function getIcon($user_id){
        $stmt = $this->dbh->prepare('select icon_image from user_icon where user_id = :user');
        $stmt->bindValue(':user', $user_id, PDO::PARAM_STR);
        $stmt->execute();
        
        $result = $stmt->fetchAll();
        if(count($result) == 0){
            return NULL;
        }
        
        return $result[0][icon_image];
    }
    
    public function setAccount($user_id, $pass){
        try{
            $stmt = $this->dbh->prepare('insert into user_data values(:user, :pass, NULL)');
            $stmt->bindValue(':user', $user_id, PDO::PARAM_STR);
            $stmt->bindValue(':pass', $pass, PDO::PARAM_STR);
            $stmt->execute();
        
        } catch (PDOException $e) {
            throw $e;
        }
    }
    
    public function setProfile($user_id, $name){
        try{
            $stmt = $this->dbh->prepare('insert into user_profile values(:user, :name)');
            $stmt->bindValue(':user', $user_id, PDO::PARAM_STR);
            $stmt->bindValue(':name', $name, PDO::PARAM_STR);
            $stmt->execute();
        
        } catch (PDOException $e) {
            throw $e;
        }
    }
    
    public function setState($user_id, $state_text, $state){
        try{
            $stmt = $this->dbh->prepare('insert into user_state values(:user, :state_text, :state)');
            $stmt->bindValue(':user', $user_id, PDO::PARAM_STR);
            $stmt->bindValue(':state_text', $state_text, PDO::PARAM_STR);
            $stmt->bindValue(':state', $state, PDO::PARAM_STR);
            $stmt->execute();
    
        } catch (PDOException $e) {
            throw $e;
        }
    }
    
    public function setIcon($user_id, $img_data){
        try{
            $stmt = $this->dbh->prepare('insert into user_icon values(:user, :data)');
            $stmt->bindValue(':user', $user_id, PDO::PARAM_STR);
            $stmt->bindValue(':data', $img_data, PDO::PARAM_STR);
            $stmt->execute();

        } catch (PDOException $e) {
            throw $e;
        }
    }
    
    public function setFriendRelation($friend_id){
        try{
            $stmt = $this->dbh->prepare('select * from friend_relations where user_id = :user and friend_id = :friend');
            $stmt->bindValue(':user', $this->userID, PDO::PARAM_STR);
            $stmt->bindValue(':friend', $friend_id, PDO::PARAM_STR);
            $stmt->execute();
            
            if (count($stmt->fetchAll()) >= 1){
                return true;
            }
            
            $stmt = $this->dbh->prepare('insert into friend_relations values(:user, :friend)');
            $stmt->bindValue(':user', $this->userID, PDO::PARAM_STR);
            $stmt->bindValue(':friend', $friend_id, PDO::PARAM_STR);
            $stmt->execute();
    
        } catch (PDOException $e) {
            return false;
        }
        return true;
    }
    
    public function updateDeviceToken($device_token){
        try{
            $stmt = $this->dbh->prepare('update user_data set device_token = :token where user_id = :c_user');
            $stmt->bindValue(':token', $device_token, PDO::PARAM_STR);
            $stmt->bindValue(':c_user', $this->userID, PDO::PARAM_STR);
            $stmt->execute();
        
        } catch (PDOException $e) {
            return false;
        }
        return true;
    }
    
    public function updateAccount($user_id, $pass){
        try{
            $stmt = $this->dbh->prepare('update user_data set user_id = :user, password = :pass where user_id = :c_user');
            $stmt->bindValue(':user', $user_id, PDO::PARAM_STR);
            $stmt->bindValue(':pass', $pass, PDO::PARAM_STR);
            $stmt->bindValue(':c_user', $this->userID, PDO::PARAM_STR);
            $stmt->execute();
    
        } catch (PDOException $e) {
            return false;
        }
        return true;
    }
    
    public function updateProfile($name){
        try{
            $stmt = $this->dbh->prepare('update user_profile set name = :name where user_id = :c_user');
            $stmt->bindValue(':name', $name, PDO::PARAM_STR);
            $stmt->bindValue(':c_user', $this->userID, PDO::PARAM_STR);
            $stmt->execute();
    
        } catch (PDOException $e) {
            return false;
        }
        return true;
    }
    
    public function updateState($state_text, $state){
        try{
            $stmt = $this->dbh->prepare('update user_state set state_text = :state_text, state = :state where user_id = :c_user');
            $stmt->bindValue(':state_text', $state_text, PDO::PARAM_STR);
            $stmt->bindValue(':state', $state, PDO::PARAM_STR);
            $stmt->bindValue(':c_user', $this->userID, PDO::PARAM_STR);
            $stmt->execute();
    
        } catch (PDOException $e) {
            return false;
        }
        return true;
    }
    
    public function updateIcon($img_data){
        try{
            $stmt = $this->dbh->prepare('update user_icon set icon_image = :data where user_id = :c_user');
            $stmt->bindValue(':data', $img_data, PDO::PARAM_STR);
            $stmt->bindValue(':c_user', $this->userID, PDO::PARAM_STR);
            $stmt->execute();
    
        } catch (PDOException $e) {
            return false;
        }
        return true;
    }
    
    public function deleteFriendRelation($user_id){
        try{
            $stmt = $this->dbh->prepare('delete from friend_relations where user_id = :user and friend_id = :friend');
            $stmt->bindValue(':user', $this->userID, PDO::PARAM_STR);
            $stmt->bindValue(':friend', $user_id, PDO::PARAM_STR);
            $stmt->execute();
    
        } catch (PDOException $e) {
            return false;
        }
        return true;
    }
    
        
}