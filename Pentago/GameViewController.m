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
#define LABEL_FRAME CGRectMake(0, 750, 768, 100)

@implementation GameViewController
@synthesize board = _board;
@synthesize grids = _grids;
@synthesize gridAnimate = _gridAnimate;
@synthesize label = _label;
@synthesize state = _state;
@synthesize turn = _turn;

-(void)dealloc {
	self.board = nil;
	self.grids = nil;
	self.gridAnimate = nil;
	self.label = nil;
	[super dealloc];
}

-(void)resetGame {
	self.turn = Player1;
	self.state = GameStatePlace;
	for (GridView *grid in self.grids) {
		[grid clearGrid];
	}
	[self.board clearBoard];
}

-(void)viewDidLoad {
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor darkGrayColor];
	self.board = [[[Board alloc] init] autorelease];
	GridView *grid0 = [GridView gridWithPosition:GRID0_POS tag:0];
	GridView *grid1 = [GridView gridWithPosition:GRID1_POS tag:1];
	GridView *grid2 = [GridView gridWithPosition:GRID2_POS tag:2];
	GridView *grid3 = [GridView gridWithPosition:GRID3_POS tag:3];
	self.grids = [NSArray arrayWithObjects:grid0, grid1, grid2, grid3, nil];
	for (GridView *grid in self.grids) {
		grid.delegate = self;
		[self.view addSubview:grid];
	}
	self.label = [[[UILabel alloc] initWithFrame:LABEL_FRAME] autorelease];
	self.label.backgroundColor = [UIColor clearColor];
	self.label.textAlignment = UITextAlignmentCenter;
	self.label.font = [UIFont systemFontOfSize:40];
	self.label.textColor = [UIColor lightGrayColor];
	[self.view addSubview:self.label];
	[self resetGame];
}

-(void)setState:(GameState)state {
	_state = state;
	NSString *player = (self.turn == Player1) ? @"Red" : @"Blue";
	if (state == GameStatePlace) {
		self.label.text = [player stringByAppendingString:@" : place a piece"];
	} else {
		self.label.text = [player stringByAppendingString:@" : rotate a board"];
	}
}

-(void)gameOver:(NSString *)message {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

-(void)handleWinner:(Winner)winner {
	switch (winner) {
		case WinnerPlayer1:
			[self gameOver:@"Red Wins!"];
			break;
		case WinnerPlayer2:
			[self gameOver:@"Blue Wins!"];
			break;
		case WinnerDraw:
			[self gameOver:@"Draw"];
			break;
		case WinnerTie:
			[self gameOver:@"Tie"];
			break;
		case WinnerNone:
			break;
	}
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	[self resetGame];
}

-(Position)boardPosition:(Position)viewPosition grid:(GridView*)grid {
	Position boardPosition = viewPosition;
	if (grid.tag == 1 || grid.tag == 3) boardPosition.column += grid.Length;
	if (grid.tag == 2 || grid.tag == 3) boardPosition.row += grid.Length;
	return boardPosition;
}

-(void)gridView:(GridView *)grid didTouchPosition:(Position)gridPosition {
	if (self.state != GameStatePlace) return;
	
	Position boardPosition = [self boardPosition:gridPosition grid:grid];
	
	if (self.state == GameStatePlace && [self.board playerAt:boardPosition] == PlayerNone) {
		[grid setPlayer:self.turn at:gridPosition];
		[self.board setPlayer:self.turn at:boardPosition];
		self.state = GameStateRotate;
		[self handleWinner:[self.board winnerAt:boardPosition]];
	}
}

-(void)setGridPiecesFromBoard:(GridView *)grid {
	for (int row = 0; row < grid.Length; row++) {
		for (int col = 0; col < grid.Length; col++) {
			Position viewPosition = PositionMake(row, col);
			Position boardPosition = [self boardPosition:viewPosition grid:grid];
			Player player = [self.board playerAt:boardPosition];
			[grid setPlayer:player at:viewPosition];
		}
	}
}

-(void)gridView:(GridView *)grid didSwipe:(Direction)direction {
	if (self.state != GameStateRotate) return;
	
	grid.hidden = YES;
	
	self.gridAnimate = [GridView gridWithPosition:grid.frame.origin tag:grid.tag];
	[self setGridPiecesFromBoard:self.gridAnimate];
	
	[self.board rotateGrid:grid.tag direction:direction];
	[self setGridPiecesFromBoard:grid];
	
	[self.view addSubview:self.gridAnimate];
	self.state = GameStateNoInput;
	
	CGFloat angle = (direction == DirectionRight) ? M_PI_2 : -M_PI_2;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop)];
	self.gridAnimate.transform = CGAffineTransformMakeRotation(angle);
	[UIView commitAnimations];
}

-(void)animationDidStop {
	[[self.grids objectAtIndex:self.gridAnimate.tag] setHidden:NO];
	[self.gridAnimate removeFromSuperview];
	self.turn = (self.turn == Player1) ? Player2 : Player1;
	self.state = GameStatePlace;
	[self handleWinner:[self.board winnerAtGrid:self.gridAnimate.tag]];
	self.gridAnimate = nil;
}

@end
