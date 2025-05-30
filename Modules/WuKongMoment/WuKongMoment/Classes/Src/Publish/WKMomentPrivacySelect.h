//
//  WKMomentPrivacySelect.h
//  WuKongMoment
//
//  Created by tt on 2022/11/29.
//

#import <Foundation/Foundation.h>
#import <WuKongIMSDK/WuKongIMSDK.h>
NS_ASSUME_NONNULL_BEGIN

@interface WKMomentPrivacySelect : NSObject<NSCopying>


@property(nonatomic,copy) NSString *privacyKey;

@property(nonatomic,copy) NSString *privacyName;

@property(nonatomic,copy) NSString *displayName;

@property(nonatomic,strong) NSMutableArray<WKChannelInfo*> *contacts;

@property(nonatomic,strong) NSMutableSet<NSString*> *labelIDs;

@property(nonatomic,strong) NSMutableSet<NSString*> *labelUIDs;

@property(nonatomic,strong) NSMutableArray<NSString*> *privacyUIDS;

-(NSString*) privacyName:(NSString*)privacyKey;



@end

NS_ASSUME_NONNULL_END
