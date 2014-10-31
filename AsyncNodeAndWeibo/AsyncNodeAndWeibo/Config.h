

#ifndef AsyncNodeAndWeibo_Config_h
#define AsyncNodeAndWeibo_Config_h




#import <CocoaLumberjack/CocoaLumberjack.h>
#import "WeiboSDK.h"


#define kWeiboKey               @"2266597180"
#define kWeiboSecret            @"363da3b3d7381312f4bcdbe79d920e39"
#define kWeiboRedirectURL       @"https://api.weibo.com/oauth2/default.html"


//定义日志显示的级别
#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE; //设置自定义log级别以下日志都可以看见
#else
static const int ddLogLevel = LOG_LEVEL_OFF; //发布版本时, 直接关闭所有日志输出
#endif

#import "AppDelegate.h"
#define APP_DELEGATE (AppDelegate*)[[UIApplication sharedApplication] delegate]

#endif
