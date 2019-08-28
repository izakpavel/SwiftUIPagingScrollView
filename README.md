# SwiftUIPagingScrollView
implementation of generic paging scrollView in SwiftUI since there is not such option with SwiftUI ScrollView implementation

![Example](https://github.com/izakpavel/SwiftUIPagingScrollView/blob/master/example.gif)

This is still heavily WIP but so far demonstrates the idea of using Hstack as a container and modifing the items offset based on the drag gesture

**Notes:**
* the drag gesture seems incompatible with Buttons, so to get tap on items tapGesture is used instead
* tested with XCode 11 beta 6

**Todo:**
* cleaner interface (remove tilePadding const)
* allow item modificators depending on scroll position outside of the scrollview (atm possible but needs to be written witin scrollview which sucks)
* interface for item tapping

