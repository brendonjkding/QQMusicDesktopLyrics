#import "LyricLabel.h"
@implementation LyricLabel
-(id)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if(!self) return self;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    _width=screenSize.width;
    
    self.textColor=[UIColor blackColor];
    self.adjustsFontSizeToFitWidth=NO;
    self.textAlignment=NSTextAlignmentCenter;
    [self setBackgroundColor:[UIColor clearColor]];

    return self;
}
-(void)adjustFontSize{
    CGFloat fontSize=1;
    while(true){
        if(fontSize==18) break;
        if([self textWidth:self.text withFont:[UIFont fontWithName:@"Helvetica-Bold" size:fontSize]]>_width) break;
        fontSize++;
    }
    fontSize--;
    UIFont*font=[UIFont fontWithName:@"Helvetica-Bold" size:fontSize];
    [self setFont:font];
}
-(void)stopTimer{
    if(_timer)  dispatch_source_cancel(_timer);
}
-(void)prepareLyric:(MySentence*)sentence{
    _sentence=sentence;
    self.text=[_sentence text];
    if([self.text isEqualToString:@" "]) return;
    [self adjustFontSize];
    _fullLyricWidth=[self textWidth:self.text withFont:self.font];
    _charactersArray=[_sentence charactersArray];
    // for(MyCharacter* c in _charactersArray){
    //     NSLog(@"%@ %lld %lld",[c character],[c startTime],[c duration]);
    // }
    _sentenceStartTime=[(MyCharacter*)_charactersArray[0] startTime];
    _lstIndex=0;
    _startTime=CACurrentMediaTime()*1000.0-500.0;
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), (1.0/24.0) * NSEC_PER_SEC, 0);

    dispatch_source_set_event_handler(_timer, ^{
        @synchronized(self){
            double currentTime=CACurrentMediaTime()*1000.0;
            double progressTime=currentTime-_startTime;
            double cProgressTime;
            double duration;
            int startCIndex=0,endCIndex=0;
            int i;
            for(i=_lstIndex;i<[_charactersArray count];i++){
                MyCharacter*character=_charactersArray[i];
                duration=[character duration];
                double cStartTime=[character startTime];
                double cEndTime=cStartTime+duration;
                if(progressTime >cStartTime&&progressTime<cEndTime){
                    _lstIndex=i;
                    cProgressTime=progressTime-cStartTime;
                    startCIndex=[character start];
                    endCIndex=[character end];
                    break;
                }
            }

            // NSLog(@"%d,%d",startCIndex,endCIndex);
            if(i==[_charactersArray count]) {
                dispatch_source_cancel(_timer);
                _currentLyricPosition=_width;
                
            }
            else {
                double currentLyricPosition=[self locationToCharacterIndex:startCIndex];
                double nextLyricPostion=[self locationToCharacterIndex:endCIndex];
                double offsetWidth=(cProgressTime/duration)*(nextLyricPostion-currentLyricPosition);
                // offsetWidth=0;
                _currentLyricPosition=currentLyricPosition+offsetWidth;
            }
            // double offsetWidth=(cProgressTime/duration)*[self textWidth:character withFont:self.font];
            
            // _currentLyricPosition-=offsetWidth;
            [self setNeedsDisplay];
        }
        
        
    });
    dispatch_resume(_timer); 
}
- (CGFloat)locationToCharacterIndex:(int)index{
    NSString*currentLyric=[self.text substringToIndex:index];
    CGFloat currentLyricWidth=[self textWidth:currentLyric withFont:self.font];
    CGFloat ret=(_width-_fullLyricWidth)/2.0+currentLyricWidth;
    return ret;
}
-(void)testSwitch{
    self.text=@"Author:Brend0n";
    self.font=[UIFont fontWithName:@"Helvetica-Bold" size:17];
    _fullLyricWidth=[self textWidth:self.text withFont:self.font];
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(self.timer, dispatch_walltime(NULL, 0), (1.0/15.0) * NSEC_PER_SEC, 0);
    __block int i=0;
    dispatch_source_set_event_handler(self.timer, ^{
        i++;
        i%=(self.text.length+1);
        _currentLyricPosition=[self locationToCharacterIndex:i];
        [self setNeedsDisplay];
        
    });
    dispatch_resume(self.timer); 
}
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    // 设置颜色
    [[UIColor greenColor] set];
    rect.size.width =_currentLyricPosition;
    
    // 图形混合模式
    UIRectFillUsingBlendMode(rect, kCGBlendModeSourceIn);
}
-(CGFloat)textWidth:(NSString*)string withFont:(UIFont*)textFont{
    
    // UIFont * textFont = [UIFont fontWithName:@"Helvetica-Bold" size:fontSize];//设置字体大小
    
    //高度估计文本大概要显示几行，宽度根据需求自己定义。 MAXFLOAT 可以算出具体要多高
    
    // CGFloat textWide = 300;//设置文字可显示宽度
    
    CGSize size =CGSizeMake(CGFLOAT_MAX,CGFLOAT_MAX);
    
    //获取当前文本的属性
    
    NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:textFont,NSFontAttributeName,nil];
    
    //获取文本需要的size，限制宽度
    
    CGSize  actualsize =[string boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin  attributes:dic context:nil].size;
    
    return actualsize.width;
    
}
@end