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

@interface GameViewController : UIViewController <GridViewDelegate,UIAlertViewDelegate>

@property (nonatomic, retain) Board *board;
@property (nonatomic, retain) GridView *grid0;
@property (nonatomic, retain) GridView *grid1;
@property (nonatomic, retain) GridView *grid2;
@property (nonatomic, retain) GridView *grid3;
@property (nonatomic, retain) NSArray *grids;
@property (nonatomic, assign) Player turn;

@end
