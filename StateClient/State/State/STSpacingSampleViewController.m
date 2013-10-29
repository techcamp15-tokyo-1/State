//
//  STSpacingSampleViewController.m
//  UICollectionViewSample
//
//  Created by EIMEI on 2013/06/20.
//  Copyright (c) 2013 stack3.net. All rights reserved.
//

#import "STSpacingSampleViewController.h"
#import "STCollectionItem.h"
#import "STCustomCollectionViewCell.h"
#import "STCustomCollectionSectionView.h"
#import <AudioToolbox/AudioServices.h>



@implementation STSpacingSampleViewController {
    IBOutlet __weak UICollectionView *_collectionView;
    __weak IBOutlet UILabel *myTime;
    __weak IBOutlet BButton *StateButton;
    __strong NSMutableArray *_sections;
    __weak IBOutlet UIControl *hiddenView;

    __weak IBOutlet UISegmentedControl *FreeSwitch;
    NSDictionary *userInfo;
    NSDictionary *userState;
    NSUserDefaults *ud;
    NSMutableDictionary *imgCache;
    NSMutableDictionary *cellCache;
    NSString *pingUserID;
    
    CFURLRef soundURL;
    SystemSoundID soundID;
    
    NSTimer *tm;
    
    NSMutableDictionary *myInfomation;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"STSpacingSampleViewController" bundle:nil];
    if (self) {
        self.title = @"ホーム";
        self.tabBarItem.image = [UIImage imageNamed:@"home"];
        
        imgCache = [NSMutableDictionary dictionary];
        myInfomation = [NSMutableDictionary dictionary];
        _sections = [NSMutableArray array];
        for (int i = 0; i < 3; i++) {
            [_sections addObject:[NSMutableArray array]];
        }
        
        ud = [NSUserDefaults standardUserDefaults];
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
  //  STSpacingSampleViewController *con = [[STSpacingSampleViewController alloc] init];
    
    UINib *nib = [UINib nibWithNibName:@"STCustomCollectionViewCell" bundle:nil];
    [_collectionView registerNib:nib forCellWithReuseIdentifier:@"CellId"];
    
    nib = [UINib nibWithNibName:@"STCustomCollectionSectionView" bundle:nil];
    [_collectionView registerNib:nib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Section"];
    
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    
    //_textField.text=@"hello!";
    _textField.keyboardType=UIKeyboardTypeDefault;
   // _textField.hidden=YES;
    
    _stateTable.dataSource=self;
    _stateTable.delegate=self;
    _stateTable.hidden=YES;
    // UIPickerのインスタンス化
    
    

    // デリゲートを設定
    _picker.delegate = self;
    
    // データソースを設定
    _picker.dataSource = self;
    
    // 選択インジケータを表示
    _picker.showsSelectionIndicator = YES;
    
    // UIPickerのインスタンスをビューに追加
    [self.view addSubview:_picker];
    
    
    
    _picker.hidden=YES;
    _myView.userInteractionEnabled = YES;
    [self.view bringSubviewToFront:_myView];
    
    //時間ラベルの設定
    _selectedStringLabel.backgroundColor = [UIColor whiteColor];
    _selectedStringLabel.transform = CGAffineTransformRotate(_selectedStringLabel.transform, -M_PI/6);
    _selectedStringLabel.hidden=YES;
    
    //現在時刻の取得
    date = [NSDate date];
    calendar = [NSCalendar currentCalendar];
    dateComps = [calendar components:NSYearCalendarUnit |
                                   NSMonthCalendarUnit  |
                                   NSDayCalendarUnit    |
                                   NSHourCalendarUnit   |
                                   NSMinuteCalendarUnit |
                                   NSSecondCalendarUnit
                            fromDate:date];
    
    //ピッカーの初期値
    [_picker selectRow:150+dateComps.hour+1 inComponent:0 animated:NO];
    [_picker selectRow:140 inComponent:1 animated:NO];
    
    myTime.transform = CGAffineTransformRotate(myTime.transform, -M_PI/6);
        
    [self updateCell];
    
    [StateButton initWithFrame:CGRectMake(32.0f + (1 * 144.0f), 20.0f + (1 * 60.0f), 112.0f, 40.0f) color:[UIColor colorWithRed:1.20f green:0.40f blue:0.00f alpha:1.00f]];
    
    tm = [NSTimer scheduledTimerWithTimeInterval:30.0f
                                          target:self
                                        selector:@selector(updateCell)
                                        userInfo:nil
                                         repeats:YES];
    
    
}



-(void)updateCell{
    [[[StateServerConnection alloc] initWithUser:[ud stringForKey:@"USER_ID"]
                                        Password:[ud stringForKey:@"PASSWORD"] Delegate:self]
     getMyInfomation];
}

- (void)connectionDidFinishGetMyInfomation:(NSDictionary*)myInfo Error:(NSError*)error{
    
    [myInfomation setObject:[myInfo objectForKey:@"name"] forKey:@"name"];
    
    [[[StateServerConnection alloc] initWithUser:[ud stringForKey:@"USER_ID"]
                                        Password:[ud stringForKey:@"PASSWORD"] Delegate:self]
     getMyState];
}

- (void)connectionDidFinishGetMyState:(NSDictionary *)myState Error:(NSError *)error{
    
    [myInfomation setObject:[myState objectForKey:@"state_text"] forKey:@"state_text"];
    [myInfomation setObject:[myState objectForKey:@"state"] forKey:@"state"];
    
//    id state = [myState objectForKey:@"state"];
//    if (state == [NSNull null]) {
//        myTime.text = @"";
//        myTime.hidden = YES;
//    }
//    else if ([state isEqualToString:@"0000-00-00 00:00:00"]){
//        myTime.text = @"";
//        myTime.hidden = YES;
//    }
//    else{
//        myTime.text = [state substringWithRange:NSMakeRange(11,5)];
//        myTime.hidden = NO;
//    }
    
    [[[StateServerConnection alloc] initWithUser:[ud stringForKey:@"USER_ID"]
                                        Password:[ud stringForKey:@"PASSWORD"] Delegate:self]
     getMyFriendInfomationList];

}


- (void)connectionDidFinishGetMyFriendInfomationList:(NSDictionary*)friendInfoList Error:(NSError*)error{
    if (error != nil) {
        NSLog(@"MainView %@", error.domain);
    }
    else{
        userInfo = friendInfoList;
        [[[StateServerConnection alloc] initWithUser:[ud stringForKey:@"USER_ID"]
                                            Password:[ud stringForKey:@"PASSWORD"] Delegate:self]
         getMyFriendStateList];
    }
}

- (void)connectionDidFinishGetMyFriendStateList:(NSDictionary *)friendStateList Error:(NSError *)error{
    if (error != nil) {
        NSLog(@"MainView %@", error.domain);
    }
    else{
        [imgCache setObject:[NSNull null] forKey:[ud stringForKey:@"USER_ID"]];
        [self updateImage:[ud stringForKey:@"USER_ID"]];
        
        userState = friendStateList;
        
        _sections = [NSMutableArray array];
        for (int i = 0; i < 3; i++) {
            [_sections addObject:[NSMutableArray array]];
        }
        
        UINib *nib = [UINib nibWithNibName:@"STCustomCollectionViewCell" bundle:nil];
        [_collectionView registerNib:nib forCellWithReuseIdentifier:[ud stringForKey:@"USER_ID"]];
        
        STCollectionItem *item = [[STCollectionItem alloc] init];
        item.userID = [ud stringForKey:@"USER_ID"];
        item.state = [myInfomation objectForKey:@"state"];
        item.state_text = [myInfomation objectForKey:@"state_text"];
        item.name = [myInfomation objectForKey:@"name"];
        if (item.state == [NSNull null]) {
            [[_sections objectAtIndex:0] addObject:item];
        }
        else if ([item.state isEqualToString:@"0000-00-00 00:00:00"]){
            [[_sections objectAtIndex:2] addObject:item];
        }
        else{
            [[_sections objectAtIndex:1] addObject:item];
        }
        
        
        NSEnumerator *enu;
        
        if (self.friendList == nil) {
            enu = [userState keyEnumerator];
        }
        else{
            enu = [self.friendList objectEnumerator];
        }
        
        for (id key in enu) {
            
            nib = [UINib nibWithNibName:@"STCustomCollectionViewCell" bundle:nil];
            [_collectionView registerNib:nib forCellWithReuseIdentifier:key];
            
            [imgCache setObject:[NSNull null] forKey:key];
            STCollectionItem *item = [[STCollectionItem alloc] init];
            item.userID = key;
            item.state = [[userState objectForKey:key] objectForKey:@"state"];
            item.state_text = [[userState objectForKey:key] objectForKey:@"state_text"];
            item.name = [[userInfo objectForKey:key] objectForKey:@"name"];
            if (item.state == [NSNull null]) {
                [[_sections objectAtIndex:0] addObject:item];
            }
            else if ([item.state isEqualToString:@"0000-00-00 00:00:00"]){
                [[_sections objectAtIndex:2] addObject:item];
            }
            else{
                [[_sections objectAtIndex:1] addObject:item];
            }
        }
        
        nib = [UINib nibWithNibName:@"STCustomCollectionViewCell" bundle:nil];
        [_collectionView registerNib:nib forCellWithReuseIdentifier:@"\n"];
        
        
        if ([[_sections objectAtIndex:0] count] == 0) {
            STCollectionItem *item = [[STCollectionItem alloc] init];
            item.userID = @"\n";
            item.state = @"";
            item.state_text = @"";
            item.name = @"";
            [[_sections objectAtIndex:0] addObject:item];
        }
        if ([[_sections objectAtIndex:1] count] == 0){
            STCollectionItem *item = [[STCollectionItem alloc] init];
            item.userID = @"\n";
            item.state = @"";
            item.state_text = @"";
            item.name = @"";
            [[_sections objectAtIndex:1] addObject:item];
        }
    }
    
    [_collectionView reloadData];
    NSLog(@"update");
    //[tm fire];
    if ([self.myName.text isEqualToString:@""]) {
        self.myName.text = [myInfomation objectForKey:@"name"];
        self.myStateLabel.text = [myInfomation objectForKey:@"state_text"];
        
        id state = [myInfomation objectForKey:@"state"];
        if (state == [NSNull null]) {
            myTime.text = @"";
            myTime.hidden = YES;
        }
        else if ([state isEqualToString:@"0000-00-00 00:00:00"]){
            myTime.text = @"";
            myTime.hidden = YES;
        }
        else{
            myTime.text = [state substringWithRange:NSMakeRange(11,5)];
            myTime.hidden = NO;
        }
    }

}

#pragma mark - UICollectionViewDataSource



- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 3;
   // return _sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *items = [_sections objectAtIndex:section];
    return items.count;
  //  return items.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        STCustomCollectionSectionView *sectionView = [_collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Section" forIndexPath:indexPath];
        if(indexPath.section==0){
             sectionView.titleLabel.text = [NSString stringWithFormat:@"ひまだよ！"];
        }
        else if(indexPath.section==1){
            sectionView.titleLabel.text = [NSString stringWithFormat:@"あとでね！"];
        }
        if(indexPath.section==2){
            sectionView.titleLabel.text = [NSString stringWithFormat:@"今日はごめん！"];
        }
        
        return sectionView;
    } else {
        return nil;
    }
    
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}
/**
 * ピッカーに表示する行数を返す
 */
- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0: // 1列目
            return 250;
            break;
            
        case 1: // 2列目
            return 210;
            break;
 
        default:
            return 0;
            break;
    }
}
/**
 * ピッカーに表示する値を返す
 */
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    switch (component) {
        case 0: // 1列目
            
            if(row%25==0){
                return [NSString stringWithFormat:@"-"];

            }
            else{
                return [NSString stringWithFormat:@"%d", (row-1)%25];
            }
            break;
            
        case 1: // 2列目
            
            if(row%7==0){
                return [NSString stringWithFormat:@"--"];
                
            }
            else if(row%7==1){
                return [NSString stringWithFormat:@"00"];
            }
            else{
                return [NSString stringWithFormat:@"%d", ((row-1)%7)*10];
            }
            break;
        default:
            return 0;
            break;
    }
    
    
}
//ピッカーのセルの高さ
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent: (NSInteger)component {
    return 35.0;
}
//ピッカーのセルの幅
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent: (NSInteger)component {
    if(component == 0) {
        return 70;
    } else {
        return 70;
    }
}

/**
 * ピッカーの選択行が決まったとき
 */
- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
   
    // 1列目の選択された行数を取得
    if([pickerView selectedRowInComponent:0]%25==0){
         val0=@"";
    }
    else {
        val0=[NSString stringWithFormat: @"%d:",([pickerView selectedRowInComponent:0]-1)%25];
    }
    
    
    // 2列目の選択された行数を取得
    if([pickerView selectedRowInComponent:1]%7==0){
        val1=@"";
    }
    else if([pickerView selectedRowInComponent:1]%7==1){
        val1=@"00";
    }
    else{
        val1=[NSString stringWithFormat:@"%d",([pickerView selectedRowInComponent:1]-1)%7*10];
    }
    if([pickerView selectedRowInComponent:1]%7!=0 && [pickerView selectedRowInComponent:0]%25!=0){
    myTime.text=[val0 stringByAppendingString:val1];
        myTime.hidden=NO;
    }
    if([pickerView selectedRowInComponent:1]%7==0 || [pickerView selectedRowInComponent:0]%25==0){
        myTime.text=@"--:--";
        myTime.hidden=YES;
    }
    //ピッカーを無限ループに
    [pickerView selectRow:[pickerView selectedRowInComponent:0] % 25 + 100 inComponent:0 animated:NO];
    [pickerView selectRow:[pickerView selectedRowInComponent:1] % 7 + 140 inComponent:1 animated:NO];
}

