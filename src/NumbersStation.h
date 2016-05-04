#import <Foundation/Foundation.h>

@interface NumbersStation : NSObject

@property (nonatomic, readonly) NSString *configurationFilePath;
@property (nonatomic, readonly) NSArray *tone;
@property (nonatomic, readonly) NSString *message;
@property (nonatomic, readonly) NSDictionary *sounds;

- (instancetype)initWithConfigurationFilePath:(NSString *)configurationFilePath;
- (instancetype)initWithConfiguration:(NSDictionary *)configuration;
- (void)run;

@end
