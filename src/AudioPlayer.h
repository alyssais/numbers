#import <Foundation/Foundation.h>

@interface AudioPlayer : NSObject

@property (nonatomic, readonly) NSTimeInterval deviceCurrentTime;
@property (nonatomic, readonly) NSInteger queueLength;

- (void)playAudioNamed:(NSString *)name atTime:(NSTimeInterval)time;

@end
