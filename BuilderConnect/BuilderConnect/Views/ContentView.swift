//
//  ContentView.swift
//  BuilderConnect
//
//  Created by Thomas Herring on 2021-03-09.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ConnectionList()
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ModelData())
    }
}
