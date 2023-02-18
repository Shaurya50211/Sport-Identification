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
            
            Image(uiImage: imageSelected)
                .resizable()
                .scaledToFit()
                .frame(width: 350)
                .cornerRadius(10)
                .padding(.top)
            
            Text(sportLabel)
                .font(.largeTitle)
                .fontWeight(.black)
            
        }.sheet(isPresented: $openCameraRoll) {
            ImagePicker(selectedImage: $imageSelected, sourceType: .camera)
        }
    }
    
    func recognizeImage(image: UIImage) {
        let config = MLModelConfiguration()
        
        do {
            let model = try Sport_Detection(configuration: config)
            let prediction = try model.prediction(image: image as! CVPixelBuffer)
        } catch {
            print(error)
            sportLabel = "Oops, error loding model!"
        }
        
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
