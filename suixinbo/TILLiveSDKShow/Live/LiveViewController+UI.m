//
//  LiveViewController+UI.m
//  TILLiveSDKShow
//
//  Created by wilderliao on 17/1/7.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "LiveViewController+UI.h"

#import "MsgTableViewCell.h"
#import "MemberListCell.h"

#import "UIImage+TintColor.h"
#import "UIColor+MLPFlatColors.h"

@implementation LiveViewController (UI)

- (void)onInteract
{
    __weak typeof(self) ws = self;
    RoomMemListRequest *listReq = [[RoomMemListRequest alloc] initWithHandler:^(BaseRequest *request) {
        RoomMemListRspData *listRspData = (RoomMemListRspData *)request.response.data;
        [ws popMemberList:listRspData.idlist];
        
    } failHandler:^(BaseRequest *request) {
        
        NSString *logInfo = [NSString stringWithFormat:@"get group member fail ,code=%ld,msg=%@",(long)request.response.errorCode, request.response.errorInfo];
        [AlertHelp alertWith:@"获取成员列表失败" message:logInfo cancelBtn:@"确定" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
    }];
    listReq.token = [AppDelegate sharedAppDelegate].token;
    listReq.roomnum = _liveItem.info.roomnum;
    listReq.index = 0;
    listReq.size = 20;
    [[WebServiceEngine sharedEngine] asyncRequest:listReq wait:NO];
}

- (void)onClickIcon
{
    [UIView animateWithDuration:0.5 animations:^{
        _reportView.hidden = NO;
        [_reportView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        [self.view bringSubviewToFront:_reportView];
    }];
}

- (void)onRecReport:(NSString *)name type:(ILiveRecordType)type
{
    RecordReportRequest *req = [[RecordReportRequest alloc] initWithHandler:^(BaseRequest *request) {
        
    } failHandler:^(BaseRequest *request) {
        
    }];
    req.token = [AppDelegate sharedAppDelegate].token;
    req.roomnum = _liveItem.info.roomnum;
    req.uid = [[ILiveLoginManager getInstance] getLoginId];
    req.name = name;
    req.type = (NSInteger)type;
    req.cover = _liveItem.info.cover;
    [[WebServiceEngine sharedEngine] asyncRequest:req];
}

- (void)onReport {
    __weak typeof(self) ws = self;
    AlertActionHandle reportBlock = ^(UIAlertAction * _Nonnull action){
        [ws showReportSucc];
    };
    NSDictionary *funs = @{@"垃圾营销":reportBlock,@"不实信息":reportBlock,@"有害信息":reportBlock,@"违法信息":reportBlock,@"淫秽信息":reportBlock};
    [AlertHelp alertWith:@"举报原因" message:nil funBtns:funs cancelBtn:@"取消" alertStyle:UIAlertControllerStyleActionSheet cancelAction:nil];
}

- (void)showReportSucc {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"举报成功,系统将在24小时内处理" preferredStyle:UIAlertControllerStyleAlert];
    [[AlertHelp topViewController] presentViewController:alert animated:YES completion:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES completion:nil];
    });
}


- (void)popMemberList:(NSArray *)members
{
    //群成员很大时，次处存在性能问题，可以单独维护房间成员，不用每次都获取。
    [_members removeAllObjects];
    
    NSString *loginId = [[ILiveLoginManager getInstance] getLoginId];
    for (MemberListItem *item in members)
    {
        BOOL isLoginId = [item.identifier isEqualToString:loginId];
        BOOL isPlaceholder = [[UserViewManager shareInstance] isExistPlaceholder:item.identifier];
        BOOL isRender = [[UserViewManager shareInstance] isExistRenderView:item.identifier];
        
        if (!isLoginId && !isPlaceholder)
        {
            if (isRender)
        {
                item.isUpVideo = YES;
            }
            [_members addObject:item];
        }
    }
    
    if (_members.count == 0)
    {
        UIAlertController *alert = [AppDelegate showAlert:self title:@"没有更多用户了" message:nil okTitle:nil cancelTitle:@"算了" ok:nil cancel:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (alert)
            {
                [alert dismissViewControllerAnimated:YES completion:nil];
            }
        });
        return;
    }
    [_bgAlphaView setFrame:CGRectMake(0, -150, self.view.bounds.size.width, self.view.bounds.size.height)];
    _bgAlphaView.hidden = NO;
    
    [_memberListView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, 150)];
    [_memberListView reloadData];
    
    [UIView animateWithDuration:0.5 animations:^{
        [_bgAlphaView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        [self.view bringSubviewToFront:_bgAlphaView];
    }];
}

