//
//  ContentView.swift
//  Sport Identification
//
//  Created by Shaurya Gupta on 2023-02-16.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State var pickImage = false
    @State var openCameraRoll = false
    @State var imageSelected = UIImage()
    @State var sportLabel = ""
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                AsyncImage(url: URL(string: "https://source.unsplash.com/\(Float(geometry.size.width).clean)x\(Float(geometry.size.height+100).clean)/?\(sportLabel == "" ? "jungle" : sportLabel)"))
                    .ignoresSafeArea()
                    .onAppear {
                        print("Height: \(Float(geometry.size.height).clean)\nWidth: \(Float(geometry.size.width).clean)")
                    }
                VStack {
                    Button {
                        pickImage = true
                        openCameraRoll = true
                    } label: {
                        Text("Identify Sport")
                            .font(.title)
                            .fontWeight(.bold)
                        Image(systemName: "questionmark.app")
                            .font(.title)
                            .bold()
                    }
                    .clipShape(Capsule())
                    .foregroundColor(.yellow)
                    .buttonStyle(.borderedProminent)
                    
                    // MARK: Image Taken
                    Image(uiImage: imageSelected)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 350)
                        .cornerRadius(10)
                        .padding(.top)
                    
                    // MARK: Sport Class
                    Text(sportLabel)
                        .font(.largeTitle)
                        .fontWeight(.black)
                    
                }.sheet(isPresented: $openCameraRoll) {
                    recognizeImage()
                } content: {
                    ImagePicker(selectedImage: $imageSelected, sourceType: .camera)
                }
            }
        }
    }
    
    // MARK: Indetify the sport using model
    func recognizeImage() {
        
        do {
            // init the model
            let model = try Sport_Detection(configuration: MLModelConfiguration())
            
            guard let buffer = buffer(from: imageSelected) else {
                return
            }
            
            let prediction = try model.prediction(image: buffer)
            
            sportLabel = prediction.classLabel.description
            
        } catch {
            print(error.localizedDescription)
            sportLabel = "Oops, error loading model!"
        }
        
    }
    
    func buffer(from image: UIImage) -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        ContentView().recognizeImage()
        return pixelBuffer
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension Float {
    var clean: String {
       return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
