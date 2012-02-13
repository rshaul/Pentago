//
//  Board.m
//  Pentago
//
//  Ryan Shaul on 2/9/12.
//  Copyright (c) 2012 Ryan Shaul. All rights reserved.
//

#import "Board.h"

#define WinCount 5

@interface Board()
@property (nonatomic, assign) Player *cells;
@end

@implementation Board
@synthesize cells = _cells;

-(void)dealloc {
	free(self.cells);
    [super dealloc];
}

-(id)init {
    if ((self = [super init])) {
		self.cells = malloc(self.Length*self.Length*sizeof(Player));
		[self clearBoard];
    }
    return self;
}

-(int)Length {
	return 6;
}

-(void)clearBoard {
	for (int i=0; i < self.Length*self.Length; i++) {
		self.cells[i] = PlayerNone;
	}
}

-(Player*)addressOf:(Position)p {
	return &self.cells[p.row*self.Length + p.column];
}
-(Player)playerAt:(Position)position {
	return *[self addressOf:position];
}
-(void)setPlayer:(Player)player at:(Position)position {
	(*[self addressOf:position]) = player;
}


// Determining the winner

int max(int,int);
int max(int a, int b) {
	return (a > b) ? a : b;
}
int min(int,int);
int min(int a, int b) {
	return (a < b) ? a : b;
}

-(BOOL)hasOpenCells {
	for (int i=0; i < self.Length*self.Length; i++) {
		if (self.cells[i] == PlayerNone) return YES;
	}
	return NO;
}

-(BOOL)winnerAt:(Position)position forPlayer:(Player)player {
	int pColumn = position.column;
	int pRow = position.row;
	int count, row, col;

	// Check Column
	count = 0;
	for (row=0; row < self.Length; row++) {
		if ([self playerAt:PositionMake(row, pColumn)] == player) count++;
		else count = 0;
		if (count == WinCount) return YES;
	}
	
	// Check Row
	count = 0;
	for (col=0; col < self.Length; col++) {
		if ([self playerAt:PositionMake(pRow, col)] == player) count++;
		else count = 0;
		if (count == WinCount) return YES;
	}
	
	// Check Diagonal \ -- Start at the top left
	count = 0;
	col = max(pColumn - pRow, 0);
	row = pRow - (pColumn - col);
	while (row < self.Length && col < self.Length) {
		if ([self playerAt:PositionMake(row, col)] == player) count++;
		else count = 0;
		if (count == WinCount) return YES;
		row++;
		col++;
	}
	
	// Check Diagonal / -- Start at the top right
	count = 0;
	col = min(pColumn + pRow, self.Length-1);
	row = pRow - (col - pColumn);
	while (row < self.Length && col >= 0) {
		if ([self playerAt:PositionMake(row, col)] == player) count++;
		else count = 0;
		if (count == WinCount) return YES;
		row++;
		col--;
	}
	
	return NO;
}

-(Winner)getWinnerP1:(BOOL)p1 p2:(BOOL)p2 {
	if (p1 && p2) return WinnerTie;
	if (p1) return WinnerPlayer1;
	if (p2) return WinnerPlayer2;
	if (![self hasOpenCells]) return WinnerDraw;
	return WinnerNone;	
}

-(Winner)winnerAt:(Position)position {
	BOOL p1 = [self winnerAt:position forPlayer:Player1];
	BOOL p2 = [self winnerAt:position forPlayer:Player2];
	return [self getWinnerP1:p1 p2:p2];
}

// Check for a winner along the edge of a grid
-(Winner)winnerAtGrid:(int)grid {
	int count = 5;
	Position *positions = malloc(count*sizeof(Position));
	// Edge positions for grid 0
	positions[0] = PositionMake(0, 2);
	positions[1] = PositionMake(1, 2);
	positions[2] = PositionMake(2, 2);
	positions[3] = PositionMake(2, 1);
	positions[4] = PositionMake(2, 0);
	if (grid == 1 || grid == 3) { // Flip horizontal
		for (int i=0; i < count; i++) {
			positions[i].column = (self.Length-1) - positions[i].column;
		}
	}
	if (grid == 2 || grid == 3) { // Flip vertical
		for (int i=0; i < count; i++) {
			positions[i].row = (self.Length-1) - positions[i].row;
		}
	}
	// Check for winners along the edge
	BOOL p1 = NO;
	BOOL p2 = NO;
	for (int i=0; i < count; i++) {
		Winner winner = [self winnerAt:positions[i]];
		p1 = p1 || winner == WinnerPlayer1 || winner == WinnerTie;
		p2 = p2 || winner == WinnerPlayer2 || winner == WinnerTie;
	}
	free(positions);
	return [self getWinnerP1:p1 p2:p2];
}

@end
