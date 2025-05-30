
## 文档地址

https://tsdaodao.com/dev/ios/intro.html

修复问题：
ios 输入文字的时候查看图片 不会隐藏键盘 （已修复）- WKImageMessageCell：231行
ios 聊天时收到新消息 有概率不显示 （难-待定）
ios 输入框输入时 长按之前的信息弹出菜单没有隐藏键盘（已修复）- WKMessageCell：377行
ios 有时候点击图片可能闪退（已修复）- YBIBUtilities：102行，替换 UIImage *YBIBSnapshotView(UIView *view)  的实现：
```
UIImage *YBIBSnapshotView(UIView *view) {
    if (@available(iOS 10.0, *)) {
        UIGraphicsImageRendererFormat *format = [[UIGraphicsImageRendererFormat alloc] init];
        format.scale = [UIScreen mainScreen].scale;
        format.opaque = YES;
        UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:view.bounds.size format:format];
        UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull context) {
            [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
        }];
        return image;
    } else {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, [UIScreen mainScreen].scale);
        [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
}
```

ios 上传头像只能选择部分图片（已修复）更新了WuKongBase.podspec中的TZImagePickerController依赖库：s.dependency 'TZImagePickerController', '~>3.8.6'
