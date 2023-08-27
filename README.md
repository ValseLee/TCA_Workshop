# TCA_Workshop
📍  Apple Developer Academy 2nd, TCA Workshop
> Workshop Version Infos: <br>
> 본 워크숍 문서는 공시된 하단의 버전을 바탕으로 작성되었으며, 해당 버전에서 최적화되어 있습니다. <br>
> \- Swift 5.7.1 +, Deploy iOS 16.2, Xcode 14.2, TCA 1.0.0 <br>

---
## Architecture?
#### 아키텍쳐를 쓰는 이유?
  - 각 기능의 각 책임이 어디에 어떻게 존재하는지 명확히 알 수 있다.
  - 객체간 책임을 잘 분리하여 더 쉽게 테스트를 진행할 수 있다.
  - 프로젝트가 긴 기간동안 유지 가능하도록 할 수 있다(코드의 일관성을 가져갈 수 있다).
  - 약속된 규칙으로 기능을 디자인할 수 있다.

#### 꼭 써야 하나?
  - 테스트도 하지 않고, 각 기능의 책임을 분리하기 복잡하지도 않다면?
  - 특정 아키텍쳐의 기반 코드를 작성하고 적용할 만큼 큰 단위의 프로젝트가 아니라면?
  - 아키텍쳐를 적용하는 것보다 적용하지 않을 때 더 빠르게 프로젝트를 마무리할 수 있다면?

