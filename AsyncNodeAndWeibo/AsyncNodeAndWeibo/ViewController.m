

#import "ViewController.h"
#import "SinaWeiboEngine.h"

#import <AsyncDisplayKit/AsyncDisplayKit.h>

@interface ViewController () <UIAlertViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *ssoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [ssoButton setTitle:@"请求微博认证（SSO授权）" forState:UIControlStateNormal];
    [ssoButton addTarget:self action:@selector(ssoButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    ssoButton.frame = CGRectMake(20, 20, 280, 50);
    [self.view addSubview:ssoButton];
    
    UIButton *ssoOutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [ssoOutButton setTitle:@"退出微博认证" forState:UIControlStateNormal];
    [ssoOutButton addTarget:self action:@selector(ssoOutButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    ssoOutButton.frame = CGRectMake(20, CGRectGetMaxY(ssoButton.frame), 280, 50);
    [self.view addSubview:ssoOutButton];
    
    UIButton *userButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [userButton setTitle:@"获取用户信息" forState:UIControlStateNormal];
    [userButton addTarget:self action:@selector(userButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    userButton.frame = CGRectMake(20, CGRectGetMaxY(ssoOutButton.frame), 280, 50);
    [self.view addSubview:userButton];
    
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [shareButton setTitle:@"分享到微博" forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(shareButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    shareButton.frame = CGRectMake(20, CGRectGetMaxY(userButton.frame), 280, 50);
    [self.view addSubview:shareButton];
    
    UIButton *getWeiboListButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [getWeiboListButton setTitle:@"获取用户最近的微博列表" forState:UIControlStateNormal];
    [getWeiboListButton addTarget:self action:@selector(getWeiboListButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    getWeiboListButton.frame = CGRectMake(20, CGRectGetMaxY(shareButton.frame), 280, 50);
    [self.view addSubview:getWeiboListButton];
    
    UIButton *getWeiboButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [getWeiboButton setTitle:@"获取用户最近的微博" forState:UIControlStateNormal];
    [getWeiboButton addTarget:self action:@selector(getWeiboButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    getWeiboButton.frame = CGRectMake(20, CGRectGetMaxY(getWeiboListButton.frame), 280, 50);
    [self.view addSubview:getWeiboButton];
    
}

- (void)ssoButtonPressed{
    [[SinaWeiboEngine sharedSinaWeiboEngine] SSOAuthrize];
}

- (void)ssoOutButtonPressed{
    [[SinaWeiboEngine sharedSinaWeiboEngine] SSOLogoutWithCompletion:nil];
}

- (void)shareButtonPressed {
    [[[UIAlertView alloc] initWithTitle:@"选择分享类型" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"文字分享", @"图片分享", @"多媒体分享" , nil] show];
}

- (void)getWeiboListButtonPressed {
    
    [[SinaWeiboEngine sharedSinaWeiboEngine] getLatestWeiboWithComplet:^(NSArray *weiboList) {
        
    }];
}

- (void)getWeiboButtonPressed {
    
    NSString * weiBoId = @"3772069408149884";
    
    [[SinaWeiboEngine sharedSinaWeiboEngine] getWeiboWithID:weiBoId Completion:^(Status *wb) {
        
    }];
}

- (void)userButtonPressed {
    
    [[SinaWeiboEngine sharedSinaWeiboEngine] getUserInfoWithCompletion:^(UserInfo *info) {
        
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 1:
            DDLogInfo(@"文字分享");
            [[SinaWeiboEngine sharedSinaWeiboEngine] shareToSinaWeiboWithKind:Text ShareContent:nil  Completion:nil];
            break;
        case 2:
            DDLogInfo(@"图片分享");
            [[SinaWeiboEngine sharedSinaWeiboEngine] shareToSinaWeiboWithKind:Imange ShareContent:nil Completion:nil];
            break;
        case 3:
            DDLogInfo(@"多媒体分享");
            [[SinaWeiboEngine sharedSinaWeiboEngine] shareToSinaWeiboWithKind:Multimudia ShareContent:nil Completion:nil];
            break;
    }
}

@end
