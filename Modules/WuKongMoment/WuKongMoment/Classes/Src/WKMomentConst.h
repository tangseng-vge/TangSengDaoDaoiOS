//
//  WKMomentConst.h
//  Pods
//
//  Created by tt on 2020/11/5.
//

#define BIG_BACKGROUP_IMAGE_HEIGHT WKScreenHeight*(0.4)

#define cellTopSpace 20.0f


// ---------- 头像和名字 ----------

#define avatarSize [WKApp shared].config.messageAvatarSize.height

#define nameTopSpace 0.0f // 名字顶部距离
#define nameHeight 18.0f // 名字高度
#define nameLeftSpace 15.0f // 名字距离头像左边的间距

#define nameColor [UIColor colorWithRed:95.0f/255.0f green:116.0f/255.0f blue:158.0f/255.0f alpha:1.0f] // 名字颜色

#define avatarLeftSpace 15.0f // 头像左边间距

// ---------- 朋友圈正文 ----------
#define contentTopSpace 10.0f // 正文距离名字的距离
#define contentFontSize 16.0f
#define contentMaxWidth WKScreenWidth - (avatarLeftSpace + avatarSize + nameLeftSpace)-15.0f // 正文最大宽度


// ---------- 图片 ----------


#define imgBoxTopSpace 15.0f // 图片顶部距离文本的距离
#define imgSpace 5.0f // 图片之间的间距

// ---------- 操作 ----------

#define menusWidth 180.0f

// ----------点赞 ----------

#define likeIconSize 16.0f
#define likeFontSize 14.0f // 点赞字体大小
#define likeIconLeftSpace 5.0f // 点赞icon左边距离
#define likeIconRightSpace 5.0f // 点赞icon右边距离
#define likeBorder 4.0f // 点赞的边距

// ----------评论 ----------

#define commentParagraphSpacing  6.0f // 评论之间的间距
#define commentFontSize 14.0f // 评论字体大小
#define commentBorder 4.0f // 文字的边距
