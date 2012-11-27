#import "GameObject.h"

@class BreakableBox;


// A BrokenBox is a composite object that holds all the sprites, physics,
// etc for all the broken chunks of one BreakableBox.
@interface BrokenBox : GameObject {}

-(id)initFromBox:(BreakableBox *)box;

@end
