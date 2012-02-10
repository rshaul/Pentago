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
@property (nonatomic, assign) UIImageView **pieces;
@property (nonatomic, retain) UISwipeGestureRecognizer *left;
@property (nonatomic, retain) UISwipeGestureRecognizer *right;
@end

@implementation GridView
@synthesize redImage = _redImage;
@synthesize blueImage = _blueImage;
@synthesize pieces = _pieces;
@synthesize left = _left;
@synthesize right = _right;
@synthesize delegate = _delegate;

-(void)dealloc {
	[self removeGestureRecognizer:self.left];
	[self removeGestureRecognizer:self.right];
	[self clearGrid];
	free(self.pieces);
	self.redImage = nil;
	self.blueImage = nil;
	self.left = nil;
	self.right = nil;
	self.delegate = nil;
	[super dealloc];
}

-(int)Length {
	return 3;
}

-(id)initWithPosition:(CGPoint)point tag:(int)tag {
    if ((self = [super initWithFrame:CGRectMake(point.x, point.y, GRID_SIZE, GRID_SIZE)])) {
        UIImage *grid = [UIImage imageNamed:@"grid"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:grid];
        [self addSubview:imageView];
        [imageView release];
		
		self.pieces = malloc(self.Length*self.Length*sizeof(UIImageView*));
		for (int i=0; i < self.Length*self.Length; i++) self.pieces[i] = nil;
		
		self.tag = tag;
		
		self.left = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)] autorelease];
		self.left.direction = UISwipeGestureRecognizerDirectionLeft;
		self.right = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)] autorelease];
		self.right.direction = UISwipeGestureRecognizerDirectionRight;
		[self addGestureRecognizer:self.left];
		[self addGestureRecognizer:self.right];
		
		self.redImage = [UIImage imageNamed:@"red"];
		self.blueImage = [UIImage imageNamed:@"blue"];
    }
    return self;
}
+(id)gridWithPosition:(CGPoint)point tag:(int)tag {
	return [[[GridView alloc] initWithPosition:point tag:tag] autorelease];
}


-(CGRect)frameForPieceAt:(Position)position {
	int x = 3 + ((CELL_SIZE+3) * position.column);
	int y = 3 + ((CELL_SIZE+3) * position.row);
	return CGRectMake(x, y, CELL_SIZE, CELL_SIZE);
}

-(int)indexForPieceAt:(Position)position {
	return (position.row*self.Length + position.column);
}

-(void)removePieceAtIndex:(int)index {
	[self.pieces[index] removeFromSuperview];
	[self.pieces[index] release];
	self.pieces[index] = nil;	
}

-(void)clearGrid {
	for (int i=0; i < self.Length*self.Length; i++) {
		[self removePieceAtIndex:i];
	}
}

-(void)setPlayer:(Player)player at:(Position)position {
	int index = [self indexForPieceAt:position];
	[self removePieceAtIndex:index];
	if (player != PlayerNone) {
		UIImageView *piece = [[UIImageView alloc] init];
		piece.frame = [self frameForPieceAt:position];
		piece.image = (player == Player1) ? self.redImage : self.blueImage;
		[self addSubview:piece];
		self.pieces[index] = [piece retain];
		[piece release];
	}
}

-(Player)playerAt:(Position)position {
	int index = [self indexForPieceAt:position];
	UIImageView *view = self.pieces[index];
	if (view == nil) return PlayerNone;
	return (view.image == self.redImage) ? Player1 : Player2;
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
			Position p = PositionMake(row, col);
			CGRect piece = [self frameForPieceAt:p];
			if (CGRectContainsPoint(piece, touchLocation)) {
				[self.delegate gridView:self didTouchPosition:p];
			}
		}
	}
}

// Swipe

-(void)didSwipe:(UIGestureRecognizer *)recognizer {
	UISwipeGestureRecognizer *swipe = (UISwipeGestureRecognizer*)recognizer;
	Direction direction = (swipe.direction == UISwipeGestureRecognizerDirectionLeft) ? DirectionLeft : DirectionRight;
	[self.delegate gridView:self didSwipe:direction];
}

// Rotate

-(void)rotatePieces:(Direction)direction {
	GridView *copy = [GridView copyGrid:self];
	for (int row = 0; row < self.Length; row++) {
		for (int col = 0; col < self.Length; col++) {
			int rotateRow = col;
			int rotateCol = row;
			if (direction == DirectionLeft) {
				rotateRow = (self.Length-1) - rotateRow;
			} else if (direction == DirectionRight) {
				rotateCol = (self.Length-1) - rotateCol;
			}
			Player player = [copy playerAt:PositionMake(row, col)];
			[self setPlayer:player at:PositionMake(rotateRow, rotateCol)];
		}
	}
	[copy release];
}

-(void)rotate:(Direction)direction {
	CGFloat angle = (direction == DirectionRight) ? M_PI_2 : -M_PI_2;
	
	[self rotatePieces:direction];
	self.transform = CGAffineTransformMakeRotation(-angle);
	
	[UIView beginAnimations:@"board" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop)];
	self.transform = CGAffineTransformIdentity;
	[UIView commitAnimations];
}
-(void)animationDidStop {
	[self.delegate gridViewRotateDidStop:self];
}

@end
