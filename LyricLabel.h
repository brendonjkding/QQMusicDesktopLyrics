#import "MyLyric.h"
@interface LyricLabel:UILabel
@property CGFloat fullLyricWidth;
@property CGFloat currentLyricPosition;
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, strong) MySentence* sentence;
@property (nonatomic, strong) NSArray*charactersArray;
@property (nonatomic) double startTime;
@property (nonatomic) double sentenceStartTime;
@property (nonatomic) int lstIndex;
-(void)prepareSentence:(MySentence*)sentences;
-(void)stopTimer;
-(void)showAuthor;
- (CGFloat)locationToCharacterIndex:(int)index;
@end