//
//  WKReceiptListVC.m
//  WuKongBase
//
//  Created by tt on 2021/4/10.
//

#import "WKReceiptListVC.h"
#import "WKReceiptListCell.h"
#import "WKReceiptClient.h"
#import "WKReceiptListCell.h"
@interface WKReceiptListVC ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UIView *headerView;

@property(nonatomic,strong) UIButton *readedTab;
@property(nonatomic,strong) UIButton *unreadTab;

@property(nonatomic,strong) NSArray<WKReadedUserResp*> *readedItems;
@property(nonatomic,strong) NSArray<WKUnreadUserResp*> *unreadItems;

@property(nonatomic,strong) UIView *indicatorView;

@property(nonatomic,strong) UIScrollView *bodyView;

@property(nonatomic,strong) UITableView *readedTableView;

@property(nonatomic,strong) UITableView *unreadTableView;

@property(nonatomic,assign) NSInteger currentTabIndex;

@property(nonatomic,strong) UIView *emptyView; // 空view解决左侧滑动冲突问题

@end

@implementation WKReceiptListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = [NSString stringWithFormat:LLang(@"已读(%d)"),self.readedCount];
    
    
    
    self.currentTabIndex = -1;
    
    [self refreshReadedCount:self.readedCount];
    [self refreshUnreadCount:self.unreadCount];
    
//    [self.view addSubview:self.headerView];
//    [self.headerView addSubview:self.readedTab];
//    [self.headerView addSubview:self.unreadTab];
//    [self.headerView addSubview:self.indicatorView];
    
    [self.view addSubview:self.bodyView];
    [self.bodyView addSubview:self.readedTableView];
    [self.bodyView addSubview:self.unreadTableView];
    
    [self tabSelected:0];
    
    [self.view addSubview:self.emptyView];
}

- (NSArray<WKUnreadUserResp *> *)unreadItems {
    if(!_unreadItems) {
        _unreadItems = [NSArray array];
    }
    return _unreadItems;
}

- (NSArray<WKReadedUserResp *> *)readedItems {
    if(!_readedItems) {
        _readedItems = [NSArray array];
    }
    return _readedItems;
}

- (UIView *)headerView {
    if(!_headerView) {
        CGRect visibleRect = [self visibleRect];
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(visibleRect.origin.x, visibleRect.origin.y, visibleRect.size.width, 50.0f)];
        [_headerView setBackgroundColor:[WKApp shared].config.cellBackgroundColor];
    }
    return _headerView;
}

-(UIView*) indicatorView {
    if(!_indicatorView) {
        _indicatorView = [[UIView alloc] init];
        _indicatorView.lim_height = 2.0f;
        _indicatorView.lim_top = self.headerView.lim_height - _indicatorView.lim_height;
        _indicatorView.backgroundColor = [WKApp shared].config.themeColor;
        _indicatorView.lim_width = self.headerView.lim_width/2.0f - 40.0f;
        _indicatorView.lim_left = (self.headerView.lim_width/2.0f)/2.0f - _indicatorView.lim_width/2.0f;
    }
    return _indicatorView;
}

- (UIView *)emptyView {
    if(!_emptyView) {
        _emptyView = [[UIView alloc] init];
        _emptyView.lim_height = self.view.lim_height;
        _emptyView.lim_width = 20.0f;
        [_emptyView setBackgroundColor:[UIColor clearColor]];
    }
    return _emptyView;
}

- (UIButton *)readedTab {
    if(!_readedTab) {
        _readedTab = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.headerView.lim_width/2.0f, self.headerView.lim_height)];
        [[_readedTab titleLabel] setFont:[[WKApp shared].config appFontOfSize:14.0f]];
        [_readedTab addTarget:self action:@selector(readedTap) forControlEvents:UIControlEventTouchUpInside];
    }
    return _readedTab;
}

