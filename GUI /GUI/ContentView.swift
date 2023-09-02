//
//  ContentView.swift
//  GUI
//
//  Created by Felix on 31.08.23.
//

import SwiftUI

struct ContentView: View {
    
    @State private var selection = 0
    
    @State private var selectedVersionIndex = 0
    
    @State private var width = UIScreen.main.bounds.width
    @State private var height = UIScreen.main.bounds.height
    
    let ios14Versions = ["14.0", "14.1"]
    
    let iosVersions = [
        "14.0",
        "14.0.1",
        "14.2",
        "14.2.1",
        "14.3",
        "14.4",
        "14.4.1",
        "14.4.2",
        "14.5",
        "14.6",
        "14.7",
        "14.7.1",
        "14.8",
        "15.0",
        "15.6",
        
        // ... Add more iOS versions here
    ]
    
    
    
    @available(iOS 13.0, *)
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: 0x01A4FF), Color(hex: 0xA3A261), Color(hex: 0xFF7B01)]),
                           startPoint: .top,
                           endPoint: .bottom).edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("2ndra1n")
                    .font(.system(size: height * 0.06))
                    .fontWeight(.bold)
                    .opacity(0.7)
                    .multilineTextAlignment(.center)
//                    .padding(.horizontal) // Add some top padding here if needed
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .position(x: width / 2, y: height / 2)
            
            VStack {
                HStack {
                    Image(ios14Versions.contains(iosVersions[selectedVersionIndex]) ? "iOS 14 Icons" : "iOS 15 Icons")
                        .resizable()
                        .frame(width: 128, height: 128)
                        .position(x: width / 2, y: height / 4)
                }
                
                Picker("iOS Version", selection: $selectedVersionIndex) {
                    ForEach(iosVersions.indices, id: \.self) { index in
                        Text("\(iosVersions[index])")
                            .tag(index)
                    }
                }
                .pickerStyle(.wheel)
                .position(x: width / 2, y: height / 5)
                
                Button(action: {
                    
                }) {
                    Text("Credits")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: width / 2.5)
                        .background(Color(red: 0.5, green: 0.5, blue: 0.5, opacity: 0.4)) // Change background color and opacity)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .position(x: width / 3.5, y: height / 3)
                
                Button(action: {
                    
                }) {
                    Text("Settings")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: width / 2.5)
                        .background(Color(red: 0.5, green: 0.5, blue: 0.5, opacity: 0.4)) // Change background color and opacity)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .position(x: width / 1.4, y: height / 6.6)
                
                
                
                
                Button(action: {
                    // Add your action here for the "Dualboot" button
                }) {
                    Text("Dualboot")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: width / 1.2)
                        .background(Color(red: 0.5, green: 0.5, blue: 0.5, opacity: 0.4)) // Change background color and opacity)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .position(x: width / 2, y: height / 10)
                
                
            }
        }
    }
    private func updateImage(for version: String) {
        // Determine if the version is in the iOS 14 range
        let isIOS14 = ios14Versions.contains(version)
        
        // Update the image based on whether it's iOS 14 or not
        // You should replace these with your actual image names
       _ = isIOS14 ? "iOS 14 Icons" : "iOS 15 Icons"
        
        // Update the image using some logic here
        // For example, if you're using an @State variable for the image name
        // you can update that here
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


extension Color {
    init(hex: UInt32) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}
