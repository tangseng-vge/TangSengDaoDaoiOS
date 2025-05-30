//
//  WKFileContent.m
//  WuKongFile
//
//  Created by tt on 2020/5/5.
//

#import "WKFileContent.h"

@interface WKFileContent ()
@property(nonatomic,strong) NSData *fileData;

@end

@implementation WKFileContent

+(WKFileContent*) initWithFileName:(NSString*)fileName fileData:(NSData*)data {
    WKFileContent *fileContent = [WKFileContent new];
    fileContent.name = fileName;
    fileContent.fileData = data;
    fileContent.size = data.length;
    return fileContent;
}

- (NSDictionary *)encodeWithJSON {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"name"] = self.name;
    if(self.url && ![self.url isEqualToString:@""]) {
        dict[@"url"] = self.url;
    }else{
        dict[@"url"] = self.remoteUrl;
    }
    dict[@"size"] = @(self.size);
    return dict;
}

- (void)decodeWithJSON:(NSDictionary *)contentDic {
    self.name = contentDic[@"name"];
    self.url = contentDic[@"url"];
    self.remoteUrl = self.url;
    self.size = contentDic[@"size"]?[contentDic[@"size"] integerValue]:0;
}

- (void) writeDataToLocalPath {
    [super writeDataToLocalPath];
    if(self.fileData) {
        [self.fileData writeToFile:self.localPath atomically:YES];
    }
    
}

- (NSString *)localPath {
    NSString *uid = [WKSDK shared].options.connectInfo.uid;
    return   [NSString stringWithFormat:@"%@/%@/%@",[WKSDK shared].options.messageFileRootDir,uid, [self getLocalRelativePath]];
}
-(NSString*) getLocalRelativePath{
   WKChannel *channel =  self.message.channel;
    NSString *extension = [self.name pathExtension];
    NSString *realName = [self.name stringByReplacingOccurrencesOfString:extension withString:@""];
    NSString *fullName = @"";
    if(self.extra[@"extNum"]) {
        fullName = [NSString stringWithFormat:@"%@ %d%@",realName,[self.extra[@"extNum"] intValue],extension];
    }else {
        fullName = [NSString stringWithFormat:@"%@%@",realName,extension];
    }
    return [NSString stringWithFormat:@"%@/%@",[self getChannelDir:channel],fullName];
}
-(NSString*) getChannelDir:(WKChannel*) channel {
    return [NSString stringWithFormat:@"%d/%@",channel.channelType,channel.channelId];
}

+(NSNumber*) contentType {
    return @(WK_FILE);
}


- (NSString *)conversationDigest {
    return LLang(@"[文件]");
}

- (NSString *)searchableWord {
    return @"[文件]";
}

@end
