/*
 Copyright (C) 2009-2011 id Software LLC, a ZeniMax Media company.
 Copyright (C) 2009 Id Software, Inc.
 
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 
 */

#import <UIKit/UIKit.h>
#include <unistd.h>
#include <string.h>
#include <exception>
#include <typeinfo>

extern char iphoneAppDirectory[1024];
extern int myargc;
extern char **myargv;

static void DoomTerminateHandler() {
    NSLog(@"[CRASH HANDLER] std::terminate called!");
    try {
        std::exception_ptr p = std::current_exception();
        if (p) {
            std::rethrow_exception(p);
        } else {
            NSLog(@"[CRASH HANDLER] No active C++ exception found in current_exception");
        }
    } catch (const std::exception &e) {
        NSLog(@"[CRASH HANDLER] Caught C++ std::exception: type=%s, what=%s", typeid(e).name(), e.what());
    } catch (id obj) {
        NSLog(@"[CRASH HANDLER] Caught Objective-C exception object: %@", obj);
    } catch (...) {
        NSLog(@"[CRASH HANDLER] Caught unknown C++ exception!");
    }
    abort();
}

int main(int argc, char *argv[]) {
    std::set_terminate(DoomTerminateHandler);

    NSSetUncaughtExceptionHandler([](NSException *exception) {
        NSLog(@"[CRASH HANDLER] Uncaught NSException: %@, reason: %@, callStack: %@",
              exception.name, exception.reason, exception.callStackSymbols);
    });

	// save for doom
	myargc = argc;
	myargv = argv;

	// get the app directory based on argv[0]
	strcpy( iphoneAppDirectory, argv[0] );
	int len = strlen( iphoneAppDirectory );
	for( int i = len-1; i >= 0; i-- ) {
		if ( iphoneAppDirectory[i] == '/' ) {
			iphoneAppDirectory[i] = 0;
			break;
		}
		iphoneAppDirectory[i] = 0;
	}
	
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];
    return retVal;
}
