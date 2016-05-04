#import "AudioPlayer.h"
#import "NumbersStation.h"

static NSString *const message = @"WE ARE TINY KETTLE";

@interface NumbersStation ()

@property (nonatomic, readonly) AudioPlayer *player;
@property (nonatomic) NSTimeInterval start;
@property (nonatomic) int t;
@property (nonatomic) int messageIndex;

@end

@implementation NumbersStation

- (instancetype)init
{
    self = [super init];
    _player = [[AudioPlayer alloc] init];
    return self;
}

- (NSString *)nameForCharacter:(unichar)character
{
    if (character == ' ') return nil;
    return [NSString stringWithFormat:@"%i", character - 'A' + 1];
}

- (NSString *)nameForAudioAtTime:(NSTimeInterval)time
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger minutes = [calendar component:NSCalendarUnitMinute fromDate:date];
    NSInteger seconds = [calendar component:NSCalendarUnitSecond fromDate:date];

    if (minutes == 59) {
        switch (seconds) {
            case 0: return @"sine1000";
            case 55 ... 59: return @"sine0100";
        }
    }

    NSArray *tone = @[@"katherine"];

    NSString *name;
    if (self.messageIndex >= [message length]) {
        name = tone[self.messageIndex - [message length]];
    } else {
        name = [self nameForCharacter:[message characterAtIndex:self.messageIndex]];
    }
    self.messageIndex = (self.messageIndex + 1) % ([message length] + [tone count]);

    return name;
}

- (void)tick
{
    if (self.player.queueLength < 10) {
        NSTimeInterval time = self.start + ++self.t;
        NSString *name = [self nameForAudioAtTime:time];
        [self.player playAudioNamed:name atTime:time];

        if (self.player.queueLength < 2) {
            [self tick]; // immediately! hurry!
        } else {
            [self queueTickAfter:0];
        }
    } else {
        [self queueTickAfter:2];
    }
}

- (void)queueTickAfter:(NSTimeInterval)delay
{
    if (delay > 0) {
        dispatch_after(
            dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)),
            dispatch_get_main_queue(),
        	^{ [self tick]; }
        );
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{ [self tick]; });
    }
}

- (void)run
{
    self.start = [self.player deviceCurrentTime];
    [self tick];
}

@end
