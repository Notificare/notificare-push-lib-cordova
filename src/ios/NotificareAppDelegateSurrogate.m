/*
 Copyright 2015 Notificare B.V.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "NotificareAppDelegateSurrogate.h"

NSString * const NotificareDefaultDelegateNilException = @"NotificareDefaultDelegateNilException";

@interface NotificareAppDelegateSurrogate()

@property (nonatomic, readwrite, copy) NSDictionary *launchOptions;

@end

@implementation NotificareAppDelegateSurrogate

// Get the shared instance and create it if necessary.
+ (NotificareAppDelegateSurrogate *)shared {
    
    static NotificareAppDelegateSurrogate *shared = nil;
    
    if (shared == nil) {
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            shared = [[NotificareAppDelegateSurrogate alloc] init];
            
        });
    }
    return shared;
}

/* this method is called the moment the class is made known to the obj-c runtime,
 before app launch completes. */
+ (void)load {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:[NotificareAppDelegateSurrogate shared] selector:@selector(handleLaunchNotification:) name:@"UIApplicationDidFinishLaunchingNotification" object:nil];
}

- (void)handleLaunchNotification:(NSNotification *)notification {
    [self setLaunchOptions:[notification userInfo]];
    //swap pointers with the initial app delegate
    @synchronized ([UIApplication sharedApplication]) {
        [self setDefaultAppDelegate:[[UIApplication sharedApplication] delegate]];
        [[UIApplication sharedApplication] setDelegate:self];
    }
}

- (void)clearLaunchOptions {
    [self setLaunchOptions:nil];
}

#pragma mark Message forwarding

- (void)forwardInvocation:(NSInvocation *)invocation {
    SEL selector = [invocation selector];
    // Throw the exception here to make debugging easier. We are going to forward the invocation to the
    // defaultAppDelegate without checking if it responds for the purpose of crashing the app in the right place
    // if the delegate does not respond which would be expected behavior. If the defaultAppDelegate is nil, we
    // need to exception here, and not fail silently.
    if (!_defaultAppDelegate) {
        NSString *errorMsg = @"NotificareAppDelegateSurrogate defaultAppDelegate was nil while forwarding an invocation";
        NSException *defaultAppDelegateNil = [NSException exceptionWithName:NotificareDefaultDelegateNilException
                                                                     reason:errorMsg
                                                                   userInfo:nil];
        [defaultAppDelegateNil raise];
    }
    
    BOOL responds = NO;
    
    //give the surrogate and default app delegates an opportunity to handle the message
    if ([_surrogateDelegate respondsToSelector:selector]) {
        responds = YES;
        [invocation invokeWithTarget:_surrogateDelegate];
    }
    if ([_defaultAppDelegate respondsToSelector:selector]) {
        responds = YES;
        [invocation invokeWithTarget:_defaultAppDelegate];
    }
    
    if (!responds) {
        //in the off chance that neither app delegate responds, forward the message
        //to the default app delegate anyway.  this will likely result in a crash,
        //but that way the exception will come from the expected location
        [invocation invokeWithTarget:_defaultAppDelegate];
    }
    
}


- (BOOL)respondsToSelector:(SEL)selector {
    if ([super respondsToSelector:selector]) {
        return YES;
    }
    
    else {
        //if this isn't a selector we normally respond to, say we do as long as either delegate does
        if ([_defaultAppDelegate respondsToSelector:selector] || [_surrogateDelegate respondsToSelector:selector]) {
            return YES;
        }
    }
    
    return NO;
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector {
    NSMethodSignature *signature = nil;
    // First non nil method signature returns
    signature = [super methodSignatureForSelector:selector];
    if (signature) return signature;
    
    signature = [_defaultAppDelegate methodSignatureForSelector:selector];
    if (signature) return signature;
    
    signature = [_surrogateDelegate methodSignatureForSelector:selector];
    if (signature) return signature;
    
    // If none of the above classes return a non nil method signature, this will likely crash
    return signature;
}

@end

