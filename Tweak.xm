#import "QQWQSuspendView/QQWQSuspendView.h"
#import "LyricLabel.h"
#import "MyLyric.h"

#import <substrate.h>
#import <rocketbootstrap/rocketbootstrap.h>
#import <AppSupport/CPDistributedMessagingCenter.h>
#import <SpringBoard/SpringBoard.h>
#import <notify.h>

//cuctom
@interface LyricWindow:UIWindow
@property BOOL positionLocked;
@end

@interface QQLyricMessagingCenter : NSObject {
	CPDistributedMessagingCenter * _messagingCenter;
}
@end

//global
BOOL enabled;
QQWQSuspendView* lyricView;
LyricWindow *lyricWindow;
NSMutableDictionary *allLyrics;
double lstTime=0;
MySentence* lstSentence;
NSString*lstSongName;
int lstSentenceIndex=0;
CPDistributedMessagingCenter * _messagingCenter;
UIWindow*rootWindow=0;
BOOL positionLocked=0;
unsigned lyricWindowContextId=0;
LyricLabel *lyric;
NSString*prefPath=@"/var/mobile/Library/Preferences/com.brend0n.qqmusicdesktoplyrics.plist";
void loadPref();

//custom imp
@implementation LyricWindow
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	if(_positionLocked) return nil;
    UIView *hitTestView = [super hitTest:point withEvent:event];
    if(hitTestView==self) return nil;
    else return hitTestView;
}
@end
@implementation QQLyricMessagingCenter
+ (instancetype)sharedInstance {
	static dispatch_once_t once = 0;
	__strong static id sharedInstance = nil;
	dispatch_once(&once, ^{
		sharedInstance = [self new];
	});
	return sharedInstance;
}

- (instancetype)init {
	if ((self = [super init])) {
		_messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.brend0n.qqmusicdesktoplyrics"];
		// apply rocketbootstrap regardless of iOS version (via rpetrich)
#if TARGET_OS_SIMULATOR
#else
    	rocketbootstrap_distributedmessagingcenter_apply(_messagingCenter);
#endif
		[_messagingCenter runServerOnCurrentThread];
		[_messagingCenter registerForMessageName:@"changeLyric" target:self selector:@selector(handleMessageNamed:withUserInfo:)];
	}

	return self;
}

- (NSDictionary *)handleMessageNamed:(NSString *)name withUserInfo:(NSDictionary *)userInfo {
	if(!enabled) return nil;
	NSString*lyricText=userInfo[@"lyricText"];
	lyricView.label.text=lyricText;

	MySentence*sentence=[NSKeyedUnarchiver unarchiveObjectWithData:userInfo[@"sentence"]];
	[lyric removeFromSuperview];
	[lyric stopTimer];
	
	CGSize screenSize = [[UIScreen mainScreen] bounds].size;
	lyric=[[LyricLabel alloc] initWithFrame:CGRectMake(0,0,screenSize.width,30)];
	[lyric prepareLyric:sentence];
    [lyricView addSubview:lyric];
	return nil;
}

@end

@interface UIWindow()
-(unsigned)_contextId;
@end

// //Header SB


// @interface FBScene
// @property (nonatomic,copy,readonly) NSString * identifier;   
// @end

// @interface FBSceneHostWrapperView:UIView
// @property (nonatomic,retain,readonly) FBScene* scene;
// @end

// @interface FBContextLayerHostView:UIView
// @end

// @interface CALayerHost:CALayer
// -(unsigned)contextId;
// @end

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


//hook
%group QQMusicHook
%hook AudioPlayManager
- (void)updateProgress:(id)arg1 { 
	%orig;
    double curTime=[self curTime]*1000;
    double diff=curTime-lstTime;
    if(diff<200&&diff>-1)return;
    lstTime=curTime;
    
    NSString*_lrc=0;
    NSArray* sentencesArray=[allLyrics objectForKey:[[self currentSong] song_Name]];
    if(!sentencesArray){
    	NSLog(@"no lyric:%@",[[self currentSong] song_Name]);
        if(![[lstSentence text] isEqualToString:@" "]){
            lstSentence=[MySentence alloc];
            [lstSentence setText:@" "];
            _lrc=[lstSentence text];
        }
    }
    else{
        MySentence* curLyric=0;
        
        if(![[[self currentSong] song_Name] isEqualToString:lstSongName]){
        	lstSentenceIndex=0;
        }
        for(int i=lstSentenceIndex;i<[sentencesArray count];i++){
        	MySentence*sentence=sentencesArray[i];
            if([sentence startTime]>curTime) break;
            curLyric=sentence;
            lstSentenceIndex=i;
        }
        
        if(curLyric&&curLyric!=lstSentence) {
            lstSentence=curLyric;
            _lrc=[lstSentence text];
        }
    }
	if(_lrc) {
		NSLog(@"curSentence:%@",_lrc);
    	// Send a message with a dictionary
    	NSData*sentenceData=[NSKeyedArchiver archivedDataWithRootObject:lstSentence];
	    NSDictionary * message = [NSDictionary dictionaryWithObjectsAndKeys: _lrc,@"lyricText",sentenceData,@"sentence",nil];
	    [_messagingCenter sendMessageName:@"changeLyric" userInfo:message];
		
	}
}
%end


