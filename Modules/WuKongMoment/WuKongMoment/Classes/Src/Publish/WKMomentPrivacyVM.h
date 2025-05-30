//
//  WKMomentPrivacyVM.h
//  WuKongMoment
//
//  Created by tt on 2020/11/13.
//

#import <WuKongBase/WuKongBase.h>
#import "WKMomentPrivacySelect.h"
NS_ASSUME_NONNULL_BEGIN

@interface WKMomentPrivacyVM : WKBaseTableVM

@property(nonatomic,strong) WKMomentPrivacySelect *momentPrivacySelect;
//
@property(nonatomic,strong) NSMutableSet<NSString*> *labelUIDs;
//
//@property(nonatomic,strong) NSMutableSet<NSString*> *selectedLabelIDs;


//-(NSString*) privacyName:(NSString*)privacyKey;

-(NSString*) selectItemName;

@end

NS_ASSUME_NONNULL_END
