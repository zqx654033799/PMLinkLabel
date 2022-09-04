//
//  PMLinkLabel.h
//  Pods-PMLinkLabel_Example
//
//  Created by iPaperman on 2022/9/4.
//

#import <UIKit/UIKit.h>

@interface PMLinkLabel : UILabel

/// 链接文字颜色，普通状态
@property (strong, nonatomic) UIColor *linkColor;
/// 链接文字背景颜色，高亮状态
@property (strong, nonatomic) UIColor *highlightedLinkBackgroundColor;
/// 设置链接文字范围 触发回调
- (void)setLinkRange:(NSRange)range tapHandler:(void(^)(void))handler;

@end
