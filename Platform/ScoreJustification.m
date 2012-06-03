//
//  ScoreJustification.m
//  Platform
//
//  Created by Jasjeet Gill on 6/1/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "ScoreJustification.h"


@implementation ScoreJustification
@synthesize points = m_points;
@synthesize justification = m_justification;

- (id) initFromJSONDictionary:(NSDictionary *)jsonDictionary {

    self.points = [jsonDictionary valueForKey:POINTS];
    self.justification = [jsonDictionary valueForKey:JUSTIFICATION];
   
    return self;
}
@end
