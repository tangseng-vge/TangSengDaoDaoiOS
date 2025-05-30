//
//  WKMomentPrivacySelect.m
//  WuKongMoment
//
//  Created by tt on 2022/11/29.
//

#import "WKMomentPrivacySelect.h"
#import <WuKongBase/WuKongBase.h>
@implementation WKMomentPrivacySelect

-(NSString*) privacyName {
    return [self privacyName:self.privacyKey];
}

-(NSString*) privacyName:(NSString*)privacyKey{
    if(!privacyKey) {
        return @"";
    }
    if([privacyKey isEqualToString:@"public"]) {
        return LLang(@"公开");
    }
    if([privacyKey isEqualToString:@"private"]) {
        return LLang(@"私密");
    }
    if([privacyKey isEqualToString:@"internal"]) {
        return LLang(@"部分可见");
    }
    if([privacyKey isEqualToString:@"prohibit"]) {
        return LLang(@"不给谁看");
    }
    return @"";
}

- (NSMutableArray *)contacts {
    if(!_contacts) {
        _contacts = [NSMutableArray array];
    }
    return _contacts;
}

- (NSMutableSet<NSString *> *)labelIDs {
    if(!_labelIDs) {
        _labelIDs = [NSMutableSet set];
    }
    return _labelIDs;
}

- (NSMutableSet<NSString *> *)labelUIDs {
    if(!_labelUIDs) {
        _labelUIDs = [NSMutableSet set];
    }
    return _labelUIDs;
}

- (NSMutableArray<NSString *> *)privacyUIDS {
    NSMutableArray<NSString*> *uids = [NSMutableArray array];
    if(self.labelUIDs && self.labelUIDs.count>0) {
        for (NSString *labelUID in self.labelUIDs) {
            [uids addObject:labelUID];
        }
    }
    if(self.contacts && self.contacts.count>0) {
        for (WKChannelInfo *channelInfo in self.contacts) {
            [uids addObject:channelInfo.channel.channelId];
        }
    }
    return uids;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    WKMomentPrivacySelect *select = [[[self class] allocWithZone:zone] init];
    select.privacyKey = self.privacyKey;
    select.privacyName = self.privacyName;
    select.displayName = self.displayName;
    select.contacts = [self.contacts mutableCopy];
    select.labelIDs = [self.labelIDs mutableCopy];
    select.labelUIDs = [self.labelUIDs mutableCopy];
    
    return select;
}

@end
