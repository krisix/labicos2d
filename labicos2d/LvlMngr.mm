//
//  LvlMngr.m
//  labicos2d
//
//  Created by Krzysztof Wolski on 11-04-25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LvlMngr.h"

#define PTM_RATIO 32

@implementation LvlMngr

@synthesize CurrentLevel;

static int const kTileWidth = 20;
static int const kTileHeight = 20;

#pragma mark -
#pragma mark init

- (id)init {
	if ( (self = [super init]) ) {
		
	}
	
	return self;
}

#pragma mark -
#pragma mark singleton

static LvlMngr *_Instance = NULL;

+ (LvlMngr *)instance
{
	@synchronized(self)
    {
		if (_Instance == NULL)
			_Instance = [[self alloc] init];
    }
	return(_Instance);
}

#pragma mark -
#pragma mark methods

- (void) loadLevel:(NSInteger)lvlNumber intoLayer:(CCLayer *)layer withBox2DBody:(b2World*)_World 
  withTileFromFile:(NSString *)tileFilename {
	
	// get dimension from tile
	CCSprite *tmpSprite = [CCSprite spriteWithFile:@"box-003.png"];
//	float tileWidth = tmpSprite.contentSize.width;
//	float tileHeight = tmpSprite.contentSize.height;
	float tileWidth = [tmpSprite texture].contentSize.width;
	float tileHeight = [tmpSprite texture].contentSize.height;
	float halfWidth = tileWidth * 0.5f;
	float halfHeight = tileHeight * 0.5f;
	
	// read level definition from plist file
	NSString *plistPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"level-%03d", lvlNumber] ofType:@"plist"];
	NSDictionary *lvlConfig = [NSDictionary dictionaryWithContentsOfFile:plistPath];

	NSArray *lvlDescription = (NSArray *)[lvlConfig objectForKey:@"LvlDescription"];
	int rowIdx = 1;
	for (NSString *item in lvlDescription) {
		int colIdx = 1;
		NSArray *cols = [item componentsSeparatedByString:@"\t"];
		
		for (NSString *col in cols) {
			float posX = (tileWidth * colIdx) - tileWidth;
			float posY = (tileHeight * rowIdx) - tileHeight;
			
			CCLOG(@"tile: posX=%f posY=%f", posX, posY);
			
			if ([col isEqualToString:@"1"]) {
				CCSprite *tile = [CCSprite spriteWithFile:@"box-003.png"];
				tile.position = CGPointMake(posX, posY);
				
				[layer addChild:tile];
				
				b2BodyDef boxBodyDef;
				boxBodyDef.position.Set(posX / PTM_RATIO, posY / PTM_RATIO);
				boxBodyDef.userData = tile;
				b2Body *boxBody = _World->CreateBody(&boxBodyDef);
				
				b2PolygonShape polygonShape;
				polygonShape.SetAsBox(halfWidth / PTM_RATIO, halfHeight / PTM_RATIO);
				
				b2FixtureDef polygonShapeDef;
				polygonShapeDef.shape = &polygonShape;
				polygonShapeDef.density = 1800;
				polygonShapeDef.restitution = 0.2f;
				
				boxBody->CreateFixture(&polygonShapeDef);
			}
			else if ([col isEqualToString:@"0"]) {
				CCSprite *tile = [CCSprite spriteWithFile:@"ground-001.png"];
				tile.position = CGPointMake(posX, posY);
				
				[layer addChild:tile];
			}
			else if ([col isEqualToString:@"7"]) {
				CCSprite *tileGround = [CCSprite spriteWithFile:@"ground-001.png"];
				tileGround.position = CGPointMake(posX, posY);
				
				[layer addChild:tileGround z:0];
				
				
				CCSprite *tileHole = [CCSprite spriteWithFile:@"hole-001.png"];
				tileHole.position = CGPointMake(posX, posY);
				
				[layer addChild:tileHole z:1];
			}
			
			colIdx++;
		}
		
		rowIdx++;
	}

}

@end
