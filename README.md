# TCA_Workshop
📍  Apple Developer Academy 2nd, TCA Workshop

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
  - How to manage the state of your application using simple value types, and share state across many screens so that mutations in one screen can be immediately observed in another screen.

- **합성(Composition)**
  - 거대한 기능을 독립된 컴포넌트로 추출하는 방법, 그리고 이들을 다시 합쳐서 기능을 구성하는 방법(모듈화)
  - How to break down large features into smaller components that can be extracted to their own, isolated modules and be easily glued back together to form the feature.

- **사이드 이펙트(Side effects)**
  - 외부 세계와의 통신을 가장 테스터블하고 이해하기 쉬운 방식으로 구현하는 방법
  - How to let certain parts of the application talk to the outside world in the most testable and understandable way possible.

- **테스트(Testing)**
  - 아키텍쳐 내부의 코드 테스트 방법과 여러 파트로 구성된 기능들의 통합 테스트를 작성하는 방법, 끝점 테스트를 작성하여 사이드 이펙트가 애플리케이션이 끼칠 영향을 이해하는 방법,
  - 이는 우리의 비즈니스 로직이 예상대로 작동할 것이라는 확신을 보장을 갖도록 한다.
  - How to not only test a feature built in the architecture, but also write integration tests for features that have been composed of many parts, and write end-to-end tests to understand how side effects influence your application. This allows you to make strong guarantees that your business logic is running in the way you expect.

- **인체공학적(Ergonomics)**
  - 가능한 한 적은 개념과 부분들의 이동을 통해 위의 모든 내용을 달성할 수 있는지에 대한 설명
  - How to accomplish all of the above in a simple API with as few concepts and moving parts as possible.

---
## 기본 개념
> 이번 워크숍의 TCA 관련 내용은 ReducerProtocol 이후의 내용을 다룹니다!
### Reducer
### State
### Action
### Effect
### Etc
- Environment
- Dependency
