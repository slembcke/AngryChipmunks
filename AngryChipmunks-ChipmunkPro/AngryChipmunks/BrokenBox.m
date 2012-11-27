#import "BrokenBox.h"

#import "Physics.h"
#import "BreakableBox.h"

@implementation BrokenBox

static float frand_unit(){ return (rand()/(float)RAND_MAX)*2.0f - 1.0f; }

static void
MakeChunk(BreakableBox *box, cpVect direction, NSMutableArray *chipmunkObjects, NSMutableArray *sprites){
		ChipmunkBody *boxBody = box.body;
		CGRect boxRect = box.sprite.textureRect;
		CGFloat hw = boxRect.size.width/2.0f;
		CGFloat hh = boxRect.size.height/2.0f;
		
		cpFloat mass = boxBody.mass/4.0f;
    ChipmunkBody *body = [ChipmunkBody bodyWithMass:mass andMoment:cpMomentForBox(mass, hw, hh)];
    body.pos = [boxBody local2world:cpv(direction.x*hw/2.0f, direction.y*hh/2.0f)];
		body.angle = boxBody.angle;
		body.vel = cpvadd(boxBody.vel, cpvrotate(cpvmult(direction, 50), boxBody.rot));
		body.angVel = boxBody.angVel + frand_unit()*2.0f;
    
    ChipmunkShape * shape = [ChipmunkPolyShape boxWithBody:body width:hw height:hh];
		shape.elasticity = 0.3f;
		shape.friction = 0.8f;
		shape.layers = PhysicsLayerDebris;
		shape.group = [BrokenBox class]; // debris should not collide with debris
    
		// Note that Cocos2D texture y-coords are flipped
		CGRect rect = CGRectMake(boxRect.origin.x + (direction.x*0.5f + 0.5f)*hw, boxRect.origin.y + (0.5f - direction.y*0.5f)*hh, hw, hh);
		CCPhysicsSprite *sprite = [CCPhysicsSprite spriteWithFile:@"Sprites.png" rect:rect];
		sprite.chipmunkBody = body;
		
		[chipmunkObjects addObject:body];
		[chipmunkObjects addObject:shape];
		[sprites addObject:sprite];
}

-(id)initFromBox:(BreakableBox *)box;
{
	if((self = [super init])){
		NSMutableArray *_chipmunkObjects = [NSMutableArray array];
		NSMutableArray *_sprites = [NSMutableArray array];
		
		MakeChunk(box, cpv(-1.0f, -1.0f), _chipmunkObjects, _sprites);
		MakeChunk(box, cpv( 1.0f, -1.0f), _chipmunkObjects, _sprites);
		MakeChunk(box, cpv(-1.0f,  1.0f), _chipmunkObjects, _sprites);
		MakeChunk(box, cpv( 1.0f,  1.0f), _chipmunkObjects, _sprites);
		
		chipmunkObjects = _chipmunkObjects;
		sprites = _sprites;
		
		[self fadeOut:1.0f];
	}
	
	return self;
}

@end
