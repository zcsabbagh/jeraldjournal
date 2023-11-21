//
//  OTPVC.swift
//  jeraldjournal
//
//  Created by cqlsys on 18/11/23.
//

import Combine
import SwiftUI

struct OTPVC: View {
    @State private var showWelcomeView = false
    @State var phoneNumber: String = ""
    @State private var isValid = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    
    enum FocusPin {
        case  pinOne, pinTwo, pinThree, pinFour, pinFive, pinSix
    }
    
    @FocusState private var pinFocusState : FocusPin?
    @State var pinOne: String = ""
    @State var pinTwo: String = ""
    @State var pinThree: String = ""
    @State var pinFour: String = ""
    @State var pinFive: String = ""
    @State var pinSix: String = ""
    
    var body: some View {
        ZStack() {
            VStack() {
                Group {
                    VStack() {
                        Spacer().frame(height: 100)
                        Image("ic_logo")
                        Spacer().frame(height: 50)
                        Text("Incoming text🤠").foregroundColor(.white).font(Font.system(size: 25,weight: Font.Weight.bold))
                        Spacer().frame(height: 29)
                        
                        HStack() {
                            TextField("", text: $pinOne , prompt: Text("-").foregroundColor(Color.white)) .foregroundColor(.white)
                                .modifier(OtpModifer(pin:$pinOne))
                                .onChange(of:pinOne){newVal in
                                    if (newVal.count == 1) {
                                        pinFocusState = .pinTwo
                                    }
                                }
                                .focused($pinFocusState, equals: .pinOne)
                            
                            TextField("", text: $pinTwo , prompt: Text("-").foregroundColor(Color.white))
                                .foregroundColor(.white)
                                .modifier(OtpModifer(pin:$pinTwo))
                                .onChange(of:pinTwo){newVal in
                                    if (newVal.count == 1) {
                                        pinFocusState = .pinThree
                                    } else {
                                        if (newVal.count == 0) {
                                            pinFocusState = .pinOne
                                        }
                                    }
                                }
                                .focused($pinFocusState, equals: .pinTwo)
                            
                            
                            TextField("", text: $pinThree , prompt: Text("-").foregroundColor(Color.white))
                                .foregroundColor(.white)
                                .modifier(OtpModifer(pin:$pinThree))
                                .onChange(of:pinThree){newVal in
                                    if (newVal.count == 1) {
                                        pinFocusState = .pinFour
                                    } else {
                                        if (newVal.count == 0) {
                                            pinFocusState = .pinTwo
                                        }
                                    }
                                }
                                .focused($pinFocusState, equals: .pinThree)
                            
                            TextField("", text: $pinFour , prompt: Text("-").foregroundColor(Color.white))
                                .foregroundColor(.white)
                                .modifier(OtpModifer(pin:$pinFour))
                                .onChange(of:pinFour){newVal in
                                    if (newVal.count == 1) {
                                        pinFocusState = .pinFive
                                    } else {
                                        if (newVal.count == 0) {
                                            pinFocusState = .pinThree
                                        }
                                    }
                                }
                                .focused($pinFocusState, equals: .pinFour)
                            
                            TextField("", text: $pinFive , prompt: Text("-").foregroundColor(Color.white))
                                .foregroundColor(.white)
                                .modifier(OtpModifer(pin:$pinFive))
                                .onChange(of:pinFive){newVal in
                                    if (newVal.count == 1) {
                                        pinFocusState = .pinSix
                                    }  else {
                                        if (newVal.count == 0) {
                                            pinFocusState = .pinFour
                                        }
                                    }
                                }
                                .focused($pinFocusState, equals: .pinFive)
                            
                            TextField("", text: $pinSix , prompt: Text("-").foregroundColor(Color.white))
                                .foregroundColor(.white)
                                .modifier(OtpModifer(pin:$pinSix))
                                .onChange(of:pinSix){newVal in
                                    if (newVal.count == 0) {
                                        pinFocusState = .pinFive
                                    }
                                }
                                .focused($pinFocusState, equals: .pinSix)
                                
                            
                            
                        }.frame(maxWidth: .infinity, maxHeight: 50).background(Color.clear).padding(.leading, 30).padding(.trailing, 30)
                        
                        
                        HStack() {
                            VStack(){
                                
                            }.frame(maxWidth: .infinity, maxHeight: 2).background(Color.white)
                            
                            VStack(){
                                
                            }.frame(maxWidth: .infinity, maxHeight: 2).background(Color.white)
                            
                            VStack(){
                                
                            }.frame(maxWidth: .infinity, maxHeight: 2).background(Color.white)
                            
                            VStack(){
                                
                            }.frame(maxWidth: .infinity, maxHeight: 2).background(Color.white)
                            
                            VStack(){
                                
                            }.frame(maxWidth: .infinity, maxHeight: 2).background(Color.white)
                            
                            
                            VStack(){
                                
                            }.frame(maxWidth: .infinity, maxHeight: 2).background(Color.white)
                            
                        }.frame(maxWidth: .infinity, maxHeight: 2).background(Color.clear).padding(.leading, 30).padding(.trailing, 30)
                        
                    }
                    
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("SMS sent to (831) 313-6619").foregroundColor(.white).font(Font.system(size: 10)) .frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 25)
                    Text("keep and eye out for it in the box below.").foregroundColor(.white).font(Font.system(size: 10)) .frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 25)
                    
                    
                    
                }.frame(maxWidth: .infinity, maxHeight: 60).background(Color.black)
                
                
                
            }
            
            VStack(alignment: .leading) {
                Spacer()
                HStack() {
                    Spacer()
                    
                    
                    Button{
                        isValid = validate()
                        print("sssdds")
                    } label: {
                        Image("ic_arrow")
                    }.background(
                        NavigationLink(
                            destination: EnterUserName(),
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
        return validate() == true ? Color(red: 54 / 255, green: 157 / 255, blue: 122 / 255) : .gray
    }
    
    private func validate() -> Bool {
        var count = 0
        
        if pinOne.count == 1 {
            count = 1
        }
        
        if pinTwo.count == 1 {
            count = count + 1
        }
        
        if pinThree.count == 1 {
            count = count + 1
        }
        
        if pinFour.count == 1 {
            count = count + 1
        }
        
        if pinFive.count == 1 {
            count = count + 1
        }
        
        if pinSix.count == 1 {
            count = count + 1
        }
        return count == 6 ? true : false
    }
}

struct OTPVC_Previews: PreviewProvider {
    static var previews: some View {
        OTPVC()
    }
}


struct OtpModifer: ViewModifier {
    
    @Binding var pin : String
    
    var textLimt = 1
    
    func limitText(_ upper : Int) {
        if pin.count > upper {
            self.pin = String(pin.prefix(upper))
        }
    }
    
    
    //MARK -> BODY
    func body(content: Content) -> some View {
        content
            .multilineTextAlignment(.center)
            .keyboardType(.numberPad)
            .onReceive(Just(pin)) {_ in limitText(textLimt)}
            .frame(maxWidth: .infinity, maxHeight: 50)
            .background(Color.clear.cornerRadius(5))
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color("blueColor"), lineWidth: 12)
            )
    }
}
