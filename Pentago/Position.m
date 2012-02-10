#import "Position.h"

Position PositionMake(int row, int column) {
	Position p;
	p.row = row;
	p.column = column;
	return p;
}