//表の行数を指定
-(NSInteger)tableView:(UITableView *)tableView
numberOfRowsInSection:(NSInteger)section{
    return 10;
}

//表の情報を設定
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:12];
  //  cell.textLabel.textAlignment=UITextAlignmentLeft;
    
    if( indexPath.row == 0 ) {
        cell.textLabel.text = @"研究室";
    }else if( indexPath.row == 1 ) {
        cell.textLabel.text = @"家にいます";
    }else if( indexPath.row == 2 ) {
        cell.textLabel.text = @"バイト中";
    }
    else if( indexPath.row == 3){
        cell.textLabel.text=@"講義中";
    }
    else if( indexPath.row == 4){
        cell.textLabel.text=@"遊びに誘って！";
    }
    else if(indexPath.row == 5){
        cell.textLabel.text=@"出かけてます";
    }
    else if(indexPath.row == 6){
        cell.textLabel.text=@"マンガ読んでる";
    }
    else if(indexPath.row == 7){
        cell.textLabel.text=@"サークル活動中";
    }
    else if(indexPath.row == 8){
        cell.textLabel.text=@"ハワイ旅行";
    }
    else if(indexPath.row == 9){
        cell.textLabel.text=@"寝てます";
    }
    else if(indexPath.row == 10){
        cell.textLabel.text=@"呑んでます";
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
    // cell.textLabel.text = [NSString stringWithFormat:@"ｋこれは%d行目", indexPath.row]; // 何番目のセルかを表示させました
    return cell;
}

