//
//  ConnectionList.swift
//  BuilderConnect
//
//  Created by Thomas Herring on 2021-03-09.
//

import SwiftUI

struct ConnectionList: View {
    @EnvironmentObject var modelData: ModelData
    @ObservedObject var locationManager = LocationManager()

    @State private var trackPosition = false{
        didSet{
            print("condition changed to \(trackPosition)")
            if trackPosition {
                locationManager.startTracking()
            } else {
                locationManager.stopTracking()
            }
        }
    }

//    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        
        let bind = Binding<Bool>(
                  get:{self.trackPosition},
                  set:{self.trackPosition = $0}
                )
        
        return NavigationView {
            List {
                
                Toggle(isOn: bind) { 
                    Text("Maintain Connection")
                }
                
                ForEach(modelData.connections) { connection in
                    NavigationLink(destination: ConnectionView(connection: connection)) {
                        ConnectionRow(connection: connection)
                            
                    }
                }
            }
//            .navigationBarHidden(false)
            .navigationBarBackButtonHidden(true)
            .navigationTitle("Connections")
            
//            Text("Hello!")

        }
        .navigationViewStyle(StackNavigationViewStyle())
//        .navigationViewStyle(DoubleColumnNavigationViewStyle())
//        .padding()


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

struct ConnectionList_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["iPhone XS Max", "iPad Pro (11-inch) (2nd Generation)"], id: \.self) { deviceName in
            ConnectionList()
                .environmentObject(ModelData())
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }
            }
}
