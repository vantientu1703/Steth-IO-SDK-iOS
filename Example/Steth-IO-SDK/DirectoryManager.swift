//
//  CreatingFolder.swift
//  Steth-IO-Patient
//
//  Created by VinothKumar on 29/01/20.
//  Copyright © 2020 AlexAppadurai. All rights reserved.
//

import Foundation
//import Zip
class DirectoryManager {
    
    lazy var documentPath = { ()->String in
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return NSTemporaryDirectory()
        }
        return path + "/"
    }()
    enum LocalFileName: String {
        case result = "Result"
        case local = "Local"
    }
    enum LocalFolder: String {
        case examAudio = "Exam/Audio/"
        case examFile = "Exam/File/"
        case config = "Config/"
    }
    var folderType :LocalFolder!
    
    init(folderType :LocalFolder) {
        self.folderType = folderType
        createFolder()
    }
    var path:String{
        documentPath + folderType.rawValue
    }
    private func createFolder(){
        if !FileManager.default.fileExists(atPath:path) {
            try? FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
    }
    func write(data:Data, fileName:String)throws{
        try data.write(to: .init(fileURLWithPath: path.appending(fileName)))
    }
    //checks json files in local directory, if exsits the upload data.
    func localJSONFiles()-> [URL] {
        var list = Array<URL>()
        let fileManager = FileManager.default
        if let contentEnumerator:FileManager.DirectoryEnumerator = fileManager.enumerator(atPath: path) {
            let mySuffix = "json"
            while let fileName = contentEnumerator.nextObject() as? String {
                if fileName.hasSuffix(mySuffix) {
                    let url = URL.init(fileURLWithPath: "\(path)\(fileName)")
                    list.append(url)
                }
            }
        }
        return list
    }
    
    func localAudioFiles()-> [URL] {
           var list = Array<URL>()
           let fileManager = FileManager.default
           if let contentEnumerator:FileManager.DirectoryEnumerator = fileManager.enumerator(atPath: path) {
               let mySuffix = "stethio"
               while let fileName = contentEnumerator.nextObject() as? String {
                   if fileName.hasSuffix(mySuffix) {
                       let url = URL.init(fileURLWithPath: "\(path)\(fileName)")
                       list.append(url)
                   }
               }
           }
           return list
       }
    
    func path(type:LocalFileName)->String{
        return  path.appending("\(type.rawValue).json")
    }
    static func removeFiles(folderType :LocalFolder, type:LocalFileName) {
        let filePath = DirectoryManager(folderType:folderType).path(type: type)
        try? FileManager.default.removeItem(atPath: filePath)
        
    }
    

    
    static func isExamExist(folderType :LocalFolder, type:LocalFileName)->Bool{
        let filePath = DirectoryManager(folderType:folderType).path(type: type)
        return FileManager.default.fileExists(atPath: filePath)
    }
    
}


