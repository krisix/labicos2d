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

static int const kTileWidth = 40;
static int const kTileHeight = 40;

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
	// read level definition from plist file
	NSString *plistPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"level-%03d", lvlNumber] ofType:@"plist"];
	NSDictionary *lvlConfig = [NSDictionary dictionaryWithContentsOfFile:plistPath];

	NSArray *lvlDescription = (NSArray *)[lvlConfig objectForKey:@"LvlDescription"];
	int rowIdx = 1;
	for (NSString *item in lvlDescription) {
		int colIdx = 1;
		NSArray *cols = [item componentsSeparatedByString:@"\t"];
		
		for (NSString *col in cols) {
			if ([col isEqualToString:@"1"]) {
				float posX = (kTileWidth * colIdx) - kTileWidth * 0.5;
				float posY = (kTileHeight * rowIdx) - kTileHeight * 0.5;
				
				CCSprite *tile = [CCSprite spriteWithFile:@"box-002.png"];
				tile.position = CGPointMake(posX, posY);
				
				[layer addChild:tile];
				
				b2BodyDef boxBodyDef;
				boxBodyDef.position.Set(posX / PTM_RATIO, posY / PTM_RATIO);
				boxBodyDef.userData = tile;
				b2Body *boxBody = _World->CreateBody(&boxBodyDef);
				
				b2PolygonShape polygonShape;
				polygonShape.SetAsBox(tile.contentSize.width * 0.5 / PTM_RATIO, tile.contentSize.height * 0.5 / PTM_RATIO);
				
				b2FixtureDef polygonShapeDef;
				polygonShapeDef.shape = &polygonShape;
				polygonShapeDef.density = 1800;
				polygonShapeDef.restitution = 0.2f;
				
				boxBody->CreateFixture(&polygonShapeDef);
			}
			
			colIdx++;
		}
		
		rowIdx++;
	}

}

@end
