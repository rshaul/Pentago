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
#define TOP_ROW CGRectMake(3, 3, 294, 96)
#define BOTTOM_ROW CGRectMake(3, 201, 294, 96)
#define LEFT_COLUMN CGRectMake(3, 3, 96, 294)
#define RIGHT_COLUMN CGRectMake(201, 3, 96, 294)

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

-(void)initPieces {
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
}

-(void)initSwipeRecognizers {
	int count = 4;
	UISwipeGestureRecognizerDirection directions[count];
	directions[0] = UISwipeGestureRecognizerDirectionLeft;
	directions[1] = UISwipeGestureRecognizerDirectionRight;
	directions[2] = UISwipeGestureRecognizerDirectionUp;
	directions[3] = UISwipeGestureRecognizerDirectionDown;
	for (int i=0; i < count; i++) {
		UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
		swipe.direction = directions[i];
		[self addGestureRecognizer:swipe];
		[swipe release];
	}
}

-(id)initWithPosition:(CGPoint)point tag:(int)tag {
    if ((self = [super initWithFrame:CGRectMake(point.x, point.y, GRID_SIZE, GRID_SIZE)])) {
        UIImageView *grid = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grid"]];
        [self addSubview:grid];
        [grid release];
		
		self.tag = tag;
		self.redImage = [UIImage imageNamed:@"red"];
		self.blueImage = [UIImage imageNamed:@"blue"];
		
		[self initPieces];	
		[self initSwipeRecognizers];
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

-(BOOL)isTopRow:(CGPoint)point {
	return CGRectContainsPoint(TOP_ROW, point);
}
-(BOOL)isRightColumn:(CGPoint)point {
	return CGRectContainsPoint(RIGHT_COLUMN, point);
}
-(BOOL)isBottomRow:(CGPoint)point {
	return CGRectContainsPoint(BOTTOM_ROW, point);
}
-(BOOL)isLeftColumn:(CGPoint)point {
	return CGRectContainsPoint(LEFT_COLUMN, point);
}

-(void)didSwipe:(UIGestureRecognizer *)recognizer {
	UISwipeGestureRecognizer *swipe = (UISwipeGestureRecognizer*)recognizer;
	CGPoint point = [swipe locationInView:self];
	UISwipeGestureRecognizerDirection direction = swipe.direction;
	if ((direction == UISwipeGestureRecognizerDirectionLeft && [self isTopRow:point])
		|| (direction == UISwipeGestureRecognizerDirectionRight && [self isBottomRow:point])
		|| (direction == UISwipeGestureRecognizerDirectionUp && [self isRightColumn:point])
		|| (direction == UISwipeGestureRecognizerDirectionDown && [self isLeftColumn:point])) {
		[self.delegate gridView:self didSwipe:DirectionCounterClockwise];
	} else if ((direction == UISwipeGestureRecognizerDirectionRight && [self isTopRow:point])
			   || (direction == UISwipeGestureRecognizerDirectionLeft && [self isBottomRow:point])
			   || (direction == UISwipeGestureRecognizerDirectionDown && [self isRightColumn:point])
			   || (direction == UISwipeGestureRecognizerDirectionUp && [self isLeftColumn:point])) {
		[self.delegate gridView:self didSwipe:DirectionClockwise];
	}
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
