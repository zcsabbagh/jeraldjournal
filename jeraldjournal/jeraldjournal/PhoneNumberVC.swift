//
//  PhoneNumberVC.swift
//  jeraldjournal
//
//  Created by cqlsys on 18/11/23.
//

import SwiftUI

struct PhoneNumberVC: View {
    @State private var showWelcomeView = false
    @State var phoneNumber: String = ""
    @State private var isValid = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var body: some View {
        NavigationView {
            ZStack() {
                VStack() {
                    Group {
                        VStack() {
                            Spacer().frame(height: 100)
                            Image("ic_logo")
                            Spacer().frame(height: 50)
                            Text("Log In or Sign Up").foregroundColor(.white).font(Font.system(size: 25,weight: Font.Weight.bold))
                            Spacer().frame(height: 29)
                            
                            HStack() {
                                HStack() {
                                    Button{
                                        
                                    } label: {
                                        Image("ic_flag")
                                    }.frame(width: 77, height: 71)
                                }.frame(maxWidth: 77, maxHeight: 71).background(Color(red: 162 / 255, green: 160 / 255, blue: 163 / 255))
                                Spacer()
                                VStack(alignment: .leading) {
                                    Spacer().frame(height: 7)
                                    Text("Mobile Number").foregroundColor(.black).font(Font.system(size: 15)) .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    TextField("", text: $phoneNumber)
                                        .onChange(of: phoneNumber, perform: { newValue in
                                            if !phoneNumber.isEmpty {
                                                phoneNumber = phoneNumber.formatPhoneNumber()
                                            }
                                            
                                            
                                        })
                                        .keyboardType(.numberPad).font(Font.system(size: 25,weight: Font.Weight.bold))
                                    
                                    
                                    
                                    
                                    
                                    Spacer()
                                }
                            }.frame(maxWidth: .infinity, maxHeight: 71).background(Color.white).cornerRadius(10).padding(30)
                            
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
        
    }
    
    var buttonColor: Color {
        return phoneNumber.count == 14 ? Color(red: 54 / 255, green: 157 / 255, blue: 122 / 255) : .gray
       }
    
    private func validate() -> Bool {
        return phoneNumber.count == 14 ? true : false
       }
}

struct PhoneNumberVC_Previews: PreviewProvider {
    static var previews: some View {
        PhoneNumberVC()
    }
}


extension String {
    func formatPhoneNumber() -> String {
        let cleanNumber = components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        let mask = "(XXX) XXX-XXXX"
        
        var result = ""
        var startIndex = cleanNumber.startIndex
        var endIndex = cleanNumber.endIndex
        
        for char in mask where startIndex < endIndex {
            if char == "X" {
                result.append(cleanNumber[startIndex])
                startIndex = cleanNumber.index(after: startIndex)
            } else {
                result.append(char)
            }
        }
        
        return result
    }
}
