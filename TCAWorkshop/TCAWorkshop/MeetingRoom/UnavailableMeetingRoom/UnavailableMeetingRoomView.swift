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
            observe: { $0 }
        ) { viewStore in
            VStack(spacing: 24) {
                Image(systemName: "calendar")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .padding(.vertical)
                    .overlay(alignment: .topTrailing) {
                        Image(systemName: "person.2.fill")
                            .resizable()
                            .frame(width: 75, height: 50)
                            .offset(x: 30)
                            .foregroundColor(.green)
                    }
                
                Divider()
                                
                HStack {
                    Text("회의실 이름")
                        .bold()
                    
                    Spacer()
                    
                    Text(viewStore.selectedMeetingRoom.meetingRoomName)
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
                    
                    Text(viewStore.selectedMeetingRoom.rentBy)
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
                    Text("대여 일자")
                        .bold()
                    
                    Spacer()
                    
                    Text(viewStore.dayFormatter.string(
                        from: viewStore.selectedMeetingRoom.rentDate)
                    )
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                    .background {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(Color(.systemGray5))
                    }
                }
                
                
                HStack {
                    Text("대여 시작 시간")
                        .bold()
                    
                    Spacer()
                    
                    Text(viewStore.minuteHourFormatter.string(
                        from: viewStore.selectedMeetingRoom.rentDate)
                    )
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                    .background {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(Color(.systemGray5))
                    }
                }
                
                HStack {
                    VStack(
                        alignment: .leading,
                        spacing: 4
                    ) {
                        Text("**대여 시간:** ") +
                        Text("**\(viewStore.selectedMeetingRoom.rentHourAndMinute) 시간**")
                            .bold()
                            .monospacedDigit()
                            .foregroundColor(.green)
                        
                        Text("최대 3시간(베타는 종일 대여)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Stepper(
                        value: .constant(viewStore.selectedMeetingRoom.rentHourAndMinute),
                        in: 1...3
                    ) {
                        // Text("LABLES HIDDEN")
                    }
                    .disabled(true)
                    .labelsHidden()
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )

                Spacer()
                
                Button {
                    // disabled
                } label: {
                    Text("회의실을 예약할 수 없습니다.")
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .shadow(radius: 10)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle)
                .disabled(true)
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
                    minuteHourFormatter: .init(),
                    dayFormatter: .init(),
                    selectedMeetingRoom: .testInstance(),
                    id: .init(0)
                ), reducer: {
                    UnavabilableMeetingRoomFeature()
                }
            )
        )
    }
}
