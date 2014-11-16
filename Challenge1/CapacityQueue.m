#import "CapacityQueue.h"

@interface CapacityQueue ()

// NSMutableArray uses a circular buffer, so it can be used as a queue without a performance hit.  Here's the most interesting article on the topic that I found http://ciechanowski.me/blog/2014/03/05/exposing-nsmutablearray/.
@property (nonatomic) NSMutableArray *queue;

@end

@implementation CapacityQueue

// Designated initializer.
- (instancetype)initWithCapacity:(NSInteger)capacity {
    self = [super init];
    if (self) {
        _capacity = capacity;
        self.queue = [NSMutableArray arrayWithCapacity:capacity];
    }
    return self;
}

- (void)addObject:(NSObject *)object {
    if (self.queue.count >= self.capacity) {
        [self.queue removeObjectAtIndex:0];
    }
    [self.queue addObject:object];
}

// Returns the object popped from the queue to make room for the added object,
// or nil if capacity has not been reached.
- (NSObject *)addObjectAndGetOverflow:(NSObject *)object {
    if (self.queue.count < self.capacity) {
        [self.queue addObject:object];
        return nil;
    } else {
        NSObject *oldObject = [self.queue objectAtIndex:0];
        [self.queue removeObjectAtIndex:0];
        [self.queue addObject:object];
        return oldObject;
    }
}

- (NSObject *)objectAtIndex:(NSInteger)index {
    return [self.queue objectAtIndex:index];
}

// Pops all objects up to index.  
- (void)popToIndex:(NSInteger)index {
    [self.queue removeObjectsInRange:NSMakeRange(0, index)];
}

- (NSInteger)count {
    return self.queue.count;
}

@end