- (void)viewDidLayoutSubviews
{
    CGRect screenRect = self.view.bounds;
    CGFloat screenW = screenRect.size.width;
    
    [_topView sizeWith:CGSizeMake(screenW * 17/20, 50)];
    [_topView alignParentTopWithMargin:kDefaultMargin];
    [_topView alignParentLeftWithMargin:kDefaultMargin];
    
    [_closeBtn sizeWith:CGSizeMake(44, 44)];
    [_closeBtn alignParentRight];
    [_closeBtn alignVerticalCenterOf:_topView];
    
    [_parView sizeWith:CGSizeMake(screenW, 56)];
    [_parView layoutBelow:_topView margin:kDefaultMargin];
    
//    [_envInfoView sizeWith:CGSizeMake(125, 30)];
//    [_envInfoView layoutBelow:_parView];
//    [_envInfoView alignParentLeft];
    
    [_bottomView sizeWith:CGSizeMake(screenW, 30)];
    [_bottomView alignParentBottomWithMargin:kDefaultMargin];
    
    [_msgInputView sameWith:_bottomView];
    [_msgInputView relayoutFrameOfSubViews];
    [_msgInputView layoutAbove:_bottomView margin:kDefaultMargin];
    
    [_msgTableView sizeWith:CGSizeMake(screenW * 4/5, 150)];
    [_msgTableView layoutAbove:_bottomView margin:kDefaultMargin];
}

- (void)switchRoomRefresh:(NSNotification *)noti
{
    _liveItem = (TCShowLiveListItem *)noti.object;
    [_msgDatas removeAllObjects];
    [_msgTableView reloadData];
}

- (void)onGotupDelete:(NSNotification *)noti
{
    [AlertHelp alertWith:@"提示" message:@"主播已经离开房间,是否退出?" cancelBtn:@"退出" alertStyle:UIAlertControllerStyleAlert cancelAction:^(UIAlertAction * _Nonnull action) {
        [self exitRoom];
    }];
}

