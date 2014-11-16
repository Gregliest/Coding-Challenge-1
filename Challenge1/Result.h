// Represents the results of analyzing one data file

#import <Foundation/Foundation.h>

@interface Result : NSObject

@property (nonatomic) NSDate *startTime;
@property (nonatomic) NSDate *endTime;
@property (nonatomic) NSTimeInterval duration;

@end
