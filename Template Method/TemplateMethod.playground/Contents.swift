import Foundation

// MARK: - Data models

// MARK: Validation error model

/// Type of error possible to appear during validation.
enum ValidationError {
    case isEmpty
    case tooShort
    case tooLong
    case missingNumber
    case missingLowercase
    case missingUppercase
    case forbiddenCharacter
}

// MARK: Input data model

/// General input data model.
protocol InputData {

    /// Id of input field.
    var fieldId: String { get }

    /// Data input.
    var input: String { get }
}

// MARK: Optional input data model

/// Optional input data model.
struct OptionalInputData: InputData {

    // - SeeAlso: ``InputData/fieldId``
    let fieldId: String

    // - SeeAlso: ``InputData/input``
    let input: String
}

// MARK: Mandatory input data model

/// Mandatory input data model.
struct MandatoryInputData: InputData {

    // - SeeAlso: ``InputData/fieldId``
    let fieldId: String

    // - SeeAlso: ``InputData/input``
    let input: String

    /// Possible issues encountered during input validation.
    let issues: [ValidationError]

    /// If input is valid.
    var isValid: Bool { issues.isEmpty }
}

// MARK: Result of validation process model

/// Result of validation processing.
struct ProcessResult {

    /// If whole form is valid.
    let isValid: Bool

    /// Original set of processed input data.
    let inputData: [InputData]

    /// Which fields were invalid and why.
    let invalidFields: [(String, [ValidationError])]
}

// MARK: - Form validation template protocol

/// Protocol defining possible validation steps.
protocol FormValidationTemplate {

    /// Model of partially processed mandatory input data.
    typealias MandatoryProcessResult = (isValid: Bool, invalidFields: [(fieldId: String, [ValidationError])])

    // MARK: Process steps

    /// Retrieves form input data.
    /// - Returns: input data from a form ready to process.
    func getInputData() -> [InputData]

    /// Extracts mandatory input data.
    /// - Parameters:
    ///    - inputData: input data to filter.
    /// - Returns: only mandatory input data models.
    func retrieveMandatoryInputData(from inputData: [InputData]) -> [MandatoryInputData]

    /// Extracts optional input data.
    /// - Parameters:
    ///    - inputData: input data to filter.
    /// - Returns: only optional input data models.
    func retrieveOptionalInputData(from inputData: [InputData]) -> [OptionalInputData]

    /// Processes result of mandatory input validation.
    /// - Parameters:
    ///    - mandatoryInputData: mandatory input data to filter.
    /// - Returns: identification data of problematic input models.
    func processMandatoryInputData(_ mandatoryInputData: [MandatoryInputData]) -> MandatoryProcessResult

    /// Maps partial processing data to final result.
    /// - Parameters:
    ///    - inputData: original set of processed input data.
    ///    - processedMandatoryInputData: result of mandatory input data filtering.
    /// - Returns: object containing result of validation processing.
    func mapToResult(_ inputData: [InputData], processedMandatoryInputData: MandatoryProcessResult) -> ProcessResult

    // MARK: Process method

    /// Main template method.
    /// - Returns: input data processing result.
    func process() -> ProcessResult
}

// MARK: Process method implementation

/// Template method implementation.
extension FormValidationTemplate {

    // - SeeAlso: ``FormValidationTemplate/process()``
    func process() -> ProcessResult {
        let inputData = getInputData()
        let mandatoryInputData = retrieveMandatoryInputData(from: inputData)
        let optionalInputData = retrieveOptionalInputData(from: inputData)
        let processedMandatoryInputData = processMandatoryInputData(mandatoryInputData)
        let result = mapToResult(inputData, processedMandatoryInputData: processedMandatoryInputData)
        return result
    }
}

// MARK: - Default form validation class

/// Simple implementation of form validation processing template.
final class DefaultFormValidationTemplate {

    /// Array of input data models.
    private var inputData: [InputData] = []

    /// Sets input data.
    /// - Parameters:
    ///    - inputData: input data to process.
    func setInputData(_ inputData: [InputData]) {
        self.inputData = inputData
    }

    /// Updates single input data model.
    /// - Parameters:
    ///    - singleInputData: input data to replace with.
    func updateInputData(of singleInputData: InputData) {
        if let index = inputData.firstIndex(where: { $0.fieldId == singleInputData.fieldId }) {
            inputData[index] = singleInputData
        } else {
            inputData.append(singleInputData)
        }
    }

    /// Removes single input data model.
    /// - Parameters:
    ///    - fieldId: id of input data to remove from processing set.
    func removeInputData(of fieldId: String) {
        inputData.removeAll(where: { $0.fieldId == fieldId })
    }
}

// MARK: DefaultFormValidationTemplate + FormValidationTemplate

extension DefaultFormValidationTemplate: FormValidationTemplate {

    // - SeeAlso: ``FormValidationTemplate/getInputData()``
    func getInputData() -> [InputData] {
        inputData
    }

    // - SeeAlso: ``FormValidationTemplate/retrieveMandatoryInputData(from:)``
    func retrieveMandatoryInputData(from inputData: [InputData]) -> [MandatoryInputData] {
        inputData.compactMap { $0 as? MandatoryInputData }
    }

    // - SeeAlso: ``FormValidationTemplate/retrieveOptionalInputData(from:)``
    func retrieveOptionalInputData(from inputData: [InputData]) -> [OptionalInputData] {
        inputData.compactMap { $0 as? OptionalInputData }
    }

    // - SeeAlso: ``FormValidationTemplate/processMandatoryInputData(_:)``
    func processMandatoryInputData(_ mandatoryInputData: [MandatoryInputData]) -> MandatoryProcessResult {
        let invalidMandatoryInputData = mandatoryInputData.filter { !$0.isValid }
        let isValid = invalidMandatoryInputData.isEmpty
        let invalidResult = invalidMandatoryInputData.map { ($0.fieldId, $0.issues) }
        return MandatoryProcessResult(isValid: isValid, invalidFields: invalidResult)
    }

    // - SeeAlso: ``FormValidationTemplate/mapToResult(_:, processedMandatoryInputData:)``
    func mapToResult(_ inputData: [InputData], processedMandatoryInputData: MandatoryProcessResult) -> ProcessResult {
        ProcessResult(
            isValid: processedMandatoryInputData.isValid,
            inputData: inputData,
            invalidFields: processedMandatoryInputData.invalidFields
        )
    }
}
