@interface MySentence:NSObject
@property(nonatomic)NSString* text;
@property(nonatomic)long long startTime;
@property(strong, nonatomic) NSMutableArray *charactersArray; // @synthesize 
@end

@interface MyCharacter:NSObject
@property(strong, nonatomic) NSString *character; // @synthesize character=_character;
@property(nonatomic) long long duration; // @synthesize duration=_duration;
@property(nonatomic) long long startTime; // @synthesize startTime=_startTime;
@property(nonatomic) long long start; // @synthesize startTime=_startTime;
@property(nonatomic) long long end; // @synthesize startTime=_startTime;
@end