void createMyLyric(SongInfo* info,LocalLyricObject*lyricObject){
	KSLyric*l=[lyricObject originLyric];
// 		NSMutableArray *ma=l.sentencesArray;
// 		KSSentence *s=ma[0];
// 		NSLog(@"text: %@",[ma[0] text]);
// 		NSLog(@"text: %@",[ma[1] text]);
// 		NSLog(@"text: %@",[ma[2] text]);

	NSString* lyricName=[info song_Name];
	// NSLog(@"name:%@",lyricName);
	NSMutableArray *sentencesArray=l.sentencesArray;
	NSMutableArray *tempMySentences=[NSMutableArray arrayWithCapacity:200];

	// NSLog(@"%llu",[(KSCharacter*)[sentencesArray[0] charactersArray][0] startTime]);
	// NSLog(@"%llu",[(KSCharacter*)[sentencesArray[0] charactersArray][0] duration]);
	// NSLog(@"%llu",[(KSCharacter*)[sentencesArray[0] charactersArray][1] startTime]);

	// NSLog(@"%llu",[(KSCharacter*)[sentencesArray[1] charactersArray][0] startTime]);
	// NSLog(@"%llu",[(KSCharacter*)[sentencesArray[1] charactersArray][0] duration]);
	// NSLog(@"%llu",[(KSCharacter*)[sentencesArray[1] charactersArray][1] startTime]);

	for(KSSentence* sentence in sentencesArray){
	    MySentence *mySentence=[MySentence alloc];
	    [mySentence setText:[sentence text]];
	    [mySentence setStartTime:[sentence startTime]];
	    NSMutableArray*charactersArray=[NSMutableArray arrayWithCapacity:30];
	    for(KSCharacter* character in [sentence charactersArray]){
	    	MyCharacter*myCharacter=[MyCharacter new];
	    	[myCharacter setStartTime:[character startTime]];
	    	[myCharacter setDuration:[character duration]];
	    	[myCharacter setStart:[character start]];
	    	[myCharacter setEnd:[character end]];
	    	[charactersArray addObject:myCharacter];
	    }
	    [mySentence setCharactersArray:charactersArray];
	    [tempMySentences addObject:mySentence];
	}
	[allLyrics setValue:tempMySentences forKey:lyricName];
}

%hook LyricManager
- (id)getLyricObjectFromLocal:(id)arg1 lyricFrom:(unsigned long long)arg2 { 
	NSLog(@"getLyricObjectFromLocal:(id)%@ lyricFrom:(unsigned long long) start",arg1);
	id r = %orig; 
	NSLog(@" = %@", r); 
	if(r){
		createMyLyric(arg1,r);
	}
	return r; 
}
- (id)getLyricObjectFromLocal:(id)arg1 { 
	NSLog(@"getLyricObjectFromLocal:(id)%@ lyricFrom:(unsigned long long) start",arg1);
	id r = %orig; 
	NSLog(@" = %@", r); 
	if(r){
		createMyLyric(arg1,r);
	}
	return r; 
}

%end
%end //QQMusicHook


