//
//  Board.m
//  Pentago
//
//  Ryan Shaul on 2/9/12.
//  Copyright (c) 2012 Ryan Shaul. All rights reserved.
//

#import "Board.h"

#define WinCount 5

@implementation Board
@synthesize cells = _cells;

-(void)dealloc {
	self.cells = nil;
    [super dealloc];
}

-(id)init {
    if ((self = [super init])) {
		NSMutableArray *cells = [NSMutableArray arrayWithCapacity:self.Length*self.Length];
		for (int row=0; row < self.Length; row++) {
			for (int col=0; col < self.Length; col++) {
				[cells addObject:[Cell cellWithRow:row column:col player:PlayerNone]];
			}
		}
		self.cells = cells;
    }
    return self;
}

-(int)Length {
	return 6;
}

-(Cell*)cellAtRow:(int)row column:(int)column {
	return [self.cells objectAtIndex:(row*self.Length+column)];
}
-(Cell*)cellAt:(Position)position {
	return [self cellAtRow:position.row column:position.column];
}

-(Player)playerAtRow:(int)row column:(int)column {
	return [[self cellAtRow:row column:column] player];
}
-(Player)playerAt:(Position)position {
	return [[self cellAt:position] player];
}
-(void)setPlayer:(Player)player at:(Position)position {
	[[self cellAt:position] setPlayer:player];
}
-(void)clearBoard {
	for (Cell *cell in self.cells) {
		cell.player = PlayerNone;
	}
}


/*
	Determining the winner
*/
int max(int,int);
int max(int a, int b) {
	return (a > b) ? a : b;
}
int min(int,int);
int min(int a, int b) {
	return (a < b) ? a : b;
}

-(BOOL)hasOpenCells {
	for (Cell *cell in self.cells) {
		if (cell.player == PlayerNone) return YES;
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
		if ([self playerAtRow:row column:pColumn] == player) count++;
		else count = 0;
		if (count == WinCount) return YES;
	}
	
	// Check Row
	count = 0;
	for (col=0; col < self.Length; col++) {
		if ([self playerAtRow:pRow column:col] == player) count++;
		else count = 0;
		if (count == WinCount) return YES;
	}
	
	// Check Diagonal \ -- Start at the top left
	count = 0;
	col = max(pColumn - pRow, 0);
	row = pRow - (pColumn - col);
	while (row < self.Length && col < self.Length) {
		if ([self playerAtRow:row column:col] == player) count++;
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
		if ([self playerAtRow:row column:col] == player) count++;
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

// Check for a winner along the edges of a grid
-(Winner)winnerAtGrid:(int)grid {
	int count = 5;
	Position *positions = malloc(count*sizeof(Position));
	// Positions for grid 0
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
	// Check for winners along the edges
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

/*
	NSFastEnumeration Protocol
*/
-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id [])buffer count:(NSUInteger)len {
	return [self.cells countByEnumeratingWithState:state objects:buffer count:len];
}

@end
