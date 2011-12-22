//
//  IDGenerator.h
//  Klink V2
//
//  Created by Bobby Gill on 8/6/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IDGenerator : NSObject {

    NSMutableArray* m_knownIDs;
}

@property (nonatomic,retain) NSMutableArray* knownIDs;

- (NSNumber*) generateNewId:(NSString*)objectType;
- (NSNumber*) generateNewId:(NSString*)objectType byUser:(NSNumber*)userid;

+ (IDGenerator*)instance;
@end
