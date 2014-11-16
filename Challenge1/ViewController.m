#import "ViewController.h"
#import "Analyzer.h"
#import "Result.h"
#import <math.h>

@interface ViewController ()

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end

static NSInteger const kSecondsInHour = 3600;
static NSInteger const kSecondsInMinute = 60;

@implementation ViewController

// On analyze, attempt to get the file name from the text field, analyze, and
// show the results.
- (IBAction)analyzePressed:(UIButton *)sender {
    Analyzer *analyzer = [Analyzer new];
    
    NSString *fileName = self.filenameTextField.text;
    NSArray *csvArray = [analyzer importFile:fileName];
    Result *result = [analyzer analyzeArray:csvArray];
    
    if (result) {
        [self.startTimeLabel setText:[self startTimeText:result]];
        [self.endTimeLabel setText:[self endTimeText:result]];
        [self.durationLabel setText:[self durationText:result]];
    } else {
        [self.startTimeLabel setText:@"Error, could not analyze that file"];
        [self.endTimeLabel setText:@""];
        [self.durationLabel setText:@""];
    }
}

# pragma mark Display helpers

- (NSString *)startTimeText:(Result *)result {
    NSString *dateString = [self.dateFormatter stringFromDate:result.startTime];
    return [NSString stringWithFormat:@"Start Time: %@", dateString];
}

- (NSString *)endTimeText:(Result *)result {
    NSString *dateString = [self.dateFormatter stringFromDate:result.endTime];
    return [NSString stringWithFormat:@"End Time: %@", dateString];
}

- (NSString *)durationText:(Result *)result {
    NSInteger hours = floor(result.duration/kSecondsInHour);
    NSInteger minutes = floor((result.duration - hours * kSecondsInHour)/kSecondsInMinute);
    return [NSString stringWithFormat:@"Duration: %02ld:%02ld", hours, minutes];
}

// Lazy load the date formatter for performance.  
- (NSDateFormatter *)dateFormatter {
    if (! _dateFormatter) {
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        
        [_dateFormatter setLocale:enUSPOSIXLocale];
        [_dateFormatter setDateFormat:@"HH:mm"];
    }
    return _dateFormatter;
}

@end
