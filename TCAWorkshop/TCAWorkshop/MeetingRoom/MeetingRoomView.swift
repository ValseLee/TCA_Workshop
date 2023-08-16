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
                
                DatePicker(
                    // TCA의 State Binding 예시 1
                    selection: viewStore.$rentDate,
                    in: Date()...,
                    displayedComponents: .date
                ) {
                    Text("대여 희망일")
                        .bold()
                }
                .environment(\.locale, .current)
                .datePickerStyle(.compact)
                
                DatePicker(
                    selection: viewStore.$rentDate,
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
                        /// TCA의 API로 구현하는 Transition은 insertion이 제대로 되지 않는다
                        /// Issue로 제보 필요
                        Text("**대여 시간:** ") +
                        Text("**\(viewStore.state.rentHourAndMinute) 시간**")
                            .bold()
                            .monospacedDigit()
                            .foregroundColor(.green)
                        
                        Text("최대 3시간(베타는 종일 대여)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Stepper(
                        // TCA의 State Binding 예시 2
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
                
                if viewStore.state.selectedMeetingRoom.rentBy == "CURRENT_USER" {
                    primaryButtonBuilder {
                        viewStore.send(.cancelReservationButtonTapped)
                    } label: {
                        if viewStore.state.isCancelReservationButtonTapped {
                            ProgressView()
                                .tint(.primary)
                                .frame(maxWidth: .infinity)
                                .progressViewStyle(.circular)
                        } else if viewStore.state.isCancelReservationCompleted {
                            Text("예약이 취소되었습니다. ✅")
                        } else {
                            Text("예약 취소하기")
                        }
                    }
                } else if viewStore.state.selectedMeetingRoom.rentBy == "AVAILABLE" {
                    primaryButtonBuilder {
                        viewStore.send(.reservationButtonTapped)
                    } label: {
                        if viewStore.state.isReservationButtonTapped {
                            ProgressView()
                                .tint(.primary)
                                .frame(maxWidth: .infinity)
                                .progressViewStyle(.circular)
                        } else if viewStore.state.isReservationCompleted {
                            Text("예약이 완료되었습니다! 🎉")
                        } else {
                            Text("예약하기")
                        }
                    }
                } else {
                    Text(viewStore.state.selectedMeetingRoom.id.uuidString)
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
    
    // MARK: Methods
    private func primaryButtonBuilder(
        action: @escaping () -> StoreTask,
        @ViewBuilder label: () -> some View
    ) -> some View {
        Button {
            let _ = action()
        } label: {
            label()
                .makeButtonLabelWithStyle()
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle)
        .tint(.green)
    }
}

struct MeetingRoomView_Previews: PreviewProvider {
    static var previews: some View {
        MeetingRoomView(
            store: Store(
                initialState: MeetingRoomDomain.State(
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

struct ButtonLabelModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .bold()
            .foregroundColor(.primary)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .shadow(radius: 10)
    }
}

extension View {
    public func makeButtonLabelWithStyle() -> some View {
        modifier(ButtonLabelModifier())
    }
}
