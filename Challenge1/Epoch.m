#import "Epoch.h"

@implementation Epoch
static NSDateFormatter *formatter = nil;

// Parses an epoch from a string.  Does some basic error checking, but generally assumes
// that the incoming data is clean, and is not robust against format changes.
+ (instancetype)parseFromString:(NSString *)csvString {
    Epoch *epoch = [Epoch new];
    NSArray *items = [csvString componentsSeparatedByString:@","];

    if (items.count < 2) {
        NSLog(@"Epoch could not be parsed %@", csvString);
        return nil;
    } else {
        epoch.activityId = [items[0] integerValue];
        
        NSDate *date = [Epoch dateFromCSV:items[1]];
        if (date) {
            epoch.date = date;
        } else {
            NSLog(@"Epoch date could not be parsed %@", csvString);
            return nil;
        }
        return epoch;
    }
    
}

// Calculates the interval between the date of the passed epoch and the receiver.
// Returns negative value if epoch is later than the receiver.
- (NSTimeInterval)intervalSinceEpoch:(Epoch *)epoch {
    if (epoch) {
        return [self.date timeIntervalSinceDate:epoch.date];
    } else {
        return 0;
    }
}

// Date formatter, assumes that all dates are represented in the same format as the original test data.  
+ (NSDate *)dateFromCSV:(NSString *)dateString {
    // If the date formatter isn't set up, create it and cache for reuse.
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        
        [formatter setLocale:enUSPOSIXLocale];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    
    // Convert csv string to an NSDate.
    return [formatter dateFromString:dateString];
}
@end
