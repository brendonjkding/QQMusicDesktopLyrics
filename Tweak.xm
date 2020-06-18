#import "QQWQSuspendView/QQWQSuspendView.h"
#import "QQWQSuspendView/TriangleView.h"
#import <substrate.h>
#import <rocketbootstrap/rocketbootstrap.h>
#import <AppSupport/CPDistributedMessagingCenter.h>
#import <SpringBoard/SpringBoard.h>
#import <GraphicsServices/GSEvent.h>
#import <notify.h>

#ifdef DEBUG
#define TEST1
#define TEST2
#endif
//cuctom
@interface MyLyric:NSObject
@property(nonatomic)NSString* text;
@property long long startTime;
@end
@implementation MyLyric
@end

@interface LyricWindow:UIWindow
@property BOOL positionLocked;
@end
@implementation LyricWindow
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	if(_positionLocked) return nil;
    UIView *hitTestView = [super hitTest:point withEvent:event];
    if(hitTestView==self) return nil;
    else return hitTestView;
}
@end

@interface QQLyricMessagingCenter : NSObject {
	CPDistributedMessagingCenter * _messagingCenter;
}
@end

//global
QQWQSuspendView* lyricView;
LyricWindow *lyricWindow;
NSMutableDictionary *allLyrics;
double lstTime=0;
MyLyric* lstLyric;
CPDistributedMessagingCenter * _messagingCenter;
UIWindow*rootWindow=0;
BOOL positionLocked=0;
unsigned lyricWindowContextId=0;
void loadPref();

//custom imp
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
		rocketbootstrap_distributedmessagingcenter_apply(_messagingCenter);

		[_messagingCenter runServerOnCurrentThread];
		[_messagingCenter registerForMessageName:@"changeLyric" target:self selector:@selector(handleMessageNamed:withUserInfo:)];
	}

	return self;
}

- (NSDictionary *)handleMessageNamed:(NSString *)name withUserInfo:(NSDictionary *)userInfo {
	NSString*lyricText=userInfo[@"lyricText"];
	lyricView.label.text=lyricText;
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

@interface KSSentence
@property(nonatomic) long long startTime; // @synthesize startTime=_startTime;
@property(retain, nonatomic) NSString *text; // @synthesize text=_text;
@property(nonatomic) int sentenceTransType;
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
    if(diff<600&&diff>-1)return;
    lstTime=curTime;
    
    NSString*_lrc=0;
    NSArray* lyricArray=[allLyrics objectForKey:[[self currentSong] song_Name]];
    if(!lyricArray){
    	NSLog(@"no lyric:%@",[[self currentSong] song_Name]);
        if(![[lstLyric text] isEqualToString:@" "]){
            lstLyric=[MyLyric alloc];
            [lstLyric setText:@" "];
            _lrc=[lstLyric text];
        }
    }
    else{
        MyLyric* curLyric=0;
        
        
        for(id myLyric in lyricArray){
            if([myLyric startTime]>curTime) break;
            curLyric=myLyric;
        }
        
        if(curLyric&&curLyric!=lstLyric) {
            lstLyric=curLyric;
            _lrc=[lstLyric text];
        }
    }
	if(_lrc) {
		NSLog(@"%@",_lrc);
    	// Send a message with a dictionary
	    NSDictionary * message = [NSDictionary dictionaryWithObjectsAndKeys: _lrc,@"lyricText", nil];
	    [_messagingCenter sendMessageName:@"changeLyric" userInfo:message];
		
	}
}
%end


@class NSMutableDictionary, NSString;

