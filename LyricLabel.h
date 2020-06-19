#import "MyLyric.h"
@interface LyricLabel:UILabel
@property CGFloat width;
@property CGFloat fullLyricWidth;
@property CGFloat currentLyricPosition;
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, strong) MySentence* sentence;
@property (nonatomic, strong) NSArray*charactersArray;
@property (nonatomic) double startTime;
@property (nonatomic) double sentenceStartTime;
@property (nonatomic) int lstIndex;
-(void)prepareLyric:(MySentence*)sentences;
-(void)stopTimer;
-(void)testSwitch;

@end