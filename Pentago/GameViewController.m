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
@synthesize label = _label;
@synthesize state = _state;
@synthesize turn = _turn;

-(void)dealloc {
	self.board = nil;
	self.grids = nil;
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
	self.view.backgroundColor = [UIColor blackColor];
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

// Changing game state updates the label

-(void)updateLabel {
	NSString *player = (self.turn == Player1) ? @"Red" : @"Blue";
	if (self.state == GameStatePlace) {
		self.label.text = [player stringByAppendingString:@" : place a piece"];
	} else {
		self.label.text = [player stringByAppendingString:@" : rotate a board"];
	}	
}
-(void)setState:(GameState)state {
	_state = state;
	[self updateLabel];
}
-(void)setTurn:(Player)turn {
	_turn = turn;
	[self updateLabel];
}

// Handle Win Conditions

-(void)gameOver:(NSString *)message {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message
													message:nil
												   delegate:self
										  cancelButtonTitle:@"Ok"
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
}
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	[self resetGame];
}

-(BOOL)handleWinner:(Winner)winner {
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
			[self gameOver:@"Tie - Everyone is a winner!"];
			break;
		case WinnerNone:
			break;
	}
	return (winner != WinnerNone);
}

// Placing a piece

-(Position)offsetGridPosition:(Position)gridPosition grid:(GridView*)grid {
	Position boardPosition = gridPosition;
	if (grid.tag == 1 || grid.tag == 3) boardPosition.column += grid.Length;
	if (grid.tag == 2 || grid.tag == 3) boardPosition.row += grid.Length;
	return boardPosition;
}

-(void)gridView:(GridView *)grid didTouchPosition:(Position)gridPosition {
	if (self.state != GameStatePlace) return;
	
	Position boardPosition = [self offsetGridPosition:gridPosition grid:grid];
	
	if ([self.board playerAt:boardPosition] == PlayerNone) {
		[grid setPlayer:self.turn at:gridPosition];
		[self.board setPlayer:self.turn at:boardPosition];
		if (![self handleWinner:[self.board winnerAt:boardPosition]]) {
			self.state = GameStateRotate;
		}
	}
}

// Rotating a board

-(void)updateBoardFromGrid:(GridView *)grid {
	for (int row=0; row < grid.Length; row++) {
		for (int col=0; col < grid.Length; col++) {
			Position gridPosition = PositionMake(row, col);
			Position boardPosition = [self offsetGridPosition:gridPosition grid:grid];
			Player player = [grid playerAt:gridPosition];
			[self.board setPlayer:player at:boardPosition];
		}
	}
}

-(void)gridView:(GridView *)grid didSwipe:(Direction)direction {
	if (self.state != GameStateRotate) return;	
	[grid rotate:direction];
	self.state = GameStateNoInput;
}
-(void)gridViewRotateDidStop:(GridView *)grid {
	[self updateBoardFromGrid:grid];
	if (![self handleWinner:[self.board winnerAtGrid:grid.tag]]) {
		self.turn = (self.turn == Player1) ? Player2 : Player1;
		self.state = GameStatePlace;
	}
}

@end