- (void)showLikeHeartStartRect:(NSNotification *)noti
{
    NSDictionary *pointDic = (NSDictionary *)noti.object;
    CGFloat aniX, aniY;
    if (pointDic)
    {
        CGFloat pariseX = [[pointDic objectForKey:@"parise_x"] floatValue];
        CGFloat pariseY = [[pointDic objectForKey:@"parise_y"] floatValue];
        
        CGRect bottomFrame =  _bottomView.frame;
        
        aniX = pariseX + bottomFrame.origin.x;
        aniY = pariseY + bottomFrame.origin.y;
    }
    else
    {
        aniX = self.view.bounds.size.width - 50;
        aniY = self.view.bounds.size.height - 70;
    }
    if (aniX+30 > self.view.bounds.size.width)
    {
        aniX = self.view.bounds.size.width - 40;
    }
    CGRect frame = CGRectMake(self.view.bounds.size.width - 70, self.view.bounds.size.height - 100, 30, 30);
    UIImageView *imageView = [[UIImageView alloc ] initWithFrame:frame];
    imageView.image = [[UIImage imageNamed:@"img_like"] imageWithTintColor:[UIColor randomFlatDarkColor]];
    [self.view addSubview:imageView];
    imageView.alpha = 0;
    
    [imageView.layer addAnimation:[self hearAnimationFrom:frame] forKey:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [imageView removeFromSuperview];
    });
    
}
- (CAAnimation *)hearAnimationFrom:(CGRect)frame
{
    //位置
    CAKeyframeAnimation *animation=[CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.beginTime = 0.5;
    animation.duration = 2.5;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    animation.repeatCount= 0;
    animation.calculationMode = kCAAnimationCubicPaced;
    
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGPoint point0 = CGPointMake(frame.origin.x + frame.size.width / 2, frame.origin.y + frame.size.height / 2);
    
    CGPathMoveToPoint(curvedPath, NULL, point0.x, point0.y);
    
    float x11 = point0.x - arc4random() % 30 + 30;
    float y11 = frame.origin.y - arc4random() % 60 ;
    float x1 = point0.x - arc4random() % 15 + 15;
    float y1 = frame.origin.y - arc4random() % 60 - 30;
    CGPoint point1 = CGPointMake(x1, y1);
    CGPathAddQuadCurveToPoint(curvedPath, NULL, x11, y11, point1.x, point1.y);
    
    int conffset2 = self.view.bounds.size.width * 0.2;
    int conffset21 = self.view.bounds.size.width * 0.1;
    float x2 = point0.x - arc4random() % conffset2 + conffset2;
    float y2 = arc4random() % 30 + 240;
    float x21 = point0.x - arc4random() % conffset21  + conffset21;
    float y21 = (y2 + y1) / 2 + arc4random() % 30 - 30;
    CGPoint point2 = CGPointMake(x2, y2);
    CGPathAddQuadCurveToPoint(curvedPath, NULL, x21, y21, point2.x, point2.y);
    
    animation.path = curvedPath;
    
    CGPathRelease(curvedPath);
    
    //透明度变化
    CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnim.fromValue = [NSNumber numberWithFloat:1.0];
    opacityAnim.toValue = [NSNumber numberWithFloat:0];
    opacityAnim.removedOnCompletion = NO;
    opacityAnim.beginTime = 0;
    opacityAnim.duration = 3;
    
    //比例
    CABasicAnimation *scaleAnim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    //        int scale = arc4random() % 5 + 5;
    scaleAnim.fromValue = [NSNumber numberWithFloat:.0];//[NSNumber numberWithFloat:((float)scale / 10)];
    scaleAnim.toValue = [NSNumber numberWithFloat:1];
    scaleAnim.removedOnCompletion = NO;
    scaleAnim.fillMode = kCAFillModeForwards;
    scaleAnim.duration = .5;
    
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.animations = [NSArray arrayWithObjects: scaleAnim,opacityAnim,animation, nil];
    animGroup.duration = 3;
    
    return animGroup;
}

- (void)popMsgInputView
{
    _msgInputView.hidden = NO;
    [_msgInputView becomeFirstResponder];
}

- (void)setTilBeauty:(float)beauty
{
    [self.preProcessor setBeautyLevel:beauty];
}

- (void)setTilWhite:(float)white
{
    [self.preProcessor setWhitenessLevel:white];
}

- (void)exitRoom
{
    [self onClose];
}

- (void)onTapBlankToHide
{
    [UIView animateWithDuration:0.5 animations:^{
        [_bgAlphaView setFrame:CGRectMake(0, -150, self.view.bounds.size.width, self.view.bounds.size.height)];
        [_memberListView setFrame:CGRectMake(0, -150, self.view.bounds.size.width, 150)];
        
    } completion:^(BOOL finished) {
        _bgAlphaView.hidden = YES;
    }];
}

//输入键盘相关
- (void)onTapBlankToHideKeyboard
{
    [_msgInputView resignFirstResponder];
}

- (void)registKeyboard
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onShowKebord:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onHideKebord:) name:UIKeyboardWillHideNotification object:nil];
}
- (void)unRegistKeyboard
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)onShowKebord:(NSNotification *)notify
{
    NSDictionary *dic = [notify userInfo];
    CGRect keyRect = [[dic objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect oldFrame = _msgInputView.frame;
    if (_isFristShow)
    {
        _oldInputFrame = oldFrame;
        _isFristShow = NO;
    }
    [_msgInputView setFrame:CGRectMake(oldFrame.origin.x, keyRect.origin.y-oldFrame.size.height, oldFrame.size.width, oldFrame.size.height)];
}

- (void)onHideKebord:(NSNotification *)notify
{
    [UIView animateWithDuration:0.1 animations:^{
        [_msgInputView alignParentBottomWithMargin:-_oldInputFrame.size.height];
    } completion:^(BOOL finished) {
        _msgInputView.hidden = YES;
    }];
}

- (void)onTapReportViewBlankToHide
{
    [UIView animateWithDuration:0.5 animations:^{
        [_reportView setFrame:CGRectMake(0, -50, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    } completion:^(BOOL finished) {
        _reportView.hidden = YES;
    }];
}

- (void)onBtnClose:(UIButton *)button
{
    __weak typeof(self) ws = self;
    AlertActionHandle okBlock = ^(UIAlertAction * _Nonnull action) {
        if (_isHost)//主播退群时，发送退群消息
        {
            ILVLiveCustomMessage *customMsg = [[ILVLiveCustomMessage alloc] init];
            customMsg.type = ILVLIVE_IMTYPE_GROUP;
            customMsg.recvId = [[ILiveRoomManager getInstance] getIMGroupId];
            customMsg.cmd = (ILVLiveIMCmd)AVIMCMD_ExitLive;
            [[TILLiveManager getInstance] sendCustomMessage:customMsg succ:^{
                [ws onClose];
                
            } failed:^(NSString *module, int errId, NSString *errMsg) {
                [ws onClose];
            }];
        }
        else
        {
            [ws onClose];
        }
    };
    [AlertHelp alertWith:@"提示" message:@"确认退出直播吗" funBtns:@{@"确定":okBlock} cancelBtn:@"取消" alertStyle:UIAlertControllerStyleAlert cancelAction:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _msgTableView)
    {
        return _msgDatas.count;
    }
    else if (tableView == _memberListView)
    {
        return _members.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _msgTableView)
    {
        MsgTableViewCell *cell = (MsgTableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        return cell.height;
    }
    else if (tableView == _memberListView)
    {
        return 44;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _msgTableView)
    {
        MsgTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LiveTextMessageCell"];
        if (cell == nil)
        {
            cell = [[MsgTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LiveTextMessageCell"];
        }
        id msg = _msgDatas[indexPath.row];
        if ([msg isKindOfClass:[ILVLiveTextMessage class]])
        {
            ILVLiveTextMessage *textMsg = (ILVLiveTextMessage *)msg;
            [cell configMsg:textMsg.sendId ? textMsg.sendId : [[ILiveLoginManager getInstance] getLoginId] msg:textMsg.text];
        }
        if ([msg isKindOfClass:[ILVLiveCustomMessage class]])
        {
            ILVLiveCustomMessage *customMsg = (ILVLiveCustomMessage *)msg;
            [cell configTips:customMsg.sendId];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (tableView == _memberListView)
    {
        MemberListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LiveRoomMemberListCell"];
        if (cell == nil)
        {
            cell = [[MemberListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LiveRoomMemberListCell"];
        }
        MemberListItem *item = [_members objectAtIndex:indexPath.row];
        [cell configId:item];
        return cell;
    }
    return nil;
}

- (void)onMessage:(ILVLiveMessage *)msg
{
    [_msgDatas addObject:msg];
    if (_msgDatas.count >= 500)
    {
        
        NSRange range = NSMakeRange(_msgDatas.count - 100, 100);//只保留最新的100条消息
        NSArray *temp = [_msgDatas subarrayWithRange:range];
        [_msgDatas removeAllObjects];
        [_msgDatas addObjectsFromArray:temp];
        [_msgTableView reloadData];
    }
    else
    {
        [_msgTableView beginUpdates];
        NSIndexPath *index = [NSIndexPath indexPathForRow:_msgDatas.count - 1 inSection:0];
        [_msgTableView insertRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationBottom];
        [_msgTableView endUpdates];
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_msgDatas.count-1  inSection:0];
    if (indexPath.row < [_msgTableView numberOfRowsInSection:0])
    {
        [_msgTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

@end
