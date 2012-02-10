//
//  GameBoard.h
//  Pentago
//
//  Created by student on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Player.h"
#import "Position.h"
#import "GridViewDelegate.h"

@interface GridView : UIView

-(id)initWithPosition:(CGPoint)point;
+(id)gridWithPosition:(CGPoint)point;

-(void)clearGrid;
-(void)setPlayer:(Player)player at:(Position)position;
@property (nonatomic, retain) id<GridViewDelegate> delegate;
@property (nonatomic, readonly) int Length;

@end
