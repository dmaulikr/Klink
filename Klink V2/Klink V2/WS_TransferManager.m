//
//  WS_TransferManager.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/24/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "WS_TransferManager.h"


@implementation WS_TransferManager
@synthesize putQueue;
static  WS_TransferManager* sharedManager;  

+ (WS_TransferManager*) getInstance {
    NSString* activityName = @"WS_TransferManager.getInstance:";
    @synchronized(self)
    {
        if (!sharedManager) {
            sharedManager = [[super allocWithZone:NULL]init];
        } 
        [BLLog v:activityName withMessage:@"completed initialization"];
        return sharedManager;
    }
}

- (id)init {
    self = [super init];
    self.putQueue = [[NSOperationQueue alloc] init];
    return self;

}

- (void) uploadAttachmentToCloud:(Attachment*)attachment {
    [self uploadAttachementToCloud:attachment.objectid withObjectType:attachment.objecttype forAttributeName:attachment.attributename atFileLocation:attachment.filelocation];
}

- (void) uploadAttachementToCloud:(NSNumber*)objectid withObjectType:(NSString*)objectType forAttributeName:(NSString*)attributeName atFileLocation:(NSString*)path {
    NSString* activityName = @"WS_TransferManager.uploadAttachementToCloud:";
    
    AuthenticationContext *authenticationContext = [[AuthenticationManager getInstance]getAuthenticationContext];
    
    
    if (authenticationContext != nil) {
        NSURL *url = [UrlManager getUploadAttachmentURL:objectid withObjectType:objectType forAttributeName:attributeName withAuthenticationContext:authenticationContext];
      
        NSMutableDictionary* userInfo = [[NSMutableDictionary alloc]init ];
        [userInfo setValue:objectid forKey:an_OBJECTID];
        [userInfo setValue:objectType forKey:an_OBJECTTYPE];
        [userInfo setValue:attributeName forKey:an_ATTRIBUTENAME];
        [userInfo setValue:path forKey:an_FILELOCATION];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [request setFile:path forKey:@"attachment"];
        request.userInfo = userInfo;
        [request setDelegate:self];
        [request setTimeOutSeconds:60];
        [request setDidFinishSelector:@selector(onUploadAttachmentComplete:)];
        [request setDidFailSelector:@selector(requestWentWrong:)];
        [self.putQueue addOperation:request];
        
        NSString *message = [[NSString alloc] initWithFormat:@"submitted operation at url: %@",url];
        [BLLog v:activityName withMessage:message];
        [message release];
        [userInfo release];
    }

}

- (void) createObjectInCloud:(NSNumber*) objectid withObjectType:(NSString*)objecttype withAttachmentFor:(NSString*)attributeName atFileLocation:(NSString*)path {
    NSString* activityName = @"WS_TransferManager.createObjectInCloud:";
    
    AuthenticationContext *authenticationContext = [[AuthenticationManager getInstance]getAuthenticationContext];
    NSArray* objectids = [NSArray arrayWithObject:objectid];
    NSArray* objectTypes = [NSArray arrayWithObject:objecttype];
    
    ServerManagedResource* object = [DataLayer getObjectByID:objectid withObjectType:objecttype];
    NSDictionary* jsonObject = [object toJSON];
    NSString* jsonRepresentation = [jsonObject JSONString];
    
    NSArray* objectsToCreate = [NSArray arrayWithObject:jsonRepresentation];
    
    if (authenticationContext != nil) {
        NSURL *url = [UrlManager getCreateObjectsURL:objectids withObjectTypes:objectTypes withAuthenticationContext:authenticationContext];
        
        Attachment* attachment = [[Attachment alloc]init];
        attachment.objectid = objectid;
        attachment.objecttype = objecttype;
        attachment.attributename = attributeName;
        attachment.filelocation = path;
        
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:attachment forKey:tn_ATTACHMENT];
                                          
        NSError* error = nil;
        
        NSString* json = [objectsToCreate JSONStringWithOptions:JKSerializeOptionNone error:&error];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [request setPostValue:json forKey:@""];
        request.userInfo = userInfo;
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(onCreateSingleObjectComplete:)];
        [request setDidFailSelector:@selector(requestWentWrong:)];
        [self.putQueue addOperation:request];
        
        NSString *message = [[NSString alloc] initWithFormat:@"submitted operation at url: %@",url];
        [BLLog v:activityName withMessage:message];
        [message release];
        
    }

}

