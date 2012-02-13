//
//  GameBoard.h
//  Pentago
//
//  Ryan Shaul on 2/8/12.
//  Copyright (c) 2012 Ryan Shaul. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Player.h"
#import "Position.h"
#import "GridViewDelegate.h"
#import "Direction.h"

// A 3x3 grid shown in the UI
@interface GridView : UIView

-(id)initWithPosition:(CGPoint)point tag:(int)tag;
+(id)gridWithPosition:(CGPoint)point tag:(int)tag;

-(void)clearGrid;
-(Player)playerAt:(Position)position;
-(void)setPlayer:(Player)player at:(Position)position;
@property (nonatomic, retain) id<GridViewDelegate> delegate;
@property (nonatomic, readonly) int Length;

// Animates
-(void)startRotate:(Direction)direction;

@end
