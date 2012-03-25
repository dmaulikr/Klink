//
//  main.m
//  Platform
//
//  Created by Bobby Gill on 10/7/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[])
{
//    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//    int retVal = UIApplicationMain(argc, argv, nil, nil);
//    [pool release];
//    return retVal;
    
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = -1;
    @try {
        retVal = UIApplicationMain(argc, argv, nil, nil);
    }
    @catch (NSException* exception) {
        NSLog(@"Uncaught exception: %@", exception.description);
        NSLog(@"Stack trace: %@", [exception callStackSymbols]);
    }
    [pool release];
    return retVal;
    
    
}
