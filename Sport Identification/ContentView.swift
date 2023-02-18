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
            ImagePicker(selectedImage: $imageSelected, sourceType: .photoLibrary)
        }
    }
    
    // MARK: Indetify the sport using model
    func recognizeImage() {
        let config = MLModelConfiguration()
        
        do {
            // init the model
            let model = try Sport_Detection(configuration: config)
            if let goodImage = buffer(from: imageSelected) {
                print("got converted")
                let prediction = try model.prediction(image: goodImage)
                print(prediction.classLabel.description)
                // set prediction text to label
                sportLabel = prediction.classLabel.description
            } else {
                print("can not be converted")
            }
            
        } catch {
            print(error)
            sportLabel = "Oops, error loding model!"
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
        
        return pixelBuffer
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
