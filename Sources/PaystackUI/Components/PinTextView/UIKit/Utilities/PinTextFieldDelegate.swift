//
//  AEOTPTextFieldDelegate.swift
//  AEOTPTextField-SwiftUI
//
//  Created by Abdelrhman Eliwa on 01/06/2022.
//

public protocol PinTextFieldDelegate: AnyObject {
    func didUserFinishEnter(the code: String)
}
