// Copyright (c) 2015 Dennis Weissmann
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

//===----------------------------------------------------------------------===//
//
// This source file is part of the DeviceKit open source project
//
// Copyright © 2014 - 2018 Dennis Weissmann and the DeviceKit project authors
//
// License: https://github.com/dennisweissmann/DeviceKit/blob/master/LICENSE
// Contributors: https://github.com/dennisweissmann/DeviceKit#contributors
//
//===----------------------------------------------------------------------===//

// Only devices that run ios11 and newer
// Info about devices at: https://www.theiphonewiki.com/wiki/Main_Page
// Info about screens at: http://www.displaymate.com/index.html
// To add a device, update the following: public enum, func mapToDevice(), description, ppi and brightness

import UIKit

enum DeviceType {
    case iphone
    case ipad
    case mac
}

enum Device {

    /// Device is an [iPod touch (5th generation)](https://support.apple.com/kb/SP657)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP657/sp657_ipod-touch_size.jpg)
    case iPodTouch5
    /// Device is an [iPod touch (6th generation)](https://support.apple.com/kb/SP720)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP720/SP720-ipod-touch-specs-color-sg-2015.jpg)
    case iPodTouch6
    /// Device is an [iPod touch (7th generation)](https://support.apple.com/kb/SP796)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP796/ipod-touch-7th-gen_2x.png)
    case iPodTouch7
    /// Device is an [iPhone 4](https://support.apple.com/kb/SP587)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP643/sp643_iphone4s_color_black.jpg)
    case iPhone4
    /// Device is an [iPhone 4s](https://support.apple.com/kb/SP643)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP643/sp643_iphone4s_color_black.jpg)
    case iPhone4s
    /// Device is an [iPhone 5](https://support.apple.com/kb/SP655)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP655/sp655_iphone5_color.jpg)
    case iPhone5
    /// Device is an [iPhone 5c](https://support.apple.com/kb/SP684)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP684/SP684-color_yellow.jpg)
    case iPhone5c
    /// Device is an [iPhone 5s](https://support.apple.com/kb/SP685)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP685/SP685-color_black.jpg)
    case iPhone5s
    /// Device is an [iPhone 6](https://support.apple.com/kb/SP705)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP705/SP705-iphone_6-mul.png)
    case iPhone6
    /// Device is an [iPhone 6 Plus](https://support.apple.com/kb/SP706)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP706/SP706-iphone_6_plus-mul.png)
    case iPhone6Plus
    /// Device is an [iPhone 6s](https://support.apple.com/kb/SP726)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP726/SP726-iphone6s-gray-select-2015.png)
    case iPhone6s
    /// Device is an [iPhone 6s Plus](https://support.apple.com/kb/SP727)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP727/SP727-iphone6s-plus-gray-select-2015.png)
    case iPhone6sPlus
    /// Device is an [iPhone 7](https://support.apple.com/kb/SP743)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP743/iphone7-black.png)
    case iPhone7
    /// Device is an [iPhone 7 Plus](https://support.apple.com/kb/SP744)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP744/iphone7-plus-black.png)
    case iPhone7Plus
    /// Device is an [iPhone SE](https://support.apple.com/kb/SP738)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP738/SP738.png)
    case iPhoneSE
    /// Device is an [iPhone 8](https://support.apple.com/kb/SP767)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP767/iphone8.png)
    case iPhone8
    /// Device is an [iPhone 8 Plus](https://support.apple.com/kb/SP768)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP768/iphone8plus.png)
    case iPhone8Plus
    /// Device is an [iPhone X](https://support.apple.com/kb/SP770)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP770/iphonex.png)
    case iPhoneX
    /// Device is an [iPhone Xs](https://support.apple.com/kb/SP779)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP779/SP779-iphone-xs.jpg)
    case iPhoneXS
    /// Device is an [iPhone Xs Max](https://support.apple.com/kb/SP780)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP780/SP780-iPhone-Xs-Max.jpg)
    case iPhoneXSMax
    /// Device is an [iPhone Xʀ](https://support.apple.com/kb/SP781)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP781/SP781-iPhone-xr.jpg)
    case iPhoneXR
    /// Device is an [iPhone 11](https://support.apple.com/kb/SP804)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP804/sp804-iphone11_2x.png)
    case iPhone11
    /// Device is an [iPhone 11 Pro](https://support.apple.com/kb/SP805)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP805/sp805-iphone11pro_2x.png)
    case iPhone11Pro
    /// Device is an [iPhone 11 Pro Max](https://support.apple.com/kb/SP806)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP806/sp806-iphone11pro-max_2x.png)
    case iPhone11ProMax
    /// Device is an [iPhone SE (2nd generation)](https://support.apple.com/kb/SP820)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP820/iphone-se-2nd-gen_2x.png)
    case iPhoneSE2
    /// Device is an [iPhone 12](https://support.apple.com/kb/SP830)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP830/sp830-iphone12-ios14_2x.png)
    case iPhone12
    /// Device is an [iPhone 12 mini](https://support.apple.com/kb/SP829)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP829/sp829-iphone12mini-ios14_2x.png)
    case iPhone12Mini
    /// Device is an [iPhone 12 Pro](https://support.apple.com/kb/SP831)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP831/iphone12pro-ios14_2x.png)
    case iPhone12Pro
    /// Device is an [iPhone 12 Pro Max](https://support.apple.com/kb/SP832)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP832/iphone12promax-ios14_2x.png)
    case iPhone12ProMax
    /// Device is an [iPad 2](https://support.apple.com/kb/SP622)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP622/SP622_01-ipad2-mul.png)
    case iPad2
    /// Device is an [iPad (3rd generation)](https://support.apple.com/kb/SP647)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP662/sp662_ipad-4th-gen_color.jpg)
    case iPad3
    /// Device is an [iPad (4th generation)](https://support.apple.com/kb/SP662)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP662/sp662_ipad-4th-gen_color.jpg)
    case iPad4
    /// Device is an [iPad Air](https://support.apple.com/kb/SP692)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP692/SP692-specs_color-mul.png)
    case iPadAir
    /// Device is an [iPad Air 2](https://support.apple.com/kb/SP708)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP708/SP708-space_gray.jpeg)
    case iPadAir2
    /// Device is an [iPad (5th generation)](https://support.apple.com/kb/SP751)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP751/ipad_5th_generation.png)
    case iPad5
    /// Device is an [iPad (6th generation)](https://support.apple.com/kb/SP774)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP774/sp774-ipad-6-gen_2x.png)
    case iPad6
    /// Device is an [iPad Air (3rd generation)](https://support.apple.com/kb/SP787)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP787/ipad-air-2019.jpg)
    case iPadAir3
    /// Device is an [iPad (7th generation)](https://support.apple.com/kb/SP807)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP807/sp807-ipad-7th-gen_2x.png)
    case iPad7
    /// Device is an [iPad (8th generation)](https://support.apple.com/kb/SP822)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP822/sp822-ipad-8gen_2x.png)
    case iPad8
    /// Device is an [iPad Air (4th generation)](https://support.apple.com/kb/SP828)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP828/sp828ipad-air-ipados14-960_2x.png)
    case iPadAir4
    /// Device is an [iPad Mini](https://support.apple.com/kb/SP661)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP661/sp661_ipad_mini_color.jpg)
    case iPadMini
    /// Device is an [iPad Mini 2](https://support.apple.com/kb/SP693)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP693/SP693-specs_color-mul.png)
    case iPadMini2
    /// Device is an [iPad Mini 3](https://support.apple.com/kb/SP709)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP709/SP709-space_gray.jpeg)
    case iPadMini3
    /// Device is an [iPad Mini 4](https://support.apple.com/kb/SP725)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP725/SP725ipad-mini-4.png)
    case iPadMini4
    /// Device is an [iPad Mini (5th generation)](https://support.apple.com/kb/SP788)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP788/ipad-mini-2019.jpg)
    case iPadMini5
    /// Device is an [iPad Pro 9.7-inch](https://support.apple.com/kb/SP739)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP739/SP739.png)
    case iPadPro9Inch
    /// Device is an [iPad Pro 12-inch](https://support.apple.com/kb/SP723)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP723/SP723-iPad_Pro_2x.png)
    case iPadPro12Inch
    /// Device is an [iPad Pro 12-inch (2nd generation)](https://support.apple.com/kb/SP761)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP761/ipad-pro-12in-hero-201706.png)
    case iPadPro12Inch2
    /// Device is an [iPad Pro 10.5-inch](https://support.apple.com/kb/SP762)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP761/ipad-pro-10in-hero-201706.png)
    case iPadPro10Inch
    /// Device is an [iPad Pro 11-inch](https://support.apple.com/kb/SP784)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP784/ipad-pro-11-2018_2x.png)
    case iPadPro11Inch
    /// Device is an [iPad Pro 12.9-inch (3rd generation)](https://support.apple.com/kb/SP785)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP785/ipad-pro-12-2018_2x.png)
    case iPadPro12Inch3
    /// Device is an [iPad Pro 11-inch (2nd generation)](https://support.apple.com/kb/SP814)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP814/ipad-pro-11-2020.jpeg)
    case iPadPro11Inch2
    /// Device is an [iPad Pro 12.9-inch (4th generation)](https://support.apple.com/kb/SP815)
    ///
    /// ![Image](https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/SP815/ipad-pro-12-2020.jpeg)
    case iPadPro12Inch4
    /// Device is unknown
    case unknown(String)
    //// Device is running macOS
    case macOS


