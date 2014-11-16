#import "Analyzer.h"
#import "Epoch.h"
#import "CapacityQueue.h"

// The activity id we're interested in.
static NSInteger const kActivityId = 8;

// The number of epochs in the rolling average
static NSInteger const kNumRollingAverageEpochs = 150;

// The percent of the epochs that have to match the kActivityId to trigger a start event
const float kFractionEpochsMatching = .96f;

// The number of consecutive epochs required to be above the trigger level to trigger a start event
static NSInteger const kConsecutiveTriggerEpochs = 150;

// The number of epochs required to trigger an end event
static NSInteger const kNumEndEpochs = 375;

@implementation Analyzer

// Imports a text file and returns an array of strings, one for each line in the file.
- (NSArray *)importFile:(NSString *)fileName {
    NSArray *pathFragments = [fileName componentsSeparatedByString:@"."];
    if (pathFragments.count < 2) {
        return nil;
    }
    NSString *path = pathFragments[0];
    NSString *type = pathFragments[1];
    NSString *fullPath = [[NSBundle mainBundle] pathForResource:path ofType:type];
    
    NSError *error;
    NSString *file = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:&error];
    return [file componentsSeparatedByString:@"\n"];
}

// BUSINESS LOGIC.  This complex function analyzes challenge data and returns the result.
// Returns nil if the conditions for an end trigger are not met.
// See inline comments for specifics about the logic and implementation.
- (Result *)analyzeArray:(NSArray *)csvArray {
    
    // Queue to hold all data relevant at a particular point in the analysis.
    // As a side note, to make this robust against changes to the constants, the initial
    // capacity should really be max(kNumEndEpochs, kNumRollingAverageEpochs + kConsecutiveTriggerEpochs),
    // but I think that's overkill unless frequent constant changes are required.  
    CapacityQueue *dataQueue = [[CapacityQueue alloc] initWithCapacity:kNumEndEpochs];
    // Queue to hold data for the rolling average.
    CapacityQueue *triggerQueue = [[CapacityQueue alloc] initWithCapacity:kNumRollingAverageEpochs];
    
    NSInteger matchingEpochsCount = 0;
    NSInteger streak = 0;
    Result *result = [Result new];
    
    // Analysis
    for (NSString *epochString in csvArray) {
        // Parse the epoch from the string.
        Epoch *epoch = [Epoch parseFromString:epochString];
        if (! epoch) {
            continue;
        }
        
        // Add the epoch to the queues
        Epoch *oldTriggerEpoch = (Epoch *)[triggerQueue addObjectAndGetOverflow:epoch];
        Epoch *discardEpoch = (Epoch *)[dataQueue addObjectAndGetOverflow:epoch];
        
        // Check if we have reached the trigger level
        matchingEpochsCount += [self countChange:epoch withOldEpoch:oldTriggerEpoch];
        BOOL isAboveTrigger = matchingEpochsCount > kNumRollingAverageEpochs * kFractionEpochsMatching;
        
        // If we haven't triggered a start event yet.
        if (result.startTime == nil) {
            // Add one to the streak or reset.
            streak = isAboveTrigger ? streak + 1 : 0;
            
            // If a start event has been triggered.
            if (streak >= kConsecutiveTriggerEpochs) {
                // Record the start time
                NSInteger startEpochIndex = dataQueue.count - (kNumRollingAverageEpochs + kConsecutiveTriggerEpochs);
                result.startTime = [self getDateAtIndex:startEpochIndex fromQueue:dataQueue];
                
                // Pop off all data in the data queue before the start event, because we are not interested in analyzing them
                [dataQueue popToIndex:startEpochIndex];
                streak = 0;
            }
            
        // If we have triggered a start event, add to the duration and look for an end event.
        } else {
            // Add one to the streak or reset.
            streak = ! isAboveTrigger ? streak + 1 : 0;
            
            // Add the period at the beginning of the data queue to the duration if both activity ids match.
            Epoch *analysisEpoch = (Epoch *)[dataQueue objectAtIndex:0];
            if (analysisEpoch.activityId == kActivityId && discardEpoch.activityId == kActivityId) {
                result.duration += [analysisEpoch intervalSinceEpoch:discardEpoch];
            }
            
            // If an end event has been triggered
            if (streak >= kNumEndEpochs) {
                // Record the end time
                NSInteger endEpochIndex = dataQueue.count - kNumEndEpochs;
                result.endTime = [self getDateAtIndex:endEpochIndex fromQueue:dataQueue];
                // Return the result, because we have already added all of the relevant durations.
                return result;
            }
        }
    }
    
    // If we didn't find an end event, return nil.
    return nil;
}

# pragma mark Helper functions

// One epoch is added to the rolling average and one is taken away.  This function
// returns the resulting change in the number of epochs in the rolling average that
// match the required activity id.
- (NSInteger)countChange:(Epoch *)newEpoch withOldEpoch:(Epoch *)oldEpoch {
    int change = 0;
    if (newEpoch && newEpoch.activityId == kActivityId) {
        change++;
    }
    if (oldEpoch && oldEpoch.activityId == kActivityId) {
        change--;
    }
    return change;
}

// Returns the date from the epoch at the index, or from the epoch at index 0 if the
// requested index is negative.
- (NSDate *)getDateAtIndex:(NSInteger)index fromQueue:(CapacityQueue *)dataQueue {
    Epoch *epoch;
    if (index >= 0) {
        epoch = (Epoch *)[dataQueue objectAtIndex:index];
    } else {
        epoch = (Epoch *)[dataQueue objectAtIndex:0];
    }
    return epoch.date;
}
@end










