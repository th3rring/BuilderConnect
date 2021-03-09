//
//  ConnectionRowView.swift
//  BuilderConnect
//
//  Created by Catherine Herring on 2021-03-09.
//

import SwiftUI

struct ConnectionRow: View {
    var connection: Connection
    
    var body: some View {
        HStack {
            connection.icon.resizable().frame(width: 25, height: 25)
            Text(connection.name)
                .font(.headline)
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(connection.address)
                    .font(.subheadline)
                    .foregroundColor(Color.gray)
                
                Spacer()
                
                Text(connection.port)
                    .font(.subheadline)
                    .foregroundColor(Color.gray)
            }.padding()
            
            
//            if landmark.isFavorite {
//                Image(systemName: "star.fill")
//                    .foregroundColor(.yellow)
//            }
        }
    }
}

struct ConnectionRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ConnectionRow(connection: ModelData().connections[0])
            ConnectionRow(connection:  ModelData().connections[1])
        }
        .previewLayout(.fixed(width: 400, height: 70))    }
}
