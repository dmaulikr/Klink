//
//  User.h
//  Platform
//
//  Created by Bobby Gill on 10/7/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface User : Resource {
    
}

@property (nonatomic,retain) NSString* displayname;
@property (nonatomic,retain) NSNumber* numberofvotes;
@end
