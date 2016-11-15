//
//  ManageControls.swift
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

class ManageControls: NSObject {
    
    public static func button(_ button: NSButton, dependentPopUp: NSPopUpButton) {
        if (dependentPopUp.indexOfSelectedItem > 0) {
            button.isEnabled = true
        } else {
            button.isEnabled = false
        }
    }
    
    public static func button(_ button: NSButton, dependentTextArray: [NSTextField]) {
        var enable = true
        for textField in dependentTextArray {
            if (textField.stringValue.isEmpty) {
                enable = false
            }
        }
        button.isEnabled = enable
    }

    // Enable the popup button if the dependency has text entered
    public static func popUpButton(_ popUpButton: NSPopUpButton, dependentText: NSTextField) {
        if (dependentText.stringValue.characters.count > 0) {
            popUpButton.isEnabled = true
        } else {
            popUpButton.isEnabled = false
            popUpButton.selectItem(at: 0)
        }
    }
    
    public static func popUpButton(_ popUpButton: NSPopUpButton, dependentPopUp: NSPopUpButton) {
        if (dependentPopUp.indexOfSelectedItem > 0) {
            popUpButton.isEnabled = true
        } else {
            popUpButton.isEnabled = false
            popUpButton.selectItem(at: 0)
        }
    }
    
    public static func textField(_ textField: NSTextField, dependentPopUp: NSPopUpButton) {
        if (dependentPopUp.indexOfSelectedItem > 0) {
            textField.isEnabled = true
        } else {
            textField.stringValue = ""
            textField.isEnabled = false
        }
    }
    
    public static func segmentedControl(_ segmentedControl: NSSegmentedControl, dependentText: NSTextField) {
        if (dependentText.stringValue.characters.count > 0) {
            enableSegmentedControl(control: segmentedControl, enable: true)
        } else {
            enableSegmentedControl(control: segmentedControl, enable: false)
        }
    }
    
    // Enable the segmented control if the dependency has text entered or a selection made
    public static func segmentedControl(_ segmentedControl: NSSegmentedControl, dependentPopUp: NSPopUpButton) {
        
        if (dependentPopUp.indexOfSelectedItem > 0) {
            enableSegmentedControl(control: segmentedControl, enable: true)
        } else {
            enableSegmentedControl(control: segmentedControl, enable: false)
        }
    }
    
    public static func segmentedControl(_ segmentedControl: NSSegmentedControl, dependentPopUp: NSPopUpButton, popUpIndex: Int?, dependentText: NSTextField) {
        
        if let index = popUpIndex {
            if (dependentPopUp.indexOfSelectedItem == index && dependentText.stringValue.characters.count > 0) {
                enableSegmentedControl(control: segmentedControl, enable: true)
            } else {
                enableSegmentedControl(control: segmentedControl, enable: false)
            }
        } else {
            if (dependentPopUp.indexOfSelectedItem > 0 && dependentText.stringValue.characters.count > 0) {
                enableSegmentedControl(control: segmentedControl, enable: true)
            } else {
                enableSegmentedControl(control: segmentedControl, enable: false)
            }
        }
    }
    
    private static func enableSegmentedControl(control: NSSegmentedControl, enable: Bool) {
        for segment in 0 ..< control.segmentCount {
            control.setEnabled(enable, forSegment: segment)
            if (!enable) {
                control.setSelected(enable, forSegment: segment)
            }
        }
    }
}