//タップしたセルの内容をテキストとフィールドに移す
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    self.myStateLabel.text= cell.textLabel.text;
    self.textField.text = cell.textLabel.text;
    _stateTable.hidden=YES;
    [self.textField resignFirstResponder];
}


- (IBAction)hiddenUI:(UIControl *)sender {
    _picker.hidden = YES;
    hiddenView.hidden = YES;
    _stateTable.hidden = YES;
    [_textField resignFirstResponder];
}

- (IBAction)pushStateButton:(id)sender {
    
    [self.textField resignFirstResponder];
    _stateTable.hidden=YES;
    _picker.hidden=YES;
    self.myStateLabel.text =_textField.text;
    
    
    StateServerConnection *ssc =[[StateServerConnection alloc] initWithUser:[ud stringForKey:@"USER_ID"]
                                                                                    Password:[ud stringForKey:@"PASSWORD"] Delegate:self];
    
    if(FreeSwitch.selectedSegmentIndex==0){
        [ssc updateState:self.myStateLabel.text State:[NSNull null]];
    }
    else if([myTime.text isEqualToString:@"--:--"]){
        [ssc updateState:self.myStateLabel.text State:@"0000-00-00 00:00:00"];
    }
    else{
        [ssc updateState:self.myStateLabel.text State:[NSString stringWithFormat:@"2013-08-28 %@:00",myTime.text]];
    }
    [self updateCell];
    _textField.text = @"";
    
}

