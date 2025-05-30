//
//  WKMomentMsgManager.h
//  WuKongMoment
//
//  Created by tt on 2020/11/25.
//

#import <Foundation/Foundation.h>
#import <WuKongBase/WuKongBase.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WKMomentMsgManagerDelegate <NSObject>

@optional

-(void) recvMomentCMDMsg:(WKCMDModel*)cmd;

@end

@interface WKMomentMsgManager : NSObject

+ (WKMomentMsgManager *)shared;

-(void) setup;

-(void) addDelegate:(id<WKMomentMsgManagerDelegate>) delegate;
- (void)removeDelegate:(id<WKMomentMsgManagerDelegate>) delegate;

@end

NS_ASSUME_NONNULL_END
