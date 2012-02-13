//
//  GameBoard.m
//  Pentago
//
//  Ryan Shaul on 2/8/12.
//  Copyright (c) 2012 Ryan Shaul. All rights reserved.
//

#import "GridView.h"

#define GRID_SIZE 300
#define CELL_SIZE 96

@interface GridView ()
@property (nonatomic, retain) UIImage *redImage;
@property (nonatomic, retain) UIImage *blueImage;
@property (nonatomic, retain) NSMutableArray *pieces;
@end

@implementation GridView
@synthesize redImage = _redImage;
@synthesize blueImage = _blueImage;
@synthesize pieces = _pieces;
@synthesize delegate = _delegate;

-(void)dealloc {
	self.redImage = nil;
	self.blueImage = nil;
	self.pieces = nil;
	self.delegate = nil;
	[super dealloc];
}

-(int)Length {
	return 3;
}

-(CGRect)frameForPieceAt:(Position)position {
	int x = 3 + ((CELL_SIZE+3) * position.column);
	int y = 3 + ((CELL_SIZE+3) * position.row);
	return CGRectMake(x, y, CELL_SIZE, CELL_SIZE);
}

-(id)initWithPosition:(CGPoint)point tag:(int)tag {
    if ((self = [super initWithFrame:CGRectMake(point.x, point.y, GRID_SIZE, GRID_SIZE)])) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grid"]];
        [self addSubview:imageView];
        [imageView release];
		
		self.pieces = [NSMutableArray arrayWithCapacity:self.Length*self.Length];
		for (int row=0; row < self.Length; row++) {
			for (int col=0; col < self.Length; col++) {
				UIImageView *view = [[UIImageView alloc] init];
				view.frame = [self frameForPieceAt:PositionMake(row, col)];
				[self.pieces addObject:view];
				[self addSubview:view];
				[view release];
			}
		}
		
		self.tag = tag;
		
		UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
		left.direction = UISwipeGestureRecognizerDirectionLeft;
		UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
		right.direction = UISwipeGestureRecognizerDirectionRight;
		[self addGestureRecognizer:left];
		[self addGestureRecognizer:right];
		[left release];
		[right release];
		
		self.redImage = [UIImage imageNamed:@"red"];
		self.blueImage = [UIImage imageNamed:@"blue"];
    }
    return self;
}
+(id)gridWithPosition:(CGPoint)point tag:(int)tag {
	return [[[GridView alloc] initWithPosition:point tag:tag] autorelease];
}


-(UIImageView *)pieceAt:(Position)position {
	int index = (position.row*self.Length + position.column);
	return [self.pieces objectAtIndex:index];
}

-(void)removePieceAtIndex:(int)index {
	[[self.pieces objectAtIndex:index] setImage:nil];
}

-(void)clearGrid {
	for (UIImageView *piece in self.pieces) {
		piece.image = nil;
	}
}

-(void)setPlayer:(Player)player at:(Position)position {
	UIImageView *piece = [self pieceAt:position];
	switch (player) {
		case PlayerNone:
			piece.image = nil;
			break;
		case Player1:
			piece.image = self.redImage;
			break;
		case Player2:
			piece.image = self.blueImage;
			break;
	}
}

-(Player)playerAt:(Position)position {
	UIImageView *piece = [self pieceAt:position];
	if (piece.image == nil) return PlayerNone;
	return (piece.image == self.redImage) ? Player1 : Player2;
}

// Copy

+(id)copyGrid:(GridView *)grid {
	GridView *copy = [[GridView alloc] initWithPosition:grid.frame.origin tag:grid.tag];
	copy.delegate = grid.delegate;
	for (int row=0; row < grid.Length; row++) {
		for (int col=0; col < grid.Length; col++) {
			Position position = PositionMake(row, col);
			Player player = [grid playerAt:position];
			[copy setPlayer:player at:position];
		}
	}
	return copy;
}

// Touch

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint touchLocation = [touch locationInView:self];
	for (int row=0; row < self.Length; row++) {
		for (int col=0; col < self.Length; col++) {
			Position position = PositionMake(row, col);
			UIImageView *piece = [self pieceAt:position];
			if (CGRectContainsPoint(piece.frame, touchLocation)) {
				[self.delegate gridView:self didTouchPosition:position];
			}
		}
	}
}

// Swipe

-(void)didSwipe:(UIGestureRecognizer *)recognizer {
	UISwipeGestureRecognizer *swipe = (UISwipeGestureRecognizer*)recognizer;
	Direction direction = (swipe.direction == UISwipeGestureRecognizerDirectionLeft) ? DirectionCounterClockwise : DirectionClockwise;
	[self.delegate gridView:self didSwipe:direction];
}

// Rotate

-(void)rotatePieces:(Direction)direction {
	GridView *copy = [GridView copyGrid:self];
	for (int row = 0; row < self.Length; row++) {
		for (int col = 0; col < self.Length; col++) {
			int dstRow = col;
			int dstCol = row;
			if (direction == DirectionCounterClockwise) {
				dstRow = (self.Length-1) - dstRow;
			} else if (direction == DirectionClockwise) {
				dstCol = (self.Length-1) - dstCol;
			}
			Player player = [copy playerAt:PositionMake(row, col)];
			[self setPlayer:player at:PositionMake(dstRow, dstCol)];
		}
	}
	[copy release];
}

-(void)startRotate:(Direction)direction {
	CGFloat angle = (direction == DirectionClockwise) ? M_PI_2 : -M_PI_2;
	
	[self rotatePieces:direction];
	self.transform = CGAffineTransformMakeRotation(-angle);
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop)];
	self.transform = CGAffineTransformIdentity;
	[UIView commitAnimations];
}
-(void)animationDidStop {
	[self.delegate gridViewRotateDidStop:self];
}

@end
