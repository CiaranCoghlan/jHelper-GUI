//
//  HelperUtils.swift
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

class HelperUtils: NSObject {
    
    // Gets the first letter of each word in a string
    // Then returns them in lower case
    public static func getFirstLetterOfEachWord(string: String)->String {
        let wordArray = string.components(separatedBy: " ")
        var abbreviatedWords = ""
        
        for word in wordArray {
            abbreviatedWords += String(word).substring(to: String(word).characters.index(String(word).startIndex, offsetBy: 1)).lowercased()
        }
        
        return abbreviatedWords
    }
    
    // Execute terminal commands
    public static func executeCommand(_ command: String, args: [String], out: Bool) -> String? {
        let pipe = Pipe()
        let task = Process()
        task.launchPath = command
        task.arguments = args
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String? = String(data: data, encoding: String.Encoding.utf8)
        
        if (out) {
            return output
        } else {
            return nil
        }
    }
    
    // Date and time stamp
    public static func printTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd HH-mm-ss"
        return formatter.string(from: Date())
    }
    
    // Creates an XML for the script
    public static func getScriptXml(name: String, data: String) -> String {
        let root = XMLElement(name: "script")
        root.addChild(XMLElement(name: "name", stringValue: name))
        root.addChild(XMLElement(name: "script_contents", stringValue: data))
        
        let xml = XMLDocument(rootElement: root)
        let xmlString = String(data: xml.xmlData(withOptions: Int(XMLNode.Options.documentIncludeContentTypeDeclaration.rawValue)), encoding: .utf8)
        return xmlString!
    }

    // Set -1 values to empty strings
    public static func setValidSelectionValue(value: String)->String {
        if value != "-1" {
            return value.lowercased()
        } else {
            return ""
        }
    }
    
    // Opens a Finder file select dialog window
    public static func openFilePanel()-> URL? {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = true
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = ["png", "jpg", "jpeg", "gif", "bmp", "ico"]
        openPanel.runModal()
        
        if let url = openPanel.url {
            return url
        }
        
        return nil
    }
    
    public static func savePanel()-> String? {
        let panel = NSSavePanel()
        panel.nameFieldLabel = "Name: "
        panel.showsTagField = false
        panel.runModal()
        
        if let url = panel.url {
            return url.path
        } else {
            return ""
        }
    }
    
    // Display an alert with a given title, button title, and a scrollview for a body
    public static func displayAlert(_ title: String, scrollView: NSScrollView?) {
        let alert = NSAlert()
        alert.addButton(withTitle: "Ok")
        alert.alertStyle = .informational
        alert.messageText = title
        alert.informativeText = " "
        if let body = scrollView {
            alert.accessoryView = body
        }
        alert.runModal()
    }
    
    // Display an alert with a given title, button title, and text for the body
    public static func displayAlert(_ title: String, string: String?) {
        let alert = NSAlert()
        alert.messageText = title
        alert.addButton(withTitle: "Ok")
        alert.alertStyle = .informational
        
        if let string = string {
            alert.informativeText = string
        }
        alert.runModal()
    }
}
