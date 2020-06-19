#import "MyLyric.h"
@implementation MySentence
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        _text = [aDecoder decodeObjectForKey:@"text"];
        _startTime = [[aDecoder decodeObjectForKey:@"startTime"] longLongValue];
        _charactersArray = [aDecoder decodeObjectForKey:@"charactersArray"];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    // [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_text forKey:@"text"];
    [aCoder encodeObject:[NSNumber numberWithLongLong:_startTime] forKey:@"startTime"];
    [aCoder encodeObject:_charactersArray forKey:@"charactersArray"];
}
@end
@implementation MyCharacter
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        _character = [aDecoder decodeObjectForKey:@"character"];
        _startTime = [[aDecoder decodeObjectForKey:@"startTime"] longLongValue];
        _duration = [[aDecoder decodeObjectForKey:@"duration"] longLongValue];
        _start = [[aDecoder decodeObjectForKey:@"start"] longLongValue];
        _end = [[aDecoder decodeObjectForKey:@"end"] longLongValue];

    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    // [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_character forKey:@"character"];
    [aCoder encodeObject:[NSNumber numberWithLongLong:_startTime] forKey:@"startTime"];
    [aCoder encodeObject:[NSNumber numberWithLongLong:_duration] forKey:@"duration"];
    [aCoder encodeObject:[NSNumber numberWithLongLong:_start] forKey:@"start"];
    [aCoder encodeObject:[NSNumber numberWithLongLong:_end] forKey:@"end"];
}
@end