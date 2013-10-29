//
//  StateServerConnection.h
//  StateServerConnection
//
//  Created by keke on 2013/08/21.
//  Copyright (c) 2013年 keke. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol StateServerConnectionDelegate <NSObject>

@optional

//データ取得系のデリゲートメソッド
- (void)connectionDidFinishAuthentication:(BOOL)result Error:(NSError*)error;
- (void)connectionDidFinishFindAccount:(NSDictionary*)friendInfo Error:(NSError*)error;
- (void)connectionDidFinishGetMyInfomation:(NSDictionary*)myInfo Error:(NSError*)error;
- (void)connectionDidFinishGetMyState:(NSDictionary *)myState Error:(NSError *)error;
- (void)connectionDidFinishGetMyFriendInfomationList:(NSDictionary*)friendInfoList Error:(NSError*)error;
- (void)connectionDidFinishGetMyFriendStateList:(NSDictionary*)friendStateList Error:(NSError*)error;
- (void)connectionDidFinishGetIcon:(UIImage*)iconImage UserID:(NSString*)user Error:(NSError*)error;
#warning 
- (void)connectionDidFinishSendPing:(BOOL)result Error:(NSError *)error;
/////////

//データ更新系のデリゲートメソッド
- (void)connectionDidFinishUpdateAccount:(BOOL)result Error:(NSError*)error;
- (void)connectionDidFinishUpdateProfile:(BOOL)result Error:(NSError*)error;
- (void)connectionDidFinishUpdateState:(BOOL)result Error:(NSError*)error;
- (void)connectionDidFinishUpdateIcon:(BOOL)result Error:(NSError*)error;
#warning 
- (void)connectionDidFinishUpdateDeviceToken:(BOOL)result Error:(NSError *)error;
//////////

//データ作成系のデリゲートメソッド
- (void)connectionDidFinishCreateAccount:(BOOL)result Error:(NSError *)error;
- (void)connectionDidFinishCreateFriendRelation:(BOOL)result Error:(NSError *)error;

//データ削除系のデリゲートメソッド
- (void)connectionDidFinishDeleteFriendRelation:(BOOL)result Error:(NSError *)error;

@end


@interface StateServerConnection : NSObject

@property (retain) NSString *userID;
@property (retain) NSString *password;
@property (nonatomic, assign) id<StateServerConnectionDelegate> delegate;

- (id)initWithUser:(NSString*)user Password:(NSString*)pass Delegate:(id<StateServerConnectionDelegate>)delegate;

//データ取得系のメソッド
- (void)authentication;
- (void)findAccount:(NSString*)userID;
- (void)getMyInfomation;
- (void)getMyState;
- (void)getMyFriendInfomationList;
- (void)getMyFriendStateList;
- (void)getIcon:(NSString*)userID;
#warning 
- (void)sendPing:(NSString*)user;
////////

//データ更新系のメソッド
- (void)updateAccount:(NSString*)user Password:(NSString*)pass;
#warning 
- (void)updateDeviceToken:(NSString*)token;
///////
- (void)updateProfile:(NSString*)name;
- (void)updateState:(NSString*)state_text State:(id)state;
- (void)updateIcon:(UIImage*)img;

//データ作成系のメソッド
- (void)createAccount:(NSString*)user
             Password:(NSString*)pass
                 Name:(NSString*)name
            StateText:(NSString*)state_text
                State:(id)state
                 Icon:(UIImage*)icon;

- (void)createFriendRelation:(NSString*)friendID;

//データ削除系のメソッド
- (void)deleteFriendRelation:(NSString*)friendID;


@end
