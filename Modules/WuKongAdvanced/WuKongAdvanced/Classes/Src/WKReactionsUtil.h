//
//  WKReactionsUtil.h
//  WuKongAdvanced
//
//  Created by tt on 2022/8/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKReactionsUtil : NSObject

/**
  获取回应的emoji icon
 */
+(NSString*) getReactionIconURL:(NSString*)emoji;
@end

NS_ASSUME_NONNULL_END
