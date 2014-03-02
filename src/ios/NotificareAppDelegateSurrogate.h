//
// Copyright 2014 Notificare
//

#import <Foundation/Foundation.h>

extern NSString * const NotificareDefaultDelegateNilException;

@interface NotificareAppDelegateSurrogate : NSObject <UIApplicationDelegate>

@property(nonatomic, strong) NSObject<UIApplicationDelegate> *surrogateDelegate;
@property(nonatomic, strong) NSObject<UIApplicationDelegate> *defaultAppDelegate;
@property(nonatomic, readonly, copy) NSDictionary *launchOptions;

+ (NotificareAppDelegateSurrogate *)shared;
- (void)clearLaunchOptions;

@end
