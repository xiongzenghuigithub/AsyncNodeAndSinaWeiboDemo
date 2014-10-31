

#import "SinaWeiboEngine.h"

//要使用SSL连接
#define kHostName                       @"api.weibo.com"
#define kXXX                            @"2/statuses/queryid"

#define kMaxQueeuSize                   10

static SinaWeiboEngine * engine = nil;

@interface SinaWeiboEngine () <WeiboSDKDelegate, WBHttpRequestDelegate> {
    NSOperationQueue * _operationQueue;
}

@end

@implementation SinaWeiboEngine

+ (SinaWeiboEngine *)sharedSinaWeiboEngine {
    if (engine == nil) {
        engine = [[SinaWeiboEngine alloc] initWithHostName:kHostName];
        
        [WeiboSDK enableDebugMode:YES];
        [WeiboSDK registerApp:kWeiboKey];
    }
    return engine;
}

- (NSOperationQueue *)getOperationQueue {
    if (_operationQueue == nil) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = kMaxQueeuSize;
    }
    return _operationQueue;
}

- (void)SSOAuthrize {
    
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = kWeiboRedirectURL;
    request.scope = @"all";
    request.userInfo = @{@"SSO_From": @"ViewController",
                         @"Other_Info_1": [NSNumber numberWithInt:123],
                         @"Other_Info_2": @[@"obj1", @"obj2"],
                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}
                         };
    [WeiboSDK sendRequest:request];
}

- (void)SSOLogoutWithCompletion:(void (^)(void))complet {
    [WeiboSDK logOutWithToken:self.weiboToken delegate:self withTag:nil];
}

- (void)invitFriendWithUID:(NSString *)uid JsonStringData:(NSString *)data Delegate:(id)delegate Tag:(NSString *)tag Completion:(void (^)(void))complet{
    if (delegate == nil) {
        [WeiboSDK inviteFriend:data withUid:uid withToken:_weiboToken delegate:self withTag:tag];
    }else {
        if ([delegate respondsToSelector:@selector(request:didFinishLoadingWithResult:)] && [delegate respondsToSelector:@selector(request:didFailWithError:)]) {
            [WeiboSDK inviteFriend:data withUid:uid withToken:_weiboToken delegate:delegate withTag:tag];
        }
    }
}

- (void)shareToSinaWeiboWithKind:(ShareKind)kind ShareContent:(NSDictionary *)content Completion:(void (^)(void))complet{
    
    WBMessageObject *message = [WBMessageObject message];
    __weak WBMessageObject * weakMsg = message;
    
    if (kind == Text) {
        message.text = [content objectForKey:@"message"];
    }
    else if (kind == Imange) {
        
        WBImageObject * obj = [WBImageObject object];
        __weak WBImageObject * weakObj = obj;
        NSURL * imageURL = [NSURL URLWithString:[content objectForKey:@"imageURL"]];
        NSURLRequest * req = [NSURLRequest requestWithURL:imageURL];
        [NSURLConnection sendAsynchronousRequest:req queue:[self getOperationQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            //异步请求回调函数中取得网络图片的NSData数据
            WBImageObject * imgObj = [WBImageObject object];
            [imgObj setImageData:data];
            message.imageObject = imgObj;
        }];
    }
    else if (kind == Multimudia) {
        WBWebpageObject * webpage = [WBWebpageObject object];
        webpage.objectID = [content objectForKey:@"objectID"];
        webpage.title = [content objectForKey:@"title"];
        webpage.description = [content objectForKey:@""];
        webpage.thumbnailData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"image_2" ofType:@"jpg"]];
        webpage.webpageUrl = [content objectForKey:@""];
        message.mediaObject = webpage;

    }
}


#pragma mark - WBHttpRequestDelegate 请求成功与失败 回调

- (void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result
{
    DDLogInfo(@"SinaWeiboEngine - didFinishLoadingWithResult: 收到网络回调结果 = %@" ,result);
}


- (void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error;
{
    DDLogError(@"SinaWeiboEngine - didFailWithError: 请求异常 = %@" ,error);
}

#pragma mark - WeiboSDKDelegate 接受sina微博服务器的响应
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request {
    
    DDLogInfo(@"SinaWeiboEngine - didReceiveWeiboRequest: ");
    
    if ([request isKindOfClass:WBProvideMessageForWeiboRequest.class])
    {
        
    }
    
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    
    DDLogInfo(@"SinaWeiboEngine - didReceiveWeiboResponse: ");
    
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {
        //发送消息回调
 
        int statusCode = response.statusCode;
        _userInfo = response.userInfo;
        _requestUserInfo = response.requestUserInfo;
    }
    else if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        //SSO授权回调
        
        int statusCode = response.statusCode;
        _userID = [(WBAuthorizeResponse *)response userID];
        _weiboToken = [(WBAuthorizeResponse *)response accessToken];
        _userInfo = [(WBAuthorizeResponse *)response userInfo];
        _requestUserInfo = [(WBAuthorizeResponse *)response requestUserInfo];
    }
}

#pragma mark - dealloc
- (void)dealloc {
    _userID = nil;
    _weiboToken = nil;
    _userInfo = nil;
    _requestUserInfo = nil;
    _operationQueue = nil;
}


@end
