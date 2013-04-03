//
//  FSM.h
//  A Simple Finite State Machine
//
//  Created by Orion on 29/03/13.
//  Copyright (c) 2013 Monte-Carlo Computing. All rights reserved.
//

/*
 
  Usage:
 
  FSM *machine = [[FSM alloc]init];
 
  [machine on:@"Power" transitionFromState:@"PoweredDown" toState:@"PoweredUp" usingBlock:^(id userInfo, FSMStateBlock done){
    doStuff1();

    done();
  }];
 
  // Allow the machine to handle "InsertCoin" event when powered up
  [machine on:@"InsertCoin" transitionFromState:@"PoweredUp" toState:@"PoweredUp" usingBlock:nil];
 
  [machine enterState:@"PoweredDown" usingBlock:^{
    doStuff2();
  }];
 
  // Start the machine in state "PoweredDown"
  [machine setState:@"PoweredDown" options:kFSMStateEnter];
 
  
 
  // Let's power the machine
  [machine event:@"Power"];
 
 */

#import <Foundation/Foundation.h>

typedef void(^FSMStateBlock)(void);
typedef void(^FSMTransitionBlock)(id userInfo, FSMStateBlock done);

typedef enum {
  kFSMStateInitial = 0,
  kFSMStateEnter = 1 << 0,
  kFSMStateCycle = 1 << 1
} FSMStateOptions;

@interface FSM : NSObject
@property (retain, nonatomic) NSString *name;

- (void)on:(NSString *)event transitionFromState:(NSString *)from toState:(NSString *)to usingBlock:(FSMTransitionBlock)block;
- (void)enterState:(NSString *)name usingBlock:(FSMStateBlock)block;
- (void)leaveState:(NSString *)name usingBlock:(FSMStateBlock)block;
- (void)cycleState:(NSString *)name usingBlock:(FSMStateBlock)block;

- (BOOL)setState:(NSString *)name options:(FSMStateOptions)options;
- (BOOL)event:(NSString *)event userInfo:(id)userInfo exclusive:(BOOL)exclusive;
- (BOOL)event:(NSString *)event userInfo:(id)userInfo;
- (BOOL)event:(NSString *)event;

@end