    // MARK: - Init
    init() {
        self = Device.mapToDevice(identifier: Device.identifier)
    }

    // MARK: - Computed variables and methods
    static var identifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }

    private static func mapToDevice(identifier: String) -> Device {
        #if !targetEnvironment(macCatalyst)
        switch identifier {
        case "iPod5,1": return iPodTouch5
        case "iPod7,1": return iPodTouch6
        case "iPod9,1": return iPodTouch7
        case "iPhone3,1", "iPhone3,2", "iPhone3,3": return iPhone4
        case "iPhone4,1": return iPhone4s
        case "iPhone5,1", "iPhone5,2": return iPhone5
        case "iPhone5,3", "iPhone5,4": return iPhone5c
        case "iPhone6,1", "iPhone6,2": return iPhone5s
        case "iPhone7,2": return iPhone6
        case "iPhone7,1": return iPhone6Plus
        case "iPhone8,1": return iPhone6s
        case "iPhone8,2": return iPhone6sPlus
        case "iPhone9,1", "iPhone9,3": return iPhone7
        case "iPhone9,2", "iPhone9,4": return iPhone7Plus
        case "iPhone8,4": return iPhoneSE
        case "iPhone10,1", "iPhone10,4": return iPhone8
        case "iPhone10,2", "iPhone10,5": return iPhone8Plus
        case "iPhone10,3", "iPhone10,6": return iPhoneX
        case "iPhone11,2": return iPhoneXS
        case "iPhone11,4", "iPhone11,6": return iPhoneXSMax
        case "iPhone11,8": return iPhoneXR
        case "iPhone12,1": return iPhone11
        case "iPhone12,3": return iPhone11Pro
        case "iPhone12,5": return iPhone11ProMax
        case "iPhone12,8": return iPhoneSE2
        case "iPhone13,2": return iPhone12
        case "iPhone13,1": return iPhone12Mini
        case "iPhone13,3": return iPhone12Pro
        case "iPhone13,4": return iPhone12ProMax
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4": return iPad2
        case "iPad3,1", "iPad3,2", "iPad3,3": return iPad3
        case "iPad3,4", "iPad3,5", "iPad3,6": return iPad4
        case "iPad4,1", "iPad4,2", "iPad4,3": return iPadAir
        case "iPad5,3", "iPad5,4": return iPadAir2
        case "iPad6,11", "iPad6,12": return iPad5
        case "iPad7,5", "iPad7,6": return iPad6
        case "iPad11,3", "iPad11,4": return iPadAir3
        case "iPad7,11", "iPad7,12": return iPad7
        case "iPad11,6", "iPad11,7": return iPad8
        case "iPad13,1", "iPad13,2": return iPadAir4
        case "iPad2,5", "iPad2,6", "iPad2,7": return iPadMini
        case "iPad4,4", "iPad4,5", "iPad4,6": return iPadMini2
        case "iPad4,7", "iPad4,8", "iPad4,9": return iPadMini3
        case "iPad5,1", "iPad5,2": return iPadMini4
        case "iPad11,1", "iPad11,2": return iPadMini5
        case "iPad6,3", "iPad6,4": return iPadPro9Inch
        case "iPad6,7", "iPad6,8": return iPadPro12Inch
        case "iPad7,1", "iPad7,2": return iPadPro12Inch2
        case "iPad7,3", "iPad7,4": return iPadPro10Inch
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4": return iPadPro11Inch
        case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8": return iPadPro12Inch3
        case "iPad8,9", "iPad8,10": return iPadPro11Inch2
        case "iPad8,11", "iPad8,12": return iPadPro12Inch4
        default: return unknown(identifier)
        }
        #else
        return macOS
        #endif
    }

    var description: String {
        switch self {
        case .iPodTouch5: return "iPod touch (5th generation)"
        case .iPodTouch6: return "iPod touch (6th generation)"
        case .iPodTouch7: return "iPod touch (7th generation)"
        case .iPhone4: return "iPhone 4"
        case .iPhone4s: return "iPhone 4s"
        case .iPhone5: return "iPhone 5"
        case .iPhone5c: return "iPhone 5c"
        case .iPhone5s: return "iPhone 5s"
        case .iPhone6: return "iPhone 6"
        case .iPhone6Plus: return "iPhone 6 Plus"
        case .iPhone6s: return "iPhone 6s"
        case .iPhone6sPlus: return "iPhone 6s Plus"
        case .iPhone7: return "iPhone 7"
        case .iPhone7Plus: return "iPhone 7 Plus"
        case .iPhoneSE: return "iPhone SE"
        case .iPhone8: return "iPhone 8"
        case .iPhone8Plus: return "iPhone 8 Plus"
        case .iPhoneX: return "iPhone X"
        case .iPhoneXS: return "iPhone Xs"
        case .iPhoneXSMax: return "iPhone Xs Max"
        case .iPhoneXR: return "iPhone Xʀ"
        case .iPhone11: return "iPhone 11"
        case .iPhone11Pro: return "iPhone 11 Pro"
        case .iPhone11ProMax: return "iPhone 11 Pro Max"
        case .iPhoneSE2: return "iPhone SE (2nd generation)"
        case .iPhone12: return "iPhone 12"
        case .iPhone12Mini: return "iPhone 12 mini"
        case .iPhone12Pro: return "iPhone 12 Pro"
        case .iPhone12ProMax: return "iPhone 12 Pro Max"
        case .iPad2: return "iPad 2"
        case .iPad3: return "iPad (3rd generation)"
        case .iPad4: return "iPad (4th generation)"
        case .iPadAir: return "iPad Air"
        case .iPadAir2: return "iPad Air 2"
        case .iPad5: return "iPad (5th generation)"
        case .iPad6: return "iPad (6th generation)"
        case .iPadAir3: return "iPad Air (3rd generation)"
        case .iPad7: return "iPad (7th generation)"
        case .iPad8: return "iPad (8th generation)"
        case .iPadAir4: return "iPad Air (4th generation)"
        case .iPadMini: return "iPad Mini"
        case .iPadMini2: return "iPad Mini 2"
        case .iPadMini3: return "iPad Mini 3"
        case .iPadMini4: return "iPad Mini 4"
        case .iPadMini5: return "iPad Mini (5th generation)"
        case .iPadPro9Inch: return "iPad Pro (9.7-inch)"
        case .iPadPro12Inch: return "iPad Pro (12.9-inch)"
        case .iPadPro12Inch2: return "iPad Pro (12.9-inch) (2nd generation)"
        case .iPadPro10Inch: return "iPad Pro (10.5-inch)"
        case .iPadPro11Inch: return "iPad Pro (11-inch)"
        case .iPadPro12Inch3: return "iPad Pro (12.9-inch) (3rd generation)"
        case .iPadPro11Inch2: return "iPad Pro (11-inch) (2nd generation)"
        case .iPadPro12Inch4: return "iPad Pro (12.9-inch) (4th generation)"
        case .unknown(let identifier): return "unknown: \(identifier)"
        case .macOS: return "macos"
        }
    }


    var ppi: Float? {
        switch self {
        case .iPodTouch5: return 326
        case .iPodTouch6: return 326
        case .iPodTouch7: return 326
        case .iPhone4: return 326
        case .iPhone4s: return 326
        case .iPhone5: return 326
        case .iPhone5c: return 326
        case .iPhone5s: return 326
        case .iPhone6: return 326
        case .iPhone6Plus: return 401
        case .iPhone6s: return 326
        case .iPhone6sPlus: return 401
        case .iPhone7: return 326
        case .iPhone7Plus: return 401
        case .iPhoneSE: return 326
        case .iPhone8: return 326
        case .iPhone8Plus: return 401
        case .iPhoneX: return 458
        case .iPhoneXS: return 458
        case .iPhoneXSMax: return 458
        case .iPhoneXR: return 326
        case .iPhone11: return 326
        case .iPhone11Pro: return 458
        case .iPhone11ProMax: return 458
        case .iPhoneSE2: return 326
        case .iPhone12: return 460
        case .iPhone12Mini: return 476
        case .iPhone12Pro: return 460
        case .iPhone12ProMax: return 458
        case .iPad2: return 132
        case .iPad3: return 264
        case .iPad4: return 264
        case .iPadAir: return 264
        case .iPadAir2: return 264
        case .iPad5: return 264
        case .iPad6: return 264
        case .iPadAir3: return 264
        case .iPad7: return 264
        case .iPad8: return 264
        case .iPadAir4: return 264
        case .iPadMini: return 163
        case .iPadMini2: return 326
        case .iPadMini3: return 326
        case .iPadMini4: return 326
        case .iPadMini5: return 326
        case .iPadPro9Inch: return 264
        case .iPadPro12Inch: return 264
        case .iPadPro12Inch2: return 264
        case .iPadPro10Inch: return 264
        case .iPadPro11Inch: return 264
        case .iPadPro12Inch3: return 264
        case .iPadPro11Inch2: return 264
        case .iPadPro12Inch4: return 264
        case .unknown: return nil
        case .macOS: return nil
        }
    }

    var brightness: Float? {
        switch self {
        case .iPodTouch5: return 500
        case .iPodTouch6: return 500
        case .iPodTouch7: return 500
        case .iPhone4: return 500
        case .iPhone4s: return 500
        case .iPhone5: return 500
        case .iPhone5c: return 500
        case .iPhone5s: return 500
        case .iPhone6: return 500
        case .iPhone6Plus: return 500
        case .iPhone6s: return 550
        case .iPhone6sPlus: return 550
        case .iPhone7: return 625
        case .iPhone7Plus: return 625
        case .iPhoneSE: return 625
        case .iPhone8: return 625
        case .iPhone8Plus: return 625
        case .iPhoneX: return 625
        case .iPhoneXS: return 625
        case .iPhoneXSMax: return 625
        case .iPhoneXR: return 625
        case .iPhone11: return 625
        case .iPhone11Pro: return 800
        case .iPhone11ProMax: return 800
        case .iPhoneSE2: return 625
        case .iPhone12: return 625
        case .iPhone12Mini: return 625
        case .iPhone12Pro: return 800
        case .iPhone12ProMax: return 800
        case .iPad2: return 500
        case .iPad3: return 500
        case .iPad4: return 500
        case .iPadAir: return 500
        case .iPadAir2: return 500
        case .iPad5: return 500
        case .iPad6: return 500
        case .iPadAir3: return 500
        case .iPad7: return 500
        case .iPad8: return 500
        case .iPadAir4: return 500
        case .iPadMini: return 500
        case .iPadMini2: return 500
        case .iPadMini3: return 500
        case .iPadMini4: return 500
        case .iPadMini5: return 500
        case .iPadPro9Inch: return 500
        case .iPadPro12Inch: return 600
        case .iPadPro12Inch2: return 600
        case .iPadPro10Inch: return nil
        case .iPadPro11Inch: return 600
        case .iPadPro12Inch3: return 600
        case .iPadPro11Inch2: return 600
        case .iPadPro12Inch4: return 600
        case .unknown: return nil
        case .macOS: return nil
        }
    }


    var type: DeviceType {
        switch self {
        case .iPodTouch5: return .iphone
        case .iPodTouch6: return .iphone
        case .iPodTouch7: return .iphone
        case .iPhone4: return .iphone
        case .iPhone4s: return .iphone
        case .iPhone5: return .iphone
        case .iPhone5c: return .iphone
        case .iPhone5s: return .iphone
        case .iPhone6: return .iphone
        case .iPhone6Plus: return .iphone
        case .iPhone6s: return .iphone
        case .iPhone6sPlus: return .iphone
        case .iPhone7: return .iphone
        case .iPhone7Plus: return .iphone
        case .iPhoneSE: return .iphone
        case .iPhone8: return .iphone
        case .iPhone8Plus: return .iphone
        case .iPhoneX: return .iphone
        case .iPhoneXS: return .iphone
        case .iPhoneXSMax: return .iphone
        case .iPhoneXR: return .iphone
        case .iPhone11: return .iphone
        case .iPhone11Pro: return .iphone
        case .iPhone11ProMax: return .iphone
        case .iPhoneSE2: return .iphone
        case .iPhone12: return .iphone
        case .iPhone12Mini: return .iphone
        case .iPhone12Pro: return .iphone
        case .iPhone12ProMax: return .iphone
        case .iPad2: return .ipad
        case .iPad3: return .ipad
        case .iPad4: return .ipad
        case .iPadAir: return .ipad
        case .iPadAir2: return .ipad
        case .iPad5: return .ipad
        case .iPad6: return .ipad
        case .iPadAir3: return .ipad
        case .iPad7: return .ipad
        case .iPad8: return .ipad
        case .iPadAir4: return .ipad
        case .iPadMini: return .ipad
        case .iPadMini2: return .ipad
        case .iPadMini3: return .ipad
        case .iPadMini4: return .ipad
        case .iPadMini5: return .ipad
        case .iPadPro9Inch: return .ipad
        case .iPadPro12Inch: return .ipad
        case .iPadPro12Inch2: return .ipad
        case .iPadPro10Inch: return .ipad
        case .iPadPro11Inch: return .ipad
        case .iPadPro12Inch3: return .ipad
        case .iPadPro11Inch2: return .ipad
        case .iPadPro12Inch4: return .ipad
        case .unknown: return .iphone
        case .macOS: return .mac
        }
    }


    var screenInfo: String {
        switch self {
        case .iPhone6: return "http://www.displaymate.com/iPhone6_ShootOut.htm"
        case .iPhone6Plus: return "http://www.displaymate.com/iPhone6_ShootOut.htm"
        case .iPhone7: return "http://www.displaymate.com/iPhone7_ShootOut_1.htm"
        case .iPhoneX: return "http://www.displaymate.com/iPhoneX_ShootOut_1a.htm"
        case .iPhoneXSMax: return "http://www.displaymate.com/iPhoneXS_ShootOut_1s.htm"
        case .iPhone11ProMax: return "http://www.displaymate.com/iPhone_11Pro_ShootOut_1P.htm"
        case .iPadAir: return "http://www.displaymate.com/iPad6_ShootOut.htm"
        case .iPadAir2: return "http://www.displaymate.com/iPad_Pro9_ShootOut_1.htm"
        case .iPadMini3: return "http://www.displaymate.com/iPad6_ShootOut.htm"
        case .iPadMini4: return "http://www.displaymate.com/iPad_2015_ShootOut_1.htm"
        case .iPadPro9Inch: return "http://www.displaymate.com/iPad_Pro9_ShootOut_1.htm"
        case .iPadPro12Inch: return "http://www.displaymate.com/iPad_2015_ShootOut_1.htm"
        case .macOS: return ""
        default: return "you may found some info in: http://www.displaymate.com/mobile.html"
        }

    }

    var systemName: String {
        return UIDevice.current.systemName
    }

    var systemVersion: String {
        return UIDevice.current.systemVersion
    }

    var maximumFrameRate: Int {
        if type == .mac {
            return 60
        } else {
            return UIScreen.main.maximumFramesPerSecond
        }
    }

    private var x: Float? {
        if type == .mac {
            return nil
        } else {
            return Float(UIScreen.main.bounds.width * UIScreen.main.scale)
        }
    }

    private var y: Float? {
        if type == .mac {
            return nil
        } else {
            return Float(UIScreen.main.bounds.height * UIScreen.main.scale)
        }
    }

    var width: Float? {
        if let x = x, let y = y {
            return max(x, y)
        } else {
            return nil
        }

    }

    var height: Float? {
        if let x = x, let y = y {
            return min(x, y)
        } else {
            return nil
        }
    }
}
