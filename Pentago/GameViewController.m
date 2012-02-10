//
//  GameViewController.m
//  Pentago
//
//  Ryan Shaul on 2/8/12.
//  Copyright (c) 2012 Ryan Shaul. All rights reserved.
//

#import "GameViewController.h"

#define GRID0_POS CGPointMake(71, 71)
#define GRID1_POS CGPointMake(397, 71)
#define GRID2_POS CGPointMake(71, 397)
#define GRID3_POS CGPointMake(397, 397)

@implementation GameViewController
@synthesize board = _board;
@synthesize grid0 = _grid0;
@synthesize grid1 = _grid1;
@synthesize grid2 = _grid2;
@synthesize grid3 = _grid3;
@synthesize grids = _grids;
@synthesize turn = _turn;

-(void)dealloc {
	self.board = nil;
	self.grid0 = nil;
	self.grid1 = nil;
	self.grid2 = nil;
	self.grid3 = nil;
	self.grids = nil;
	[super dealloc];
}

-(void)resetGame {
	self.turn = Player1;
	for (GridView *grid in self.grids) {
		[grid clearGrid];
	}
	[self.board clearBoard];
}

-(void)viewDidLoad {
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor darkGrayColor];
	self.board = [[[Board alloc] init] autorelease];
	self.grid0 = [GridView gridWithPosition:GRID0_POS];
	self.grid1 = [GridView gridWithPosition:GRID1_POS];
	self.grid2 = [GridView gridWithPosition:GRID2_POS];
	self.grid3 = [GridView gridWithPosition:GRID3_POS];
	self.grids = [NSArray arrayWithObjects:self.grid0, self.grid1, self.grid2, self.grid3, nil];
	for (GridView *grid in self.grids) {
		grid.delegate = self;
		[self.view addSubview:grid];
	}
	[self resetGame];
}

-(void)gameOver:(NSString *)message {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	[self resetGame];
}

-(void)gridView:(GridView *)gridView didTouchPosition:(Position)viewPosition {
	Position boardPosition = viewPosition;
	if (gridView == self.grid1 || gridView == self.grid3) boardPosition.column += 3;
	if (gridView == self.grid2 || gridView == self.grid3) boardPosition.row += 3;
	
	if ([self.board playerAt:boardPosition] == PlayerNone) {
		[gridView setPlayer:self.turn at:viewPosition];
		[self.board setPlayer:self.turn at:boardPosition];
		Winner winner = [self.board winnerAt:boardPosition];
		switch (winner) {
			case WinnerPlayer1:
				[self gameOver:@"Player 1 Wins!"];
				break;
			case WinnerPlayer2:
				[self gameOver:@"Player 2 Wins!"];
				break;
			case WinnerDraw:
				[self gameOver:@"Draw"];
				break;
			case WinnerTie:
				[self gameOver:@"Tie"];
				break;
			case WinnerNone:
				self.turn = (self.turn == Player1) ? Player2 : Player1;
				break;
		}

	}
}

@end
