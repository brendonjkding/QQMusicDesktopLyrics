//
//  WQSuspendView.h
//  SuspendView
//
//  Created by 李文强 on 2019/6/6.
//  Copyright © 2019年 WenqiangLI. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger, WQSuspendViewType) {
    WQSuspendViewTypeNone = 0,  //根据左右距离的一半自动居左局右
    WQSuspendViewTypeLeft,      //居左
    WQSuspendViewTypeRight,     //居右
};

@interface QQWQSuspendView : UIView

@property (nonatomic, copy) void (^tapBlock)(void);
@property (nonatomic) UILabel* label;
@property (nonatomic,nullable)  id lastScrollView;

/** 显示 + 位置 + 点击的事件 */
+ (id)showWithType:(WQSuspendViewType)type inWindow:( UIWindow* __nullable)window tapBlock:(void (^)(void))tapBlock;
/** 移除 */
+ (void)remove;

- (instancetype)initWithFrame:(CGRect)frame showType:(WQSuspendViewType)type tapBlock:(nullable void (^)(void))tapBlock;

@end
UIScrollView* getVerticalScrollView(UIView *aView);
NS_ASSUME_NONNULL_END
