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

class HelperController: NSViewController {
    
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
    @IBOutlet weak var JSSBox: NSBox!
    @IBOutlet weak var MainLogo: NSButton!
    @IBOutlet weak var DelayOptions: NSTextField!
    @IBOutlet weak var IconFileName: NSTextField!
    @IBOutlet weak var CountdownText: NSTextField!
    @IBOutlet weak var CountdownAlignment: NSPopUpButton!
    @IBOutlet weak var SelectIconButton: NSButton!
    
    // Static variables
    fileprivate let jamfHelperPath = "/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
    fileprivate let scriptsUri = "/JSSResource/scripts/id/0"
    fileprivate let githubUrl = "https://github.com/JAMFSupport/JAMF-Helper-GUI"
    fileprivate let helper = Helper()

    // Enable countdown alignment field if countdown text is entered
    @IBAction func CountdownTextChanged(_ sender: NSTextField) {
        ManageControls().popupButton(CountdownAlignment, dependency: CountdownText)
    }
    
    // Enable countdown text if countdown button has 'Yes' selected, otherwise disable
    @IBAction func CountdownButtonChanged(_ sender: NSSegmentedControl) {
        if WindowCountdown.selectedSegment == 0 {
            CountdownText.isEnabled = true
        } else {
            CountdownText.isEnabled = false
            CountdownText.stringValue = ""
            ManageControls().popupButton(CountdownAlignment, dependency: CountdownText)
        }
    }
    
    // Enable countdown button if window timeout value is entered
    @IBAction func TimeoutChanged(_ sender: NSTextField) {
        ManageControls().segmentedControl(WindowCountdown, dependency: WindowTimeout, dependency2: nil)
    }
    
    // Enable description alignment if description text is entered
    @IBAction func DescriptionChanged(_ sender: NSTextField) {
        ManageControls().popupButton(DescriptionAlignment, dependency: WindowDescription)
    }
    
    // Open 'jamfhelper -help' as an alert when logo is pressed
    @IBAction func MainLogoClicked(_ sender: NSButton?) {
        NSWorkspace.shared().open(URL(string: githubUrl)!)
    }
    
    // Enable heading alignment if heading text is entered
    @IBAction func HeadingChanged(_ sender: NSTextField) {
        ManageControls().popupButton(HeadingAlignment, dependency: WindowHeading)
    }
    
    // Enable default and cancel buttons if button text is entered
    @IBAction func ButtonFieldChanged(_ sender: NSTextField) {
        ManageControls().segmentedControl(DefaultButton, dependency: ButtonOne, dependency2: ButtonTwo)
        ManageControls().segmentedControl(CancelButton, dependency: ButtonOne, dependency2: ButtonTwo)
    }
    
    // Manage window position, and timeout based on window type selection
    @IBAction func WindowTypeChanged(_ sender: NSPopUpButton) {
        let window_type = WindowType.indexOfSelectedItem
        // If window type is Fullscreen and no icon is selected
        if (window_type == 3 && !IconFileName.stringValue.isEmpty) {
            for segment in 0 ..< FullScreenIcon.segmentCount {
                FullScreenIcon.setEnabled(true, forSegment: segment)
            }
            WindowPosition.isEnabled = false
            WindowPosition.selectItem(at: 0)
            WindowTimeout.isEnabled = false
            WindowTimeout.stringValue = ""
            ManageControls().segmentedControl(WindowCountdown, dependency: WindowTimeout, dependency2: nil)
        // If window type is Fullscreen and an icon is selected
        } else if (window_type == 3 && IconFileName.stringValue.isEmpty) {
            WindowPosition.isEnabled = false
            WindowPosition.isEnabled = false
            WindowPosition.selectItem(at: 0)
            WindowTimeout.isEnabled = false
            WindowTimeout.stringValue = ""
            ManageControls().segmentedControl(WindowCountdown, dependency: WindowTimeout, dependency2: nil)
        // If window type is not Fullscreen
        } else {
            // Disable button for fullscreen icon
            for segment in 0 ..< FullScreenIcon.segmentCount {
                FullScreenIcon.setEnabled(false, forSegment: segment)
                FullScreenIcon.setSelected(false, forSegment: segment)
            }
            // Enable window position if it is disabled
            if (!WindowPosition.isEnabled) {
                WindowPosition.isEnabled = true
            }
            // Enable time out if it is disabled
            if (!WindowTimeout.isEnabled) {
                WindowTimeout.isEnabled = true
            }
            // Enable countdown if timeout is entered
            ManageControls().segmentedControl(WindowCountdown, dependency: WindowTimeout, dependency2: nil)
        }
    }
    
