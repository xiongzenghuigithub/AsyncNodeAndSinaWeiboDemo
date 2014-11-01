

#import "MKNetworkEngine.h"
#import "Status.h"
#include "UserInfo.h"

typedef enum ShareKind{
    Text = 0,
    Imange,
    Multimudia
}ShareKind;


@interface SinaWeiboEngine : MKNetworkEngine


@property (nonatomic, copy) NSString * userID;
@property (nonatomic, copy) NSString * weiboToken;
@property (nonatomic, copy) NSDate * expirationDate;
@property (nonatomic, copy) NSDictionary * userInfo;
@property (nonatomic, copy) NSDictionary * requestUserInfo;


+ (SinaWeiboEngine *)sharedSinaWeiboEngine ;

- (NSOperationQueue *)getOperationQueue;

/** SSO的登录授权 */
- (void)SSOAuthrize;

/** 退出登陆 */
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

/** 获取用户信息 */
- (void)getUserInfoWithCompletion:(void (^)(UserInfo * info))complet;

/** 返回最新的200条公共微博 , child path: statuses/public_timeline */
- (void)getLatestWeiboWithComplet:(void (^)(NSArray * weiboList))complet;

/** 查询指定id微博 */
- (void)getWeiboWithID:(NSString *)wbId
            Completion:(void (^)(Status * wb))complet;

/** 对接收到的指定新消息进行回复 (text：纯文本、articles：图文、position：位置)*/
- (void)replyMessageWithReceiverId:(NSString *)rid
                              Data:(NSString *)data
                         ReplyKind:(NSString *)kind
                        Completion:(void (^)())complet;

/** 异步获取网络图片的NSData */
- (void)getNetworkImage:(NSString *)url
             Completion:(void (^)(NSData * imageData))complet;



@end
