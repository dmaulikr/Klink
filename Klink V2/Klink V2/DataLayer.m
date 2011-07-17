//
//  DataLayer.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/16/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "DataLayer.h"
#import "ServerManagedResource.h"

@implementation DataLayer
@synthesize lastIDGenerated;
static  DataLayer* sharedManager; 

+ (DataLayer*)getInstance {
    NSString* activityName = @"DataLayer.getInstance:";
    @synchronized(self)
    {
        if (!sharedManager) {
            sharedManager = [[super allocWithZone:NULL]init];
        } 
//        [BLLog v:activityName withMessage:@"completed initialization"];
        return sharedManager;
    }
}

+ (id) getObjectByType:(NSString*)typeName withId:(NSNumber*)identifier {
    id retVal = nil;
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *appContext = appDelegate.managedObjectContext;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:typeName inManagedObjectContext:appContext];
    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"objectid=%@",identifier];    
    [request setPredicate:predicate];
    
    NSError* error = nil;
    NSArray* results = [appContext executeFetchRequest:request error:&error];
    
    if (results == nil) {
        NSLog(@"error fetching from core data model: %@",[error description]);
    }
    else if ([results count] == 0) {
        NSLog(@"no objects found with id");
    
    }
    else {
        retVal = [results objectAtIndex:0];
    }
    
    return retVal;
    
}

- (id) init{
    self = [super init];
    if (self != nil) {
        self.lastIDGenerated = 0;
    }
    return self;
}

//Generates a unique identifier for a new entity
-(NSNumber*)getNextID {
    NSString* activityName = @"DataLayer.getNextID";
    AuthenticationManager* authenticationManager = [AuthenticationManager getInstance];
    NSNumber* userID = authenticationManager.m_LoggedInUserID;

    int int_secondsSinceEpoch = (int)[[NSDate date]timeIntervalSince1970];
    NSNumber* secondsSinceEpoch = [NSNumber numberWithInt:int_secondsSinceEpoch];
    
    NSString* idString = [NSString stringWithFormat:@"%@%@",userID,secondsSinceEpoch];
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc]init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber* retVal = [f numberFromString:idString] ;
    [f release];
    
    while ([retVal longLongValue]==self.lastIDGenerated) {
        long long nextID = self.lastIDGenerated +1;
        retVal = [NSNumber numberWithLongLong:(nextID)];
    }
    
//    NSString* message = [NSString stringWithFormat:@"Generated new id of %@",retVal];
//    [BLLog v:activityName withMessage:message];

    self.lastIDGenerated = [retVal longLongValue];
    return retVal;
}



+ (void) deleteObjectByType:(NSString*)typeName withId:(NSNumber*)identifier {
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];

    NSManagedObjectContext *appContext = appDelegate.managedObjectContext;    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:typeName inManagedObjectContext:appContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init] ;
    [request setEntity:entityDescription];
    [request setIncludesPropertyValues:NO];
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"objectid=%@",identifier];    
    [request setPredicate:predicate];
    
    
    NSError *error;
    NSArray *items = [appContext executeFetchRequest:request error:&error];
    [request release];
    
    
    for (NSManagedObject *managedObject in items) {
        [appContext deleteObject:managedObject];
        NSLog(@"deleted object from entity %@",typeName);
    }
}

+ (id) getObjectsByType:(NSString*)typeName withValueEqual:(NSString*)value forAttribute:(NSString*)attributeName {
    NSString* activityName = @"DataLayer.getObjectsByType:";
    NSArray* retVal = nil;
    
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *appContext = appDelegate.managedObjectContext;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:typeName inManagedObjectContext:appContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"%K=%@",attributeName,value];    
    [request setPredicate:predicate];
    
    NSError* error = nil;
    NSArray* results = [appContext executeFetchRequest:request error:&error];
    
    if (results == nil) {
        [BLLog e:activityName withMessage:@"error fetching from core model"];
        
    }
    else if ([results count] == 0) {
        [BLLog v:activityName withMessage:@"no objects found with id"];
        
    }
    else {
//        [BLLog v:activityName withMessage:@"found object with id"];
        retVal = results;
    }
    [request release];
    return retVal; 
}

+ (id) getObjectByType:(NSString *)typeName withValueEqual:(NSString *)value forAttribute:(NSString *)attributeName {
    NSArray* results = [DataLayer getObjectsByType:typeName withValueEqual:value forAttribute:attributeName];
    
    if ([results count]>0) {
        return [results objectAtIndex:0];
    }
    else {
        return nil;
    }
}


+ (id) getObjectByID:(NSNumber*) identifier withObjectType:(NSString*)objectType {
    
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *appContext = appDelegate.managedObjectContext;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:objectType
                                                         inManagedObjectContext:appContext];

    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"objectid=%@",identifier];    
    [request setPredicate:predicate];
    
    NSError* error = nil;
    NSArray* results = [appContext executeFetchRequest:request error:&error];
    
    if (results != nil &&
        [results count] == 1) {
        return [results objectAtIndex:0];
    }
    return nil;
}

//Returns an array of objects of the specified type sorted according to the specified attribute
+ (id) getObjectsByType:(NSString*)objectType sortBy:(NSString*)attributeName sortAscending:(BOOL)sortAscending {
    NSString* activityName = @"DataLayer.getObjectsByType:";
    
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *appContext = appDelegate.managedObjectContext;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:objectType
                                                         inManagedObjectContext:appContext];    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:attributeName ascending:sortAscending];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError* error = nil;
    NSArray* results = [appContext executeFetchRequest:request error:&error];
    
    if (error != nil) {
        [BLLog e:activityName withMessage:[error description]];
    }
    
    [request release];
    return results;

}


                                                                                                        

#pragma mark - Theme specific retrieval methods
+ (id) getNewestTheme {
    NSArray* themes = [DataLayer getObjectsByType:tn_THEME sortBy:an_DATECREATED sortAscending:NO];
    
    if ([themes count] > 0) {
        return [themes objectAtIndex:0];
    }
    else {
        return nil;
    }
}

@end
