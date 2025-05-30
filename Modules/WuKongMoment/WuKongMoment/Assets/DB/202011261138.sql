create table moment_msg(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    action varchar(40) NOT NULL default '',  -- 行为 comment：评论 like: 点赞
    action_at   INTEGER NOT NULL default 0, -- 行为时间
    moment_no varchar(40) NOT NULL default '', -- 朋友圈编号
    content text  NOT NULL  default '', -- 朋友圈内容
    uid varchar(40) NOT NULL default '',  -- 用户唯一ID
    name varchar(100) NOT NULL default '',  -- 用户名称
    comment text  NOT NULL  default '', -- 评论内容
    version bigint NOT NULL  default 0, -- 版本号
    is_deleted smallint NOT NULL default 0, -- 是否删除
    created_at   timeStamp        not null DEFAULT (datetime('now', 'localtime')), -- 创建时间
    updated_at   timeStamp        not null DEFAULT (datetime('now', 'localtime'))  -- 更新时间
);
