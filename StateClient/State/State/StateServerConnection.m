//
//  StateServerConnection.m
//  StateServerConnection
//
//  Created by keke on 2013/08/21.
//  Copyright (c) 2013年 keke. All rights reserved.
//

#import "StateServerConnection.h"

@interface StateServerConnection ()


@end

@implementation StateServerConnection{
    NSURLConnection *connection;
    NSMutableData *listData;
    NSString *requestMethod;
    NSString *requestUserID;
}

//
//イニシャライザ
//
- (id)initWithUser:(NSString*)user Password:(NSString*)pass Delegate:(id<StateServerConnectionDelegate>)delegate
{
    if (self = [super init]) {
        // 初期化処理
        self.userID = user;
        self.password = pass;
        self.delegate = delegate;
        listData = [[NSMutableData alloc] initWithCapacity:0];
    }
    return self;
}



//
//ヘッダとボディを作成してから通信を開始するメソッド
//
- (void)requestSendData:(NSMutableDictionary*)jsonDictionary Image:(UIImage*)img{
    
    [jsonDictionary setObject:self.userID forKey:@"user_id"];
    [jsonDictionary setObject:self.password forKey:@"password"];

    //JSON形式の文字列生成
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *urlString = @"http://54.213.27.241:18180/State.php";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSMutableData *body = [NSMutableData data];
    
    NSString *boundary = @"---------------------------168072824752491622650073";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    //JSONの挿入
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"json\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: text/plain; charset=\"utf-8\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    if (img == nil) {
        [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else{
        //画像のNSDataの生成
        NSData* jpgData = [[NSData alloc] initWithData:UIImageJPEGRepresentation(img, 0.8)];
        
        //画像データの挿入
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Disposition: form-data; name=\"icon\"; filename=\"image.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[NSData dataWithData:jpgData]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [request setHTTPBody:body];
    
    if (connection) [connection cancel];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [listData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)rData {
    [listData appendData:rData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [self returnError];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self returnResult];
}




/////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                             //
//==================================  通信結果を返すためのメソッド群  ==============================//
//                                                                                             //
/////////////////////////////////////////////////////////////////////////////////////////////////


- (void)returnError{
        
    NSError *error;
    
    
    //---------------------------  データ取得系のメソッド群のエラー結果  -------------------------------
    
    if([requestMethod isEqualToString:@"findAccount"]){
        error = [NSError errorWithDomain:@"findAccount" code:1 userInfo:nil];
        [self.delegate connectionDidFinishFindAccount:nil Error:error];
    }
    else if ([requestMethod isEqualToString:@"authentication"]){
        error = [NSError errorWithDomain:@"authentication" code:1 userInfo:nil];
        [self.delegate connectionDidFinishAuthentication:NO Error:error];
    }
    else if ([requestMethod isEqualToString:@"getMyInfomation"]){
        error = [NSError errorWithDomain:@"getMyInfomation" code:1 userInfo:nil];
        [self.delegate connectionDidFinishGetMyInfomation:nil Error:error];
    }
    else if ([requestMethod isEqualToString:@"getMyState"]){
        error = [NSError errorWithDomain:@"getMyState" code:1 userInfo:nil];
        [self.delegate connectionDidFinishGetMyState:nil Error:error];
    }
    else if ([requestMethod isEqualToString:@"getMyFriendInfomationList"]){
        error = [NSError errorWithDomain:@"getMyFriendInfomationList" code:1 userInfo:nil];
        [self.delegate connectionDidFinishGetMyFriendInfomationList:nil Error:error];
    }
    else if ([requestMethod isEqualToString:@"getMyFriendStateList"]){
        error = [NSError errorWithDomain:@"getMyFriendStateList" code:1 userInfo:nil];
        [self.delegate connectionDidFinishGetMyFriendStateList:nil Error:error];
    }
    else if ([requestMethod isEqualToString:@"getIcon"]){
        error = [NSError errorWithDomain:@"getIcon" code:1 userInfo:nil];
        [self.delegate connectionDidFinishGetIcon:nil UserID:requestUserID Error:error];
    }
#warning
    else if ([requestMethod isEqualToString:@"sendPing"]){
        error = [NSError errorWithDomain:@"sendPing" code:1 userInfo:nil];
        [self.delegate connectionDidFinishSendPing:NO Error:error];
    }
    /////
    
    //---------------------------  データ更新系のメソッド群のエラー結果  -------------------------------
    
    else if ([requestMethod isEqualToString:@"updateAccount"]){
        error = [NSError errorWithDomain:@"updateAccount" code:1 userInfo:nil];
        [self.delegate connectionDidFinishUpdateAccount:NO Error:error];
    }
#warning
    else if ([requestMethod isEqualToString:@"updateDeviceToken"]){
        error = [NSError errorWithDomain:@"updateDeviceToken" code:1 userInfo:nil];
        [self.delegate connectionDidFinishUpdateDeviceToken:NO Error:error];
    }
    /////
    else if ([requestMethod isEqualToString:@"updateProfile"]){
        error = [NSError errorWithDomain:@"updateProfile" code:1 userInfo:nil];
        [self.delegate connectionDidFinishUpdateProfile:NO Error:error];
    }
    else if ([requestMethod isEqualToString:@"updateState"]){
        error = [NSError errorWithDomain:@"updateState" code:1 userInfo:nil];
        [self.delegate connectionDidFinishUpdateState:NO Error:error];
    }
    else if ([requestMethod isEqualToString:@"updateIcon"]){
        error = [NSError errorWithDomain:@"updateIcon" code:1 userInfo:nil];
        [self.delegate connectionDidFinishUpdateIcon:NO Error:error];
    }
    
    //---------------------------  データ作成系のメソッド群のエラー結果  -------------------------------
    
    else if ([requestMethod isEqualToString:@"createAccount"]){
        error = [NSError errorWithDomain:@"createAccount" code:1 userInfo:nil];
        [self.delegate connectionDidFinishCreateAccount:NO Error:error];
    }
    
    else if ([requestMethod isEqualToString:@"createFriendRelation"]){
        error = [NSError errorWithDomain:@"createFriendRelation" code:1 userInfo:nil];
        [self.delegate connectionDidFinishCreateFriendRelation:NO Error:error];
    }
    
    //---------------------------  データ削除系のメソッド群のエラー結果  -------------------------------
    
    else if ([requestMethod isEqualToString:@"deleteFriendRelation"]){
        error = [NSError errorWithDomain:@"deleteFriendRelation" code:1 userInfo:nil];
        [self.delegate connectionDidFinishDeleteFriendRelation:NO Error:error];
    }
    
}


- (void)returnResult{
        
    id resultDictionary;
    UIImage* icon_image;
    
    
    if ( [requestMethod isEqualToString:@"getIcon"] ){
        icon_image = [[UIImage alloc] initWithData:listData];
    }
    else{
        resultDictionary = [NSJSONSerialization JSONObjectWithData:listData
                                                           options:NSJSONReadingAllowFragments
                                                             error:nil];
        
        if ([@"ERROR" isEqualToString:[resultDictionary objectForKey:@"result"]]) {
            [self returnError];
            return;
        }
    }
    
    //---------------------------  データ取得系のメソッド群の結果  -------------------------------
    
    if([requestMethod isEqualToString:@"findAccount"]){
        [self.delegate connectionDidFinishFindAccount:[resultDictionary objectForKey:@"resultBody"] Error:nil];
    }
    else if ([requestMethod isEqualToString:@"authentication"]){
        [self.delegate connectionDidFinishAuthentication:YES Error:nil];
    }
    else if ([requestMethod isEqualToString:@"getMyInfomation"]){
        [self.delegate connectionDidFinishGetMyInfomation: [resultDictionary objectForKey:@"resultBody"] Error:nil];
    }
    else if ([requestMethod isEqualToString:@"getMyState"]){
        [self.delegate connectionDidFinishGetMyState: [resultDictionary objectForKey:@"resultBody"] Error:nil];
        
    }
    else if ([requestMethod isEqualToString:@"getMyFriendInfomationList"]){
        [self.delegate connectionDidFinishGetMyFriendInfomationList: [resultDictionary objectForKey:@"resultBody"] Error:nil];
    }
    else if ([requestMethod isEqualToString:@"getMyFriendStateList"]){
        [self.delegate connectionDidFinishGetMyFriendStateList:[resultDictionary objectForKey:@"resultBody"] Error:nil];
    }
    else if ([requestMethod isEqualToString:@"getIcon"]){
        [self.delegate connectionDidFinishGetIcon:icon_image UserID:requestUserID Error:nil];
    }
#warning 
    else if ([requestMethod isEqualToString:@"sendPing"]){
        [self.delegate connectionDidFinishSendPing:YES Error:nil];
    }
    /////
    
    //---------------------------  データ更新系のメソッド群の結果  -------------------------------
    
    else if ([requestMethod isEqualToString:@"updateAccount"]){
        [self.delegate connectionDidFinishUpdateAccount:YES Error:nil];
    }
#warning 
    else if ([requestMethod isEqualToString:@"updateDeviceToken"]){
        [self.delegate connectionDidFinishUpdateDeviceToken:YES Error:nil];
    }
    /////
    else if ([requestMethod isEqualToString:@"updateProfile"]){
        [self.delegate connectionDidFinishUpdateProfile:YES Error:nil];
    }
    else if ([requestMethod isEqualToString:@"updateState"]){
        [self.delegate connectionDidFinishUpdateState:YES Error:nil];
    }
    else if ([requestMethod isEqualToString:@"updateIcon"]){
        [self.delegate connectionDidFinishUpdateIcon:YES Error:nil];
    }
    
    //---------------------------  データ作成系のメソッド群の結果  -------------------------------
    
    else if ([requestMethod isEqualToString:@"createAccount"]){
        [self.delegate connectionDidFinishCreateAccount:YES Error:nil];
    }
    else if ([requestMethod isEqualToString:@"createFriendRelation"]){
        [self.delegate connectionDidFinishCreateFriendRelation:YES Error:nil];
    }
    
    //---------------------------  データ削除系のメソッド群の結果  -------------------------------
    
    else if ([requestMethod isEqualToString:@"deleteFriendRelation"]){
        [self.delegate connectionDidFinishDeleteFriendRelation:YES Error:nil];
    }
    
}




/////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                             //
//=====================================  データ取得系のメソッド群  ================================//
//                                                                                             //
/////////////////////////////////////////////////////////////////////////////////////////////////


- (void)authentication{
    
    requestMethod = @"authentication";
    
    NSMutableDictionary* requestBody = [NSMutableDictionary dictionary];
    [requestBody setObject:self.userID forKey:@"user_id"];
    [requestBody setObject:self.password forKey:@"password"];
    
    NSMutableDictionary* jsonDictionary = [NSMutableDictionary dictionary];
    [jsonDictionary setObject:@"authentication" forKey:@"request"];
    [jsonDictionary setObject:requestBody forKey:@"requestBody"];
    
    [self requestSendData:jsonDictionary Image:nil];
    
}


- (void)findAccount:(NSString*)userID{
    
    requestMethod = @"findAccount";
    
    NSMutableDictionary* requestBody = [NSMutableDictionary dictionary];
    [requestBody setObject:userID forKey:@"user_id"];
    
    NSMutableDictionary* jsonDictionary = [NSMutableDictionary dictionary];
    [jsonDictionary setObject:@"findAccount" forKey:@"request"];
    [jsonDictionary setObject:requestBody forKey:@"requestBody"];
    
    [self requestSendData:jsonDictionary Image:nil];
}


- (void)getMyInfomation{
    
    requestMethod = @"getMyInfomation";
    
    NSMutableDictionary* jsonDictionary = [NSMutableDictionary dictionary];
    [jsonDictionary setObject:@"getMyInfomation" forKey:@"request"];
    
    [self requestSendData:jsonDictionary Image:nil];
}


- (void)getMyState{
    
    requestMethod = @"getMyState";
    
    NSMutableDictionary* jsonDictionary = [NSMutableDictionary dictionary];
    [jsonDictionary setObject:@"getMyState" forKey:@"request"];
    
    [self requestSendData:jsonDictionary Image:nil];
}


- (void)getMyFriendInfomationList{
    
    requestMethod = @"getMyFriendInfomationList";
    
    NSMutableDictionary* jsonDictionary = [NSMutableDictionary dictionary];
    [jsonDictionary setObject:@"getMyFriendInfomationList" forKey:@"request"];
    
    [self requestSendData:jsonDictionary Image:nil];
}


- (void)getMyFriendStateList{
    
    requestMethod = @"getMyFriendStateList";
    
    NSMutableDictionary* jsonDictionary = [NSMutableDictionary dictionary];
    [jsonDictionary setObject:@"getMyFriendStateList" forKey:@"request"];
    
    [self requestSendData:jsonDictionary Image:nil];
}


- (void)getIcon:(NSString*)userID{
        
    requestMethod = @"getIcon";
    requestUserID = userID;
    
    NSMutableDictionary* requestBody = [NSMutableDictionary dictionary];
    [requestBody setObject:userID forKey:@"user_id"];
    
    NSMutableDictionary* jsonDictionary = [NSMutableDictionary dictionary];
    [jsonDictionary setObject:@"getIcon" forKey:@"request"];
    [jsonDictionary setObject:requestBody forKey:@"requestBody"];
    
    [self requestSendData:jsonDictionary Image:nil];
}

#warning
- (void)sendPing:(NSString*)user{
    
    requestMethod = @"sendPing";
    
    NSMutableDictionary* requestBody = [NSMutableDictionary dictionary];
    [requestBody setObject:user forKey:@"user_id"];
    
    NSMutableDictionary* jsonDictionary = [NSMutableDictionary dictionary];
    [jsonDictionary setObject:@"sendPing" forKey:@"request"];
    [jsonDictionary setObject:requestBody forKey:@"requestBody"];
    
    [self requestSendData:jsonDictionary Image:nil];
    
}
///////



/////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                             //
//=====================================  データ更新系のメソッド群  ================================//
//                                                                                             //
/////////////////////////////////////////////////////////////////////////////////////////////////


- (void)updateAccount:(NSString*)user Password:(NSString*)pass{
    
    requestMethod = @"updateAccount";
    
    NSMutableDictionary* requestBody = [NSMutableDictionary dictionary];
    [requestBody setObject:user forKey:@"user_id"];
    [requestBody setObject:pass forKey:@"password"];
    
    NSMutableDictionary* jsonDictionary = [NSMutableDictionary dictionary];
    [jsonDictionary setObject:@"updateAccount" forKey:@"request"];
    [jsonDictionary setObject:requestBody forKey:@"requestBody"];
    
    [self requestSendData:jsonDictionary Image:nil];
    
}

#warning 
- (void)updateDeviceToken:(NSString*)token{
    
    requestMethod = @"updateDeviceToken";
    
    NSMutableDictionary* requestBody = [NSMutableDictionary dictionary];
    [requestBody setObject:token forKey:@"device_token"];
    
    NSMutableDictionary* jsonDictionary = [NSMutableDictionary dictionary];
    [jsonDictionary setObject:@"updateDeviceToken" forKey:@"request"];
    [jsonDictionary setObject:requestBody forKey:@"requestBody"];
    
    [self requestSendData:jsonDictionary Image:nil];
    

}
//////////

- (void)updateProfile:(NSString*)name{
    
    requestMethod = @"updateProfile";
    
    NSMutableDictionary* requestBody = [NSMutableDictionary dictionary];
    [requestBody setObject:name forKey:@"name"];
    
    NSMutableDictionary* jsonDictionary = [NSMutableDictionary dictionary];
    [jsonDictionary setObject:@"updateProfile" forKey:@"request"];
    [jsonDictionary setObject:requestBody forKey:@"requestBody"];
    
    [self requestSendData:jsonDictionary Image:nil];
    
}

- (void)updateState:(NSString*)state_text State:(id)state{
    
    requestMethod = @"updateState";
    
    NSMutableDictionary* requestBody = [NSMutableDictionary dictionary];
    [requestBody setObject:state_text forKey:@"state_text"];
    [requestBody setObject:state forKey:@"state"];
    
    NSMutableDictionary* jsonDictionary = [NSMutableDictionary dictionary];
    [jsonDictionary setObject:@"updateState" forKey:@"request"];
    [jsonDictionary setObject:requestBody forKey:@"requestBody"];
    
    [self requestSendData:jsonDictionary Image:nil];
    
}

- (void)updateIcon:(UIImage*)img{
    
    requestMethod = @"updateIcon";
    
    NSMutableDictionary* jsonDictionary = [NSMutableDictionary dictionary];
    [jsonDictionary setObject:@"updateIcon" forKey:@"request"];
    
    [self requestSendData:jsonDictionary Image:img];

}




/////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                             //
//=====================================  データ作成系のメソッド群  ================================//
//                                                                                             //
/////////////////////////////////////////////////////////////////////////////////////////////////


- (void)createAccount:(NSString*)user Password:(NSString*)pass Name:(NSString*)name StateText:(NSString*)state_text State:(id)state Icon:(UIImage*)icon{
    
    requestMethod = @"createAccount";
    
    NSMutableDictionary* requestBody = [NSMutableDictionary dictionary];
    [requestBody setObject:user forKey:@"user_id"];
    [requestBody setObject:pass forKey:@"password"];
    [requestBody setObject:name forKey:@"name"];
    [requestBody setObject:state_text forKey:@"state_text"];
    [requestBody setObject:state forKey:@"state"];

    
    NSMutableDictionary* jsonDictionary = [NSMutableDictionary dictionary];
    [jsonDictionary setObject:@"createAccount" forKey:@"request"];
    [jsonDictionary setObject:requestBody forKey:@"requestBody"];
    
    [self requestSendData:jsonDictionary Image:icon];
}


- (void)createFriendRelation:(NSString*)friendID{
    
    requestMethod = @"createFriendRelation";
    
    NSMutableDictionary* requestBody = [NSMutableDictionary dictionary];
    [requestBody setObject:friendID forKey:@"friend_id"];
        
    NSMutableDictionary* jsonDictionary = [NSMutableDictionary dictionary];
    [jsonDictionary setObject:@"createFriendRelation" forKey:@"request"];
    [jsonDictionary setObject:requestBody forKey:@"requestBody"];
    
    [self requestSendData:jsonDictionary Image:nil];
}




/////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                             //
//=====================================  データ削除系のメソッド群  ================================//
//                                                                                             //
/////////////////////////////////////////////////////////////////////////////////////////////////


- (void)deleteFriendRelation:(NSString*)friendID{
    
    requestMethod = @"deleteFriendRelation";
    
    NSMutableDictionary* requestBody = [NSMutableDictionary dictionary];
    [requestBody setObject:friendID forKey:@"friend_id"];
    
    NSMutableDictionary* jsonDictionary = [NSMutableDictionary dictionary];
    [jsonDictionary setObject:@"deleteFriendRelation" forKey:@"request"];
    [jsonDictionary setObject:requestBody forKey:@"requestBody"];
    
    [self requestSendData:jsonDictionary Image:nil];
}




@end
