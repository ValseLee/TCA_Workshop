//
//  MeetingRoomView.swift
//  TCAWorkshop
//
//  Created by Celan on 2023/08/11.
//

import ComposableArchitecture
import SwiftUI

struct MeetingRoomView: View {
    let store: StoreOf<MeetingRoomDomain>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
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
                
                DatePicker(
                    // TCA의 State Binding 예시
                    selection: viewStore.binding(
                        get: { $0.rentDate },
                        send: { .rentDatePicked($0) }
                    ),
                    in: Date()...,
                    displayedComponents: .date
                ) {
                    Text("대여 희망일")
                        .bold()
                }
                .environment(\.locale, .current)
                .datePickerStyle(.compact)
                
                DatePicker(
                    selection: viewStore.binding(
                        get: { $0.rentDate },
                        send: { .rentDatePicked($0) }
                    ),
                    in: Date()...,
                    displayedComponents: .hourAndMinute
                ) {
                    Text("대여 시작 시간")
                        .bold()
                }
                .environment(\.locale, .current)
                .datePickerStyle(.graphical)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("대여 시간")
                            .bold()
                        
                        Text("최대 3시간(베타는 종일 대여)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    /// TCA의 API로 구현하는 Transition은 insertion이 제대로 되지 않는다
                    /// Issue로 제보 필요
                    Text("**\(viewStore.state.rentHourAndMinute) 시간**")
                        .monospacedDigit()
                    
                    Spacer()
                    
                    Stepper(
                        value: viewStore.binding(
                            get: { $0.rentHourAndMinute },
                            send: { .rentHourAndMinutePicked($0) }
                        ),
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
                    viewStore.send(.reservationButtonTapped)
                } label: {
                    if viewStore.state.isReservationButtonTapped {
                        ProgressView()
                            .tint(.primary)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .progressViewStyle(.circular)
                        
                    } else if viewStore.state.isReservationCompleted {
                        Text("예약이 완료되었습니다! 🎉")
                            .bold()
                            .foregroundColor(.primary)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .shadow(radius: 10)
                        
                    } else {
                        Text("예약하기")
                            .bold()
                            .foregroundColor(.primary)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .shadow(radius: 10)
                    }
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle)
                .tint(.green)
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

struct MeetingRoomView_Previews: PreviewProvider {
    static var previews: some View {
        MeetingRoomView(
            store: Store(
                initialState: MeetingRoomDomain.State(
                    rentLearnerName: "CURRENT_USER",
                    rentDate: .now,
                    id: .init(),
                    selectedMeetingRoom: MeetingRoom.testInstance()
                ), reducer: {
                    MeetingRoomDomain()
                }
            )
        )
    }
}
