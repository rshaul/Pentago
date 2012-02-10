//
//  Board.h
//  Pentago
//
//  Ryan Shaul on 2/9/12.
//  Copyright (c) 2012 Ryan Shaul. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Player.h"
#import "Position.h"
#import "Cell.h"
#import "Direction.h"
#import "Winner.h"

// Enumerates over the cells
@interface Board : NSObject <NSFastEnumeration>

@property (nonatomic, readonly) int Length;
@property (nonatomic, retain) NSArray *cells;

-(Player)playerAt:(Position)position;
-(void)setPlayer:(Player)player at:(Position)position;
-(void)clearBoard;

-(void)rotateGrid:(int)grid direction:(Direction)direction;

-(Winner)winnerAt:(Position)position;
-(Winner)winnerAtGrid:(int)grid;

@end
