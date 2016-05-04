#import <Foundation/Foundation.h>

@interface AudioPlayer : NSObject

@property (nonatomic, readonly) NSTimeInterval deviceCurrentTime;
@property (nonatomic, readonly) NSInteger queueLength;

- (void)playAudioAtFilePath:(NSString *)filePath atTime:(NSTimeInterval)time;

@end