- (void) createObjectsInCloud:(NSArray*)objectids withObjectTypes:(NSArray*)objectTypes withAttachments:(NSArray *)attachments{
    NSString* activityName = @"WS_TransferManager.updateObjectInCloud:";


    NSMutableArray *objectsToCreate = [[NSMutableArray alloc]initWithCapacity:[objectids count]];
    JKSerializeOptionFlags flags = JKSerializeOptionNone;
    
    for (int i = 0; i < [objectids count];i++) {
       ServerManagedResource* resource =  [DataLayer getObjectByID:[objectids objectAtIndex:i] withObjectType:[objectTypes objectAtIndex:i]];
        
        NSError* error = nil;
        NSDictionary* jsonDictionary = [resource toJSON];
        NSString* jsonRepresentation = [jsonDictionary JSONStringWithOptions:flags error:&error];
        [objectsToCreate insertObject:jsonRepresentation atIndex:i];
        
    }
    
    AuthenticationContext *authenticationContext = [[AuthenticationManager getInstance]getAuthenticationContext];
   

    if (authenticationContext != nil) {
        NSURL *url = [UrlManager getCreateObjectsURL:objectids withObjectTypes:objectTypes withAuthenticationContext:authenticationContext];
        
        NSString* json = [objectsToCreate JSONString];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [request setPostValue:json forKey:@""];    
        
        if (attachments != nil && [attachments count]>0) {
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithObject:attachments forKey:tn_ATTACHMENT];
            request.userInfo = dictionary;
            
        }
        
            
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(onCreateComplete:)];
        [request setDidFailSelector:@selector(requestWentWrong:)];
        [self.putQueue addOperation:request];
        
        NSString *message = [[NSString alloc] initWithFormat:@"submitted operation at url: %@",url];
        [BLLog v:activityName withMessage:message];
        [message release];
    }
        
      
    

    
}

- (void) deleteObjectInCloud:(NSNumber*)objectid withObjectType:(NSString*)objectType {
//    NSString* activityName = @"WS_TransferManager.deleteObjectInCloud";
    
    AuthenticationContext *authenticationContext = [[AuthenticationManager getInstance]getAuthenticationContext];
    
    
    if (authenticationContext != nil) {
        NSMutableDictionary* userInfo = [[NSMutableDictionary alloc]init];
        [userInfo setObject:objectid forKey:an_OBJECTID];
        [userInfo setObject:objectType forKey:an_OBJECTTYPE];
        
        NSURL* url = [UrlManager getDeleteURL:objectid withObjectType:objectType withAuthenticationContext:authenticationContext];
        ASIFormDataRequest *request = [[ASIFormDataRequest alloc]initWithURL:url];
        request.delegate = self;
        request.userInfo = userInfo;
        [request setPostValue:@"dicks" forKey:@""];
        [request setDidFinishSelector:@selector(onDeleteComplete:)];
        [request setDidFailSelector:@selector(requestWentWrong:)];
        [self.putQueue addOperation:request];
        
        [userInfo release];
        
    }
    
    
}


