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
@property (nonatomic, retain) NSMutableArray *pieces;
@end

@implementation GridView
@synthesize pieces = _pieces;
@synthesize delegate = _delegate;

-(void)dealloc {
	self.pieces = nil;
	self.delegate = nil;
	[super dealloc];
}

-(id)initWithPosition:(CGPoint)point {
    if ((self = [super initWithFrame:CGRectMake(point.x, point.y, GRID_SIZE, GRID_SIZE)])) {
        UIImage *grid = [UIImage imageNamed:@"grid300"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:grid];
        [self addSubview:imageView];
        [imageView release];
		self.pieces = [NSMutableArray array];
    }
    return self;
}
+(id)gridWithPosition:(CGPoint)point {
	return [[[GridView alloc] initWithPosition:point] autorelease];
}

-(int)Length {
	return 3;
}

-(void)clearGrid {
	for (UIImageView *piece in self.pieces) {
		[piece removeFromSuperview];
	}
	[self.pieces removeAllObjects];
}

-(CGRect)frameForPieceAt:(Position)position {
	int x = 3 + ((CELL_SIZE+3) * position.column);
	int y = 3 + ((CELL_SIZE+3) * position.row);
	return CGRectMake(x, y, CELL_SIZE, CELL_SIZE);
}

-(void)setPlayer:(Player)player at:(Position)position {
	if (player == PlayerNone) assert(0);

	UIImageView *piece = [[UIImageView alloc] init];
	piece.frame = [self frameForPieceAt:position];
	NSString *name = (player == Player1) ? @"redMarble" : @"blueMarble";
	piece.image = [UIImage imageNamed:name];
	piece.transform = CGAffineTransformMakeScale(PIECE_SCALE, PIECE_SCALE);
	[self addSubview:piece];
	[self.pieces addObject:piece];
	[piece release];
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

@end