-(void) readedTap {
    [self changeToTab:0];
}
- (UIButton *)unreadTab {
    if(!_unreadTab) {
        _unreadTab = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.headerView.lim_width/2.0f, self.headerView.lim_height)];
        _unreadTab.lim_left = self.headerView.lim_width/2.0f;
        [[_unreadTab titleLabel] setFont:[[WKApp shared].config appFontOfSize:14.0f]];
        [_unreadTab addTarget:self action:@selector(unreadTap) forControlEvents:UIControlEventTouchUpInside];
    }
    return _unreadTab;
}
-(void) unreadTap {
    [self changeToTab:1];
}

- (UIScrollView *)bodyView {
    if(!_bodyView) {
        _bodyView = [[UIScrollView alloc] initWithFrame:[self visibleRect]];
//        _bodyView.lim_top = _bodyView.lim_top + self.headerView.lim_height;
//        _bodyView.lim_height = _bodyView.lim_height - self.headerView.lim_height;
//        [_bodyView setContentSize:CGSizeMake(_bodyView.lim_width*2, _bodyView.lim_height)];
        _bodyView.delegate = self;
        _bodyView.pagingEnabled = YES;
        _bodyView.scrollEnabled = YES;
    }
    return _bodyView;
}


- (UITableView *)readedTableView {
    if(!_readedTableView) {
        _readedTableView = [[UITableView alloc] initWithFrame:self.bodyView.bounds];
        _readedTableView.delegate = self;
        _readedTableView.dataSource = self;
        _readedTableView.tableHeaderView =  [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.001)];
        _readedTableView.tableFooterView = [[UIView alloc] init];
        [_readedTableView.tableHeaderView setBackgroundColor:[UIColor whiteColor]];
        _readedTableView.backgroundColor=[UIColor clearColor];
        _readedTableView.sectionIndexBackgroundColor = [UIColor clearColor];
        _readedTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_readedTableView registerClass:WKReceiptListCell.class forCellReuseIdentifier:@"WKReceiptListCell"];
    }
    return _readedTableView;
}

- (UITableView *)unreadTableView {
    if(!_unreadTableView) {
        _unreadTableView = [[UITableView alloc] initWithFrame:self.bodyView.bounds];
        _unreadTableView.lim_left = self.bodyView.lim_width;
        _unreadTableView.delegate = self;
        _unreadTableView.dataSource = self;
        _unreadTableView.tableHeaderView =  [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.001)];
        _unreadTableView.tableFooterView = [[UIView alloc] init];
        [_unreadTableView.tableHeaderView setBackgroundColor:[UIColor whiteColor]];
        _unreadTableView.backgroundColor=[UIColor clearColor];
        _unreadTableView.sectionIndexBackgroundColor = [UIColor clearColor];
        _unreadTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_unreadTableView registerClass:WKReceiptListCell.class forCellReuseIdentifier:@"WKReceiptListCell"];
    }
    return _unreadTableView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView == self.bodyView) {
        self.indicatorView.lim_left = scrollView.contentOffset.x/2.0f + ((self.headerView.lim_width/2.0f)/2.0f - _indicatorView.lim_width/2.0f);
        if(scrollView.contentOffset.x<=0) {
            [self tabSelected:0];
        }else if(scrollView.contentOffset.x>self.headerView.lim_width/2.0f){
            [self tabSelected:1];
        }
    }
    
}

-(void) changeToTab:(NSInteger)index {
    [self tabSelected:index];
    if(index==0) {
        [self.bodyView setContentOffset:CGPointMake(0.0f, 0.0f) animated:YES];
    }else{
        [self.bodyView setContentOffset:CGPointMake(self.view.lim_width, 0.0f) animated:YES];
    }
    
}

