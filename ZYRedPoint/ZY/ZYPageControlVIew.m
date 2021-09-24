//
//  ZYPageControlVIew.m
//  ZYRedPoint
//
//  Created by lihaoze on 2021/9/23.
//

#import "ZYPageControlVIew.h"
#import "ZYPagePoint.h"

#warning 这些属性暂时不想外漏 别问为啥就是不想
static CGSize kPageSize = (CGSize){10, 10};
static CGFloat kHorizontalMargin = 4;
static CGFloat kVerticalMargin = 2;
static CGFloat kPointScale = 0.75;

static void hz_performAnimated(dispatch_block_t block) {
    [UIView animateWithDuration:0.25 animations:block];
}

@interface ZYPageControlVIew ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray <ZYPagePoint *>*pagePointArray;

@property (nonatomic, assign) NSUInteger maxValidPages; ///< 最大有效个数
@end

@implementation ZYPageControlVIew

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _pagePointArray = [NSMutableArray array];
        _maximumVisablePages = 5;
        _pageIndicatorTintColor = [UIColor lightGrayColor];
        _currentPageIndicatorTintColor = [UIColor redColor];
        
        [self setUpSubviews];
    }
    return self;
}

- (void)setUpSubviews {
    [self addSubview:self.scrollView];
}

#pragma mark - layout
- (void)layoutSubviews {
    [super layoutSubviews];

    CGSize suitableSize = [self calculateSuitableFrameSize];
    if (CGSizeEqualToSize(suitableSize, self.scrollView.frame.size) == NO) {
        self.scrollView.bounds = (CGRect){{0, 0}, suitableSize};
    }
    self.scrollView.center = CGPointMake(CGRectGetWidth(self.frame) * 0.5, CGRectGetHeight(self.frame) * 0.5);
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [self calculateSuitableFrameSize];
}

- (CGSize)intrinsicContentSize {
    return [self calculateSuitableFrameSize];
}

#pragma mark - private method
#pragma mark refresh UI
- (void)__refreshPage {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsLayout];
        [self layoutIfNeeded];
        
        CGSize freshScrollContentSize = [self calculateScrollViewContentSize];
        if (CGSizeEqualToSize(self.scrollView.contentSize, freshScrollContentSize) == NO) {
            self.scrollView.contentSize = freshScrollContentSize;
        }
        
        [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        NSUInteger indexOfVisableRange = [self calculateCurrentPagePositionInVisablePages];
        [self scrollNearestCenterWithCurrentPage:self.currentPage];
        if (self.numberOfPages <= 1 && self.hidesForSinglePage == YES) {
            return;
        }
        for (int i = 0; i < self.numberOfPages; i++) {
            ZYPagePoint *pagePoint = [self dequeuePagePointWithIndex:i];
            pagePoint.pageIndicatorTintColor = self.pageIndicatorTintColor;
            pagePoint.currentPageIndicatorTintColor = self.currentPageIndicatorTintColor;
            [self.scrollView addSubview:pagePoint];
            
            CGFloat x = kHorizontalMargin + i * (kHorizontalMargin + kPageSize.width);
            CGFloat y = kVerticalMargin;
            pagePoint.frame = (CGRect){{x, y}, kPageSize};
            pagePoint.selected = i == self.currentPage;
            // scale
            if (i <= self.currentPage - indexOfVisableRange && i != 0) {
                pagePoint.scale = kPointScale;
            } else if (i >= (self.maxValidPages - 1) - indexOfVisableRange + self.currentPage && i != self.numberOfPages - 1){
                pagePoint.scale = kPointScale;
            } else {
                pagePoint.scale = 1;
            }
        }
        
    });
    
}

