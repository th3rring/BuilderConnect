//
//  ConnectionView.swift
//  BuilderConnect
//
//  Created by Catherine Herring on 2021-03-09.
//

import SwiftUI

struct ConnectionView: View {
    var connection : Connection
    @StateObject var webViewStore = WebViewStore()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>


    var body: some View {
          WebView(webView: webViewStore.webView).onAppear {
            self.webViewStore.webView.load(URLRequest(url: URL(string: connection.protocal + connection.address + ":" + connection.port)!, cachePolicy: .useProtocolCachePolicy))
          }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
//          .background(Color.black)
//          .edgesIgnoringSafeArea(.all)
//          .statusBar(hidden: true)
          .navigationBarBackButtonHidden(true)
          .navigationBarHidden(true)
          .navigationBarTitle(Text(connection.address), displayMode: .inline)

}
    

}
struct ConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionView(connection: ModelData().connections[0])
            
    }
}


