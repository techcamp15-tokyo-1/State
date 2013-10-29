<?php

error_reporting(-1);

require_once 'ApnsPHP/Autoload.php';

function push($device_token, $user_id, $name){
    
    $push = new ApnsPHP_Push(
            ApnsPHP_Abstract::ENVIRONMENT_SANDBOX,
            'certificates/push.pem'
    );
    
    // Set the Provider Certificate passphrase
    //$push->setProviderCertificatePassphrase('harakojima');
    
    $push->setRootCertificationAuthority('certificates/Entrust_Root_Certification_Authority.pem');
    
    $push->connect();
    
    $message = new ApnsPHP_Message($device_token);
    
    $message->setCustomIdentifier("state_ping");
    
    $message->setBadge(1);
    
    $message->setText($name.'さんからピンが来ました');
    
    $message->setSound();
    
    // Set a custom property
    $message->setCustomProperty('user_id', $user_id);
    
    // Set another custom property
    //$message->setCustomProperty('acme3', array('bing', 'bong'));
    
    // Set the expiry value to 30 seconds
    $message->setExpiry(30);
    
    $push->add($message);
    
    $push->send();
    
    $push->disconnect();
    
    $aErrorQueue = $push->getErrors();
    if (!empty($aErrorQueue)) {
        //var_dump($aErrorQueue);
    }
}