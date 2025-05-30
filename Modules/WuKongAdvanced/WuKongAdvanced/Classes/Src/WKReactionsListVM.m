//
//  WKReactionsListVM.m
//  WuKongAdvanced
//
//  Created by tt on 2022/8/9.
//

#import "WKReactionsListVM.h"
#import "WKReactionsCell.h"
@implementation WKReactionsListVM

- (NSArray<NSDictionary *> *)tableSectionMaps {
    NSMutableArray *items = [NSMutableArray array];
    if(self.reactions) {
        for (WKReaction *reaction in self.reactions) {
            [items addObject:@{
                @"class": WKReactionsCellModel.class,
                @"reaction": reaction,
            }];
        }
    }
    
    return @[@{
        @"height":WKSectionHeight,
        @"items": items,
    }];
}

@end
