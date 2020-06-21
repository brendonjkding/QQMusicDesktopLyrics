//Header QQMusic
@interface AudioPlayManager
- (double)curTime;
@property(retain, nonatomic) id currentSong; // @synthesize currentSong;
@end

@interface KSCharacter
@property(retain, nonatomic) NSString *character; // @synthesize character=_character;
@property(nonatomic) long long duration; // @synthesize duration=_duration;
@property(nonatomic) long long end; // @synthesize end=_end;
@property(nonatomic) long long start; // @synthesize start=_start;
@property(nonatomic) long long startTime; // @synthesize startTime=_startTime;

@end

@interface KSSentence
@property(nonatomic) long long startTime; // @synthesize startTime=_startTime;
@property(retain, nonatomic) NSString *text; // @synthesize text=_text;
@property(nonatomic) int sentenceTransType;
@property(retain, nonatomic) NSMutableArray *charactersArray; // @synthesize charactersArray=_charactersArray;
@end


@interface KSLyric
@property(retain, nonatomic) NSMutableArray *sentencesArray; // @synthesize
@property(nonatomic) int lyricFormat; 
@property(retain, nonatomic) NSString *title; // @synthesize title=_title;
@end


@interface KSQrcLyricParser
@property(nonatomic) int currentTransType; // @synthesize currentTransType=_currentTransType;
@property(retain, nonatomic) KSLyric *lyric; // @synthesize lyric=_lyric;
@end

@interface SongInfo
- (id)song_Name;
@end

@interface LocalLyricObject
@property(retain, nonatomic) KSLyric *originLyric; // @synthesize originLyric=_originLyric;
@end
