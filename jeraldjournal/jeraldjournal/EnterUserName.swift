//
//  EnterUserName.swift
//  jeraldjournal
//
//  Created by cqlsys on 19/11/23.
//

import SwiftUI

struct EnterUserName: View {
    @State private var showWelcomeView = false
    @State var phoneNumber: String = ""
    @State private var isValid = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        ZStack() {
            VStack() {
                Group {
                    VStack() {
                        Spacer().frame(height: 100)
                        Image("ic_logo")
                        Spacer().frame(height: 50)
                        Text("New here? 👋").foregroundColor(.white).font(Font.system(size: 25,weight: Font.Weight.bold))
                        Spacer().frame(height: 29)
                        
                        HStack() {
                            Spacer()
                            VStack(alignment: .leading) {
                                Spacer().frame(height: 7)
                                TextField("", text: $phoneNumber , prompt: Text("Your name").foregroundColor(Color.black))
                                    .onChange(of: phoneNumber, perform: { newValue in

                                    })
                                    .font(Font.system(size: 25))
                                Spacer().frame(height: 7)
                            }
                        }.frame(maxWidth: .infinity, maxHeight: 71).background(Color.white).cornerRadius(10).padding(.leading, 30).padding(.trailing, 30)
                        
                        Text("Use your name so your friends can find you!").foregroundColor(Color(red: 152 / 255, green: 148 / 255, blue: 148 / 255)).font(Font.system(size: 12)) .frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 40).padding(.top, 10)
                    }
                    
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("By signing up for Candid you agree to our").foregroundColor(.white).font(Font.system(size: 10)) .frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 25)
                    HStack(spacing: 2) {
                        
                        
                        Button{
                            
                        } label: {
                            Text("Privacy Policy").foregroundColor(.white).font(Font.system(size: 10,weight: Font.Weight.bold)) .padding(.leading, 25)
                        }
                        
                        Text("and").foregroundColor(.white).font(Font.system(size: 10))
                        
                        Button{
                            
                        } label: {
                            Text("Terms of Service").foregroundColor(.white).font(Font.system(size: 10,weight: Font.Weight.bold))
                        }
                        
                        Spacer()
                    }
                    
                    
                }.frame(maxWidth: .infinity, maxHeight: 60).background(Color.black)
                
                
                
            }
            
            VStack(alignment: .leading) {
                Spacer()
                HStack() {
                    Spacer()
                    
//                        NavigationLink(destination: Record(), isActive: isValid) {
//                            Image("ic_arrow")
//                                .frame(width: 60, height: 60)
//                                .background(buttonColor).cornerRadius(30)
//                        }
//                        .padding(.bottom, 30)
                    
                    Button{
                        isValid = validate()
                        print("sssdds")
                    } label: {
                        Image("ic_arrow")
                    }.background(
                        NavigationLink(
                            destination: OTPVC(),
                            isActive: $isValid,
                            label: {
                                EmptyView()
                            })
                        .hidden()
                        
                    ).frame(width: 60, height: 60).background(buttonColor).cornerRadius(30).padding(30)
                }
                
                
            }
            
            
        }.navigationBarHidden(true)
        .frame(maxWidth: .infinity, maxHeight: .infinity).background(Color(red: 27 / 255, green: 27 / 255, blue: 27 / 255))
    }
    
    var buttonColor: Color {
        return phoneNumber.count > 5 ? Color(red: 54 / 255, green: 157 / 255, blue: 122 / 255) : .gray
       }
    
    private func validate() -> Bool {
        return phoneNumber.count > 5 ? true : false
       }
}

struct EnterUserName_Previews: PreviewProvider {
    static var previews: some View {
        EnterUserName()
    }
}
