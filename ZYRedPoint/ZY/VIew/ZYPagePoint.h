//
//  ZYPagePoint.h
//  ZYRedPoint
//
//  Created by lihaoze on 2021/9/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZYPagePoint : UIView

@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) CGFloat scale;

/// The tint color for non-selected indicators. Default is nil.
@property (nullable, nonatomic, strong) UIColor *pageIndicatorTintColor;

/// The tint color for the currently-selected indicators. Default is nil.
@property (nullable, nonatomic, strong) UIColor *currentPageIndicatorTintColor;
@end

NS_ASSUME_NONNULL_END
