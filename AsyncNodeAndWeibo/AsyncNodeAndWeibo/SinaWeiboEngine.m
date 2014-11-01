

#import "SinaWeiboEngine.h"

//要使用SSL连接
#define kHostName                       @"api.weibo.com"
#define kLatestWeiboListPath            @"2/statuses/public_timeline.json"
#define kgetWeiboPath                   @"2/comments/show.json"
#define kgetUserInfoPath                @"2/users/show.json"
#define kReplyMessagePath               @"2/messages/reply.json"

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
        
        NSURL * imageURL = [content objectForKey:@"thumbnailDataURL"];
        NSURLRequest * req = [NSURLRequest requestWithURL:imageURL];
        [NSURLConnection sendAsynchronousRequest:req queue:[self getOperationQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            
            webpage.thumbnailData = data;
        }];
        
        webpage.webpageUrl = [content objectForKey:@""];
        message.mediaObject = webpage;
    }
    
    WBProvideMessageForWeiboResponse *response = [WBProvideMessageForWeiboResponse responseWithMessage:message];
    
    if ([WeiboSDK sendResponse:response])
    {
        if (complet != nil) {
            complet();//[调用该方法的控制器对象 dismissModalViewControllerAnimated:YES];
        }
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
#pragma mark - 发送消息回调
 
        int statusCode = response.statusCode;
        _userInfo = response.userInfo;
        _requestUserInfo = response.requestUserInfo;
    }
    else if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
#pragma mark - SSO授权回调
        
        int statusCode = response.statusCode;
        _userID = [(WBAuthorizeResponse *)response userID];
        _weiboToken = [(WBAuthorizeResponse *)response accessToken];
        _userInfo = [(WBAuthorizeResponse *)response userInfo];
        _requestUserInfo = [(WBAuthorizeResponse *)response requestUserInfo];
        _expirationDate = [(WBAuthorizeResponse *)response expirationDate];
    }
}

#pragma mark - Sina SDK 封装函数
- (void)getUserInfoWithCompletion:(void (^)(UserInfo * info))complet {
    
    NSDictionary * paramDict = @{
                                 @"source":kWeiboKey,
                                 @"access_token":[[SinaWeiboEngine sharedSinaWeiboEngine] weiboToken],
                                 @"uid":[[SinaWeiboEngine sharedSinaWeiboEngine] userID]
                                 };
    
    MKNetworkOperation * op = [[SinaWeiboEngine sharedSinaWeiboEngine] operationWithPath:kgetUserInfoPath params:paramDict httpMethod:@"GET" ssl:YES];
    [op setFreezable:YES];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary * jsonDict = [completedOperation responseJSON];
        DDLogInfo(@"jsonDict = %@", jsonDict);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        DDLogError(@"获取路径 %@ 失败: %@", kgetUserInfoPath, [error localizedDescription]);
    }];
    
    [[SinaWeiboEngine sharedSinaWeiboEngine] enqueueOperation:op];
}

- (void)getLatestWeiboWithComplet:(void (^)(NSArray * weiboList))complet {
    
    NSDictionary * paramDict = @{
                                 @"source":kWeiboKey,
                                 @"access_token":[[SinaWeiboEngine sharedSinaWeiboEngine] weiboToken],
                                 @"count":@"20"
                                 };
    
    MKNetworkOperation * op = [[SinaWeiboEngine sharedSinaWeiboEngine] operationWithPath:kLatestWeiboListPath params:paramDict httpMethod:@"GET" ssl:YES];
    
    [op setFreezable:YES];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        
        NSDictionary * jsonDict = [completedOperation responseJSON];
//        NSData * data = [completedOperation responseData];
//        UIImage * image = [completedOperation responseImage];
//        NSString * string = [completedOperation responseString];
        
        if ([completedOperation isCachedResponse]) {
            DDLogInfo(@"该请求的response数据已经缓存");
        }else{
            DDLogInfo(@"获取到新的数据: 最近的微博数");
            DDLogVerbose(@"responseJSON = %@", jsonDict);
        }
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        DDLogError(@"获取路径 = %@ 数据失败, error = %@", kLatestWeiboListPath, [error localizedDescription]);
    }];
    
    [[SinaWeiboEngine sharedSinaWeiboEngine] enqueueOperation:op];
    
}

- (void)getWeiboWithID:(NSString *)wbId Completion:(void (^)(Status * wb))complet {
    
    NSDictionary * paramDict = @{
                            @"source":kWeiboKey,
                            @"access_token":[[SinaWeiboEngine sharedSinaWeiboEngine] weiboToken],
                            @"id":wbId,
                                 };
    
    MKNetworkOperation * op = [[SinaWeiboEngine sharedSinaWeiboEngine] operationWithPath:kgetWeiboPath params:paramDict httpMethod:@"GET" ssl:YES];
    
    [op setFreezable:YES];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        
        NSDictionary * jsonDict = [completedOperation responseJSON];
        
        if ([completedOperation isCachedResponse]) {
            DDLogInfo(@"该请求的response数据已经缓存");
        }else{
            DDLogInfo(@"获取到新的数据: 最近的微博数");
            DDLogVerbose(@"responseJSON = %@", jsonDict);
        }
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        DDLogError(@"获取路径 = %@ 数据失败, error = %@", kgetWeiboPath, [error localizedDescription]);
    }];
    
    [[SinaWeiboEngine sharedSinaWeiboEngine] enqueueOperation:op];
}

- (void)replyMessageWithReceiverId:(NSString *)rid Data:(NSString *)data ReplyKind:(NSString *)kind Completion:(void (^)())complet {
    
    NSDictionary * paramDict = @{
                                 @"source":kWeiboKey,
                                 @"access_token":[[SinaWeiboEngine sharedSinaWeiboEngine] weiboToken],
                                 @"type":kind,
                                 @"data":[data stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                 @"receiver_id":rid,
                                 };
    
    MKNetworkOperation * op = [[SinaWeiboEngine sharedSinaWeiboEngine] operationWithPath:kReplyMessagePath params:paramDict httpMethod:@"POST" ssl:YES];
    
    [op setFreezable:YES];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        
    }];
    [[SinaWeiboEngine sharedSinaWeiboEngine] enqueueOperation:op];
}

#pragma mark - 异步获取网络图片NSData
- (void)getNetworkImage:(NSString *)url
             Completion:(void (^)(NSData * imageData))complet {
    
    //1. MKnetworkKitEngine 的 operationWithPath:params:httpMethod:ssl: => 在新开的线程执行网络请求
    MKNetworkOperation * op = [[SinaWeiboEngine sharedSinaWeiboEngine] operationWithPath:url params:nil httpMethod:@"GET" ssl:NO];
    
    [op setFreezable:YES];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        complet([completedOperation responseData]);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        DDLogError(@"访问 %@ 网络图片失败: %@", url, [error localizedDescription]);
    }];
}

#pragma mark - dealloc
- (void)dealloc {
    _userID = nil;
    _weiboToken = nil;
    _userInfo = nil;
    _requestUserInfo = nil;
    _expirationDate = nil;
    _operationQueue = nil;
}


@end
