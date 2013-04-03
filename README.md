## Description
A very lightweight Finite State Machine in ObjC using blocks

## Usage

Instanciate an new machine and add state transitions using blocks... basta cosi!

Note that a state is implicitly defined when a transition is added for a particular state.
All transition block need to call the done() callback from within the block to finish the transition (see example below). There is no watchdog for missing done() callbacks!


## API

Define a transition:

```objc
- (void)on:(NSString *)event transitionFromState:(NSString *)from toState:(NSString *)to usingBlock:(FSMTransitionBlock)block;
```

Set a particular starting state:

```objc
- (BOOL)setState:(NSString *)name options:(FSMStateOptions)options;
```

Send an event:

```objc
- (BOOL)event:(NSString *)event;
```

Send an event with userInfo:

```objc
- (BOOL)event:(NSString *)event userInfo:(id)userInfo;
```

Define a block to be run on entering a state:

```objc
- (void)enterState:(NSString *)name usingBlock:(FSMStateBlock)block;
```

Define a block to be run on leaving a state:

```objc
- (void)leaveState:(NSString *)name usingBlock:(FSMStateBlock)block;
```

Define a block to be run on cycling a state:

```objc
- (void)cycleState:(NSString *)name usingBlock:(FSMStateBlock)block;
```


## Example

```objc
FSM *machine = [[FSM alloc]init];

[machine on:@"Power" transitionFromState:@"PoweredDown" toState:@"PoweredUp" usingBlock:^(id userInfo, FSMStateBlock done){
  powerup();
  done(); // !
}];

// Allow the machine to handle "Coin" event when powered up
[machine on:@"Coin" transitionFromState:@"PoweredUp" toState:@"PoweredUp" usingBlock:nil];

[machine enterState:@"PoweredDown" usingBlock:^{
  shutdown();
}];

// Start the machine in state "PoweredDown"
[machine setState:@"PoweredDown" options:kFSMStateEnter];

// Now, let's power up the machine
[machine event:@"Power"];
```

## License terms

Copyright (c), 2013 Thierry Passeron

The MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.