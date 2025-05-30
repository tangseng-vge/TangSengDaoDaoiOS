//
//  WKReactionsUtil.m
//  WuKongAdvanced
//
//  Created by tt on 2022/8/9.
//

#import "WKReactionsUtil.h"
#import "WKApp.h"
@implementation WKReactionsUtil

+(NSString*) getReactionIconURL:(NSString*)emoji{
    NSBundle *bundle = [WKApp.shared resourceBundleWithClass:self.class];
    return  [NSString stringWithFormat:@"file://%@",[bundle pathForResource:[NSString stringWithFormat:@"Other/reactions/%@",emoji] ofType:@"webp"]];
}

@end
