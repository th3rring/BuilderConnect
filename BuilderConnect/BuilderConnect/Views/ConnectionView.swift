//
//  ConnectionView.swift
//  BuilderConnect
//
//  Created by Thomas Herring on 2021-03-09.
//

import SwiftUI

struct ConnectionView: View {
    var connection : Connection
    @StateObject var webViewStore = WebViewStore()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>


    var body: some View {
        
        let urlString = connection.protocal + connection.address + ":" + connection.port
        
        return WebView(webView: webViewStore.webView).onAppear {
            self.webViewStore.webView.load(URLRequest(url: URL(string: urlString)!, cachePolicy: .useProtocolCachePolicy))
          }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
//          .background(Color.black)
//          .edgesIgnoringSafeArea(.all)
//          .statusBar(hidden: true)
          .navigationBarBackButtonHidden(true)
          .navigationBarHidden(true)
//          .navigationBarTitle(Text(connection.address), displayMode: .inline)
          .navigationBarTitle(Text(""))

}
    

}

func verifyUrl (urlString: String?) -> Bool {
   if let urlString = urlString {
       if let url = NSURL(string: urlString) {
           return UIApplication.shared.canOpenURL(url as URL)
       }
   }
   return false
}


struct ConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["iPhone XS Max", "iPad Pro (11-inch) (2nd Generation)"], id: \.self) { deviceName in
            ConnectionView(connection: ModelData().connections[0])            .previewDevice(PreviewDevice(rawValue: deviceName))
            .previewDisplayName(deviceName)
        }
    }
}


