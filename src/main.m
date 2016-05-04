#import "NumbersStation.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NumbersStation *station = [[NumbersStation alloc] init];
        [station run];
        [[NSRunLoop currentRunLoop] run];
    }
    return 0;
}
