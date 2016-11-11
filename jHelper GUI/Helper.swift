//
//  Helper.swift
//  JAMF Helper GUI
//
//  Created by Jordan Wisniewski on 9/29/15.
//
//  Copyright (C) 2016, JAMF Software, LLC All rights reserved.
//
//  THIS SOFTWARE IS PROVIDED BY JAMF SOFTWARE, LLC "AS IS" AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JAMF SOFTWARE, LLC BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
//  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
//  IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
//  DAMAGE.

import Cocoa

class Helper: NSObject {
    
    private var windowType = Argument(name: "-windowType")
    private var windowPosition = Argument(name: "-windowPosition")
    private var titleText = Argument(name: "-title")
    private var headingText = Argument(name: "-heading")
    private var headingAlign = Argument(name: "-alignHeading")
    private var descriptionText = Argument(name: "-description")
    private var descriptionAlign = Argument(name: "-alignDescription")
    private var icon = Argument(name: "-icon")
    private var iconSize = Argument(name: "-iconSize")
    private var iconFullScreen = Argument(name: "-fullScreenIcon")
    private var buttonOne = Argument(name: "-button1")
    private var buttonTwo = Argument(name: "-button2")
    private var buttonDefault = Argument(name: "-defaultButton")
    private var buttonCancel = Argument(name: "-cancelButton")
    private var timeout = Argument(name: "-timeout")
    private var countdown = Argument(name: "-countdown")
    private var countdownPrompt = Argument(name: "-countDownPrompt")
    private var countdownAlign = Argument(name: "-alignCountDown")
    private var lockHud = Argument(name: "-lockHud")
    private var startLaunchD = Argument(name: "-startLaunchD")
    private var showDelayOptions = Argument(name: "-showDelayOptions")
    
    func toArray()->[String] {
        let argumentArray: [Argument] = [windowType,
                                         windowPosition,
                                         titleText,
                                         headingText,
                                         headingAlign,
                                         descriptionText,
                                         descriptionAlign,
                                         icon,
                                         iconSize,
                                         iconFullScreen,
                                         buttonOne,
                                         buttonTwo,
                                         buttonDefault,
                                         buttonCancel,
                                         timeout,
                                         countdown,
                                         countdownPrompt,
                                         countdownAlign,
                                         lockHud,
                                         startLaunchD,
                                         showDelayOptions]
        
        let segmentedControls: [String] = [iconFullScreen.name,
                                           countdown.name,
                                           lockHud.name,
                                           startLaunchD.name]
        
        var stringArray: [String] = []
        
        for argument in argumentArray {
            if (segmentedControls.contains(argument.name)) {
                if (argument.value == "0") {
                    stringArray.append(argument.name)
                }
            } else {
                if (!argument.value.isEmpty) {
                    stringArray.append(argument.name)
                    stringArray.append(argument.value)
                }
            }
        }
        
        return stringArray
    }
    
    func getWindowType()->String {
        return windowType.value
    }
    
    func setWindowType(windowType: String?) {
        if let type = windowType {
            if !type.isEmpty {
                if type.lowercased() == "fullscreen" {
                    self.windowType.value = "fs"
                } else {
                    self.windowType.value = type.lowercased()
                }
            }
        }
    }
    
    func getWindowPosition()->String {
        return windowPosition.value
    }
    
    func setWindowPosition(windowPosition: String?) {
        if let position = windowPosition {
            if (!position.isEmpty && position.lowercased() != "center") {
                self.windowPosition.value = HelperUtils.getFirstLetterOfEachWord(string: position)
            } else {
                self.windowPosition.value = ""
            }
        }
    }
    
    func getTitle()->String {
        return titleText.value
    }
    
    func setTitle(titleText: String) {
        self.titleText.value = titleText
    }
    
    func getHeading()->String {
        return headingText.value
    }
    
    func setHeading(headingText: String) {
        self.headingText.value = headingText
    }
    
    func getHeadingAlignment()->String {
        return headingAlign.value
    }
    
    func setHeadingAlignment(headingAlign: String?) {
        if let align = headingAlign {
            self.headingAlign.value = HelperUtils.setValidSelectionValue(value: align)
        }
    }
    
    func getDescription()->String {
        return descriptionText.value
    }
    
    func setDescription(descriptionText: String) {
        self.descriptionText.value = descriptionText
    }
    
    func getDescriptionAlign()->String {
        return descriptionAlign.value
    }
    
    func setDescriptionAlign(descriptionAlign: String?) {
        if let align = descriptionAlign {
            self.descriptionAlign.value = HelperUtils.setValidSelectionValue(value: align)
        }
    }
    
    func getIcon()->String {
        return icon.value
    }
    
    func setIcon(icon: String?) {
        if let icon = icon {
            self.icon.value = icon
        }
    }
    
    func getIconSize()->String {
        return iconSize.value
    }
    
    func setIconSize(iconSize: String) {
        self.iconSize.value = iconSize
    }
    
    func getIconFullScreen()->String {
        return iconFullScreen.value
    }
    
    func setIconFullScreen(iconFullScreen: String) {
        print(iconFullScreen)
        if (iconFullScreen == "0") {
            self.iconFullScreen.value = iconFullScreen
        }
    }
    
    func getButtonOne()->String {
        return buttonOne.value
    }
    
    func setButtonOne(buttonOne: String) {
        self.buttonOne.value = buttonOne
    }
    
    func getButtonTwo()->String {
        return buttonTwo.value
    }
    
    func setButtonTwo(buttonTwo: String) {
        self.buttonTwo.value = buttonTwo
    }
    
    func getDefaultButton()->String {
        return buttonDefault.value
    }
    
    func setDefaultButton(buttonDefault: String) {
        self.buttonDefault.value = HelperUtils.setValidSelectionValue(value: buttonDefault)
    }
    
    func getCancelButton()->String {
        return buttonCancel.value
    }
    
    func setCancelButton(buttonCancel: String) {
        self.buttonCancel.value = HelperUtils.setValidSelectionValue(value: buttonCancel)
    }
    
    func getTimeout()->String {
        return timeout.value
    }
    
    func setTimeout(timeout: String) {
        self.timeout.value = timeout
    }
    
    func getCountdown()->String {
        return countdown.value
    }
    
    func setCountdown(countdown: String) {
        self.countdown.value = HelperUtils.setValidSelectionValue(value: countdown)
    }
    
    func getCountdownAlign()->String {
        return countdownAlign.value
    }
    
    func setCountdownAlign(countdownAlign: String?) {
        if let align = countdownAlign {
            self.countdownAlign.value = HelperUtils.setValidSelectionValue(value: align)
        }
    }
    
    func getCountdownPrompt()->String {
        return countdownPrompt.value
    }
    
    func setCountdownPrompt(countdownPrompt: String) {
        self.countdownPrompt.value = countdownPrompt
    }
    
    func getLockHud()->String {
        return lockHud.value
    }
    
    func setLockHud(lockHud: String) {
        if ( lockHud == "1") {
            self.lockHud.value = lockHud
        }
    }
    
    func getStartLaunchD()->String {
        return startLaunchD.value
    }
    
    func setStartLaunchD(startLaunchD: String) {
        if (startLaunchD == "1") {
            self.startLaunchD.value = startLaunchD
        }
    }
    
    func getShowDelayOptions()->String {
        return showDelayOptions.value
    }
    
    func setShowDelayOptions(showDelayOptions: String) {
        self.showDelayOptions.value = showDelayOptions
    }
}

struct Argument {
    var name: String = ""
    var value: String = ""
    
    init(name: String) {
        self.name = name
    }
}
