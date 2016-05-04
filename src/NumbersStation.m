#import "AudioPlayer.h"
#import "NumbersStation.h"

@interface NumbersStation ()

@property (nonatomic, readonly) AudioPlayer *player;
@property (nonatomic, readonly) NSDictionary *configuration;
@property (nonatomic) NSTimeInterval start;
@property (nonatomic) int t;
@property (nonatomic) int messageIndex;

@end

@implementation NumbersStation

#pragma mark - Initializers

- (instancetype)initWithConfigurationFilePath:(NSString *)relativePath
{
    NSString *cwd = [[[NSFileManager defaultManager] currentDirectoryPath] stringByAppendingString:@"/"];
    NSString *path = [self resolvePath:relativePath relativeToPath:cwd];
    NSLog(@"Reading configuration from %@", path);
    NSInputStream *stream = [[NSInputStream alloc] initWithFileAtPath:path];
    [stream open];
    NSDictionary *configuration = [NSJSONSerialization JSONObjectWithStream:stream options:0 error:nil];
    [stream close];
    self = [self initWithConfiguration:configuration];
    _configurationFilePath = path;
    return self;
}

- (instancetype)initWithConfiguration:(NSDictionary *)configuration
{
    self = [self init];
    _configuration = configuration;
    return self;
}

- (instancetype)init
{
    self = [super init];
    _player = [[AudioPlayer alloc] init];
    return self;
}

#pragma mark - Property overrides

- (NSArray *)tone
{
    return self.configuration[@"tone"];
}

- (NSString *)message
{
    return self.configuration[@"message"];
}

- (NSDictionary *)sounds
{
    return self.configuration[@"sounds"];
}

#pragma mark - Logic

- (NSString *)nameForCharacter:(unichar)character
{
    if (character == ' ') return nil;
    return [NSString stringWithFormat:@"%i", toupper(character) - 'A' + 1];
}

- (NSString *)nameForCharacterAtMessageIndex:(NSInteger)index
{
    return [self nameForCharacter:[self.message characterAtIndex:index]];
}

- (NSString *)nameForAudioAtTime:(NSTimeInterval)time
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger minutes = [calendar component:NSCalendarUnitMinute fromDate:date];
    NSInteger seconds = [calendar component:NSCalendarUnitSecond fromDate:date];

    if (minutes == 59) {
        switch (seconds) {
            case 0: return @"longbeep";
            case 55 ... 59: return @"beep";
        }
    }
    
    if (self.message == nil && self.tone == nil) return nil;

    NSString *name;
    if (self.messageIndex >= self.message.length) {
        name = self.tone[self.messageIndex - self.message.length];
        if ([name isEqual:[NSNull null]]) name = nil;
    } else {
        name = [self nameForCharacterAtMessageIndex:self.messageIndex];
    }
    self.messageIndex = (self.messageIndex + 1) % (self.message.length + self.tone.count);

    return name;
}

- (NSString *)resolvePath:(NSString *)relativePath relativeToPath:(NSString *)basePath
{
    NSURL *baseURL = [NSURL URLWithString:basePath];
    return [NSURL URLWithString:relativePath relativeToURL:baseURL].path;
}

- (NSString *)resolvePath:(NSString *)relativePath
{
    return [self resolvePath:relativePath relativeToPath:self.configurationFilePath];
}

- (void)tick
{
    if (self.player.queueLength < 10) {
        NSTimeInterval time = self.start + ++self.t;
        NSString *name = [self nameForAudioAtTime:time];
        if (name) {
            NSString *path = [self resolvePath:self.sounds[name]];
            [self.player playAudioAtFilePath:path atTime:time];
        }

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
    [self checkConfiguration];
    self.start = [self.player deviceCurrentTime];
    [self tick];
}

- (void)checkConfiguration
{
    NSMutableArray *errors = [[NSMutableArray alloc] init];
    NSMutableArray *names = [@[@"beep", @"longbeep"] mutableCopy];
    
    for (int i = 0; i < self.message.length; i++) {
        NSString *name = [self nameForCharacterAtMessageIndex:i];
        if (name) {
            [names addObject:name];
        }
    }
    
    for (NSString *name in names) {
        if (self.sounds[name] == nil) {
            [errors addObject:[NSString stringWithFormat:@"No sound for %@", name]];
        }
    }
    
    if (errors.count > 0) {
        for (NSString *error in errors) {
            NSLog(@"%@", error);
        }
        exit(1);
    }
}

@end
