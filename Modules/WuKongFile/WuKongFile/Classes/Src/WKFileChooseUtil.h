//
//  WKFileChooseUtil.h
//  WuKongContacts
//
//  Created by tt on 2020/7/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^fileChooseComplete)(NSString *fileName,NSData *fileData);

@interface WKFileChooseUtil : NSObject

+(WKFileChooseUtil*) shared;

-(void) chooseFile:(fileChooseComplete)complete onCancel:(void(^)(void))onCancel;

@end

NS_ASSUME_NONNULL_END
