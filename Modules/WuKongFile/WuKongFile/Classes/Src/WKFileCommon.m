//
//  WKFileCommon.m
//  WuKongFile
//
//  Created by tt on 2020/5/5.
//

#import "WKFileCommon.h"

@implementation WKFileInfoModel



@end

@interface WKFileCommon ()

@property(nonatomic,strong) NSArray *imgExtends;
@property(nonatomic,strong) NSArray *docExtends;
@property(nonatomic,strong) NSArray *xlsExtends;

@end

@implementation WKFileCommon

static WKFileCommon *_instance;


+ (id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}
+ (WKFileCommon *)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        
    });
    return _instance;
}

-(WKFileInfoModel*) fileInfoWithName:(NSString*)name {
    if(!name) {
        return nil;
    }
    WKFileInfoModel *fileInfoModel = [WKFileInfoModel new];
    WKFileType fileType = [self getFileType:name];
    switch (fileType) {
        case WKFileTypeWord:
            fileInfoModel.extendIcon = @"Word";
            fileInfoModel.fileColor = [UIColor colorWithRed:73.0f/255.0f green:126.0f/255.0f blue:247.0f/255.0f alpha:1.0f];
            break;
        case WKFileTypeExcel:
            fileInfoModel.extendIcon = @"Excel";
            fileInfoModel.fileColor = [UIColor colorWithRed:39.0f/255.0f green:204.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
            break;
        case WKFileTypePPT:
            fileInfoModel.extendIcon = @"Ppt";
            fileInfoModel.fileColor = [UIColor colorWithRed:255.0f/255.0f green:182.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
            break;
        case WKFileTypePDF:
            fileInfoModel.extendIcon = @"Pdf";
            fileInfoModel.fileColor = [UIColor colorWithRed:255.0f/255.0f green:91.0f/255.0f blue:16.0f/255.0f alpha:1.0f];
            break;
         case WKFileTypeZIP:
            fileInfoModel.extendIcon = @"Zip";
            fileInfoModel.fileColor = [UIColor colorWithRed:234.0f/255.0f green:156.0f/255.0f blue:112.0f/255.0f alpha:1.0f];
            break;
         case WKFileTypeRAR:
            fileInfoModel.extendIcon = @"Rar";
            fileInfoModel.fileColor = [UIColor colorWithRed:245.0f/255.0f green:180.0f/255.0f blue:80.0f/255.0f alpha:1.0f];
            break;
        default:
            fileInfoModel.extendIcon = @"File";
            fileInfoModel.fileColor = [UIColor colorWithRed:255.0f/255.0f green:182.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
            break;
    }
    return fileInfoModel;
}

-(WKFileType) getFileType:(NSString*)name {
   NSString *extension = [name pathExtension];
    extension = [extension lowercaseString];
    if([self.imgExtends containsObject:extension]) {
        return WKFileTypeImage;
    }
    if([self.docExtends containsObject:extension]) {
        return WKFileTypeWord;
    }
    if([self.xlsExtends containsObject:extension]) {
        return WKFileTypeExcel;
    }
    if([extension isEqualToString:@"zip"]) {
        return WKFileTypeZIP;
    }
    if([extension isEqualToString:@"rar"]) {
        return WKFileTypeRAR;
    }
    if([extension isEqualToString:@"ppt"]) {
        return WKFileTypePPT;
    }
    if([extension isEqualToString:@"pdf"]) {
        return WKFileTypePDF;
    }
    if([extension isEqualToString:@"pages"]) {
        return WKFileTypePages;
    }
    if([self.textExtends containsObject:extension]) {
        return WKFileTypeText;
    }
    return WKFileTypeUnknown;
}

- (NSArray *)imgExtends {
    return @[@"png",@"jpg",@"jpeg",@"bmp",@"gif"];
}

- (NSArray *)docExtends {
    return @[@"doc",@"docx"];
}

- (NSArray *)xlsExtends {
    return @[@"xls",@"xlsx"];
}
- (NSArray *)textExtends {
    return @[@"txt",@"log"];
}

-(NSString*) sizeFormat:(NSInteger)size {
   if (size < 1024) {
       return [NSString stringWithFormat:@"%ld B",(long)size];
    }
    if (size > 1024 && size < 1024 * 1024) {
        return [NSString stringWithFormat:@"%0.2f KB",size/1024.0f];
    }
    if (size > 1024 * 1024 && size < 1024 * 1024 * 1024) {
        return [NSString stringWithFormat:@"%0.2f M",size/(1024.0f*1024.0f)];
    }
    return [NSString stringWithFormat:@"%0.2f G",size/(1024.0f*1024.0f*1024.0f)];
}

-(BOOL) support:(NSString*)filename {
    WKFileType fileType = [self getFileType:filename];
    switch (fileType) {
        case WKFileTypePDF:
        case WKFileTypeText:
        case WKFileTypeImage:
        case WKFileTypeWord:
        case WKFileTypeExcel:
        case WKFileTypePages:
            return true;
        default:
            break;
    }
    return false;
}
@end
