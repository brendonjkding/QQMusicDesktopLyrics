//
//  WQSuspendView.m
//  SuspendView
//
//  Created by 李文强 on 2019/6/6.
//  Copyright © 2019年 WenqiangLI. All rights reserved.
//

#import "QQWQSuspendView.h"
#ifdef DEBUG
#define kButtonWidth 30
#else
#define kButtonWidth 30
#endif
BOOL positionLocked;
@interface QQWQSuspendView  (){
    CGPoint _originalPoint;//之前的位置
}

@property (nonatomic, assign) WQSuspendViewType type;
@property BOOL isLongPressing;
@property (nonatomic, strong) dispatch_source_t timer;

@end


@implementation QQWQSuspendView
static QQWQSuspendView *_suspendView;

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self configurationUI];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame showType:(WQSuspendViewType)type tapBlock:(void (^)(void))tapBlock{
    self = [super initWithFrame:frame];
    if (self) {
        _type = type;
        _tapBlock = tapBlock;
        [self configurationUI];
        self.isLongPressing=NO;
    }
    return self;
}

- (void)configurationUI{
    //自定义
    self.backgroundColor = [[UIColor alloc] initWithRed:1 green:1 blue:1 alpha:0.3];
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    //边框宽度
    self.layer.borderWidth = 1.0;
    //边框颜色
    self.layer.borderColor = [UIColor clearColor].CGColor;
    //图片~文字等...

    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    _label=[[UILabel alloc] initWithFrame:CGRectMake(0,0,screenSize.width,kButtonWidth)];
    _label.text=@"Author: Brend0n";
    _label.textColor=[UIColor blackColor];
    _label.adjustsFontSizeToFitWidth=YES;
    _label.textAlignment=NSTextAlignmentCenter;
    [_label setBackgroundColor:[[UIColor alloc] initWithRed:1 green:1 blue:1 alpha:0.3]];
    [_label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
    [self addSubview:_label];

    //滑动手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
}

//移除
+ (void)remove{
    [_suspendView removeFromSuperview];
}


+ (id)showWithType:(WQSuspendViewType)type inWindow:(UIWindow*)window tapBlock:(void (^)(void))tapBlock{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        _suspendView = [[QQWQSuspendView alloc] initWithFrame:CGRectMake(0, 50, screenSize.width, kButtonWidth) showType:type tapBlock:tapBlock];
    });
    if (!_suspendView.superview&&window) {
        [window addSubview:_suspendView];
        [window bringSubviewToFront:_suspendView];
    }
    return _suspendView;
}

//点击事件
- (void)tap:(UITapGestureRecognizer *)tap{
    
}
- (void)longPress:(UITapGestureRecognizer *)longPress{
    
}

//滑动事件
- (void)pan:(UIPanGestureRecognizer *)pan{
    //获取当前位置
    CGPoint currentPosition = [pan locationInView:self];
    if (pan.state == UIGestureRecognizerStateBegan) {
        _originalPoint = currentPosition;
    }else if(pan.state == UIGestureRecognizerStateChanged){
        //偏移量(当前坐标 - 起始坐标 = 偏移量)
        CGFloat offsetX = currentPosition.x - _originalPoint.x;
        CGFloat offsetY = currentPosition.y - _originalPoint.y;
        
        //移动后的按钮中心坐标
        CGFloat centerX = self.center.x + offsetX;
        CGFloat centerY = self.center.y + offsetY;
        self.center = CGPointMake(centerX, centerY);
        
        //父试图的宽高
        CGFloat superViewWidth = self.superview.frame.size.width;
        CGFloat superViewHeight = self.superview.frame.size.height;
        CGFloat btnX = self.frame.origin.x;
        CGFloat btnY = self.frame.origin.y;
        CGFloat btnW = self.frame.size.width;
        CGFloat btnH = self.frame.size.height;
        
        //x轴左右极限坐标
        if (btnX > superViewWidth){
            //按钮右侧越界
            CGFloat centerX = superViewWidth - btnW/2;
            self.center = CGPointMake(centerX, centerY);
        }else if (btnX +kButtonWidth< 0){
            //按钮左侧越界
            CGFloat centerX = btnW * 0.5;
            // self.center = CGPointMake(centerX, centerY);
        }
        
    }else if (pan.state == UIGestureRecognizerStateEnded){
        CGFloat btnWidth = self.frame.size.width;
        CGFloat btnHeight = self.frame.size.height;
        CGFloat btnY = self.frame.origin.y;
        //        CGFloat btnX = self.frame.origin.x;
        //按钮靠近右侧
        switch (_type) {
                
            case WQSuspendViewTypeNone:{
                //自动识别贴边
                if (self.center.x >= self.superview.frame.size.width/2) {
                    
                    [UIView animateWithDuration:0.5 animations:^{
                        //按钮靠右自动吸边
                        CGFloat btnX = self.superview.frame.size.width - btnWidth;
                        self.frame = CGRectMake(btnX, btnY, btnWidth, btnHeight);
                    }];
                }else{
                    
                    [UIView animateWithDuration:0.5 animations:^{
                        //按钮靠左吸边
                        CGFloat btnX = 0;
                        self.frame = CGRectMake(btnX, btnY, btnWidth, btnHeight);
                    }];
                }
                break;
            }
            case WQSuspendViewTypeLeft:{
                [UIView animateWithDuration:0.5 animations:^{
                    //按钮靠左吸边
                    CGFloat btnX = 0;
                    self.frame = CGRectMake(btnX, btnY, btnWidth, btnHeight);
                }];
                break;
            }
            case WQSuspendViewTypeRight:{
                [UIView animateWithDuration:0.5 animations:^{
                    //按钮靠右自动吸边
                    CGFloat btnX = self.superview.frame.size.width - btnWidth;
                    self.frame = CGRectMake(btnX, btnY, btnWidth, btnHeight);
                }];
            }
        }
    }
    
}
@end