- (void)scrollNearestCenterWithCurrentPage:(NSUInteger)currentPage {
    NSUInteger centerPage = (self.maxValidPages + 1) / 2 - 1; ///< -1的原因是page从0开始
    NSUInteger rightDeltaPage = self.maxValidPages - 1 - centerPage; /// 右侧的空余
    NSUInteger totalDeltaPage = self.numberOfPages - 1 - currentPage;
    
    // 相当于让index滚动到cneterIndex
    CGFloat contentOffsetX = 0.f;
    if (currentPage < centerPage) {
        contentOffsetX = 0.f;
    } else if (totalDeltaPage < rightDeltaPage) {
        contentOffsetX = (self.numberOfPages - self.maxValidPages) * (kPageSize.width + kHorizontalMargin);
    } else {
        NSInteger deltaPage = currentPage - centerPage;
        contentOffsetX =  deltaPage * (kHorizontalMargin + kPageSize.width);
    }
    
    hz_performAnimated(^{
        [self.scrollView setContentOffset:CGPointMake(contentOffsetX, 0)];
    });
}

#pragma mark helper
- (CGSize)calculateSuitableFrameSize {
    NSUInteger containerCount = self.maxValidPages;
    if (containerCount == 0) {
        return CGSizeZero;
    }
    CGFloat suitableWidth = containerCount * kPageSize.width + (containerCount - 1) * kHorizontalMargin + 2 * kHorizontalMargin;
    CGFloat suitableHeight = kPageSize.height + kVerticalMargin * 2;
    return CGSizeMake(suitableWidth, suitableHeight);
}

- (CGSize)calculateScrollViewContentSize {
    NSUInteger containerCount = self.numberOfPages;
    if (containerCount == 0) {
        return CGSizeZero;
    }
    CGFloat suitableWidth = containerCount * kPageSize.width + (containerCount - 1) * kHorizontalMargin + 2 * kHorizontalMargin;
    CGFloat suitableHeight = kPageSize.height + kVerticalMargin * 2;
    return CGSizeMake(suitableWidth, suitableHeight);
}

- (ZYPagePoint *)dequeuePagePointWithIndex:(NSUInteger)index {
    if (index < 0) {
        return nil;
    }
    if (index >= self.pagePointArray.count) {
        ZYPagePoint *pagePoint = [[ZYPagePoint alloc] init];
        @synchronized ([self class]) {
            [self.pagePointArray addObject:pagePoint];
        }
        return pagePoint;
    }
    @synchronized ([self class]) {
        return self.pagePointArray[index];;
    }
}

/// 计算当前选中的point在可视范围内是第几个 0...max-1
- (NSUInteger)calculateCurrentPagePositionInVisablePages {
    NSUInteger centerPage = (self.maxValidPages - 1) / 2; ///< -1的原因是page从0开始
    NSUInteger rightDeltaPage = (self.maxValidPages - 1) - centerPage; /// 右侧的空余
    NSUInteger totalDeltaPage = (self.numberOfPages - 1) - self.currentPage;
    if (self.currentPage <= centerPage) {
        return self.currentPage;
    } else if (totalDeltaPage <= rightDeltaPage) {
        return (self.maxValidPages - 1) - totalDeltaPage;
    } else {
        return centerPage;
    }
}

#pragma mark - setter method
- (void)setCurrentPage:(NSInteger)currentPage {
    if (currentPage < 0) {
        currentPage = 0;
    }
    if (currentPage >= self.numberOfPages) {
        currentPage = MAX(self.numberOfPages - 1, 0);
    }
    _currentPage = currentPage;
    [self __refreshPage];
}

- (void)setNumberOfPages:(NSInteger)numberOfPages {
    _numberOfPages = MAX(0, numberOfPages);
    // numberOfPages改变的时候要修正currentPage
    if (_currentPage >= _numberOfPages) {
        // 防止currentPage为-1
        _currentPage = MAX(0, _numberOfPages - 1);
    }
    
    [self __refreshPage];
}

- (void)setMaximumVisablePages:(NSInteger)maximumVisablePages {
    _maximumVisablePages = MAX(0, maximumVisablePages);
    [self __refreshPage];
}

#pragma mark - getter method
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.pagingEnabled = NO;
        _scrollView.bounces = NO;
        _scrollView.scrollEnabled = NO;
    }
    return _scrollView;
}

- (NSUInteger)maxValidPages {
    return MIN(self.numberOfPages, self.maximumVisablePages);
}

@end
