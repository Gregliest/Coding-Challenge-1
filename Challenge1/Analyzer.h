// This class analyzes challenge files.

#import <Foundation/Foundation.h>
#import "Result.h"

@interface Analyzer : NSObject

- (NSArray *)importFile:(NSString *)fileName;
- (Result *)analyzeArray:(NSArray *)csvArray;

@end