%group SBHook
%hook SpringBoard
-(void) applicationDidFinishLaunching:(id)application{
	%orig;
	NSLog(@"applicationDidFinishLaunching");
	lyricWindow=[[LyricWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    lyricWindow.windowLevel = UIWindowLevelStatusBar;
	[lyricWindow setHidden:NO];
	[lyricWindow setAlpha:1.0];
	[lyricWindow setBackgroundColor:[UIColor clearColor]];
	lyricView=[QQWQSuspendView showWithType:WQSuspendViewTypeNone inWindow:nil tapBlock:^{} ];
	[lyricWindow addSubview:lyricView];

	loadPref();
	[QQLyricMessagingCenter sharedInstance];
	unsigned contextId=[lyricWindow _contextId];
	lyricWindowContextId=contextId;

	
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];
    if(!prefs) prefs=[NSMutableDictionary new];
    prefs[@"lyricWindowContextId"]=[NSNumber numberWithUnsignedInt:lyricWindowContextId];
    [prefs writeToFile:prefPath atomically:YES];
    notify_post("com.brend0n.qqmusicdesktoplyrics/loadPref");

	[lyricView.label removeFromSuperview];
	CGSize screenSize = [[UIScreen mainScreen] bounds].size;
	lyric=[[LyricLabel alloc] initWithFrame:CGRectMake(0,0,screenSize.width,30)];
	[lyric testSwitch];
    [lyricView addSubview:lyric];
    
}
%end



// %hook FBRootWindow
// +(id) alloc{
// 	id ret=%orig;
// 	rootWindow=ret;
// 	return ret;
// }
// %end

// %hook UIWindow
// -(id)hitTest:(CGPoint)arg1 withEvent:(id)arg2 {
// 	static dispatch_once_t onceToken;
//     dispatch_once(&onceToken, ^{
//     	// id wrappers=[[rootWindow subviews][0] subviews];
//     	// for(id wrapper in wrappers){
//     	// 	if(![[wrapper subviews] count]) continue;
//     	// 	id sceneLayer=[wrapper subviews][0];
//     	// 	if(![[sceneLayer subviews] count]) continue;
//     	// 	id contextLayer=[sceneLayer subviews][0];
//     	// 	id layerHost=[contextLayer layer];
//     	// 	unsigned contextId=[layerHost contextId];
//     	// 	NSString*sceneId=[[sceneLayer scene] identifier];
//     	// 	// NSLog(@"%@,%u",sceneId,contextId);
//     	// 	if([sceneId containsString:@"LyricWindow"]){
//     	// 		lyricWindowContextId=contextId;
//     	// 		NSLog(@"got:%u",contextId);
//     	// 		NSString*prefPath=@"/var/mobile/Library/Preferences/com.brend0n.qqmusicdesktoplyrics.plist";
// 			  //   NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];
// 			  //   if(!prefs) prefs=[NSMutableDictionary new];
// 			  //   prefs[@"lyricWindowContextId"]=[NSNumber numberWithUnsignedInt:lyricWindowContextId];
// 			  //   [prefs writeToFile:prefPath atomically:YES];
// 			  //   notify_post("com.brend0n.qqmusicdesktoplyrics/loadPref");
//     	// 	}
//     	// }
//     });
// 	id ret= %orig;

// 	return ret;

// }
// %end
%end// SBHook

%group BBHook
%hook CAWindowServerDisplay
-(unsigned)contextIdAtPosition:(CGPoint)arg1 excludingContextIds:(id)arg2  { 
	// NSLog(@"contextIdAtPosition:(CGPoint){%g, %g} excludingContextIds:(id)%@  start",arg1.x,arg1.y,arg2);
	unsigned r ;
	if(positionLocked&&lyricWindowContextId){
		if(!arg2) arg2=[NSMutableArray new];
		else arg2=[arg2 mutableCopy];
		[arg2 addObject:[NSNumber numberWithUnsignedInt:lyricWindowContextId]];
		r=%orig(arg1,arg2);

	}
	else r= %orig; 
	// NSLog(@" = %u", r); 
	return r; 
}
%end
%end //BBHook

void loadPref(){
	NSLog(@"loadPref");
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];
	
	if(!prefs) enabled=YES;
	else enabled=[prefs[@"enabled"] boolValue];
	if(!prefs) positionLocked=FALSE;
	else positionLocked=[prefs[@"positionLocked"] boolValue];

	lyricWindowContextId=[prefs[@"lyricWindowContextId"] unsignedIntValue];

	if(lyricWindow){
		[lyricWindow setHidden:!enabled];
		[lyricView setHidden:!enabled];
		[lyricWindow setPositionLocked:positionLocked];
	}
	
}

//ctor
%ctor{
	NSLog(@"ctor QQMusicDesktopLyrics");
	if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.tencent.QQMusic"]||[[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.tencent.QQMusicHD"]){
		%init(QQMusicHook);

		allLyrics=[NSMutableDictionary dictionaryWithCapacity:100];
		_messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.brend0n.qqmusicdesktoplyrics"];
#if TARGET_OS_SIMULATOR
#else
    	rocketbootstrap_distributedmessagingcenter_apply(_messagingCenter);
#endif

	}
	else if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.backboardd"]){
		%init(BBHook);
		int token=0;
		notify_register_dispatch("com.brend0n.qqmusicdesktoplyrics/loadPref", &token, dispatch_get_main_queue(), ^(int token) {
		loadPref();
		});
	}
	else{
		%init(SBHook);
		int token=0;
		notify_register_dispatch("com.brend0n.qqmusicdesktoplyrics/loadPref", &token, dispatch_get_main_queue(), ^(int token) {
		loadPref();
		});
	}
	
}