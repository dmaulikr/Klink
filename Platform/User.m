//
//  User.m
//  Platform
//
//  Created by Bobby Gill on 10/7/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "User.h"
#import <CoreData/CoreData.h>


@implementation User
@dynamic displayname;
@dynamic numberofvotes;
@dynamic thumbnailurl;
@dynamic numberofcaptionslw;
@dynamic numberofdraftscreatedlw;
@dynamic numberofdraftsparticipated;
@dynamic numberofpagespublished;
@dynamic numberofphotoslw;
@dynamic iseditor;
@dynamic datebecameeditor;
@dynamic numberofphotos;
@dynamic numberofcaptions;
@dynamic numberofdraftscreated;
@dynamic maxweeklyparticipation;

- (id) initFromJSONDictionary:(NSDictionary *)jsonDictionary {
    ResourceContext* resourceContext = [ResourceContext instance];
    NSManagedObjectContext* appContext = resourceContext.managedObjectContext;
    NSEntityDescription* entity = [NSEntityDescription entityForName:USER inManagedObjectContext:appContext];
    return [super initFromJSONDictionary:jsonDictionary withEntityDescription:entity insertIntoResourceContext:resourceContext];
}
@end
