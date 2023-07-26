// swiftlint:disable large_tuple function_parameter_count
import SwiftUI

@resultBuilder
struct FormInputDataBuilder {

    static func buildBlock<C1: FormInputItemView>(_ component1: C1)
    -> FormInputData<C1> {
        return FormInputData(validators: [component1.isValid],
                             submissions: [component1.submit],
                             content: component1)
    }

    static func buildBlock<C1: FormInputItemView,
                                  C2: FormInputItemView>(_ component1: C1,
                                                         _ component2: C2)
    -> FormInputData<TupleView<(C1, C2)>> {
        return FormInputData(validators: [component1.isValid,
                                          component2.isValid],
                             submissions: [component1.submit,
                                           component2.submit],
                             content: TupleView((component1,
                                                 component2)))
    }

    static func buildBlock<C1: FormInputItemView,
                                  C2: FormInputItemView,
                                  C3: FormInputItemView>(_ component1: C1,
                                                         _ component2: C2,
                                                         _ component3: C3)
    -> FormInputData<TupleView<(C1, C2, C3)>> {
        return FormInputData(validators: [component1.isValid,
                                          component2.isValid,
                                          component3.isValid],
                             submissions: [component1.submit,
                                           component2.submit,
                                           component3.submit],
                             content: TupleView((component1,
                                                 component2,
                                                 component3)))
    }

    static func buildBlock<C1: FormInputItemView,
                                  C2: FormInputItemView,
                                  C3: FormInputItemView,
                                  C4: FormInputItemView>(_ component1: C1,
                                                         _ component2: C2,
                                                         _ component3: C3,
                                                         _ component4: C4)
    -> FormInputData<TupleView<(C1, C2, C3, C4)>> {
        return FormInputData(validators: [component1.isValid,
                                          component2.isValid,
                                          component3.isValid,
                                          component4.isValid],
                             submissions: [component1.submit,
                                           component2.submit,
                                           component3.submit,
                                           component4.submit],
                             content: TupleView((component1,
                                                 component2,
                                                 component3,
                                                 component4)))
    }

    static func buildBlock<C1: FormInputItemView,
                                  C2: FormInputItemView,
                                  C3: FormInputItemView,
                                  C4: FormInputItemView,
                                  C5: FormInputItemView>(_ component1: C1,
                                                         _ component2: C2,
                                                         _ component3: C3,
                                                         _ component4: C4,
                                                         _ component5: C5)
    -> FormInputData<TupleView<(C1, C2, C3, C4, C5)>> {
        return FormInputData(validators: [component1.isValid,
                                          component2.isValid,
                                          component3.isValid,
                                          component4.isValid,
                                          component5.isValid],
                             submissions: [component1.submit,
                                           component2.submit,
                                           component3.submit,
                                           component4.submit,
                                           component5.submit],
                             content: TupleView((component1,
                                                 component2,
                                                 component3,
                                                 component4,
                                                 component5)))
    }

    static func buildBlock<C1: FormInputItemView,
                                  C2: FormInputItemView,
                                  C3: FormInputItemView,
                                  C4: FormInputItemView,
                                  C5: FormInputItemView,
                                  C6: FormInputItemView>(_ component1: C1,
                                                         _ component2: C2,
                                                         _ component3: C3,
                                                         _ component4: C4,
                                                         _ component5: C5,
                                                         _ component6: C6)
    -> FormInputData<TupleView<(C1, C2, C3, C4, C5, C6)>> {
        return FormInputData(validators: [component1.isValid,
                                          component2.isValid,
                                          component3.isValid,
                                          component4.isValid,
                                          component5.isValid,
                                          component6.isValid],
                             submissions: [component1.submit,
                                           component2.submit,
                                           component3.submit,
                                           component4.submit,
                                           component5.submit,
                                           component6.submit],
                             content: TupleView((component1,
                                                 component2,
                                                 component3,
                                                 component4,
                                                 component5,
                                                 component6)))
    }

    static func buildIf<Content: FormInputItemView>(_ content: Content?) -> some FormInputItemView {
        return OptionalFormInputItemView(content: content)
    }

}

// swiftlint:enable large_tuple function_parameter_count
