//
//  ImagePicker.swift
//  Instafilter
//
//  Created by Salim Hafid on 7/30/20.
//

import Foundation
import SwiftUI


//this is an image picker struct that knows how to create a UIImagePickerControllers (makeUIViewController and updateUIViewController) and with the makeCoordinator function it can also handle messages/actions sent from the UIImagePickerController

//selecting a photo from library requires UIImagePickerController and delegates which decide where work happens
//delegates here would be UINavigationControllerDelegate and UIImagePickerControllerDelegate
//UIKit view controllers must conform to UIViewControllerRepresentable protocol which requires two methods, makeUIViewController() which creates the view controller and updateUIViewController which updates the view controller

//SwiftUIView that conforms to UIViewControllerRepresentable
struct ImagePicker: UIViewControllerRepresentable {
    //binding property lets us send back changes to parent view (ContentView)
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    //method that creates a UIViewController
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        //when something happens to picker (the UIImagePickerController), tell the coordinator
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    }
    
    //Coordinator must conform to NSObject and be a delegate for the UIImagePicker view
    
    //nested coordinator class is a bridge between UIKit and SwiftUI view
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        //didFinishPicking method is triggered when an image is selected
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
    }
    //this function authomatically calls and configures an instance of the coordinator class when an instance of ImagePicker is created
    //also automatically associates the coordinator with the ImagePicker struct
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
