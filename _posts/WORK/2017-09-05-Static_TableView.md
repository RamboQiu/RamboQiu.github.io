---
layout: post
title:  "静态TableView通过后端数据的实时布局方案"
date:   2017-09-05
desc: "静态TableView通过后端数据的实时布局方案"
keywords: "OC,TableView"
categories: [Tech, iOS]
tags: [OC, TableView]
icon: icon-html
comments: true
---

## 静态TableView的快速布局

项目开发中碰到的所有界面基本上都少不了TableView的布局，大体参考视觉元素设计能将界面按行拆解开来，包括分割行

![](/assets/img/work/20170905/20170905185040.png){: width='320' .normal}

这么设计的原因是整个界面元素的显示与排列顺序能灵活的根据产品变动进行快速变更

行元素定义如下：

~~~ objc
@interface RAMCellData : NSObject
@property (nonatomic, copy) Class cellClass;
/// cell构造方法
@property (nonatomic, assign) SEL cellCustomSEL;
/// cell点选方法
@property (nonatomic, assign) SEL cellSelectSEL;

@property (nonatomic, assign) CGFloat cellHeight;
/// 填充cell的model，用在cellForRow中
@property (nonatomic, strong) id model;
/// 一般可以使用 NSStringFromClass(self.class)
@property (nonatomic, copy) NSString *cellIdentifier;
@property (nonatomic, assign) NSInteger tag;
/// 当前cell锁在的section
@property (nonatomic, assign) CGFloat sectionHeaderHeight;
@property (nonatomic, assign) CGFloat sectionFooterHeight;
/// 勾选的时候需要使用到的didSelModel，如果没有一般是用model
@property (nonatomic, strong) id didSelModel;
@end
~~~

定义一个cell

~~~objc
RAMCellData *blockData = RAMCellData.new;
blockData.cellClass = RAMBaseTableViewCell.class;
blockData.cellHeight = [RAMBaseTableViewCell cellHeightWithModel:blockModel];
blockData.cellCustomSEL = @selector(cusNormalCell:withData:);
blockData.cellSelectSEL = @selector(selNormalCellData:);
blockData.model = blockModel;
[section2 addObject:blockData];
~~~

使用一个可变数组进行行元素存储，在实现的tableview的delegate和datasource中统一处理，如下：

~~~ objc
// 获取有多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.staticData.count;
}
// 处理cell的点击，转到RAMCellData中cellSelectSEL
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RAMCellData *data = [self objectAtIndex:indexPath.row];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (data.cellSelectSEL)
        [self performSelector:data.cellSelectSEL withObject:data];
#pragma clang diagnostic pop
}
// 处理cell的点击，转到RAMCellData中cellCustomSEL
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RAMCellData *data = [self objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:data.cellIdentifier];
    if (!cell) {
        cell = [[data.cellClass alloc] initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:data.cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (data.cellCustomSEL) {
        [self performSelector:data.cellCustomSEL withObject:cell withObject:data];
    }
#pragma clang diagnostic pop
    return cell;
}
// 获取每行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    RAMCellData *data = [self objectAtIndex:indexPath.row];
    if (data.cellHeight > 0)
        return data.cellHeight;
    return 54;// 给个默认高度
}
~~~

最后我们只需要在界面刷新的时候统一处理staticData，并最后调用reloadData即可

## 优点

1. 解耦cellForRowAtIndexPath和didSelectRowAtIndexPath中的逻辑，将每个cell本身自己的点击和初始化隔离出来单独设计，消除这两个方法的臃肿设计
2. 灵活，上线的功能模块时常会被下线，或是出现界面改动，只需关注当前改动cell即可

## 项目源码

[RAMCellData](https://github.com/RamboQiu/RAMUtil/tree/master/RAMUtil/RAMCellData)

