//
//  ContentView.swift
//  FileManager
//
//  Created by Skorobogatow, Christian on 20/7/22.
//

import SwiftUI


class LocalFileManager {
    
    static let instance = LocalFileManager()
    
    let folderName = "MyApp_Images"
    
    init() {
        createFolderIfNeeded()
    }
    
    func createFolderIfNeeded() {
        guard
            let path = FileManager
                .default
                .urls(for: .cachesDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent(folderName)
                .path else {
            return
        }
        
        if !FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.createDirectory(atPath: path,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
                print("Success creating folder")
            } catch let error {
                print("Error Creating folder")
            }
        }
    }
    
    func deleteFolder() {
        guard
            let path = FileManager
                .default
                .urls(for: .cachesDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent(folderName)
                .path else {
            return
        }
        
        do {
            try FileManager.default.removeItem(atPath: path)
            print("Sucess deleting folder")
        } catch let error {
            print("Error deleting Folder: \(error)")
        }
        
    }
    
    func saveImage(image: UIImage, name: String) -> String{
        guard
            let data = image.jpegData(compressionQuality: 1.0),
            let path = getPathForImage(name: name) else {
            
            return "Error getting data."
        }
        
        do {
            try data.write(to: path)
            print(path)
            return "Success Saving!"
        } catch let error {
            return "Error Saving: \(error)"
        }
    }
    
    func getImage(name: String) -> UIImage? {
        guard
            let path = getPathForImage(name: name)?.path,
            FileManager.default.fileExists(atPath: path) else {
            print("Error getting path")
            return nil
        }
        
        return UIImage(contentsOfFile: path)
    }
    
    func deleteImage(name: String) ->  String{
        guard
            let path = getPathForImage(name: name)?.path,
            FileManager.default.fileExists(atPath: path) else {
            return "Error getting path"
        }
        
        
        do {
            try FileManager.default.removeItem(atPath: path)
            return "Sucessfully deleted"
        } catch let error {
            return "Error deleting image \(error)"
        }
    }
    
    func getPathForImage(name: String) -> URL?{
        guard
            let path = FileManager
                .default
                .urls(for: .cachesDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent(folderName)
                .appendingPathComponent("\(name).jpg") else {
            print("Error getting Path")
            return nil
        }
        
        return path
    }
}

class FileManagerViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    
    
    let imageName: String = "steve-jobs"
    let manager = LocalFileManager.instance
    
    @Published var infoMessage: String = ""
    
    init() {
        getImageFromAssetsFolder()
        //        getImageFromFileManager()
    }
    
    
    
    func getImageFromAssetsFolder() {
        image = UIImage(named: imageName)
    }
    
    func getImageFromFileManager() {
        image = manager.getImage(name: imageName)
    }
    
    func saveImage() {
        guard let image = image else {
            return
        }
        
        infoMessage = manager.saveImage(image: image, name: imageName)
    }
    
    func deleteImage() {
        infoMessage = manager.deleteImage(name: imageName)
        manager.deleteFolder()
    }
    
}


struct ContentView: View{
    
    @StateObject var vm = FileManagerViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                
                if let image = vm.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .clipped()
                        .cornerRadius(10)
                        .padding()
                }
                
                HStack {
                    Button {
                        vm.saveImage()
                    } label: {
                        Text("Save to Filemanager")
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding()
                            .padding(.horizontal)
                            .background(.blue)
                            .cornerRadius(10 )
                        
                    }
                    
                    Button {
                        vm.deleteImage()
                    } label: {
                        Text("Delete Image from FM")
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding()
                            .padding(.horizontal)
                            .background(.red)
                            .cornerRadius(10 )
                        
                    }
                }
                
                Text(vm.infoMessage)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
            }
            .navigationTitle("File Manager")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
