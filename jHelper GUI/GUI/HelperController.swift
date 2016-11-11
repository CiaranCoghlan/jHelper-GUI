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
    @IBOutlet weak var DelayOptions: NSTextField!
    @IBOutlet weak var IconFileName: NSTextField!
    @IBOutlet weak var CountdownText: NSTextField!
    @IBOutlet weak var CountdownAlignment: NSPopUpButton!
    @IBOutlet weak var SelectIconButton: NSButton!
    
    // Variables for cocoa bindings
    var bindType: NSString = ""
    var bindScriptName: NSString = ""
    var bindJssUrl: NSString = ""
    var bindJssUser: NSString = ""
    var bindJssPass: NSString = ""
    var bindHeading: NSString = ""
    var bindDescription: NSString = ""
    var bindButtonOne: NSString = ""
    var bindButtonTwo: NSString = ""
    var bindTimeout: NSString = ""
    var bindCountdown: NSString = ""
    
    // Static variables
    fileprivate let jamfHelperPath = "/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
    fileprivate let scriptsUri = "/JSSResource/scripts/id/0"
    fileprivate let githubUrl = "https://github.com/JAMFSupport/JAMF-Helper-GUI"
    fileprivate let helper = Helper()

    // Enable countdown alignment field if countdown text is entered
    @IBAction func CountdownTextChanged(_ sender: NSTextField) {
    }
    
    // Enable countdown text if countdown button has 'Yes' selected, otherwise disable
    @IBAction func CountdownButtonChanged(_ sender: NSSegmentedControl) {

    }
    
    // Enable countdown button if window timeout value is entered
    @IBAction func TimeoutChanged(_ sender: NSTextField) {

    }
    
    // Enable description alignment if description text is entered
    @IBAction func DescriptionChanged(_ sender: NSTextField) {

    }

    // Enable heading alignment if heading text is entered
    @IBAction func HeadingChanged(_ sender: NSTextField) {

    }
    
    // Enable default and cancel buttons if button text is entered
    @IBAction func ButtonFieldChanged(_ sender: NSTextField) {

    }
    
    // Manage window position, and timeout based on window type selection
    @IBAction func WindowTypeChanged(_ sender: NSPopUpButton) {
        let windowType = WindowType.indexOfSelectedItem
        if (windowType == 3 && !IconFileName.stringValue.isEmpty) {
            enableSegmentedControl(control: FullScreenIcon, enable: true)
        } else {
            enableSegmentedControl(control: FullScreenIcon, enable: false)
        }
    }

    // Submit the script to the JSS
    @IBAction func SubmitToJSS(_ sender: NSButton) {
        let scriptHeader = "#!/bin/bash\n\"" + jamfHelperPath + "\" "
        let argumentString = scriptHeader + self.processInputs().joined(separator: " ")
        let scriptName = ScriptName.stringValue
        let script_xml = HelperUtils.getScriptXml(name: " ", data: argumentString)
        let request = HttpRequest()
        request.post(jssURL.stringValue + scriptsUri, user: jssUser.stringValue, password: jssPass.stringValue, data: script_xml)
    }
    
    // Execute a JAMF Helper 'kill' command
    @IBAction func KillHelper(_ sender: NSButton) {
        DispatchQueue.global().async {
            HelperUtils.executeCommand(self.jamfHelperPath, args: ["-kill"], out: false)
        }
    }
    
    // Get the path to the image to use as an icon
    @IBAction func SelectIcon(_ sender: NSButton) {
        if let path = HelperUtils.openFilePanel() {
            IconFileName.stringValue = path
            IconSize.isEnabled = true
            if (WindowType.indexOfSelectedItem == 3) {
                enableSegmentedControl(control: FullScreenIcon, enable: true)
            } else {
                enableSegmentedControl(control: FullScreenIcon, enable: false)
            }
        } else {
            IconSize.isEnabled = false
        }
    }
    
    // Asynchronously launch JAMF Helper window
    @IBAction func LaunchHelper(_ sender: NSButton) {
        DispatchQueue.global().async {
            print(self.processInputs())
            HelperUtils.executeCommand(self.jamfHelperPath, args: self.processInputs(), out: false)
        }
    }
    
    // Create a script and save to the desktop
    @IBAction func CreateScript(_ sender: NSButton) {
        let scriptHeader = "#!/bin/bash\n\"" + jamfHelperPath + "\" "
        let argumentString = scriptHeader + self.processInputs().joined(separator: " ")

        if let path = HelperUtils.savePanel() {
            try! argumentString.write(toFile: path, atomically: false, encoding: String.Encoding.utf8)
        }
    }
    
    override func viewWillAppear() {
        let blue = NSColor(red: 91/255.0, green: 105/255.0, blue: 130/255.0, alpha: 1.0)
        let darkBlue = NSColor(red: 44/255.0, green: 58/255.0, blue: 82/255.0, alpha: 1.0)
        //let white = NSColor(red: 244/255.0, green: 246/255.0, blue: 249/255.0, alpha: 1.0)
        //let lightBlue = NSColor(red: 158/255.0, green: 184/255.0, blue: 213/255.0, alpha: 1.0)
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

    fileprivate func enableSegmentedControl(control: NSSegmentedControl, enable: Bool) {
        for segment in 0 ..< control.segmentCount {
            control.setEnabled(enable, forSegment: segment)
            if (!enable) {
                control.setSelected(enable, forSegment: segment)
            }
        }
    }
}

