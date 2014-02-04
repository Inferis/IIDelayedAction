//
//  IIDelayedActionSpec.m
//  DelayedActionDemo
//
//  Created by Tom Adriaenssen on 03/02/14.
//  Copyright (c) 2014 Tom Adriaenssen. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "IIDelayedAction.h"

SPEC_BEGIN(IIDelayedActionSpec)

describe(@"Using the IIDelayedAction", ^{

    context(@"when initializing without an action", ^{
        __block IIDelayedAction* _action;

        beforeAll(^{
            _action = [IIDelayedAction delayedActionWithDelay:1];
        });

        it(@"should perform the callback", ^{
            __block NSNumber* done = nil;
            [_action action:^{
                done = @YES;
            }];

            [[done shouldEventually] beYes];
        });

        it(@"should respect the specified delay", ^{
            __block NSNumber* done = nil;
            NSDate* since = [NSDate date];
            [_action action:^{
                done = @YES;
                [[theValue([NSDate timeIntervalSinceReferenceDate]) should] equal:[since timeIntervalSinceReferenceDate]+1.0 withDelta:0.1];
            }];

            [[done shouldEventually] beYes];
        });

        it(@"should discard previous actions", ^{
            __block NSNumber* done = nil;
            [_action action:^{
                [NSException raise:NSInternalInconsistencyException format:@"Shouldn't call the first action"];
            }];
            [_action action:^{
                done = @YES;
            }];

            [[done shouldEventually] beYes];
        });

        it(@"should callback on a background thread by default", ^{
            __block NSNumber* done = nil;
            [_action action:^{
                [[theValue([NSThread isMainThread]) should] beNo];
                done = @YES;
            }];

            [[done shouldEventually] beYes];
        });

        it(@"should callback on the main thread if asked", ^{
            __block NSNumber* done = nil;
            _action.onMainThread = YES;
            [_action action:^{
                [[theValue([NSThread isMainThread]) should] beYes];
                done = @YES;
            }];

            [[done shouldEventually] beYes];
        });
    });

    context(@"when initializing with an action", ^{
        __block NSNumber* done = nil;
        __block IIDelayedAction* _action;
        __block void(^block)(void) = nil;

        beforeAll(^{
            _action = [IIDelayedAction delayedAction:^{
                if (block) block();
                done = @YES;
            } withDelay:1];
        });

        it(@"should perform the callback", ^{
            [[done shouldEventually] beYes];
        });

        it(@"should respect the specified delay", ^{
            NSDate* since = [NSDate date];
            block = ^{
                [[theValue([NSDate timeIntervalSinceReferenceDate]) should] equal:[since timeIntervalSinceReferenceDate]+1.0 withDelta:0.1];
            };

            [[done shouldEventually] beYes];
        });
    });

});

SPEC_END


