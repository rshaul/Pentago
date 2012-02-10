//
//  GameViewController.m
//  Pentago
//
//  Created by student on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameViewController.h"

#define GRID0_POS CGPointMake(0, 0)
#define GRID1_POS CGPointMake(300, 0)
#define GRID2_POS CGPointMake(0, 300)
#define GRID3_POS CGPointMake(300, 300)

@implementation GameViewController
@synthesize board = _board;
@synthesize grid0 = _grid0;
@synthesize grid1 = _grid1;
@synthesize grid2 = _grid2;
@synthesize grid3 = _grid3;

-(void)dealloc {
	self.board = nil;
	self.grid0 = nil;
	self.grid1 = nil;
	self.grid2 = nil;
	self.grid3 = nil;
	[super dealloc];
}

-(void)viewDidLoad {
    [super viewDidLoad];
	self.board = [[[Board alloc] init] autorelease];
	self.grid0 = [GridView gridWithPosition:GRID0_POS];
	self.grid1 = [GridView gridWithPosition:GRID1_POS];
	self.grid2 = [GridView gridWithPosition:GRID2_POS];
	self.grid3 = [GridView gridWithPosition:GRID3_POS];
	[self.view addSubview:self.grid0];
	[self.view addSubview:self.grid1];
	[self.view addSubview:self.grid2];
	[self.view addSubview:self.grid3];
}

@end
