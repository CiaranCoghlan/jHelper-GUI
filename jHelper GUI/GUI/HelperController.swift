//
//  HelperController.swift
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
import Foundation

class HelperController: NSViewController, NSTextFieldDelegate {
    
    // Link controls to View Controller
    @IBOutlet weak var WindowType: NSPopUpButton!
    @IBOutlet weak var WindowTitle: NSTextField!
    @IBOutlet weak var WindowHeading: NSTextField!
    @IBOutlet weak var HeadingAlignment: NSPopUpButton!
    @IBOutlet weak var WindowDescription: NSTextField!
    @IBOutlet weak var DescriptionAlignment: NSPopUpButton!
    @IBOutlet weak var WindowPosition: NSPopUpButton!
    @IBOutlet weak var IconSize: NSTextField!
    @IBOutlet weak var ButtonOne: NSTextField!
    @IBOutlet weak var ButtonTwo: NSTextField!
    @IBOutlet weak var DefaultButton: NSSegmentedControl!
    @IBOutlet weak var CancelButton: NSSegmentedControl!
    @IBOutlet weak var LockHUD: NSSegmentedControl!
    @IBOutlet weak var WindowCountdown: NSSegmentedControl!
    @IBOutlet weak var WindowTimeout: NSTextField!
    @IBOutlet weak var StartLaunchD: NSSegmentedControl!
    @IBOutlet weak var ScriptName: NSTextField!
    @IBOutlet weak var jssURL: NSTextField!
    @IBOutlet weak var jssUser: NSTextField!
    @IBOutlet weak var jssPass: NSSecureTextField!
    @IBOutlet weak var FullScreenIcon: NSSegmentedControl!
    @IBOutlet weak var DelayOptions: NSTextField!
    @IBOutlet weak var CountdownText: NSTextField!
    @IBOutlet weak var CountdownAlignment: NSPopUpButton!
    @IBOutlet weak var SelectIconButton: NSButton!
    @IBOutlet weak var IconView: NSImageView!
    @IBOutlet weak var IconPath: NSTextField!
    @IBOutlet weak var createScriptButton: NSButton!
    @IBOutlet weak var launchHelperButton: NSButton!
    @IBOutlet weak var submitToJssButton: NSButton!
    
    // Static variables
    fileprivate let jamfHelperPath = "/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
    fileprivate let scriptsUri = "/JSSResource/scripts/id/0"
    fileprivate let githubUrl = "https://github.com/JAMFSupport/JAMF-Helper-GUI"
    fileprivate let helper = Helper()

    // Enable countdown text if countdown button has 'Yes' selected, otherwise disable
    @IBAction func countdownButtonAction(_ sender: NSSegmentedControl) {
        if WindowCountdown.selectedSegment == 0 {
            CountdownText.isEnabled = true
        } else {
            CountdownText.isEnabled = false
            CountdownText.stringValue = ""
        }
    }

    // Enable majority of controls once a window type is selected
    @IBAction func WindowTypeChanged(_ sender: NSPopUpButton) {
        ManageControls.segmentedControl(LockHUD, dependentPopUp: sender)
        ManageControls.textField(ScriptName, dependentPopUp: sender)
        ManageControls.textField(jssURL, dependentPopUp: sender)
        ManageControls.textField(jssUser, dependentPopUp: sender)
        ManageControls.textField(jssPass, dependentPopUp: sender)
        ManageControls.button(createScriptButton, dependentPopUp: sender)
        ManageControls.segmentedControl(FullScreenIcon, dependentPopUp: sender, popUpIndex: nil, dependentText: IconPath)
        ManageControls.popUpButton(WindowPosition, dependentPopUp: sender)
        ManageControls.segmentedControl(LockHUD, dependentPopUp: sender)
        ManageControls.textField(WindowTitle, dependentPopUp: sender)
        ManageControls.textField(WindowDescription, dependentPopUp: sender)
        ManageControls.textField(WindowHeading, dependentPopUp: sender)
        ManageControls.textField(ButtonOne, dependentPopUp: sender)
        ManageControls.textField(ButtonTwo, dependentPopUp: sender)
        ManageControls.button(SelectIconButton, dependentPopUp: sender)
        ManageControls.textField(WindowTimeout, dependentPopUp: sender)
        ManageControls.textField(DelayOptions, dependentPopUp: sender)
        ManageControls.segmentedControl(StartLaunchD, dependentPopUp: sender)
        ManageControls.button(launchHelperButton, dependentPopUp: sender)
    }

    // Submit the script to the JSS
    @IBAction func SubmitToJSS(_ sender: NSButton) {
        let scriptHeader = "#!/bin/bash\n\"" + jamfHelperPath + "\" "
        let argumentString = scriptHeader + self.processInputs().joined(separator: " ")
        let scriptName = ScriptName.stringValue
        let script_xml = HelperUtils.getScriptXml(name: scriptName, data: argumentString)
        let request = HttpRequest()
        request.post(jssURL.stringValue + scriptsUri, user: jssUser.stringValue, password: jssPass.stringValue, data: script_xml)
    }
    
