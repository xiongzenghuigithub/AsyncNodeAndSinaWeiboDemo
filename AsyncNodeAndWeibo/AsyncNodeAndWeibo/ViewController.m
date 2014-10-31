

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
    ssoButton.frame = CGRectMake(20, 250, 280, 50);
    [self.view addSubview:ssoButton];
    
    UIButton *ssoOutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [ssoOutButton setTitle:@"请求微博认证（SSO授权）" forState:UIControlStateNormal];
    [ssoOutButton addTarget:self action:@selector(ssoOutButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    ssoOutButton.frame = CGRectMake(20, CGRectGetMaxY(ssoButton.frame), 280, 50);
    [self.view addSubview:ssoOutButton];
    
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [shareButton setTitle:@"分享到微博" forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(shareButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    shareButton.frame = CGRectMake(20, CGRectGetMaxY(ssoOutButton.frame), 280, 50);
    [self.view addSubview:shareButton];
    
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
