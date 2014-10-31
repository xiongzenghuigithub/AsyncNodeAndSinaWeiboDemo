

#import "MKNetworkEngine.h"

typedef enum ShareKind{
    Text = 0,
    Imange,
    Multimudia
}ShareKind;

@interface SinaWeiboEngine : MKNetworkEngine


@property (nonatomic, copy) NSString * userID;
@property (nonatomic, copy) NSString * weiboToken;
@property (nonatomic, copy) NSDictionary * userInfo;
@property (nonatomic, copy) NSDictionary * requestUserInfo;


+ (SinaWeiboEngine *)sharedSinaWeiboEngine ;

- (NSOperationQueue *)getOperationQueue;

/** SSO的登录授权 */
- (void)SSOAuthrize;

/** 推出登陆 */
- (void)SSOLogoutWithCompletion:(void (^)(void))complet;

/** 邀请微博好友 - UID */
- (void)invitFriendWithUID:(NSString *)uid
            JsonStringData:(NSString *)data
                  Delegate:(id)delegate
                       Tag:(NSString *)tag
                Completion:(void (^)(void))complet;

/** 分享 Text/Image/MultiMedia */
- (void)shareToSinaWeiboWithKind:(ShareKind)kind
                    ShareContent:(NSDictionary *)content
                      Completion:(void (^)(void))complet;

/** 异步获取网络图片的NSData */
- (void)getNetworkImage:(NSString *)url
             Completion:(void (^)(NSData * imageData))complet;



@end
