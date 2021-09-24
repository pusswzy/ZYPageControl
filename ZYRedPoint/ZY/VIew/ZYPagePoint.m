//
//  ZYPagePoint.m
//  ZYRedPoint
//
//  Created by lihaoze on 2021/9/23.
//

#import "ZYPagePoint.h"

@interface ZYPagePoint ()
@property (nonatomic, strong) UIView *pagePoint;
@end

@implementation ZYPagePoint

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpSubviews];
    }
    return self;
}

- (void)setUpSubviews {
    [self addSubview:self.pagePoint];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize suitableSize = CGSizeMake(self.bounds.size.width * self.scale, self.bounds.size.height * self.scale);
    if (CGSizeEqualToSize(suitableSize, self.pagePoint.frame.size) == NO) {
        self.pagePoint.bounds = (CGRect){{0, 0}, suitableSize};
    }
    self.pagePoint.center = CGPointMake(CGRectGetWidth(self.frame) * 0.5, CGRectGetHeight(self.frame) * 0.5);
    self.pagePoint.layer.cornerRadius = CGRectGetHeight(self.pagePoint.frame) * 0.5;
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.pagePoint.backgroundColor = selected ? self.currentPageIndicatorTintColor : self.pageIndicatorTintColor;
    }];
}

- (void)setScale:(CGFloat)scale {
    _scale = scale;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark -
- (UIView *)pagePoint {
    if (!_pagePoint) {
        _pagePoint = [[UIView alloc] init];
    }
    return _pagePoint;
}

@end
