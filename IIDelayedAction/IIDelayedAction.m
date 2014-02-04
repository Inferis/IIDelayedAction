//
//  IIDelayedAction.m
//
//  Created by Tom Adriaenssen on 01/02/14.
//  Copyright (c) 2014 Tom Adriaenssen. All rights reserved.
//

#import "IIDelayedAction.h"

@interface IIDelayedAction () {
    NSOperationQueue* _queue;
}

@property (nonatomic, assign) NSTimeInterval delay;

- (id)initWithAction:(void(^)(void))action delayed:(NSTimeInterval)delay;

@end

@implementation IIDelayedAction

@synthesize delay = _delay;

#pragma mark - Actions

- (void)action:(void (^)(void))action {
    [_queue cancelAllOperations];
    if (action) {
        __block NSOperation* op = [NSBlockOperation blockOperationWithBlock:^{
            [NSThread sleepForTimeInterval:_delay];
            if (op.isCancelled) 
                return;
            if (self.onMainThread && ![NSThread isMainThread]) {
                dispatch_async(dispatch_get_main_queue(), action);
            }
            else {
                action();
            }
        }];
        [_queue addOperation:op];
    }
}

- (BOOL)hasAction {
    return _queue.operationCount > 0;
}

#pragma mark - Initialisation

- (id)initWithAction:(void(^)(void))action delayed:(NSTimeInterval)delay 
{
    if ((self = [self init])) {
        _delay = delay;
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 1;
        [self action:action];
    }
    return self;
}

- (void)dealloc {
    [_queue cancelAllOperations];
    _queue = nil;
}

+ (IIDelayedAction*)delayedActionWithDelay:(NSTimeInterval)delay
{
    return [self delayedAction:nil withDelay:delay];
}

+ (IIDelayedAction*)delayedAction:(void(^)(void))action withDelay:(NSTimeInterval)delay
{
    return [[IIDelayedAction alloc] initWithAction:action delayed:delay];
}

@end
