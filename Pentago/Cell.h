//
//  Cell.h
//  Pentago
//
//  Created by Ryan Shaul on 2/9/12.
//  Copyright (c) 2012 Allied Information Networks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Player.h"
#import "Position.h"

@interface Cell : NSObject

@property (nonatomic, assign) Player player;
@property (nonatomic, assign) Position position;

-(id)initWithRow:(int)row column:(int)column player:(Player)player;
+(id)cellWithRow:(int)row column:(int)column player:(Player)player;

@end