#### 간단히 살펴보는 iOS 아키텍쳐들
![Architectures_Workshop](https://github.com/ValseLee/TCA_Workshop/assets/82270058/8c841f7b-8f76-493a-9bfc-edb0a5bd3182)
- 출처: ByteByteGo
---
## The Composable Architecture
#### 소개
- Composable Architecture는 다양한 목적과 복잡성을 가진 애플리케이션을 설계할 때 도움을 주는 라이브러리 입니다. 아래의 방법들을 통해 애플리케이션을 빌드할 때 마주치는 일상적인 문제들을 해결할 때 도움을 줄 수 있습니다.

- **상태 관리(State management)**
  - 단순한 '값 타입'을 활용해서 애플리케이션의 상태를 관리하는 방법, 한 화면에서의 상태 변화를 다른 화면에서 곧바로 관찰할 수 있는 방법
  > How to manage the state of your application using simple value types, and share state across many screens so that mutations in one screen can be immediately observed in another screen.

- **합성(Composition)**
  - 거대한 기능을 독립된 컴포넌트로 추출하는 방법, 그리고 이들을 다시 합쳐서 기능을 구성하는 방법(모듈화)
  > How to break down large features into smaller components that can be extracted to their own, isolated modules and be easily glued back together to form the feature.

- **사이드 이펙트(Side effects)**
  - 외부 세계와의 통신을 가장 테스터블하고 이해하기 쉬운 방식으로 구현하는 방법
  > How to let certain parts of the application talk to the outside world in the most testable and understandable way possible.

- **테스트(Testing)**
  - 아키텍쳐 내부의 코드 테스트 방법과 여러 파트로 구성된 기능들의 통합 테스트를 작성하는 방법, 끝점 테스트를 작성하여 사이드 이펙트가 애플리케이션이 끼칠 영향을 이해하는 방법,
  - 이는 우리의 비즈니스 로직이 예상대로 작동할 것이라는 확신을 보장을 갖도록 한다.
  > How to not only test a feature built in the architecture, but also write integration tests for features that have been composed of many parts, and write end-to-end tests to understand how side effects influence your application. This allows you to make strong guarantees that your business logic is running in the way you expect.

- **인체공학적(Ergonomics)**
  - 가능한 한 적은 개념과 부분들의 이동을 통해 위의 모든 내용을 달성할 수 있는지에 대한 설명
  > How to accomplish all of the above in a simple API with as few concepts and moving parts as possible.

- 영어 원문 출처: [pointfree 공식 레포지토리](https://github.com/pointfreeco/swift-composable-architecture/blob/main/README.md)

---
## The Composable Architecture 기본 개념
> 하단의 장단점은 글쓴이의 **개인적인 견해**이며, SwiftUI 를 기준으로 작성되었습니다. <br>
> 영어 원문의 출처는 [**ComposableArchitecture 공식 문서**](https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/) 및 [**Pointfree.co Collection**](https://www.pointfree.co/collections)에서 발췌하였습니다.

### 장점
- 작은 단위의 기능을 설계하고 큰 단위의 기능에 합치기가 쉽다.
    - Scalable하고 Composable한 프로젝트를 설계할 수 있다.
- 각 기능이 유기적으로 맞물리지만 테스트는 독립적으로 실행할 수 있다.
- 객체 간 데이터 및 기능의 공유를 `Reducer` 단위에서 쉽게 구현할 수 있다.
    - 하나의 Global Store가 Domain Store를 가질 수 있다.
    - 부모-자식 간 `State` 구조체를 `.forEach()`, `.ifLet()` 등의 메소드로 안정적인 상태 공유 가능

### 단점
- TCA의 유연한 사용을 위해 이해해야 하는 특정 타입과 메소드가 분명하기 때문에 일정 수준 이상의 숙련도를 요구한다.
    - `IdentfiedArrayOf<Array<Element>>`, `.forEach(_:action:element)` 등의 API에 대한 기본적인 이해 필요
- SwiftUI의 기본 API 대신 TCA의 API를 활용하는 것이 대부분의 상황에서 강제된다.
    - `@State`는 값 타입인 `State` 구조체에 래핑되고, 뷰에 직접 바인딩하기 위해선 viewStore를 `WithViewStore` 등으로 접근하는 `@BindingState` 를 활용해야 한다는 점
    - `WithViewStore` 자체가 복잡한 뷰를 래핑할 경우, 컴파일러 자체의 연산을 느리게 할 수 있다는 단점 또한 존재
- 컴파일러의 자동 완성이 아직 완전하지 않다.
    - `Reducer` 클로저 내부에서 `state`에 대한 타입 추론이 제대로 되지 않는 경우 등 존재
- App의 Action Flow 및 Data Flow에 대한 이해가 선행되어야 코드를 작성할 수 있다.
    - 각 화면의 기능과 데이터 전달, 기능의 공유를 바탕으로 모듈화와 합성(compose)이 이루어지기 때문

---
### 데이터 플로우
- **Composable Architecture**는 여타 다른 클라이언트 아키텍쳐와 같이 단방향 플로우를 지향한다.
- `MVVM`이나 `MVC` 처럼 특정 역할을 수행하는 객체로 아키텍쳐를 구성하는 형태가 아닌, 각 기능의 상태와 액션을 관리하는 domain store의 집합 혹은 global store로 아키텍쳐를 구성한다.
    - (검토 필요)
- 기본적으로 값 타입(struct, enum)을 활용하여 State의 흐름을 제어한다.
    - 속도의 이점, 세밀한 컨트롤, 변형(mutation)에 대한 보장 등을 근거로 들 수 있다.
    ➡️ [관련 영상](https://www.pointfree.co/collections/composable-architecture/reducers-and-stores/ep68-composable-state-management-reducers)
    - 값 타입의 capture를 통해 각 변형 단계에서의 State를 비교할 수 있기 때문에 테스트와 State의 흐름을 파악할 때 편리하다.
    - 값 타입의 변형에 대해 `inout`을 제안한다.
- ![데이터 플로우 이미지가 위치할 자리]

### Reducer
- 애플리케이션의 현 상태를 주어진 action을 바탕으로 어떻게 다음 상태로 바꿀 것인지를 묘사하는 프로토콜이자, 어떤 결과(Effect)가 존재한다면 store를 통해 어떻게 실행되어야 하는지를 설명하는 프로토콜이다.
    > A protocol that describes how to evolve the current state of an application to the next state, given an action, and describes what Effects should be executed later by the store, if any.
- 애플리케이션의 상태(State)를 함수형으로, 알아보기 쉽게 작성할 수 없을까? 라는 고민으로 고안된 개념
- 클라이언트의 입장에서 유저의 상호작용에 따라 상태를 변형(mutate)할 수 있도록 돕는 프로토콜
- `Reducer` 프로토콜을 채택하는 인스턴스(대체로 `store`가 역할을 수행)는 하나의 기능을 대변하는 상태(`State`)와 액션(`Action`)을 갖는다.
- `Feature Reducer`는 `reduce(into:action:)` 메소드 혹은 `ReducerOf<SomeType: Reducer>`를 리턴하는 계산 속성`body`를 갖는다.
    - 전자의 경우, Domain Feature Store에 해당하는 하나의 Reducer를 가지며, 후자의 경우, Global Feature Store가 다른 Domain Reducer 인스턴스를 combine 할 수 있다. 즉, 여러 개의 Reducer를 가질 수 있다.
    - `Reducer`를 채택하는 인스턴스는 `Store`의 생성자에서 초기화한다.
- `reduce(into:action:)` 혹은 `body`의 클로저 내에서 상태와 액션을 처리한다.
```Swift
struct AFeature: Reducer {
    /// Reducer 프로토콜은 State와 Action을 요구한다.
    /// 이 둘을 활용하여 어떤 비즈니스 로직을 가질 것인지
    /// body 혹은 func reduce(into:action)에서 구체화한다.
    /// 각각 프로토콜을 채택한 타입의 State와 Action을 클로저의 아규먼트로 전달한다.
    struct State: Equatable { /* code */ }
    enum Action: Equatable { /* code */ }
    
    var body: some ReducerOf<AStore> {
        Reduce { state, action in }
    }
}
```
---
#### `func reduce(into:action:)`와 `body`
- `reduce(into:action:)`은 인스턴스의 상태와 액션을 아규먼트로 받아서 이를 `Effect` 타입으로 반환한다.
- 단일한 `Effect` 타입의 리턴을 통해 애플리케이션 전체의 일관성을 높일 수 있다.
    - 상태에 대한 리턴이 아닌 액션에 대한 리턴으로서, 해당 액션이 그 다음에 어떤 액션을 수행하는지를 정의한다.
- `body`는 계산 속성 클로저 내부에 전달되는 모든 리듀서를 순차적으로 실행하고, 이들을 하나로 merge하는 프로퍼티래퍼, `@ReducerBuilder`로 정의되어 있다.
    - `body`는 여러 단위의 리듀서를 합성할 때 주로 활용된다.
```swift
func reduce(
    into state: inout Self.State,
    action: Self.Action
) -> Effect<Self.Action>

@ReducerBuilder<Self.State, Self.Action> var body: Self.Body { get }

```
---
### Store
- 앱의 런타임 동안 `Reducer` 인스턴스를 관리하는 참조 타입의 `class` 객체이다.
    - View 혹은 다른 Effect에서 파생된 Action에 따라 State를 처리하고, 사이드 이펙트를 실행하고 다시 시스템으로 되돌리는 등의 책임을 갖는다.
    > It is the thing that is responsible for actually mutating the feature’s state when actions are sent, executing the side effects, and feeding their data back into the system.
- 각각의 기능을 관리하는 `Store`를 하위 뷰로 전달하기 위해 `scope(state:action:)` 메소드를 호출할 수 있다.
    - Child Feature의 State와 Action을 상위 Feature에서 관리할 수 있다.
    - 앱 전체의 기능 중 특정 뷰에서 특정 기능만을 담당해야 할 때 주요하게 활용할 수 있다.
- `Store`는 참조 타입이며, Thread-Safe 하지 않기 때문에 각 store 인스턴스에 대한 상호작용은 main Thread에서 진행하는 것을 권장한다.
- 값 타입 State는 current State를 갖는 Reducer에서 처리되고, 다른 다수의 Thread에서 이에 접근할 수 없기 때문이다.
    - 이에 따라 `send()`는 main Thread에서 처리되어야 한다.
    - Effect의 비동기 작업이 output를 non-main Thread에서 처리할 경우에는 main Thread로 되돌리기 위해 `receive(on:)`에서 main Thread를 지정해야 한다.

```swift
struct ParentFeature: Reducer {
    /// 하위 기능을 갖는 ParentFeature는 내부에 ChilFeature가 관리하는 State와 Action 타입을 가질 수 있고,
    /// 이를 scope하여 하위 뷰에 전달할 수 있다.
    struct State: Equatable {
        var childState: ChildFeature.State
    }
    
    enum Action: Equatable {
        var childAction: ChildFeature.Action
    }
    
    var body: some ReducerOf<ParentFeature> {
        Reduce { state, action in }
    }
}
        
struct ChildFeature: Reducer {
    struct State: Equatable { /* code */ }
    enum Action: Equatable { /* code */ }
    
    var body: some ReducerOf<ChildFeature> {
        Reduce { state, action in }
    }
}
        

struct AppIntroView: View {
    /// store는 State와 Reducer를 초기화하는 것으로 생성할 수 있다.
    /// 제너릭 파라미터는 어떤 타입의 Store를 초기화할 것인지를 정의한다.
    let store: StoreOf<ParentFeature> = Store(initialState: ParentFeature.State()) {
      ParentFeature()
    }
    
    var body: some View {
        NavigationStack {
            ChildView(
                /// childView가 필요로하는 ChildFeature는 ParentFeature의 하위 기능이며,
                /// 의존성을 전달할 때에는 아래와 같은 방식으로 scope하여 전달한다.
                store: self.store.scope(
                    state: \.childState,
                    action: ParentFeature.Action.childAction
                )
            )
        }
    }
}
```
---
### State
- `Reducer`의 현 상태를 보관하는 구조체를 일컫는다.
- 비즈니스 로직과 UI 렌더링에 필요한 데이터를 갖는다.
    > A type that describes the data your feature needs to perform its logic and render its UI.
- `Reducer` 프로토콜의 요구사항이다.
- `@BindingState` 등의 프로퍼티 래퍼를 활용하여 View에서 직접 접근하고 binding할 수 있다.
    - SwiftUI의 `TextField`나 `Toggle` 등의 View에 전달할 binding을 위해 주로 사용할 수 있다.
    - 이 경우, binding된 `State` 속성에 대한 처리가 필요하며, `Action` 열거형 타입이 `BindableAction` 프로토콜을 채택하고 `Reducer`가 `BindingReducer()`를 초기화해야 한다(Effect에 대한 처리는 필요하지 않다면 수행하지 않는다).
<!--     - 가능하면 **사용하지 않는 것**을 [공식 문서](https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/bindingstate)에서 권장한다. // 이거 주장의 출처를 못찾아서 각주처리 -->
```swift
struct AFeature: Reducer {
    /// Equatable 프로토콜을 채택함으로써 View가 State의 변화를 감지할 수 있다.
    struct State: Equatable {
        var id: UUID?
        var name: String = ""
        var startDate: Date = .now
    }
    
    enum Action: Equatable { /* code */ }
    
    var body: some ReducerOf<AFeature> {
        Reduce { state, action in
            // code
        }
    }
}
```
---
### Action
- Reducer의 상태(State)를 변경하거나 외부 세계와 통신할 수 있는 사이드 이펙트를 유발할 수 있는 모든 작업을 포함하는 타입이다.
    > A type that holds all possible actions that cause the State of the reducer to change and/or kick off a side Effect that can communicate with the outside world
- 모든 작업을 나타내며, 각 작업은 열거형의 케이스로 정의된다.
    - 작업에 필요한 데이터가 `Reducer`가 아닌 뷰에서 전달된다면 열거형의 연관값으로 전달받는다.
    - 케이스의 이름은 기능이 아닌 변화에 집중하여 짓는 것이 직관적이다(예시1).
    - View에서 어떤 작업을 호출하는지 바로 이해할 수 있으며, 작업의 확장 및 수정에 따라 케이스 이름 수정을 최소화할 수 있다.
    ➡️ [관련 영상](https://www.pointfree.co/collections/tours/composable-architecture-1-0/ep243-tour-of-the-composable-architecture-1-0-the-basics)
- `Reducer` 프로토콜의 요구사항이다.

```swift
struct AFeature: Reducer {
    struct State: Equatable {
        var id: UUID?
        var name: String = ""
        var startDate: Date = .now
    }
    
    enum Action: Equatable {
        /* ✅ */ case registerButtonTapped(startDate: Date) // 예시1
        /* ❌ */ case createNewUser(startDate: Date) // 예시1
        case alertDismissed
    }
    
    var body: some ReducerOf<AFeature> {
        Reduce { state, action in
            // code
        }
    }
}
```
---
### Effect
- `Action` 타입을 제너릭으로 받는 '구조체'이다.
- 크게 4가지의 타입 속성 및 메소드를 갖고 있다.
    - `.none`: 특정 액션이 끝나고 아무런 추가 액션이 필요하지 않을 때의 리턴 값으로 활용한다.
    - `.send(_:Action)`: 특정 액션 이후, 추가적인 동기 액션이 필요할 때 리턴한다. 다만 부모-자식 간의 로직 공유의 목적으로 활용하는 것을 권장한다. 액션이 전달될 때, 여러 층의 레이어를 경유하기 때문이다.
    - `.run(priority:operation:catch:fileID:line:) -> Effect<Action>`: 비동기 작업을 리턴한다.
        - 각 핸들러 클로저에 전달되는 `Send` 구조체는 `MainActor`이며 `callAsFunction`으로 호출할 수 있다.
        - 클로저 내부에서 원칙적으로 `throw` 한 작업을 호출할 수 있으며, non-cancellation 메소드들은 catch handler로 에러에 대한 처리가 필요하다.
    - `.cancel(id:)`: 주어진 identifier를 갖는 비동기 작업을 취소한다.
    - `.cancellable(id:)`: 취소될 수 있는 비동기 작업이 되도록 identifier를 제공한다. TCA 내부의 취소 작업은 `NSRecursiveLock` 및 `Combine` 프레임워크와 연계되어 처리된다.
- `Effect`는 다른 `Effect`와의 구조화된 작업을 처리할 수 있는 메소드를 제공한다.
    - `.merge(_:)`: 하나의 `Effect`와 다른 모든 `Effect`를 동시에 처리한다. `Sequence`를 만족하는 배열도 파라미터로 전달할 수 있으며, 가변 파라미터를 받는다.
    - `.merge(with:)`: 하나의 `Effect`와 다른 `Effect`를 동시에 처리한다. 각 `Effect`가 비동기 작업 혹은 동기 작업이어도 내부 Combine 프레임워크와의 연계로 작업을 합칠 수 있다.
    - `.concatenate(_:)`: 하나의 `Effect`와 다른 모든 `Effect`가 파라미터로 전달되는 순서대로 처리한다. 가변 파라미터를 받는다.
    - `.map(_:)`: 업스트림의 `Effect` 요소를 처리할 클로저를 통해 요소들을 처리한다.
        - TODO: 예시 코드 구현해두기

```swift
struct AFeature: Reducer {
    struct State: Equatable {
        var id: UUID?
        var name: String = ""
        var startDate: Date = .now
    }
    
    enum Action: Equatable {
        case registerButtonTapped(startDate: Date)
        case filterButtonTapped
        case alertDismissed
        case doNothing
    }
    
    var body: some ReducerOf<AFeature> {
        Reduce { state, action in
            switch action {
            case let .registerButtonTapped(startDate):
                print("Do Things")
                return .run { send in
                    print("Start Now", startDate)
                    await send(.doNothing)
                }
                
            case .filterButtonTapped:
                print("Start Filter")
                return .none
                
            case .alertDismissed:
                print("Alert Dismissed")
                return .merge(.send(.doNothing))
                
            case .doNothing:
                print("Do Nothing!")
                return .none
            }
        }
    }
}
```
---
### Dependency
> 하단의 모든 내용은 [라이브러리]((https://github.com/pointfreeco/swift-dependencies))의 내용을 참고했습니다. <br>
> 관련 내용을 자세하게 다루지는 않으며, TCA에서의 간단한 활용법을 다룹니다.

- 애플리케이션이 사용하는 외부 의존성을 효율적이고 인체공학적인 방식으로 처리할 수 있도록 제안하는 Pointfree의 또 다른 라이브러리이다.
- 특히 Test 코드를 작성할 때에 자주 활용하게 되며, 각 인스턴스 간의 동일성을 보장하고 개발자가 편하게 의존성을 제어할 수 있다.
    - 10분을 기다려서 확인해야 하는 로직을 1초 내에 처리할 수 있다거나, `UUID`의 랜덤 생성을 제어할 수 있다거나 등의 장점이 있다.
    - 서버 의존성을 최소화한 테스트, Preview를 구성할 수 있다.
- TCA에서만 사용될 수 있는 라이브러리는 아니지만, TCA의 Test를 위해서는 반강제적으로 사용법을 익혀야 한다.
- `UUID`, `Date`, `Clock` 등등의 기본 Dependency가 주어지며, 원한다면 추가할 수 있다.
    - 이 경우, `DependencyValue`와 `DependencyKey`로 관리해야 하며, `Reducer` 내애서도 `Dependency`를 따라야 한다.

```swift
// DependencyValues의 확장에 커스텀한 Dependency를 보관
extension DependencyValues {
    var myDependency: MyDependencyType {
        get { self[MyDependencyKey.self] }
        set { self[MyDependencyKey.self] = newValue }
    }
}

// Dependency로 접근하여 `get`할 liveValue와 testValue를 지정
// testValue가 없으면 test 시에 에러가 발생할 수 있음
fileprivate enum MyDependencyKey: DependencyKey {
    static var liveValue: MyDependencyType = .live
    static var testValue: MyDependencyType = .test
}

// REDUCER
struct MyReducer: Reducer {
    // SwiftUI 가 제안하는 `environment`의 사용과 매우 유사
    @Dependency(\.myDependency)
    var myDependency: MyDependencyType
    
    struct State: Equatable { /* code */ }
    enum Action: Equatable { /* code */ }
    var body: some RedcuerOf<Self> { /* code */ }
}
```
---
### Testable Code
- 내용 추가 예정!
