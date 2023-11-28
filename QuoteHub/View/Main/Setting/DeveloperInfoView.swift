//
//  DeveloperInfoView.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/10/02.
//

import SwiftUI

struct DeveloperInfoView: View {
    @State private var showAlert: Bool = false

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Image("dev_profile")
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
                .shadow(radius: 10)
                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                .frame(width: 150, height: 150)

            Text("YUNG")
                .font(.title)
                .fontWeight(.bold)
            
            Text("iOS Developer")
                .font(.subheadline)
                .foregroundColor(.gray)

            VStack(spacing: 10) {
                HStack {
                    Image(systemName: "envelope")
                        .foregroundColor(.blue)
                    Text("rsdbddml@gmail.com")
                }
                
                HStack {
                    Image(systemName: "link")
                        .foregroundColor(.blue)
                    Text("https://github.com/iyungui")
                        .foregroundColor(.blue)
                        .underline()
                }
                .onTapGesture {
                    self.showAlert = true
                }
            }
            
            Spacer()
        }
        .padding()
        .navigationBarTitle("개발자 정보", displayMode: .inline)
        .alert(isPresented: $showAlert) {
             Alert(
                 title: Text("외부 사이트로 이동"),
                 message: Text("개발자에 대한 자세한 정보를 외부 사이트에서 제공합니다. 외부 링크를 통해 해당 정보를 보시겠습니까?"),
                 primaryButton: .default(Text("확인")) {
                     if let url = URL(string: "https://github.com/iyungui") {
                         UIApplication.shared.open(url)
                     }
                 },
                 secondaryButton: .cancel()
             )
         }
    }
}


struct DeveloperInfoView_Previews: PreviewProvider {
    static var previews: some View {
        DeveloperInfoView()
    }
}
