//
//  GridViewDelegate.h
//  Pentago
//
//  Created by Ryan Shaul on 2/9/12.
//  Copyright (c) 2012 Ryan Shaul. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Position.h"
#import "Direction.h"

@class GridView;

@protocol GridViewDelegate <NSObject>
-(void)gridView:(GridView*)grid didTouchPosition:(Position)position;
-(void)gridView:(GridView*)grid didSwipe:(Direction)direction;
-(void)gridViewRotateDidStop:(GridView*)grid;
@end
