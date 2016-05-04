#import "NumbersStation.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSString *path;
        if (argc < 3) {
            path = @"config.json";
        } else {
            path = [NSString stringWithUTF8String:argv[2]];
        }

        NumbersStation *station = [[NumbersStation alloc] initWithConfigurationFilePath:path];
        [station run];
        [[NSRunLoop currentRunLoop] run];
    }
    return 0;
}