- (void)connectionDidFinishUpdateState:(BOOL)result Error:(NSError*)error{
    if (error != nil) {
        NSLog(@"updatestate %@", error.domain);
    }
    else{
        
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self.textField resignFirstResponder];
    _stateTable.hidden=YES;
    return YES;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *items = [_sections objectAtIndex:indexPath.section];
    STCollectionItem *item = [items objectAtIndex:indexPath.row];
    STCustomCollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:item.userID forIndexPath:indexPath];

    if ([item.userID isEqualToString:@"\n"]) {
        cell.image.hidden = YES;
        cell.nameLabel.hidden = YES;
        cell.stateLabel.hidden = YES;
        cell.timeLabel.hidden = YES;
        cell.selected = NO;
        return cell;
    }
    cell.nameLabel.text = item.name;
    cell.stateLabel.text = item.state_text;
    if (item.state == [NSNull null]) {
        cell.timeLabel.text = @"";
        cell.timeLabel.hidden = YES;
    }
    else if ([item.state isEqualToString:@"0000-00-00 00:00:00"]){
        cell.timeLabel.text = @"";
        cell.timeLabel.hidden = YES;
    }
    else{
        cell.timeLabel.text = [item.state substringWithRange:NSMakeRange(11,5)];
        cell.timeLabel.hidden = NO;
    }
    
    
    if ([imgCache objectForKey:item.userID] == [NSNull null]) {
        //NSLog(@"%@", item.userID);
        [self updateImage:item.userID];
    }
    else{
        //NSLog(@"qweqwe");
        cell.image.image = [imgCache objectForKey:item.userID];
    }
    
    if ([item.userID isEqualToString:pingUserID]) {
    pingUserID = @"";
        // サウンドの再生
        CFBundleRef mainBundle;
        mainBundle = CFBundleGetMainBundle ();
        soundURL  = CFBundleCopyResourceURL (mainBundle,CFSTR ("ta_ge_paf01"),CFSTR ("mp3"),NULL);
        AudioServicesCreateSystemSoundID (soundURL, &soundID);
        CFRelease (soundURL);
        AudioServicesPlaySystemSound (soundID);
        [UIView animateWithDuration:0.25f // アニメーション速度2.5秒
                          delay:0.0f // 1秒後にアニメーション
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         // 画像を2倍に拡大
                         cell.image.transform = CGAffineTransformMakeScale(2.0, 2.0);
                         
                     } completion:^(BOOL finished) {
                         cell.image.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         // アニメーション終了時
                     }];
    }
    
    
    [cellCache setObject:cell forKey:item.userID];
    return cell;
}

- (void)pushPing:(NSString*)pingUser{
    
    pingUserID = pingUser;
    [self updateCell];
    
}

-(void)updateImage:(NSString*)userID{
    [[[StateServerConnection alloc] initWithUser:[ud stringForKey:@"USER_ID"]
                                        Password:[ud stringForKey:@"PASSWORD"] Delegate:self]
    getIcon:userID];
}

- (void)connectionDidFinishGetIcon:(UIImage*)iconImage UserID:(NSString*)user Error:(NSError*)error{
    if (error == nil) {
        [imgCache setObject:iconImage forKey:user];
        if ([user isEqualToString:[ud stringForKey:@"USER_ID"]]) {
            self.myIcon.image = iconImage;
        }
        else{
            [_collectionView reloadData];
        }
    }
}



#pragma mark - UICollectionViewDelegate

//セル選択時にアクション
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *items = [_sections objectAtIndex:indexPath.section];
    STCollectionItem *item = [items objectAtIndex:indexPath.row];
    
    if ([item.userID isEqualToString:@"\n"] || [item.userID isEqualToString:[ud stringForKey:@"USER_ID"]]) {
        [_collectionView deselectItemAtIndexPath:indexPath animated:NO];
        return;
    }
    
    [_collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    [[[StateServerConnection alloc] initWithUser:[ud stringForKey:@"USER_ID"]
                                        Password:[ud stringForKey:@"PASSWORD"] Delegate:self]
     sendPing:item.userID];
    NSLog(@"sendPing");
    
}

- (void)connectionDidFinishSendPing:(BOOL)result Error:(NSError *)error{
    if (error != nil) {
        NSLog(@"%@", error.domain);
    }
}

- (IBAction)pushFreeButton:(id)sender {
    
    _stateTable.hidden=YES;
        [self.textField resignFirstResponder];
        count=count+1;
        NSLog(@"%d",count);
        
        if(count%2==1){
            _picker.hidden=NO;
            _freeBusyLabel.text=@"busy";
        }
        else{
            _picker.hidden=YES;
            _freeBusyLabel.text=@"free";
            _selectedStringLabel.hidden=YES;
        }
}
- (IBAction)tapUpperView:(id)sender {
    [self.textField resignFirstResponder];
    _picker.hidden=YES;
    _stateTable.hidden=YES;
    self.myStateLabel.text = self.textField.text;
}


- (IBAction)touchTextField:(id)sender {
    _stateTable.hidden=NO;
    hiddenView.hidden = NO;
}

- (IBAction)touchSegmentedControl:(UISegmentedControl *)sender {
    if(FreeSwitch.selectedSegmentIndex==0){
        _picker.hidden=YES;
        _selectedStringLabel.text=@"--:--";
        myTime.text = @"--:--";
        myTime.hidden = YES;
    }
    else{
        _picker.hidden=NO;
        hiddenView.hidden = NO;
    }
}

- (IBAction)textFieldreturn:(UITextField *)sender {
    [sender resignFirstResponder];
    self.myStateLabel.text = sender.text;
    _stateTable.hidden = YES;
    hiddenView.hidden = YES;
}
@end
