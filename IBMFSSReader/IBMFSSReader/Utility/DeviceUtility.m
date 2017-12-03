//
//  DeviceUtility.m
//  IBMFSSNewsLetter
//
//  Created by Rohit on 03/08/15.
//  Copyright (c) 2015 IBM. All rights reserved.
//

//#import "DeviceUtility.h"
#import <sys/utsname.h>
NSString* DeviceModelName() {
    
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *machineName = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    NSDictionary *commonNamesDictionary =
    @{
      @"i386":     @"iPhone Simulator",
      @"x86_64":   @"iPad Simulator",
      
      @"iPhone1,1":    @"iPhone",
      @"iPhone1,2":    @"iPhone 3G",
      @"iPhone2,1":    @"iPhone 3GS",
      @"iPhone3,1":    @"iPhone 4",
      @"iPhone3,2":    @"iPhone 4(Rev A)",
      @"iPhone3,3":    @"iPhone 4(CDMA)",
      @"iPhone4,1":    @"iPhone 4S",
      @"iPhone5,1":    @"iPhone 5(GSM)",
      @"iPhone5,2":    @"iPhone 5(GSM+CDMA)",
      @"iPhone5,3":    @"iPhone 5c(GSM)",
      @"iPhone5,4":    @"iPhone 5c(GSM+CDMA)",
      @"iPhone6,1":    @"iPhone 5s(GSM)",
      @"iPhone6,2":    @"iPhone 5s(GSM+CDMA)",
      
      @"iPhone7,1":    @"iPhone 6+ (GSM+CDMA)",
      @"iPhone7,2":    @"iPhone 6 (GSM+CDMA)",
      
      @"iPad1,1":  @"iPad",
      @"iPad2,1":  @"iPad 2(WiFi)",
      @"iPad2,2":  @"iPad 2(GSM)",
      @"iPad2,3":  @"iPad 2(CDMA)",
      @"iPad2,4":  @"iPad 2(WiFi Rev A)",
      @"iPad2,5":  @"iPad Mini 1G (WiFi)",
      @"iPad2,6":  @"iPad Mini 1G (GSM)",
      @"iPad2,7":  @"iPad Mini 1G (GSM+CDMA)",
      @"iPad3,1":  @"iPad 3(WiFi)",
      @"iPad3,2":  @"iPad 3(GSM+CDMA)",
      @"iPad3,3":  @"iPad 3(GSM)",
      @"iPad3,4":  @"iPad 4(WiFi)",
      @"iPad3,5":  @"iPad 4(GSM)",
      @"iPad3,6":  @"iPad 4(GSM+CDMA)",
      
      @"iPad4,1":  @"iPad Air(WiFi)",
      @"iPad4,2":  @"iPad Air(GSM)",
      @"iPad4,3":  @"iPad Air(GSM+CDMA)",
      
      @"iPad4,4":  @"iPad Mini 2G (WiFi)",
      @"iPad4,5":  @"iPad Mini 2G (GSM)",
      @"iPad4,6":  @"iPad Mini 2G (GSM+CDMA)",
      
      @"iPod1,1":  @"iPod 1st Gen",
      @"iPod2,1":  @"iPod 2nd Gen",
      @"iPod3,1":  @"iPod 3rd Gen",
      @"iPod4,1":  @"iPod 4th Gen",
      @"iPod5,1":  @"iPod 5th Gen",
      
      };
    
    NSString *deviceName = commonNamesDictionary[machineName];
    
    if (deviceName == nil) {
        deviceName = machineName;
    }
    
    return deviceName;
}

extern BOOL IsDeviceIPhone5() {
    if([DeviceModelName() isEqualToString:@"iPhone 5(GSM)"] ||
       [DeviceModelName() isEqualToString:@"iPhone 5(GSM+CDMA)"] ||
       [DeviceModelName() isEqualToString:@"iPhone 5c(GSM)"] ||
       [DeviceModelName() isEqualToString:@"iPhone 5c(GSM+CDMA)"] ||
       [DeviceModelName() isEqualToString:@"iPhone 5s(GSM)"] ||
       [DeviceModelName() isEqualToString:@"iPhone 5s(GSM+CDMA)"]) {
        return true;
    
    }
    return false;
}

extern BOOL IsDeviceIPhone6() {
    BOOL result = [DeviceModelName() isEqualToString:@"iPhone 6 (GSM+CDMA)"];
    return result;
}

BOOL IsDeviceIPhone6Plus() {
    BOOL result = [DeviceModelName() isEqualToString:@"iPhone 6+ (GSM+CDMA)"];
    return result;
}

BOOL isDeviceFromiPhone4Series()
{
    
    NSString *deviceModelName = DeviceModelName();
    BOOL result = ([deviceModelName isEqualToString:@"iPhone 4"] || [deviceModelName isEqualToString:@"iPhone 4(Rev A)"] || [deviceModelName isEqualToString:@"iPhone 4(CDMA)"] || [deviceModelName isEqualToString:@"iPhone 4S"] );
    return result;
}
