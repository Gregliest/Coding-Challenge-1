// This data class represents one epoch of test data.

#import <Foundation/Foundation.h>

@interface Epoch : NSObject

@property (nonatomic) NSInteger activityId;
@property (nonatomic) NSDate *date;

+ (instancetype)parseFromString:(NSString *)csvString;
- (NSTimeInterval)intervalSinceEpoch:(Epoch *)epoch;


@end
