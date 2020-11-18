//
//  ContentView.swift
//  ToySwiftUILocation
//
//  Created by Faiz Mokhtar AD0502 on 17/11/2020.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var locationObject: CoreLocationObject
    
    var body: some View {
        VStack {
            Button("Request location") {
                self.locationObject.authorize()
            }
            Text("\(locationObject.authorizationStatus.description)")
               
            self.locationObject.location.map {
                Text($0.description)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
