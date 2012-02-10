//
//  GridViewDelegate.h
//  Pentago
//
//  Created by Ryan Shaul on 2/9/12.
//  Copyright (c) 2012 Ryan Shaul. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Position.h"

@class GridView;

@protocol GridViewDelegate <NSObject>
-(void)gridView:(GridView*)gridView didTouchPosition:(Position)position;
@end
