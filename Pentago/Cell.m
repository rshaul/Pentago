//
//  Cell.m
//  Pentago
//
//  Created by Ryan Shaul on 2/9/12.
//  Copyright (c) 2012 Ryan Shaul. All rights reserved.
//

#import "Cell.h"

@implementation Cell
@synthesize player = _player;
@synthesize position = _position;

-(id)initWithRow:(int)row column:(int)column player:(Player)player {
	if ((self = [super init])) {
		Position p;
		p.row = row;
		p.column = column;
		self.position = PositionMake(row, column);
		self.player = player;
	}
	return self;
}

+(id)cellWithRow:(int)row column:(int)column player:(Player)player {
	return [[[Cell alloc] initWithRow:row column:column player:player] autorelease];
}

@end