    // Display the fields for submitting to the JSS
    @IBAction func UnhideJSS(_ sender: NSButton) {
        if (JSSBox.isHidden && !MainLogo.isHidden) {
            JSSBox.isHidden = false
            MainLogo.isHidden = true
        } else {
            JSSBox.isHidden = true
            MainLogo.isHidden = false
        }
    }
    
    // Submit the script to the JSS
    @IBAction func SubmitToJSS(_ sender: NSButton) {
        let scriptHeader = "#!/bin/bash\n\"" + jamfHelperPath + "\" "
        let argumentString = scriptHeader + self.processInputs().joined(separator: " ")
        let scriptName = ScriptName.stringValue
        
        if (WindowTypeSelected()) {
            if (!scriptName.isEmpty) {
                let script_xml = HelperUtils.getScriptXml(name: " ", data: argumentString)
                let request = HttpRequest()
                request.post(jssURL.stringValue + scriptsUri, user: jssUser.stringValue, password: jssPass.stringValue, data: script_xml)
            } else {
                HelperUtils.displayAlert("Warning!", string: "A valid script name was not specified to save the script. Please choose a valid script name and try again.")
            }
        } else {
            HelperUtils.displayAlert("Warning!", string: "The JAMF Helper binary requires a 'Window Type' be selected to run. Please select a 'Window Type' and try again.")
        }
    }
    
    // Execute a JAMF Helper 'kill' command
    @IBAction func KillHelper(_ sender: NSButton) {
        DispatchQueue.global().async {
            HelperUtils.executeCommand(self.jamfHelperPath, args: ["-kill"], out: false)
        }
    }
    
    // Get the path to the image to use as an icon
    @IBAction func SelectIcon(_ sender: NSButton) {
        if (IconFileName.stringValue.isEmpty) {
            if let path = HelperUtils.openFilePanel() {
                self.IconFileName.stringValue = path
                enableIconSize()
            }
        } else {
            IconFileName.stringValue = ""
            IconSize.stringValue = ""
            enableIconSize()
        }
    }
    
    // Asynchronously launch JAMF Helper window
    @IBAction func LaunchHelper(_ sender: NSButton) {

        if WindowTypeSelected() == true {
            
            DispatchQueue.global().async {
                print(self.processInputs())
                HelperUtils.executeCommand(self.jamfHelperPath, args: self.processInputs(), out: false)
            }
            
        } else {
            
            HelperUtils.displayAlert("Warning!", string: "The JAMF Helper binary requires a 'Window Type' be selected to run. Please select a 'Window Type' and try again.")
            
        }
    }
    
    // Create a script and save to the desktop
    @IBAction func CreateScript(_ sender: NSButton) {
        let scriptHeader = "#!/bin/bash\n\"" + jamfHelperPath + "\" "
        let argumentString = scriptHeader + self.processInputs().joined(separator: " ")

        if (WindowTypeSelected()) {
            if let path = HelperUtils.savePanel() {
                try! argumentString.write(toFile: path, atomically: false, encoding: String.Encoding.utf8)
            } else {
                HelperUtils.displayAlert("Warning!", string: "A valid path was not specified to save the script. Please choose a valid path and try again.")
            }
        } else {
            HelperUtils.displayAlert("Warning!", string: "The JAMF Helper binary requires a 'Window Type' be selected to run. Please select a 'Window Type' and try again.")
        }
    }
    
    override func viewWillAppear() {
        //let darkBlue = NSColor(red: 91/255.0, green: 105/255.0, blue: 130/255.0, alpha: 1.0)
        //let white = NSColor(red: 244/255.0, green: 246/255.0, blue: 249/255.0, alpha: 1.0)
        let lightBlue = NSColor(red: 158/255.0, green: 184/255.0, blue: 213/255.0, alpha: 1.0)
        self.view.layer?.backgroundColor = lightBlue.cgColor
        
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
        helper.setIcon(icon: IconFileName.stringValue)
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
    // Returns true if window type has a value
    fileprivate func WindowTypeSelected() -> Bool {
        if WindowType.indexOfSelectedItem != 0 {
            return true
        } else {
            return false
        }
    }
    
    // Enables icon file size field if an icon has been selected
    fileprivate func enableIconSize() {
        if (!IconFileName.stringValue.isEmpty) {
            IconSize.isEnabled = true
        } else {
            IconSize.isEnabled = false
        }
    }
}

