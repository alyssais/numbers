#import <AVFoundation/AVFoundation.h>
#import "AudioPlayer.h"

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

- (NSString *)filePathForAudioNamed:(NSString *)name
{
    return [NSString stringWithFormat:@"/Users/alyssais/Desktop/Numbers/sounds/%@.wav", name];
}

- (NSData *)dataForAudioNamed:(NSString *)name
{
    return self.dataCache[name] ?: ^{
        NSString *path = [self filePathForAudioNamed:name];
        NSData *data = [NSData dataWithContentsOfFile:path];
        self.dataCache[name] = data;
        return data;
    }();
}

- (AVAudioPlayer *)makePlayerForAudioNamed:(NSString *)name
{
    NSData *data = [self dataForAudioNamed:name];
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithData:data error:nil];
    player.delegate = self;
    [player prepareToPlay];
    return player;
}

- (NSMutableSet *)availablePlayersForAudioNamed:(NSString *)name
{
    return self.availablePlayers[[self dataForAudioNamed:name]];
}

- (AVAudioPlayer *)checkOutAvailablePlayerForAudioNamed:(NSString *)name
{
    NSMutableSet *availablePlayers = [self availablePlayersForAudioNamed:name];
    AVAudioPlayer *player = [availablePlayers anyObject]
        ?: [self makePlayerForAudioNamed:name];
    [self.busyPlayers addObject:player];
    [availablePlayers removeObject:player];
    return player;
}

- (void)playAudioNamed:(NSString *)name atTime:(NSTimeInterval)time
{
    if (name == nil) return;
    AVAudioPlayer *player = [self checkOutAvailablePlayerForAudioNamed:name];
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

    AVAudioPlayer *player = [self makePlayerForAudioNamed:@"sine0100"];
    [self playerBecameAvailable:player];
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
