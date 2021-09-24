//
//  ZYPageControlVIew.h
//  ZYRedPoint
//
//  Created by lihaoze on 2021/9/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZYPageControlVIew : UIView

/// default is 0
@property (nonatomic, assign) NSInteger numberOfPages;

/// default is 0. Value is pinned to 0..numberOfPages-1
@property (nonatomic, assign) NSInteger currentPage;

/// hides the indicator if there is only one page, default is NO
@property (nonatomic) BOOL hidesForSinglePage;

/// ✨default is 5. Value is pinned to 0..numberOfPages-1
@property (nonatomic, assign) NSInteger maximumVisablePages;

/// The tint color for non-selected indicators.
@property (nullable, nonatomic, strong) UIColor *pageIndicatorTintColor;

/// The tint color for the currently-selected indicators
@property (nullable, nonatomic, strong) UIColor *currentPageIndicatorTintColor;

@end

NS_ASSUME_NONNULL_END
