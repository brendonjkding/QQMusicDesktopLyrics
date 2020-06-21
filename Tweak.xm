#import "QQWQSuspendView/QQWQSuspendView.h"
#import "LyricLabel.h"
#import "MyLyric.h"
#import "QQMusic.h"

#import <substrate.h>
#import <rocketbootstrap/rocketbootstrap.h>
#import <AppSupport/CPDistributedMessagingCenter.h>
#import <SpringBoard/SpringBoard.h>
#import <notify.h>

//cuctom
@interface lyricWindowRootViewController : UIViewController
@property (nonatomic, strong) dispatch_source_t hideTimer;
-(void)hideWindow;
-(void)showWindow;
@end

@interface LyricWindow:UIWindow
@property BOOL positionLocked;
@end

@interface QQLyricMessagingCenter : NSObject {
	CPDistributedMessagingCenter * _messagingCenter;
}
@end

//global
BOOL enabled=0;
BOOL positionLocked=0;
BOOL autoHide=0;
unsigned lyricWindowContextId=0;
CPDistributedMessagingCenter * _messagingCenter;
void loadPref();
NSString*prefPath=@"/var/mobile/Library/Preferences/com.brend0n.qqmusicdesktoplyrics.plist";

QQWQSuspendView* lyricView;
LyricWindow *lyricWindow;
LyricLabel *lyricLabel;

NSMutableDictionary *allLyrics;
double lstTime=0;
MySentence* lstSentence;
NSString*lstSongName;
int lstSentenceIndex=0;

//custom imp
@implementation lyricWindowRootViewController

-(void)loadView{
	[super loadView];
	lyricView=[QQWQSuspendView showWithType:WQSuspendViewTypeNone inWindow:nil tapBlock:^{} ];
	[self.view addSubview:lyricView];

	CGSize screenSize = [[UIScreen mainScreen] bounds].size;
	lyricLabel=[[LyricLabel alloc] initWithFrame:CGRectMake(0,0,screenSize.width,30)];
	[lyricLabel showAuthor];
    [lyricView addSubview:lyricLabel];
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate
{
    return YES;
}
// - (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
//                                 duration:(NSTimeInterval)duration
// {
//     [UIView setAnimationsEnabled:NO];
// }

// - (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
// {   
//     [UIView setAnimationsEnabled:YES];
// }
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
	// NSLog(@"viewWillTransitionToSize");
	CGFloat oldWidth=size.height;
	CGFloat oldHeight=size.width;
	CGFloat newWidth=size.width;
	CGFloat newHeight=size.height;
    if(lyricView){
        [lyricView setFrame:CGRectMake(lyricView.frame.origin.x,lyricView.frame.origin.y*(newHeight/oldHeight),newWidth,lyricView.frame.size.height)];
        [lyricLabel setFrame:CGRectMake(lyricLabel.frame.origin.x,lyricLabel.frame.origin.y*(newHeight/oldHeight),newWidth,lyricLabel.frame.size.height)];
        }
    if (size.width > size.height) { // 横屏
        // 横屏布局 balabala
    } else {
        // 竖屏布局 balabala
    }
}
-(void)hideWindow{
	[[self.view superview] setHidden:YES];
}
-(void)showWindow{
	[[self.view superview] setHidden:NO];
}
@end

@implementation LyricWindow
- (id)initWithFrame:(CGRect)frame{
	self=[super initWithFrame:frame];
	if(!self) return self;

	self.windowLevel = UIWindowLevelStatusBar;
	self.clipsToBounds=YES;
	[self setHidden:NO];
	[self setAlpha:1.0];
	[self setBackgroundColor:[UIColor clearColor]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];

	return self;
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	if(_positionLocked) return nil;
    UIView *hitTestView = [super hitTest:point withEvent:event];
    if(hitTestView==self||hitTestView==self.rootViewController.view) return nil;
    else return hitTestView;
}

#define DegreesToRadians(degrees) (degrees * M_PI / 180)