%hook LyricManager
- (id)getLyricObjectFromLocal:(id)arg1 lyricFrom:(unsigned long long)arg2 { 
#ifdef TEST2
	NSLog(@"getLyricObjectFromLocal:(id)%@ lyricFrom:(unsigned long long) start",arg1);
#endif
	id r = %orig; 
#ifdef TEST2
	NSLog(@" = %@", r); 
#endif
	if(r){
		KSLyric*l=[r originLyric];
		NSMutableArray *ma=l.sentencesArray;
#ifdef TEST2
		KSSentence *s=ma[0];
		NSLog(@"text: %@",[ma[0] text]);
		NSLog(@"text: %@",[ma[1] text]);
		NSLog(@"text: %@",[ma[2] text]);
#endif

		NSString* lyricName=[arg1 song_Name];
		NSLog(@"name:%@",lyricName);
		NSMutableArray *sentencesArray=l.sentencesArray;
		NSMutableArray *tempMyLyrics=[NSMutableArray arrayWithCapacity:100];
		for(id sentence in sentencesArray){
		    MyLyric *myLyric=[MyLyric alloc];
		    [myLyric setText:[sentence text]];
		    [myLyric setStartTime:[sentence startTime]];
		    [tempMyLyrics addObject:myLyric];
		}
		[allLyrics setValue:tempMyLyrics forKey:lyricName];
	}
	return r; 
}
- (id)getLyricObjectFromLocal:(id)arg1 { 
#ifdef TEST2
	NSLog(@"getLyricObjectFromLocal:(id)%@ lyricFrom:(unsigned long long) start",arg1);
#endif
	id r = %orig; 
#ifdef TEST2
	NSLog(@" = %@", r); 
#endif
	if(r){
		KSLyric*l=[r originLyric];
		NSMutableArray *ma=l.sentencesArray;
#ifdef TEST2
		KSSentence *s=ma[0];
		NSLog(@"text: %@",[ma[0] text]);
		NSLog(@"text: %@",[ma[1] text]);
		NSLog(@"text: %@",[ma[2] text]);
#endif

		NSString* lyricName=[arg1 song_Name];
		NSLog(@"name:%@",lyricName);
		NSMutableArray *sentencesArray=l.sentencesArray;
		NSMutableArray *tempMyLyrics=[NSMutableArray arrayWithCapacity:100];
		for(id sentence in sentencesArray){
		    MyLyric *myLyric=[MyLyric alloc];
		    [myLyric setText:[sentence text]];
		    [myLyric setStartTime:[sentence startTime]];
		    [tempMyLyrics addObject:myLyric];
		}
		[allLyrics setValue:tempMyLyrics forKey:lyricName];
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
	// [lyricWindow makeKeyAndVisible];

	loadPref();
	[QQLyricMessagingCenter sharedInstance];
	unsigned contextId=[lyricWindow _contextId];
	NSLog(@"got------? %u",contextId);
	lyricWindowContextId=contextId;

	NSString*prefPath=@"/var/mobile/Library/Preferences/com.brend0n.qqmusicdesktoplyrics.plist";
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];
    if(!prefs) prefs=[NSMutableDictionary new];
    prefs[@"lyricWindowContextId"]=[NSNumber numberWithUnsignedInt:lyricWindowContextId];
    [prefs writeToFile:prefPath atomically:YES];
    notify_post("com.brend0n.qqmusicdesktoplyrics/loadPref");
#ifdef TEST1
	CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    LabelView *_label=[[LabelView alloc] initWithFrame:CGRectMake(0,0,screenSize.width,60)];
    [_label setBackgroundColor:[UIColor clearColor]];
    // [lyricWindow addSubview:_label];
    // [rootWindow addSubview:_label];
    [lyricWindow addSubview:lyricView];
    
#endif
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
// %hook UITouch
// - (CGPoint)locationInView:(UIView *)view{

// }
// %end
%group BBHook
%hook CAWindowServerDisplay

// -(unsigned)contextIdAtPosition:(CGPoint)arg1  { NSLog(@"contextIdAtPosition:(CGPoint){%g, %g}  start",arg1.x,arg1.y);unsigned r = %orig; NSLog(@" = %u", r); return r; }
-(unsigned)contextIdAtPosition:(CGPoint)arg1 excludingContextIds:(id)arg2  { 
	NSLog(@"contextIdAtPosition:(CGPoint){%g, %g} excludingContextIds:(id)%@  start",arg1.x,arg1.y,arg2);
	unsigned r ;
	if(positionLocked&&lyricWindowContextId){
		if(!arg2) arg2=[NSMutableArray new];
		else arg2=[arg2 mutableCopy];
		[arg2 addObject:[NSNumber numberWithUnsignedInt:lyricWindowContextId]];
		r=%orig(arg1,arg2);

	}
	else r= %orig; 
	NSLog(@" = %u", r); 
	return r; 
}
// -(unsigned)clientPortAtPosition:(CGPoint)arg1  { NSLog(@"clientPortAtPosition:(CGPoint)arg1  start");unsigned r = %orig; NSLog(@" = %u", r); return r; }
// -(CGPoint)convertPoint:(CGPoint)arg1 toContextId:(unsigned)arg2  { NSLog(@"convertPoint:(CGPoint){%g, %g} toContextId:(unsigned)%u  start",arg1.x,arg1.y,arg2);CGPoint r = %orig; NSLog(@" = {%g, %g}", r.x, r.y); return r; }
// -(CGPoint)convertPoint:(CGPoint)arg1 fromContextId:(unsigned)arg2  { NSLog(@"convertPoint:(CGPoint)arg1 fromContextId:(unsigned)arg2  start");CGPoint r = %orig; NSLog(@" = {%g, %g}", r.x, r.y); return r; }

%end
%end //BBHook
void loadPref(){
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.brend0n.qqmusicdesktoplyrics.plist"];
	bool enabled;
	if(!prefs) enabled=1;
	else enabled=[prefs[@"enabled"] boolValue]==YES?1:0;
	// BOOL positionLocked;
	if(!prefs) positionLocked=FALSE;
	else positionLocked=[prefs[@"positionLocked"] boolValue];
	lyricWindowContextId=[prefs[@"lyricWindowContextId"] unsignedIntValue];

	if(lyricWindow){
		[lyricWindow setHidden:enabled?FALSE:TRUE];
		[lyricView setHidden:enabled?FALSE:TRUE];
		[lyricWindow setPositionLocked:positionLocked];
	}
	
}

//ctor
%ctor{
	if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.tencent.QQMusic"]||[[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.tencent.QQMusicHD"]){
		%init(QQMusicHook);
		// myLyrics=[NSMutableArray arrayWithCapacity:100];
		allLyrics=[NSMutableDictionary dictionaryWithCapacity:100];
		_messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.brend0n.qqmusicdesktoplyrics"];
    	rocketbootstrap_distributedmessagingcenter_apply(_messagingCenter);

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