-(void) tabSelected:(NSInteger)index {
    if(self.currentTabIndex == index) {
        return;
    }
    if(index==0) {
        [self.readedTab setTitleColor:[WKApp shared].config.themeColor forState:UIControlStateNormal];
        [self.unreadTab setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
        __weak typeof(self) weakSelf = self;
        [[WKReceiptClient shared] readedList:self.channel messageID:self.messageID].then(^(NSArray<WKReadedUserResp*>*results){
            weakSelf.readedItems = results;
            [weakSelf.readedTableView reloadData];
            
            [self refreshReadedCount:results.count];
        }).catch(^(NSError *error){
            [weakSelf.view showMsg:error.domain];
        });
    }else if(index == 1){
        [self.unreadTab setTitleColor:[WKApp shared].config.themeColor forState:UIControlStateNormal];
        [self.readedTab setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        __weak typeof(self) weakSelf = self;
        [[WKReceiptClient shared] unreadList:self.channel messageID:self.messageID].then(^(NSArray<WKUnreadUserResp*>*results){
            weakSelf.unreadItems = results;
            [weakSelf.unreadTableView reloadData];
            
            [weakSelf refreshUnreadCount:results.count];
        }).catch(^(NSError *error){
            [weakSelf.view showMsg:error.domain];
        });
    }
    self.currentTabIndex = index;
}

-(void) refreshUnreadCount:(NSInteger)unreadCount {
    [self.unreadTab setTitle:[NSString stringWithFormat:LLang(@"未读(%d)"),unreadCount] forState:UIControlStateNormal];
}
-(void) refreshReadedCount:(NSInteger)readedCount {
    [self.readedTab setTitle:[NSString stringWithFormat:LLang(@"已读(%d)"),readedCount] forState:UIControlStateNormal];
}

- (void)viewConfigChange:(WKViewConfigChangeType)type {
    [super viewConfigChange:type];
    
    if(type == WKViewConfigChangeTypeStyle) {
        [self.headerView setBackgroundColor:[WKApp shared].config.cellBackgroundColor];
    }
   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WKReceiptListCell *cell;
    if(tableView == self.readedTableView) {
        cell = [self.readedTableView dequeueReusableCellWithIdentifier:@"WKReceiptListCell"];
       WKReadedUserResp *user =  [self.readedItems objectAtIndex:indexPath.row];
        [cell.avatarImgView lim_setImageWithURL:[NSURL URLWithString:[WKAvatarUtil getAvatar:user.uid]] placeholderImage:[WKApp shared].config.defaultAvatar];
        
        NSString *name;
        WKChannelInfo *personChannelInfo = [WKChannelManager.shared getCache:[WKChannel personWithChannelID:user.uid]];
        if(personChannelInfo && personChannelInfo.remark && ![personChannelInfo.remark isEqualToString:@""]) {
            name = personChannelInfo.remark;
        }
        if(!name) {
            WKChannelMember *channelMember = [WKChannelManager.shared getMember:self.channel uid:user.uid];
            if(channelMember) {
                name = channelMember.displayName;
            }
        }
        if(!name) {
            name = user.name;
        }
       
        cell.nameLbl.text = name;
        [cell.nameLbl sizeToFit];
    }else{
        cell = [self.unreadTableView dequeueReusableCellWithIdentifier:@"WKReceiptListCell"];
       WKUnreadUserResp *user =  [self.unreadItems objectAtIndex:indexPath.row];
        [cell.avatarImgView lim_setImageWithURL:[NSURL URLWithString:[WKAvatarUtil getAvatar:user.uid]] placeholderImage:[WKApp shared].config.defaultAvatar];
        cell.nameLbl.text = user.name;
        [cell.nameLbl sizeToFit];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.readedTableView) {
        return self.readedItems.count;
    }
    return self.unreadItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *uid = @"";
    if(tableView == self.readedTableView) {
       WKReadedUserResp *user =   [self.readedItems objectAtIndex:indexPath.row];
        uid = user.uid;
       
    }else {
        WKUnreadUserResp *user =   [self.unreadItems objectAtIndex:indexPath.row];
        uid = user.uid;
    }
    WKChannelMember *member = [[WKChannelMemberDB shared] get:self.channel memberUID:uid];
    NSString *vercode = @"";
    if(member && member.extra && member.extra[@"vercode"]) {
        vercode = member.extra[@"vercode"];
    }
    [[WKApp shared] invoke:WKPOINT_USER_INFO param:@{
        @"channel": self.channel,
        @"vercode": vercode,
        @"uid": uid,
    }];
}



@end