-(void)orientationChanged:(NSNotification*)notification{
	// UIDeviceOrientation orientation=[[UIDevice currentDevice] orientation];
	// NSLog(@"orientationChanged: %ld",orientation);
	// CGAffineTransform transform;
	// switch(orientation){
	// 	case UIDeviceOrientationPortrait:
	// 		transform=CGAffineTransformMakeRotation(DegreesToRadians(0));
	// 		break;
	// 	case UIDeviceOrientationPortraitUpsideDown:
	// 		CGAffineTransformMakeRotation(DegreesToRadians(180));
	// 		break;
	// 	case UIDeviceOrientationLandscapeLeft:

	// 		CGAffineTransformMakeRotation(DegreesToRadians(270));
	// 		break;
	// 	case UIDeviceOrientationLandscapeRight:
	// 		CGAffineTransformMakeRotation(DegreesToRadians(90));
	// 		break;
	// 	default:
	// 		break;


	// }
	// if(self){
	// 	[self setFrame:CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height)];
	// 	[self setTransform:transform];
	// 	[self layoutIfNeeded];
	// }
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

	NSData* sentenceData=userInfo[@"sentence"];
	MySentence*sentence=[NSKeyedUnarchiver unarchiveObjectWithData:sentenceData];
	[lyricLabel prepareSentence:sentence];



	[NSObject cancelPreviousPerformRequestsWithTarget:lyricWindow.rootViewController selector:@selector(hideWindow) object:nil];
	[lyricWindow.rootViewController performSelector:@selector(showWindow)];
	if(autoHide){	
		[lyricWindow.rootViewController performSelector:@selector(hideWindow) withObject:nil afterDelay:30];
	}

	return nil;
}

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
   		NSData*sentenceData=[NSKeyedArchiver archivedDataWithRootObject:lstSentence];
	    NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys: _lrc,@"lyricText",sentenceData,@"sentence",nil];
    	
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
	// NSLog(@"getLyricObjectFromLocal:(id)%@ lyricFrom:(unsigned long long) start",arg1);
	id r = %orig; 
	// NSLog(@" = %@", r); 
	if(r){
		createMyLyric(arg1,r);
	}
	return r; 
}
- (id)getLyricObjectFromLocal:(id)arg1 { 
	// NSLog(@"getLyricObjectFromLocal:(id)%@ lyricFrom:(unsigned long long) start",arg1);
	id r = %orig; 
	// NSLog(@" = %@", r); 
	if(r){
		createMyLyric(arg1,r);
	}
	return r; 
}

%end
%end //QQMusicHook

@interface UIWindow()
-(unsigned)_contextId;
@end

%group SBHook
%hook SpringBoard
-(void) applicationDidFinishLaunching:(id)application{
	%orig;
	NSLog(@"applicationDidFinishLaunching");
	[QQLyricMessagingCenter sharedInstance];

	lyricWindow=[[LyricWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	lyricWindow.rootViewController=[lyricWindowRootViewController new];
	unsigned contextId=[lyricWindow _contextId];
	lyricWindowContextId=contextId;

	
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];
    if(!prefs) prefs=[NSMutableDictionary new];
    prefs[@"lyricWindowContextId"]=[NSNumber numberWithUnsignedInt:lyricWindowContextId];
    [prefs writeToFile:prefPath atomically:YES];
    notify_post("com.brend0n.qqmusicdesktoplyrics/loadPref");

    loadPref();
    
}
%end
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
	if(!prefs) positionLocked=NO;
	else positionLocked=[prefs[@"positionLocked"] boolValue];
	if(!prefs) autoHide=NO;
	else autoHide=[prefs[@"autoHide"] boolValue];

	lyricWindowContextId=[prefs[@"lyricWindowContextId"] unsignedIntValue];

	if(lyricWindow){
		[lyricWindow setHidden:!enabled];
		[lyricWindow setPositionLocked:positionLocked];
		if(autoHide) [lyricWindow.rootViewController performSelector:@selector(hideWindow) withObject:nil afterDelay:30];
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