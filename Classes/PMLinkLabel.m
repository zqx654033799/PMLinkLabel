//
//  PMLinkLabel.m
//  Pods-PMLinkLabel_Example
//
//  Created by iPaperman on 2022/9/4.
//

#import "PMLinkLabel.h"

@implementation PMLinkLabel {
    // 链接文字范围 和 处理block
    NSMutableDictionary *_rangeMap;
    // 匹配的链接文字范围
    NSRange _matchRange;
    // 首次加载设置文字
    BOOL _loadTextDone;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initLinkLabel];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initLinkLabel];
    }
    return self;
}

- (void)initLinkLabel {
    // 可以接收到触摸事件
    self.userInteractionEnabled = true;
    // 设置行数为0，可以转行
    self.numberOfLines = 0;
    _rangeMap = [NSMutableDictionary dictionary];
    _matchRange = NSMakeRange(NSNotFound, 0);
}

- (void)setLinkRange:(NSRange)range tapHandler:(void (^)(void))handler {
    id block = [handler copy];
    [_rangeMap setValue:block forKey:NSStringFromRange(range)];
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (self.window && !_loadTextDone) {
        // 加载视图时 渲染文字
        NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
        // H：left V：center
        style.alignment = NSTextAlignmentLeft;
        id attributes = @{NSForegroundColorAttributeName: self.textColor,
                          NSParagraphStyleAttributeName: style,
                          NSFontAttributeName: self.font};
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:self.text attributes:attributes];
        for (NSString *str in _rangeMap) {
            NSRange range = NSRangeFromString(str);
            [attrString addAttributes:@{NSForegroundColorAttributeName: self.linkColor} range:range];
        }
        [super setAttributedText:attrString];
        _loadTextDone = YES;
    }
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"used setText: method"
                                 userInfo:nil];
}

// 开始触摸
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self beganTouches:touches];
}

// 移动触摸
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    // 判断是否在控件内，出控件即取消
    CGPoint loc = [[touches anyObject] locationInView:self];
    if (!CGRectContainsPoint(self.bounds, loc)) {
        [self endTouches:touches];
    }
}

// 结束触摸
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if (_matchRange.location != NSNotFound) {
        void (^block)(void) = _rangeMap[NSStringFromRange(_matchRange)];
        if (block) {
            block();
        }
    }
    [self endTouches:touches];
}

// 取消触摸
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [self endTouches:touches];
}

/// 根据触摸对象 获取 文字索引
- (NSUInteger)characterIndexForTouches:(NSSet *)touches {
    CGSize labelSize = self.frame.size;
    
    // create instances of NSLayoutManager, NSTextContainer and NSTextStorage
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:labelSize];
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:self.attributedText];
    
    // configure layoutManager and textStorage
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    
    // configure textContainer for the label
    textContainer.lineFragmentPadding = 0.0;
    textContainer.lineBreakMode = self.lineBreakMode;
    textContainer.maximumNumberOfLines = self.numberOfLines;
    
    // find the tapped character location and compare it to the specified range
    CGPoint locationOfTouchInLabel = [[touches anyObject] locationInView:self];
    CGSize textContainerSize = [layoutManager usedRectForTextContainer:textContainer].size;
    // H：left V：center
    CGPoint textContainerOffset = CGPointMake(0, (labelSize.height - textContainerSize.height) * 0.5);
    CGRect textContainerRect = (CGRect) {textContainerOffset, textContainerSize};
    if (CGRectContainsPoint(textContainerRect, locationOfTouchInLabel)) {
        CGPoint locationOfTouchInTextContainer = CGPointMake(locationOfTouchInLabel.x - textContainerOffset.x,
                                                             locationOfTouchInLabel.y - textContainerOffset.y);
        CGFloat partialFraction;
        NSUInteger index = [layoutManager characterIndexForPoint:locationOfTouchInTextContainer
                                                 inTextContainer:textContainer
                        fractionOfDistanceBetweenInsertionPoints:&partialFraction];
        // 正常范围内 0 ～ 1 之间的小数
        if (partialFraction == 0.0 ||
            partialFraction == 1.0) {
            return NSNotFound;
        }
        return index;
    }
    return NSNotFound;
}

// 处理开始触摸
- (void)beganTouches:(NSSet *)touches {
    if (_rangeMap.count == 0) return;
    
    NSUInteger index = [self characterIndexForTouches:touches];
    // 根据文字索引位置 确认在哪个范围内，设置范围内文字背景颜色
    for (NSString *str in _rangeMap) {
        NSRange range = NSRangeFromString(str);
        if (NSLocationInRange(index, range)) {
            NSMutableAttributedString *attrString = [self.attributedText mutableCopy];
            [attrString addAttributes:@{NSBackgroundColorAttributeName: self.highlightedLinkBackgroundColor} range:range];
            [super setAttributedText:attrString];
            // 有匹配范围设定
            _matchRange = range;
            return;
        }
    }
    // 无匹配范围置空
    _matchRange = NSMakeRange(NSNotFound, 0);
}

// 处理结束触摸
- (void)endTouches:(NSSet *)touches {
    if (_rangeMap.count == 0) return;
    
    // 清空所有范围的文字背景颜色
    NSMutableAttributedString *attrString = [self.attributedText mutableCopy];
    for (NSString *str in _rangeMap) {
        NSRange range = NSRangeFromString(str);
        [attrString removeAttribute:NSBackgroundColorAttributeName range:range];
    }
    [super setAttributedText:attrString];
    // 匹配范围置空
    _matchRange = NSMakeRange(NSNotFound, 0);
}
@end
