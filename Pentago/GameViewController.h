//
//  GameViewController.h
//  Pentago
//
//  Ryan Shaul on 2/8/12.
//  Copyright (c) 2012 Ryan Shaul. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Board.h"
#import "GridView.h"

typedef enum {
	GameStateNoInput,
	GameStatePlace,
	GameStateRotate
} GameState;

@interface GameViewController : UIViewController <GridViewDelegate,UIAlertViewDelegate>

@property (nonatomic, retain) Board *board;
@property (nonatomic, retain) NSArray *grids;
@property (nonatomic, retain) GridView *gridAnimate;
@property (nonatomic, retain) UILabel *label;
@property (nonatomic, assign) GameState state;
@property (nonatomic, assign) Player turn;

@end
