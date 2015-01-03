 //
//  main.m
//  BetterRIP
//
//  Created by David Yu on 19/12/2014.
//  Copyright (c) 2014 Alpharize. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    setuid(0);
    setgid(0);
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