    // Execute a JAMF Helper 'kill' command
    @IBAction func KillHelper(_ sender: NSButton) {
        DispatchQueue.global().async {
            _ = HelperUtils.executeCommand(self.jamfHelperPath, args: ["-kill"], out: false)
        }
    }
    
    // Get the path to the image to use as an icon
    @IBAction func SelectIcon(_ sender: NSButton) {
        if let path = HelperUtils.openFilePanel() {
            let icon = NSImage(contentsOf: path)
            IconPath.stringValue = path.path
            IconPath.isHidden = false
            IconPath.isEnabled = true
            IconView.image = icon
            IconSize.isEnabled = true
            ManageControls.segmentedControl(FullScreenIcon, dependentPopUp: WindowType, popUpIndex: WindowType.indexOfItem(withTitle: "Fullscreen"), dependentText: IconPath)
        } else {
            IconPath.isHidden = true
            IconPath.isEnabled = false
        }
    }
    
    // Asynchronously launch JAMF Helper window
    @IBAction func launchJamfHelperAction(_ sender: NSButton) {
        DispatchQueue.global().async {
            print(self.processInputs())
            _ = HelperUtils.executeCommand(self.jamfHelperPath, args: self.processInputs(), out: false)
        }
    }
    
    // Create a script and save to the desktop
    @IBAction func createScriptAction(_ sender: NSButton) {
        let scriptHeader = "#!/bin/bash\n\"" + jamfHelperPath + "\" "
        let argumentString = scriptHeader + self.processInputs().joined(separator: " ")

        if let path = HelperUtils.savePanel() {
            try! argumentString.write(toFile: path, atomically: false, encoding: String.Encoding.utf8)
        }
    }
    
    override func viewWillAppear() {
        let blue = NSColor(red: 91/255.0, green: 105/255.0, blue: 130/255.0, alpha: 1.0)
        self.view.layer?.backgroundColor = blue.cgColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}

extension HelperController {
    // Populate the Helper object
    fileprivate func processInputs() -> [String] {
        
        helper.setWindowType(windowType: WindowType.titleOfSelectedItem)
        helper.setWindowPosition(windowPosition: WindowPosition.titleOfSelectedItem)
        helper.setTitle(titleText: WindowTitle.stringValue)
        helper.setHeading(headingText: WindowHeading.stringValue)
        helper.setHeadingAlignment(headingAlign: HeadingAlignment.titleOfSelectedItem)
        helper.setDescription(descriptionText: WindowDescription.stringValue)
        helper.setDescriptionAlign(descriptionAlign: DescriptionAlignment.titleOfSelectedItem)
        helper.setIcon(icon: IconPath.stringValue)
        helper.setIconSize(iconSize: IconSize.stringValue)
        helper.setIconFullScreen(iconFullScreen: String(FullScreenIcon.selectedSegment))
        helper.setButtonOne(buttonOne: ButtonOne.stringValue)
        helper.setButtonTwo(buttonTwo: ButtonTwo.stringValue)
        helper.setDefaultButton(buttonDefault: String(DefaultButton.selectedSegment))
        helper.setCancelButton(buttonCancel: String(CancelButton.selectedSegment))
        helper.setTimeout(timeout: WindowTimeout.stringValue)
        helper.setCountdown(countdown: String(WindowCountdown.selectedSegment))
        helper.setCountdownAlign(countdownAlign: CountdownAlignment.titleOfSelectedItem)
        helper.setCountdownPrompt(countdownPrompt: CountdownText.stringValue)
        helper.setLockHud(lockHud: String(LockHUD.selectedSegment))
        helper.setStartLaunchD(startLaunchD: String(StartLaunchD.selectedSegment))
        helper.setShowDelayOptions(showDelayOptions: DelayOptions.stringValue)
        
        return helper.toArray()
    }
}

extension HelperController {
    override func controlTextDidChange(_ obj: Notification) {
        if let textField = obj.object as? NSTextField {
            switch(textField) {
            case (ButtonOne):
                ManageControls.segmentedControl(DefaultButton, dependentText: ButtonOne)
                ManageControls.segmentedControl(CancelButton, dependentText: ButtonOne)
            case (WindowTimeout):
                ManageControls.segmentedControl(WindowCountdown, dependentText: WindowTimeout)
            case (WindowHeading):
                ManageControls.popUpButton(HeadingAlignment, dependentText: WindowHeading)
            case (WindowDescription):
                ManageControls.popUpButton(DescriptionAlignment, dependentText: WindowDescription)
            case (CountdownText):
                ManageControls.popUpButton(CountdownAlignment, dependentText: CountdownText)
            case ScriptName, jssURL, jssUser, jssPass:
                ManageControls.button(submitToJssButton, dependentTextArray: [ScriptName, jssURL, jssUser, jssPass])
            default:
                print("Valid control not found!")
            }
        }
    }
}

