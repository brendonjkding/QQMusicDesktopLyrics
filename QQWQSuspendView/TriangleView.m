#import "TriangleView.h"
//thanks to https://blog.csdn.net/rhljiayou/article/details/9919713
@implementation DNTriangleView

- (void)drawRect:(CGRect)rect
{


    //An opaque type that represents a Quartz 2D drawing environment.
    //一个不透明类型的Quartz 2D绘画环境,相当于一个画布,你可以在上面任意绘画
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor (context,  1, 1, 1, 0.0);//设置填充颜色
    CGContextFillRect(context, rect);
    
    CGContextSetRGBStrokeColor(context,0,0,0,1.0);//画笔线的颜色
    CGContextSetLineWidth(context, 1.0);//线的宽度
    UIColor*aColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    CGContextSetFillColorWithColor(context, aColor.CGColor);//填充颜色
    
    /*画三角形*/
    //只要三个点就行跟画一条线方式一样，把三点连接起来
    CGPoint sPoints[3];//坐标点
    sPoints[0] =CGPointMake(0, 0);//坐标1
    sPoints[1] =CGPointMake(10, 0);//坐标2
    sPoints[2] =CGPointMake(5, 8.5);//坐标3
    CGContextAddLines(context, sPoints, 3);//添加线
    CGContextClosePath(context);//封起来
    CGContextDrawPath(context, kCGPathFillStroke); //根据坐标绘制路径
}

@end
@implementation UPTriangleView

- (void)drawRect:(CGRect)rect
{


    //An opaque type that represents a Quartz 2D drawing environment.
    //一个不透明类型的Quartz 2D绘画环境,相当于一个画布,你可以在上面任意绘画
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor (context,  1, 1, 1, 0.0);//设置填充颜色
    CGContextFillRect(context, rect);
    
    CGContextSetRGBStrokeColor(context,0,0,0,1.0);//画笔线的颜色
    CGContextSetLineWidth(context, 1.0);//线的宽度
    UIColor*aColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    CGContextSetFillColorWithColor(context, aColor.CGColor);//填充颜色
    
    /*画三角形*/
    //只要三个点就行跟画一条线方式一样，把三点连接起来
    CGPoint sPoints[3];//坐标点
    sPoints[0] =CGPointMake(0, 8.5);//坐标1
    sPoints[1] =CGPointMake(10, 8.5);//坐标2
    sPoints[2] =CGPointMake(5, 0);//坐标3
    CGContextAddLines(context, sPoints, 3);//添加线
    CGContextClosePath(context);//封起来
    CGContextDrawPath(context, kCGPathFillStroke); //根据坐标绘制路径
}

@end
@implementation HorizonLineView

- (void)drawRect:(CGRect)rect
{


    //An opaque type that represents a Quartz 2D drawing environment.
    //一个不透明类型的Quartz 2D绘画环境,相当于一个画布,你可以在上面任意绘画
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor (context,  1, 1, 1, 0.0);//设置填充颜色
    CGContextFillRect(context, rect);
    
    CGContextSetRGBStrokeColor(context,0,0,0,1.0);//画笔线的颜色
    CGContextSetLineWidth(context, 1.0);//线的宽度
    UIColor*aColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    CGContextSetFillColorWithColor(context, aColor.CGColor);//填充颜色
    

    CGPoint sPoints[3];//坐标点
    sPoints[0] =CGPointMake(0, 0);//坐标1
    sPoints[1] =CGPointMake(40, 0);//坐标2
    CGContextAddLines(context, sPoints, 2);//添加线
    // CGContextClosePath(context);//封起来
    CGContextDrawPath(context, kCGPathFillStroke); //根据坐标绘制路径
}

@end

@implementation LabelView

// -(void)init{

// }
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    NSLog(@"LabelView hitTest");
    return  [super hitTest:point withEvent:event];
}
- (void)drawRect:(CGRect)rect
{


    //An opaque type that represents a Quartz 2D drawing environment.
    //一个不透明类型的Quartz 2D绘画环境,相当于一个画布,你可以在上面任意绘画
    CGContextRef context = UIGraphicsGetCurrentContext();
    // CGContextSetRGBFillColor (context,  1, 1, 1, 0.3);//设置填充颜色
    // CGContextFillRect(context, rect);


    CGContextSetRGBFillColor (context,  01, 01, 01, 0.0);//设置填充颜色
    UIFont  *font = [UIFont fontWithName:@"Helvetica-Bold" size:15];//设置
    NSDictionary *attribute=@{
        NSFontAttributeName:font};

    [@"这是一个测试文字：" drawInRect:rect withAttributes:attribute];
}

@end