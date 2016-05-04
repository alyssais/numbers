#import <AVFoundation/AVFoundation.h>
#import "AudioPlayer.h"

static NSString *const KNOWN_FILE_PATH = @"/System/Library/Sounds/Sosumi.aiff";

@interface AudioPlayer () <AVAudioPlayerDelegate>

@property (nonatomic, readonly) NSMutableDictionary *dataCache;
@property (nonatomic, readonly) NSMutableDictionary *availablePlayers;
@property (nonatomic, readonly) NSMutableSet *busyPlayers;

@end

@implementation AudioPlayer

- (instancetype)init
{
    self = [super init];
    _dataCache = [[NSMutableDictionary alloc] init];
    _availablePlayers = [[NSMutableDictionary alloc] init];
    _busyPlayers = [[NSMutableSet alloc] init];
    return self;
}

- (NSData *)dataForAudioAtFilePath:(NSString *)path
{
    return self.dataCache[path] ?: ^{
        NSData *data = [NSData dataWithContentsOfFile:path];
        self.dataCache[path] = data;
        return data;
    }();
}

- (AVAudioPlayer *)makePlayerForAudioAtFilePath:(NSString *)path
{
    NSData *data = [self dataForAudioAtFilePath:path];
    NSError *error = nil;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithData:data error:&error];
    if (player == nil) {
        NSLog(@"%@", error);
    }
    player.delegate = self;
    return player;
}

- (NSMutableSet *)availablePlayersForAudioAtFilePath:(NSString *)path
{
    return self.availablePlayers[[self dataForAudioAtFilePath:path]];
}

- (AVAudioPlayer *)checkOutAvailablePlayerForAudioAtFilePath:(NSString *)path
{
    NSMutableSet *availablePlayers = [self availablePlayersForAudioAtFilePath:path];
    AVAudioPlayer *player = [availablePlayers anyObject]
        ?: [self makePlayerForAudioAtFilePath:path];
    [self.busyPlayers addObject:player];
    [availablePlayers removeObject:player];
    return player;
}

- (void)playAudioAtFilePath:(NSString *)path atTime:(NSTimeInterval)time
{
    AVAudioPlayer *player = [self checkOutAvailablePlayerForAudioAtFilePath:path];
    [player prepareToPlay];
    [player playAtTime:time];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    player.currentTime = 0;
    [self playerBecameAvailable:player];
}

- (void)playerBecameAvailable:(AVAudioPlayer *)player
{
    [self.busyPlayers removeObject:player];
    [self.availablePlayers[player.data] addObject:player];
}

- (NSArray *)playerSets
{
    return [self.availablePlayers.allValues arrayByAddingObject:self.busyPlayers];
}

- (AVAudioPlayer *)anyPlayer
{
    for (NSSet *playerSet in self.playerSets) {
        for (AVAudioPlayer *player in playerSet) {
            return player;
        }
    }

    AVAudioPlayer *player = [self makePlayerForAudioAtFilePath:KNOWN_FILE_PATH];
    return player;
}

- (NSTimeInterval)deviceCurrentTime
{
    return [self anyPlayer].deviceCurrentTime;
}

- (NSInteger)queueLength
{
    return [self.busyPlayers count];
}

@end