- (void) updateObjectInCloud:(NSNumber*)objectid withObjectType:(NSString*)objectType{
    NSString* activityName = @"WS_TransferManager.updateObjectInCloud:";
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *appContext = appDelegate.managedObjectContext;
        
    NSEntityDescription *description = [NSEntityDescription entityForName:objectType inManagedObjectContext:appContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K=%@",an_OBJECTID,objectid];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:description];
    
    NSError* error = nil;
    
    NSArray* results = [appContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        NSString* message = [NSString stringWithFormat:@"unable to retrieve object id: %@ of type %@",objectid,objectType];
        [BLLog e:activityName withMessage:message];
        
    }
    else if ([results count] != 1) {
        NSString* message = [NSString stringWithFormat:@"unable to uniquely locate object id: %@ of type: %@",objectid,objectType];
        [BLLog e:activityName withMessage:message];

    } else {
        ServerManagedResource *resource  = [results objectAtIndex:0];
        
        NSError* error = nil;
        JKSerializeOptionFlags flags = JKSerializeOptionNone;
        NSDictionary* jsonDictionary = (NSDictionary*)[resource toJSON];
        NSString* jsonRepresentation = [jsonDictionary JSONStringWithOptions:flags error:&error];
        
        AuthenticationContext *authenticationContext = [[AuthenticationManager getInstance]getAuthenticationContext];
       
        
        if (authenticationContext != nil) {
            NSURL *url = [UrlManager getUpdateObjectURL:objectid withObjectType:objectType withAuthenticationContext:authenticationContext];
            
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
            [request setPostValue:jsonRepresentation forKey:@""];
                   
            [request setDelegate:self];
            [request setDidFinishSelector:@selector(onPutComplete:)];
            [request setDidFailSelector:@selector(requestWentWrong:)];
            [self.putQueue addOperation:request];
            
            NSString *message = [[NSString alloc] initWithFormat:@"submitted operation at url: %@",url];
            [BLLog v:activityName withMessage:message];
            [message release];
            
        }
    }
    
   
    
}

#pragma mark - Asynchronous Response Handlers



-(void) onUploadAttachmentComplete:(ASIFormDataRequest*)request {
    NSString* activityName = @"WS_TransferManager.onUploadComplete:";
    NSString* response = [request responseString];
    NSDictionary *jsonDictionary = [response objectFromJSONString];
    PutResponse *putResponse = [[PutResponse alloc]initFromDictionary:jsonDictionary];
    
    if (putResponse.didSucceed == [NSNumber numberWithBool:YES]) {
        
        NSDictionary* userInfo = request.userInfo;
        
        NSString* objectType = [userInfo valueForKey:an_OBJECTTYPE];
        NSNumber* objectID = [userInfo valueForKey:an_OBJECTID];
        NSString* attributeName = [userInfo valueForKey:an_ATTRIBUTENAME];
       
        ServerManagedResource* returnedObject = putResponse.modifiedResource;
        NSString* newAttachmentAttributeValue = [returnedObject valueForKey:attributeName];
        ServerManagedResource* resource = [DataLayer getObjectByID:objectID withObjectType:objectType];
        
        
        
        [BLLog v:activityName withMessage:@"successfully completed for objectID:%@, objectType:%@, attributeName:%@ with new value %@",
         objectID,objectType,attributeName,newAttachmentAttributeValue];
        
        //now we update the attribute that was set to reflect the new attribute value;
        [resource setValue:newAttachmentAttributeValue forKey:attributeName];
        [resource commitChangesToDatabase:NO withPendingFlag:NO];
    }
    else {
        [BLLog e:activityName withMessage:@"failed to upload attachment"];
    }
    
    
    
    
}

- (void) onPutComplete:(ASIFormDataRequest*)request{
    NSString* activityName = @"WS_TransferManager.onPutComplete:";
    NSString* response = [request responseString];
    NSDictionary *jsonDictionary = [response objectFromJSONString];
    PutResponse* putResponse = [[PutResponse alloc]initFromDictionary:jsonDictionary];
    
    NSString* message2 = [NSString stringWithFormat:@"put operation compeleted with success:%@",putResponse.didSucceed];
    [BLLog v:activityName withMessage:message2];
       
    ServerManagedResource* downloadedResource = putResponse.modifiedResource;
    
    if (downloadedResource != nil) {
        [ServerManagedResource refreshWithServerVersion:downloadedResource];

    }
}



- (void) onDeleteComplete:(ASIFormDataRequest*)request {
    NSString* activityName = @"WS_TransferManager.onDeleteComplete:";
    NSDictionary* jsonResponse = [[request responseString] objectFromJSONString];
    Response* response = [[Response alloc]initFromDictionary:jsonResponse];
    
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString* message = nil;
    if ([response.didSucceed isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        message = [NSString stringWithFormat:@"deletion succeeded"];
        [BLLog v:activityName withMessage:message];
        
        NSDictionary* userInfo = [request userInfo];
        NSNumber* objectID =(NSNumber*) [userInfo valueForKey:an_OBJECTID];
        NSString* objectType = [userInfo valueForKey:an_OBJECTTYPE];
        
        //need to remove the deleted object record from the system table
        
        NSManagedObjectContext *appContext = appDelegate.systemObjectContext;
        NSEntityDescription *description = [NSEntityDescription entityForName:tn_DELETEDOBJECT inManagedObjectContext:appContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
        
        [fetchRequest setEntity:description];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K=%@ AND %K=%@",an_OBJECTID,objectID,an_OBJECTTYPE,objectType];
        
        [fetchRequest setPredicate:predicate];
        
        NSError* error = nil;
        NSArray* returnedResults = [appContext executeFetchRequest:fetchRequest error:&error];
        
        if (error != nil) {
            message = [NSString stringWithFormat:@"Failed to retrieve deleted object record for %@ with type %@",objectID,objectType];
            [BLLog e:activityName withMessage:message];
        }
        else {
            NSManagedObject* deletedObjectRecord = [returnedResults objectAtIndex:0];
            [appContext deleteObject:deletedObjectRecord];
            error = nil;
            
            [appContext save:&error];
            
            if (error != nil) {
                message = [NSString stringWithFormat:@"could not delete deleted object record for %@ with type %@",objectID,objectType];
                [BLLog e:activityName withMessage:message];
            }
            
        }
        
        [fetchRequest release];
        
    }
    else {
        message = [NSString stringWithFormat:@"deletion failed"];
        [BLLog e:activityName withMessage:message];
    }
    
    
}

-(void) onCreateSingleObjectComplete : (ASIFormDataRequest*)request {
    NSString* activityName = @"WS_TransferManager.onCreateWithAttachementComplete:";
    
    NSString* response = [request responseString];
    NSDictionary* jsonDictionary = [response objectFromJSONString];
    CreateResponse *createResponse = [[CreateResponse alloc]initFromDictionary:jsonDictionary];
    
    if (createResponse.didSucceed) {
        //now we need to process any attachments that are to be uploaded apres the creation of the object
        NSDictionary* userInfo = request.userInfo;
        
        if ([userInfo valueForKey:tn_ATTACHMENT] != [NSNull null]) {
            //we have a file attachment to upload
            Attachment *attachment = [userInfo valueForKey:tn_ATTACHMENT];
            
            NSString* message = [NSString stringWithFormat:@"Processing attachment for objectid:%@, objecttype:%@,attributename:%@,filelocation:%@",attachment.objectid,attachment.objecttype,attachment.attributename,attachment.filelocation];
            [BLLog v:activityName withMessage:message];
            [self uploadAttachmentToCloud:attachment];
        }
        
    }
    else {
        NSString* message = [NSString stringWithFormat:@"Create operation failed"];
        [BLLog e:activityName withMessage:message];
    }
    
    [createResponse release];
    
}

- (void) onCreateComplete:(ASIFormDataRequest*)request {
    NSString* activityName = @"WS_TransferManager.onCreateComplete:";
    NSString* response = [request responseString];
    NSDictionary *jsonDictionary = [response objectFromJSONString];
    CreateResponse *createResponse = [[CreateResponse alloc] initFromDictionary:jsonDictionary];
    
    NSString* message2 = [NSString stringWithFormat:@"create operation compeleted with success:%@",createResponse.didSucceed];
    [BLLog v:activityName withMessage:message2];
    
    
    //need to grab the instance from the core data model
    if (createResponse.createdResources != nil){
        for (int i = 0; i < [createResponse.createdResources count]; i++) {
            ServerManagedResource *downloadedResource = [createResponse.createdResources objectAtIndex:i];
            [ServerManagedResource refreshWithServerVersion:downloadedResource];
            

        }
    }
    
    //process any attachments to the original create request
    NSDictionary* userInfo = request.userInfo;
    if ([userInfo valueForKey:tn_ATTACHMENT] != [NSNull null]) {
        NSArray* attachments = [userInfo valueForKey:tn_ATTACHMENT];
        for (int i = 0; i < [attachments count] ; i++) {
            Attachment* attachment = [attachments objectAtIndex:i];
            NSString* message = [NSString stringWithFormat:@"Processing attachment for objectid:%@, objecttype:%@,attributename:%@,filelocation:%@",attachment.objectid,attachment.objecttype,attachment.attributename,attachment.filelocation];
            [BLLog v:activityName withMessage:message];
            
            [self uploadAttachmentToCloud:attachment];
        }
    }
    
    [createResponse release];
}

- (void) requestWentWrong:(ASIFormDataRequest*) request {
      NSString* activityName = @"WS_TransferManager.requestWentWrong:";
    [BLLog e:activityName withMessage:@" submit operation failed"];
}

@end
