//
//  ContentView.swift
//  Instafilter
//
//  Created by Salim Hafid on 7/27/20.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ContentView: View {
    @State private var image: Image?
    @State private var filterIntensity = 0.5
    @State private var filterRadius = 100.0
    @State private var filterScale = 5.0
    @State private var showingFilterSheet = false
    
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var processedImage: UIImage?
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    @State private var showingAlert = false
    @State private var alertText = "Image saved"
    @State private var filterName: String?
    let context = CIContext()
    
  
    
    var body: some View {
        let intensity = Binding<Double>(
                get: {
                    self.filterIntensity
                },
                set: {
                    filterIntensity = $0
                    self.applyProcessing()
                }
            )
        let radius = Binding<Double>(
                get: {
                    self.filterRadius
                },
                set: {
                    filterRadius = $0
                    self.applyProcessing()
                }
            )
        
        let scale = Binding<Double>(
                get: {
                    self.filterScale
                },
                set: {
                    filterScale = $0
                    self.applyProcessing()
                }
            )
        
        return NavigationView {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(Color.secondary)
                    if image != nil {
                    image?
                        .resizable()
                        .scaledToFit()
                    }
                    else {
                        Text("Tap to select a picture")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
                .onTapGesture {
                    showingImagePicker = true
                }
                
                let inputKeys = currentFilter.inputKeys
                if inputKeys.contains(kCIInputIntensityKey) {
                HStack {
                    Text("Intensity")
                    Slider(value: intensity)
                }.padding(.vertical)
                }
               
                if inputKeys.contains(kCIInputRadiusKey) {
                HStack {
                    Text("Radius")
                    Slider(value: radius)
                }.padding(.vertical)
                }
                
                if inputKeys.contains(kCIInputScaleKey) {
                HStack {
                    Text("Scale")
                    Slider(value: scale)
                }.padding(.vertical)
                }
                    
                HStack {
                    Button("\(filterName ?? "Change Filter")") {
                        self.showingFilterSheet = true
                    }
                    
                    Spacer()
                    
                    Button("Save") {
                        guard let processedImage = self.processedImage else {
                            alertText = "No image to save"
                            self.showingAlert = true
                            return }
                        
                        let imageSaver = ImageSaver()
                        imageSaver.successHandler = {
                            print("Success")
                            alertText = "Image saved"
                        }
                        
                        imageSaver.errorHandler = {
                            print("Oops, error.")
                            
                        }
                        
                        imageSaver.writeToPhotoAlbum(image: processedImage)
                        self.showingAlert = true
                    }
                }
            }
            .padding([.horizontal, .bottom])
            .navigationBarTitle("Instafilter")
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("\(alertText)"), dismissButton: .default(Text("Ok")))
            }
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: self.$inputImage)
        
            }
            .actionSheet(isPresented: $showingFilterSheet) {
                ActionSheet(title: Text("Select a filter"), buttons: [
                                .default(Text("Crystallize")) { self.setFilter(CIFilter.crystallize()); filterName = "Crystallize" },
                        .default(Text("Edges")) { self.setFilter(CIFilter.edges()) ; filterName = "Edges"},
                        .default(Text("Gaussian Blur")) { self.setFilter(CIFilter.gaussianBlur()) ; filterName = "Guassian Blur"},
                        .default(Text("Pixellate")) { self.setFilter(CIFilter.pixellate()) ; filterName = "Pixellate"},
                        .default(Text("Sepia Tone")) { self.setFilter(CIFilter.sepiaTone()) ; filterName = "Sepia Tone"},
                        .default(Text("Unsharp Mask")) { self.setFilter(CIFilter.unsharpMask()) ; filterName = "Unsharp Mask"},
                        .default(Text("Vignette")) { self.setFilter(CIFilter.vignette()) ; filterName = "Vignette"},
                        .cancel()
                ])
            }
        }
        
        
        
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            //ImagePicker struct is a UIViewControllerRepresentable which is a SwiftUI View so we can show it as a sheet
            ImagePicker(image: self.$inputImage)
        }
        //if the image is nil then onAppear won't be triggered
        .onAppear(perform: loadImage)
    }
    func loadImage() {
        //here we are getting an image of type inputImage which is an optional UIImage that we convert into a SwiftUI Image that can then be shown in the VStack
        guard let inputImage = inputImage else { return }
        alertText = "Image saved"
        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
}
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        }
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(filterRadius, forKey: kCIInputRadiusKey)
        }
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(filterScale, forKey: kCIInputScaleKey)
        }
       
        
        guard let outputImage = currentFilter.outputImage else { return }
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
        }
    }
    
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }

    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
