//
//  FSM.m
//  A Simple Finite State Machine
//
//  Created by Orion on 29/03/13.
//  Copyright (c) 2013 Monte-Carlo Computing. All rights reserved.
//

#import "FSM.h"

//#define DEBUG_FSM

@interface FSM ()
@property (retain, nonatomic) NSString *state;
@property (retain, nonatomic) NSMutableDictionary *transitions;
@property (retain, nonatomic) NSMutableDictionary *enters;
@property (retain, nonatomic) NSMutableDictionary *leaves;
@property (retain, nonatomic) NSMutableDictionary *cycles;
@end


#define kFSMStateTransitionning @"__kFSMStateTransitionning__"

@implementation FSM

- (void)dealloc {
  [_state release];
  [_transitions release];
  [_enters release];
  [_leaves release];
  [_cycles release];
  [_name release];
  [super dealloc];
}

- (id)init {
  self = [super init];
  if (!self) return nil;
  
  self.transitions = [NSMutableDictionary dictionary];
  self.enters = [NSMutableDictionary dictionary];
  self.leaves = [NSMutableDictionary dictionary];
  self.cycles = [NSMutableDictionary dictionary];
  
  return self;
}

- (void)enforceState:(NSString *)state {
  if (!_transitions[state]) _transitions[state] = [NSMutableDictionary dictionary];
}

- (void)on:(NSString *)event transitionFromState:(NSString *)from toState:(NSString *)to usingBlock:(FSMTransitionBlock)block {
  [self enforceState:from];
  
  NSAssert(from, @"from state is required!");
  NSAssert(to, @"to state is required!");

  _transitions[from][event] = @[to, block ? [[block copy]autorelease] : [NSNull null]];
}

- (void)enterState:(NSString *)name usingBlock:(void (^)(void))block {
  _enters[name] = [[block copy]autorelease];
}

- (void)leaveState:(NSString *)name usingBlock:(void (^)(void))block {
  _leaves[name] = [[block copy]autorelease];
}

- (void)cycleState:(NSString *)name usingBlock:(FSMStateBlock)block {
  _cycles[name] = [[block copy]autorelease];
}

- (BOOL)setState:(NSString *)name options:(FSMStateOptions)options {
  
  // We allow to be get in a state where there are defined transitions else it would be weird no ?
  if (!_transitions[name]) { return NO; }
  
  if ((options & kFSMStateEnter) && _enters[name]) ((FSMStateBlock)_enters[name])();
  if ((options & kFSMStateCycle) && _cycles[name]) ((FSMStateBlock)_cycles[name])();
  
  self.state = name;
  return YES;
}


- (BOOL)event:(NSString *)order {
  return [self event:order userInfo:nil exclusive:YES];
}

- (BOOL)event:(NSString *)event userInfo:(id)userInfo {
  return [self event:event userInfo:userInfo exclusive:YES];
}

- (BOOL)event:(NSString *)event userInfo:(id)userInfo exclusive:(BOOL)exclusive {
  NSAssert(_state, @"No initial state!");
  if (exclusive && [_state isEqualToString:kFSMStateTransitionning]) {
#ifdef DEBUG_FSM
    NSLog(@"Discarded event %@ due to ongoing exclusive transition", event);
#endif
    return FALSE;
  }
  
  // Check the transition exists
  if (!_transitions[_state][event]) {
    NSLog(@"Invalid transition on %@ from state %@", event, _state);
    return FALSE;
  }
  
  // We are allowed to transition
  NSString *oldState = [_state retain];
  NSString *targetState = _transitions[oldState][event][0];
  
  if (exclusive) self.state = kFSMStateTransitionning;

  // Do we need a leave ?
  if (![targetState isEqualToString:oldState] && _leaves[oldState]) {
#ifdef DEBUG_FSM
    NSLog(@"Leave block for state %@", oldState);
#endif
    dispatch_async(dispatch_get_main_queue(), (FSMStateBlock)_leaves[oldState]);
  }

  FSMStateBlock done = ^{
    dispatch_async(dispatch_get_main_queue(), ^{
      // Do we need an enter ?
      if (![targetState isEqualToString:oldState]) {
        if (_enters[targetState]){
#ifdef DEBUG_FSM
        NSLog(@"Enter block for state %@", targetState);
#endif
          ((FSMStateBlock)_enters[targetState])();
        }
      } else if (_cycles[oldState]) {
#ifdef DEBUG_FSM
        NSLog(@"Cycle block for state %@", oldState);
#endif
        ((FSMStateBlock)_cycles[oldState])();
      }
      self.state = targetState;
#ifdef DEBUG_FSM
      NSLog(@"Landed on state %@", targetState);
#endif
    });
  };
  
  if (![_transitions[oldState][event][1] isKindOfClass:[NSNull class]]) ((FSMTransitionBlock)_transitions[oldState][event][1])(userInfo, done);
  else done();
  
#ifdef DEBUG_FSM
  NSLog(@"Transitionning from state %@ to state %@ with event %@ (Exclusive: %@)", oldState, targetState, event, exclusive ? @"Yes": @"No");
#endif
    
  [oldState release];
  return TRUE;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"%@:\nTransitions:%@\nLeaves:%@\nEnters:%@\nCycles:%@", [super description], _transitions, _enters, _leaves, _cycles];
}

@end
