//
//  ConnectionList.swift
//  BuilderConnect
//
//  Created by Catherine Herring on 2021-03-09.
//

import SwiftUI

struct ConnectionList: View {
    @EnvironmentObject var modelData: ModelData
    @State private var trackPosition = false
    @State private var isShowingDetailView = false

//    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        NavigationView {
            List {

                Toggle(isOn: $trackPosition) {
                    Text("Keep connection")
                }
                
                ForEach(modelData.connections) { connection in
                    NavigationLink(destination: ConnectionView(connection: connection)) {
                        ConnectionRow(connection: connection)
                    }
                }
            }
            .navigationTitle("Connections")
            .navigationBarHidden(false)
            .navigationBarBackButtonHidden(true)
            
//            Text("Welcome!")
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
    }
}

struct ConnectionList_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionList()
    }
}

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
