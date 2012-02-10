//
//  GameBoard.m
//  Pentago
//
//  Ryan Shaul on 2/8/12.
//  Copyright (c) 2012 Ryan Shaul. All rights reserved.
//

#import "GridView.h"

#define GRID_SIZE 300
#define CELL_SIZE 94
#define PIECE_SCALE 0.9

@interface GridView ()
@property (nonatomic, assign) UIImageView **pieces;
@property (nonatomic, retain) UISwipeGestureRecognizer *left;
@property (nonatomic, retain) UISwipeGestureRecognizer *right;
@end

@implementation GridView
@synthesize pieces = _pieces;
@synthesize left = _left;
@synthesize right = _right;
@synthesize delegate = _delegate;

-(void)dealloc {
	[self removeGestureRecognizer:self.left];
	[self removeGestureRecognizer:self.right];
	free(self.pieces);
	self.left = nil;
	self.right = nil;
	self.delegate = nil;
	[super dealloc];
}

-(id)initWithPosition:(CGPoint)point tag:(int)tag {
    if ((self = [super initWithFrame:CGRectMake(point.x, point.y, GRID_SIZE, GRID_SIZE)])) {
        UIImage *grid = [UIImage imageNamed:@"grid300"];
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
    }
    return self;
}
+(id)gridWithPosition:(CGPoint)point tag:(int)tag {
	return [[[GridView alloc] initWithPosition:point tag:tag] autorelease];
}

-(int)Length {
	return 3;
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

-(CGRect)frameForPieceAt:(Position)position {
	int x = 3 + ((CELL_SIZE+3) * position.column);
	int y = 3 + ((CELL_SIZE+3) * position.row);
	return CGRectMake(x, y, CELL_SIZE, CELL_SIZE);
}

-(int)indexForPieceAt:(Position)position {
	return (position.row*self.Length + position.column);
}

-(void)setPlayer:(Player)player at:(Position)position {
	int index = [self indexForPieceAt:position];
	[self removePieceAtIndex:index];
	if (player != PlayerNone) {
		UIImageView *piece = [[UIImageView alloc] init];
		piece.frame = [self frameForPieceAt:position];
		NSString *name = (player == Player1) ? @"redMarble" : @"blueMarble";
		piece.image = [UIImage imageNamed:name];
		piece.transform = CGAffineTransformMakeScale(PIECE_SCALE, PIECE_SCALE);
		[self addSubview:piece];
		self.pieces[index] = [piece retain];
		[piece release];
	}
}

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

-(void)didSwipe:(UIGestureRecognizer *)recognizer {
	UISwipeGestureRecognizer *swipe = (UISwipeGestureRecognizer*)recognizer;
	Direction direction = (swipe.direction == UISwipeGestureRecognizerDirectionLeft) ? DirectionLeft : DirectionRight;
	[self.delegate gridView:self didSwipe:direction];
}

@end
