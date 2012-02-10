//
//  GameViewController.h
//  Pentago
//
//  Created by student on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Board.h"
#import "GridView.h"

@interface GameViewController : UIViewController

@property (nonatomic, retain) Board *board;
@property (nonatomic, retain) GridView *grid0;
@property (nonatomic, retain) GridView *grid1;
@property (nonatomic, retain) GridView *grid2;
@property (nonatomic, retain) GridView *grid3;

@end
