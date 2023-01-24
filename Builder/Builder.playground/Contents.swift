import Foundation

// MARK: - Validation protocols

// MARK: Validator protocol

/// Validator protocol to describe validation functionality.
protocol Validator {

    /// Type of error possible to appear during validation.
    associatedtype ValidationError

    /// Validation method that returns the final result of validation.
    /// - Returns: tuple with boolean status of validation and array of possible errors encountered during validation.
    func validate() -> (isValid: Bool, errors: [ValidationError])
}

// MARK: Text validator protocol

/// Validator protocol to define validation steps possible to perform on text.
protocol TextValidator: Validator {

    /// Checks if text is not empty.
    /// - Returns: `self` for further chaining.
    func checkNotEmpty() -> Self

    /// Checks if text is long enough.
    /// - Returns: `self` for further chaining.
    func checkMinLength(_ length: Int) -> Self

    /// Checks if text is not too long.
    /// - Returns: `self` for further chaining.
    func checkMaxLength(_ length: Int) -> Self

    /// Checks if text contains numbers.
    /// - Returns: `self` for further chaining.
    func checkIfContainsNumbers() -> Self

    /// Checks if text contains uppercase letters.
    /// - Returns: `self` for further chaining.
    func checkIfContainsUppercaseLetters() -> Self

    /// Checks if text contains lowercase letters.
    /// - Returns: `self` for further chaining.
    func checkIfContainsLowercaseLetters() -> Self

    /// Checks if text doesn't contain forbidden characters.
    /// - Parameters:
    ///    - forbiddenCharacters: set of characters that shouldn't be present in text.
    /// - Returns: `self` for further chaining.
    func checkNoForbiddenCharacters(_ forbiddenCharacters: CharacterSet) -> Self
}

// MARK: - Text validator builder class

/// Text validator builder to create validator for different types of string.
final class TextValidatorBuilder {

    // MARK: Private properties

    /// Array of partial errors.
    private var errors: [ValidationError] = []

    /// Text to validate.
    private let text: String

    // MARK: Initialization

    init(text: String) {
        self.text = text
    }
}

// MARK: TextValidatorBuilder + TextValidator

extension TextValidatorBuilder: TextValidator {

    // - SeeAlso: ``TextValidator/ValidationError``
    enum ValidationError {
        case isEmpty
        case tooShort
        case tooLong
        case missingNumber
        case missingLowercase
        case missingUppercase
        case forbiddenCharacter
    }

    // - SeeAlso: ``TextValidator/validate()``
    func validate() -> (isValid: Bool, errors: [ValidationError]) {
        (isValid: errors.isEmpty, errors: errors)
    }

    // - SeeAlso: ``TextValidator/checkNotEmpty()``
    func checkNotEmpty() -> Self {
        let check = !text.isEmpty
        if !check {
            errors.append(.isEmpty)
        }
        return self
    }

    // - SeeAlso: ``TextValidator/checkMinLength(_:)``
    func checkMinLength(_ length: Int) -> Self {
        let check = text.count >= length
        if !check {
            errors.append(.tooShort)
        }
        return self
    }

    // - SeeAlso: ``TextValidator/checkMaxLength(_:)``
    func checkMaxLength(_ length: Int) -> Self {
        let check = text.count <= length
        if !check {
            errors.append(.tooLong)
        }
        return self
    }

    // - SeeAlso: ``TextValidator/checkIfContainsNumbers()``
    func checkIfContainsNumbers() -> Self {
        let check = text.first { $0.isNumber } != nil
        if !check {
            errors.append(.missingNumber)
        }
        return self
    }

    // - SeeAlso: ``TextValidator/checkIfContainsUppercaseLetters()``
    func checkIfContainsUppercaseLetters() -> Self {
        let check = text.first { $0.isUppercase } != nil
        if !check {
            errors.append(.missingUppercase)
        }
        return self
    }

    // - SeeAlso: ``TextValidator/checkIfContainsLowercaseLetters()``
    func checkIfContainsLowercaseLetters() -> Self {
        let check = text.first { $0.isLowercase } != nil
        if !check {
            errors.append(.missingLowercase)
        }
        return self
    }

    // - SeeAlso: ``TextValidator/checkNoForbiddenCharacters(_:)``
    func checkNoForbiddenCharacters(_ forbiddenCharacters: CharacterSet) -> Self {
        let check = text.rangeOfCharacter(from: forbiddenCharacters) == nil
        if !check {
            errors.append(.forbiddenCharacter)
        }
        return self
    }
}

// MARK: - Director protocols

// MARK: Text builder director protocol

/// Director protocol to describe director's relation with builders and validators.
protocol TextBuilderDirector {
    
    /// Method responsible for creating validator with given builder.
    /// - Parameters:
    ///    - builder: set of characters that shouldn't be present in text.
    /// - Returns: `Validator` for further validation result extraction.
    func create(using builder: TextValidatorBuilder) -> any Validator
}

/// Username builder director to create username validator.
final class UsernameBuilderDirector: TextBuilderDirector {

    // - SeeAlso: ``TextBuilderDirector/create(using:)``
    func create(using builder: TextValidatorBuilder) -> any Validator {
        builder
            .checkNotEmpty()
            .checkMaxLength(20)
            .checkNoForbiddenCharacters(CharacterSet(charactersIn: "()<>[]{}"))
    }
}

/// Password builder director to create password validator.
final class PasswordBuilderDirector: TextBuilderDirector {

    // - SeeAlso: ``TextBuilderDirector/create(using:)``
    func create(using builder: TextValidatorBuilder) -> any Validator {
        builder
            .checkMinLength(8)
            .checkIfContainsLowercaseLetters()
            .checkIfContainsUppercaseLetters()
            .checkIfContainsNumbers()
    }
}
