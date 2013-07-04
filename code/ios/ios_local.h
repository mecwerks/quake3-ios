/*
 * Quake3 -- iOS Port
 *
 * Seth Kingsley, January 2008.
 */

#ifndef IOS_LOCAL_H
#define IOS_LOCAL_H

#include <stdio.h>

#include "../game/q_shared.h"
#include "../qcommon/qcommon.h"

#define UNIMPL()	Com_Printf("%s(): Unimplemented\n", __FUNCTION__)

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0f)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)

int device_scale;
int device_width;
int device_height;

void Sys_QueEvent(int time, sysEventType_t type, int value, int value2, int ptrLength, void *ptr);
void Sys_QueEventEx(int time, sysEventType_t type, int value, int value2, int value3, int ptrLength, void *ptr);

#endif // IOS_LOCAL_H
