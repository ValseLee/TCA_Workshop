import ComposableArchitecture
import SwiftUI

struct CartFeature: Reducer {
    struct State: Equatable {
        @BindingState var isSheetDisplayed: Bool = false
        @BindingState var itemText: String = ""
        
        var cartItemArray: [CartItem] = CartItem.mockArray()
    }
    
    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case listRowSwipeToRemove(IndexSet)
        case cartButtonTapped
        case sheetCancelButtonTapped
        case sheetConfirmButtonTapped
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case let .listRowSwipeToRemove(indices):
                state.cartItemArray.remove(atOffsets: indices)
                return .none
                
            case .cartButtonTapped:
                state.isSheetDisplayed = true
                return .none
                
            case .sheetCancelButtonTapped:
                state.isSheetDisplayed = false
                state.itemText = ""
                
                return .none
                
            case .sheetConfirmButtonTapped:
                state.cartItemArray.append(CartItem(name: state.itemText))
                state.isSheetDisplayed = false
                state.itemText = ""
                
                return .none
            }
            
        }
            ._printChanges()
    }
    
}
