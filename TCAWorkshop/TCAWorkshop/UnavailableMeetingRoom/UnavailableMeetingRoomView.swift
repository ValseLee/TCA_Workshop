//
//  UnavailableMeetingRoomView.swift
//  TCAWorkshop
//
//  Created by Celan on 2023/08/21.
//

import ComposableArchitecture
import SwiftUI

struct UnavailableMeetingRoomView: View {
    let store: StoreOf<UnavabilableMeetingRoomFeature>
    
    var body: some View {
        WithViewStore(
            self.store,
            observe: { $0.selectedMeetingRoom }
        ) { selectedMeetingRoom in
            VStack(spacing: 24) {
                Image(systemName: "calendar")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .padding(.vertical)
                    .overlay(alignment: .topTrailing) {
                        Image(systemName: "checkmark.circle")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .offset(x: 20)
                            .foregroundColor(.green)
                    }
                
                Divider()
                                
                HStack {
                    Text("회의실 이름")
                        .bold()
                    
                    Spacer()
                    
                    Text(selectedMeetingRoom.meetingRoomName)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background {
                            Capsule()
                                .foregroundColor(.green)
                        }
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                
                HStack {
                    Text("회의실 대여자")
                        .bold()
                    
                    Spacer()
                    
                    Text(selectedMeetingRoom.rentBy)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background {
                            Capsule()
                                .foregroundColor(.green)
                        }
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                
                DatePicker(
                    selection: .constant(selectedMeetingRoom.rentDate),
                    in: Date()...,
                    displayedComponents: .date
                ) {
                    Text("대여 희망일")
                        .bold()
                }
                .environment(\.locale, .current)
                .datePickerStyle(.compact)
                
                DatePicker(
                    selection: .constant(selectedMeetingRoom.rentDate),
                    in: Date()...,
                    displayedComponents: .hourAndMinute
                ) {
                    Text("대여 시작 시간")
                        .bold()
                }
                .environment(\.locale, .current)
                .datePickerStyle(.graphical)
                
                HStack {
                    VStack(
                        alignment: .leading,
                        spacing: 8
                    ) {
                        Text("**대여 시간:** ") +
                        Text("**\(selectedMeetingRoom.rentHourAndMinute) 시간**")
                            .bold()
                            .monospacedDigit()
                            .foregroundColor(.green)
                        
                        Text("최대 3시간(베타는 종일 대여)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Stepper(
                        value: .constant(selectedMeetingRoom.rentHourAndMinute),
                        in: 1...3
                    ) {
                        // Text("LABLES HIDDEN")
                    }
                    .labelsHidden()
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )

                Spacer()
                
                Button {
                    //
                } label: {
                    Text("크킥")
                }
            }
            .padding()
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
            )
        }
    }
}

struct UnavailableMeetingRoomView_Previews: PreviewProvider {
    static var previews: some View {
        UnavailableMeetingRoomView(
            store: Store(
                initialState: UnavabilableMeetingRoomFeature.State(
                    selectedMeetingRoom: .testInstance(),
                    id: .init(0)
                ), reducer: {
                    UnavabilableMeetingRoomFeature()
                }
            )
        )
    }
}
