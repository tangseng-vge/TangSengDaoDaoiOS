//
//  WKMomentDetailVC.m
//  WuKongMoment
// 朋友圈详情
//  Created by tt on 2020/11/17.
//

#import "WKMomentDetailVC.h"
#import "WKMomentCommentItemCell.h"
@interface WKMomentDetailVC ()<WKSimpleInputDelegate>

@property(nonatomic,strong) WKSimpleInput *input;
@property(nonatomic,strong) WKCommentResp *selectedComment; // 被选中的评论

@end

@implementation WKMomentDetailVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [WKMomentDetailVM new];
    }
    return self;
}

- (void)viewDidLoad {
    self.viewModel.momentNo = self.momentNo;
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.input];
    [self.view bringSubviewToFront:self.navigationBar];
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    [self adjustTable];
    [self scrollToBottomOnMain:NO];
    
    if(self.replyUID && ![self.replyUID isEqualToString:@""]) {
        self.input.placeholder = [NSString stringWithFormat:LLang(@"回复%@"),self.replyName];
    }
}

- (NSString *)langTitle {
    return LLang(@"详情");
}


- (CGRect)tableViewFrame {
    return CGRectMake(0.0f, 0.0f, WKScreenWidth, WKScreenHeight);
}


- (WKSimpleInput *)input {
    if(!_input) {
        _input = [WKSimpleInput new];
        _input.delegate = self;
    }
    return _input;
}

#pragma mark - WKSimpleInputDelegate

- (void)simpleInputUp:(WKSimpleInput *)input up:(BOOL)up {
    [self adjustTable];
}
- (void)simpleInput:(WKSimpleInput *)input heightChange:(CGFloat)height {
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.12f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [weakSelf adjustTable];
    } completion:nil];
}


- (void)simpleInput:(WKSimpleInput *)input sendText:(NSString *)text {
    
    WKCommentResp *commentResp = [WKCommentResp new];
    commentResp.uid = [WKApp shared].loginInfo.uid;
    commentResp.name = [WKApp shared].loginInfo.extra[@"name"];
    commentResp.content = text;
    if(self.selectedComment) {
        commentResp.replyUID = self.selectedComment.uid;
        commentResp.replyName = self.selectedComment.name;
    }
    commentResp.commentAt = [WKTimeTool getTimeString:[NSDate date] format:@"yyyy-MM-dd HH:mm"];
    WKMomentResp *moment = self.viewModel.moment;
    NSMutableArray *newComments =  [NSMutableArray arrayWithArray:moment.comments];
    [newComments addObject:commentResp];
    
    moment.comments = newComments;
    [self reloadData];
    [self.input endEditing:YES];
    
    WKCommentReq *req = [WKCommentReq new];
    req.content = text;
    if(self.selectedComment) {
        req.replyUID = self.selectedComment.uid;
        req.replyName = self.selectedComment.name;
        req.replyCommentID = self.selectedComment.sid;
    }
    __weak typeof(self) weakSelf = self;
    [self.viewModel requestCommentAdd:moment.momentNo req:req].then(^(NSDictionary *result){
        commentResp.sid = result[@"id"];
        [weakSelf reloadData];
    }).catch(^(NSError*error){
        [[WKNavigationManager shared].topViewController.view showHUDWithHide:error.domain];
    });
    [self scrollToBottomOnMain:true];

}

// 校准table的位置
-(void) adjustTable{
    
    CGFloat changeHeight = self.input.inputTotalHeight;
    
    [self adjustTableWithOffset:changeHeight];
    
}


- (void)scrollToBottomOnMain:(BOOL)animation{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self scrollToBottom:animation];
        
    });
}
- (void)scrollToBottom:(BOOL)animation{
    CGFloat adjustOffset = 44.0f; // 调整偏移
    if(self.tableView.contentSize.height<= [self visiableTableHeight]-adjustOffset) { // 如果内容高度小于或等于table的可示区域则不滚动
        return;
    }
    
    if(animation) {
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.12f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [weakSelf.tableView setContentOffset:CGPointMake(0, weakSelf.tableView.contentSize.height-weakSelf.tableView.lim_height)];
        } completion:nil];
        
    }else{
        [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height-self.tableView.lim_height)];
    }
}
// table的可视区域
-(CGFloat) visiableTableHeight {
    return self.tableView.lim_height-self.tableView.contentInset.top - self.tableView.contentInset.bottom;
    
}

-(void) layoutTable{
    self.tableView.lim_width = self.view.lim_width;
    self.tableView.lim_height = self.view.lim_height;
}

-(void) adjustTableWithOffset:(CGFloat)offset {
    self.tableView.lim_top = -offset;
    CGFloat statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    
    self.tableView.contentInset = UIEdgeInsetsMake(offset+(self.navigationBar.lim_height-statusHeight), 0, 0, 0);
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
}

-(void) showInputInCell:(UITableViewCell*)cell {
    self.input.hidden = NO;
    self.input.placeholder = LLang(@"评论");
    if(self.selectedComment) {
        self.input.placeholder = [NSString stringWithFormat:LLang(@"回复%@"),self.selectedComment.name];
    }
    [self.input becomeFirstResponder];
    __weak typeof(self) weakSelf = self;
    [UIView
        animateWithDuration:.25f
                 animations:^{
                     [weakSelf.tableView
                         setContentOffset:CGPointMake(0, cell.lim_bottom - WKScreenHeight + weakSelf.input.inputTotalHeight)
                                 animated:NO];
                 }];
}

- (void)tableView:(UITableView *)tableView touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.input endEditing:YES];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if([cell isKindOfClass:[WKMomentCommentItemCell class]]) {
        WKMomentCommentItemCell *commentCell = (WKMomentCommentItemCell*)cell;
        NSInteger commentIndex= [self commentInMomentIndex:commentCell.model.sid];
        self.selectedComment = self.viewModel.moment.comments[commentIndex];
        if([self.selectedComment.uid isEqualToString:[WKApp shared].loginInfo.uid]) {
            WKActionSheetView2 *sheet = [WKActionSheetView2 initWithTip:LLang(@"删除这条评论？")];
            __weak typeof(self) weakSelf  = self;
            [sheet addItem:[WKActionSheetButtonItem2 initWithAlertTitle:LLang(@"删除") onClick:^{
                [weakSelf.tableView beginUpdates];
                NSMutableArray *newComments = [NSMutableArray arrayWithArray:weakSelf.viewModel.moment.comments];
                [newComments removeObjectAtIndex:commentIndex];
                weakSelf.viewModel.moment.comments = newComments;
                NSMutableArray *newItems =  [NSMutableArray arrayWithArray:weakSelf.items[indexPath.section].items];
                [newItems removeObjectAtIndex:indexPath.row];
                weakSelf.items[indexPath.section].items = newItems;
                [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                [weakSelf.tableView endUpdates];
                
                [weakSelf.viewModel requestCommentDel:weakSelf.viewModel.moment.momentNo commentID:weakSelf.selectedComment.sid].catch(^(NSError *error){
                    [[WKNavigationManager shared].topViewController.view showHUDWithHide:error.domain];
                });
            }]];
            [sheet show];
        }else{
            [self showInputInCell:cell];
        }
    }
}

-(NSInteger) commentInMomentIndex:(NSString*)sid{
    WKMomentResp *moment = self.viewModel.moment;
    if(moment.comments) {
        for (NSInteger i=0;i<moment.comments.count; i++) {
            WKCommentResp *comment = moment.comments[i];
            if([sid isEqualToString:comment.sid]) {
                return i;
            }
        }
    }
    return -1;
}
@end
