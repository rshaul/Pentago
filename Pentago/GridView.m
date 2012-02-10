//
//  GameBoard.m
//  Pentago
//
//  Created by student on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GridView.h"

#define GRID_SIZE 373
#define CELL_SIZE 120

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
        UIImage *grid = [UIImage imageNamed:@"grid"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:grid];
        [self addSubview:imageView];
        [imageView release];
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
	for (UIImageView *view in self.pieces) {
		[view removeFromSuperview];
	}
	[self.pieces removeAllObjects];
}

-(CGRect)frameForPieceAt:(Position)position {
	int x = 3 + ((CELL_SIZE+2) * position.column);
	int y = 3 + ((CELL_SIZE+2) * position.row);
	return CGRectMake(x, y, CELL_SIZE, CELL_SIZE);
}

-(void)setPlayer:(Player)player at:(Position)position {
	if (player == PlayerNone) assert(0);

	UIImageView *piece = [[UIImageView alloc] init];
	piece.frame = [self frameForPieceAt:position];
	NSString *name = (player == Player1) ? @"redMarble" : @"blueMarble";
	piece.image = [UIImage imageNamed:name];
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
