// A first in, first out data structure with a capacity.  Objects are added until capacity has been
// reached, at which point, subsequent added objects will cause the first object in the queue to be popped.
// The user can choose whether to have the popped object returned when adding an object.

#import <Foundation/Foundation.h>

@interface CapacityQueue : NSObject

@property (nonatomic, readonly) NSInteger capacity;

- (instancetype)initWithCapacity:(NSInteger)capacity NS_DESIGNATED_INITIALIZER;

// Adds an object, ignoring overflow.
- (void)addObject:(NSObject *)object;
// Adds the object to the queue and, if the queue has reached capacity, returns the overflow object.
- (NSObject *)addObjectAndGetOverflow:(NSObject *)object;
- (NSObject *)objectAtIndex:(NSInteger)index;
// Pops all objects up to index, exclusive.
- (void)popToIndex:(NSInteger)index;

- (NSInteger)count;

@end
