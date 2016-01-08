/*
   Copyright 2016 Ryuichi Saito, LLC

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

import source
import ast

extension Parser {
    /*
    type →
    - [ ] array-type |
    - [ ] dictionary-type |
    - [ ] function-type |
    - [x] type-identifier |
    - [ ] tuple-type |
    - [ ] optional-type |
    - [ ] implicitly-unwrapped-optional-type |
    - [ ] protocol-composition-type |
    - [ ] metatype-type
    */
    func parseType() throws -> Type {
        let result = parseType(currentToken, tokens: reversedTokens.map { $0.0 })

        guard let type = result.type else {
            throw ParserError.InternalError // TODO: better error handling
        }

        for _ in 0..<result.advancedBy {
            shiftToken()
        }

        return type
    }

    private func parseType(head: Token?, tokens: [Token]) -> (type: Type?, advancedBy: Int) {
        let typeIdentifierResult = parseTypeIdentifier(head, tokens: tokens)
        if let typeIdentifier = typeIdentifierResult.typeIdentifier {
            return (typeIdentifier, typeIdentifierResult.advancedBy)
        }

        return (nil, 0)
    }

    /*
    - [_] type-identifier → type-name generic-argument-clause/opt/ | type-name generic-argument-clause/opt/ `.` type-identifier
    - [x] type-name → identifier
    */
    func parseTypeIdentifier() throws -> TypeIdentifier {
        let result = parseTypeIdentifier(currentToken, tokens: reversedTokens.map { $0.0 })

        guard let typeIdentifier = result.typeIdentifier else {
            throw ParserError.MissingIdentifier
        }

        for _ in 0..<result.advancedBy {
            shiftToken()
        }

        return typeIdentifier
    }

    private func parseTypeIdentifier(head: Token?, tokens: [Token]) -> (typeIdentifier: TypeIdentifier?, advancedBy: Int) {
        var remainingTokens = tokens
        var remainingHeadToken: Token? = head

        guard let typeName = readIdentifier(includeContextualKeywords: true, forToken: remainingHeadToken) else {
            return (nil, 0)
        }
        remainingTokens = skipWhitespacesForTokens(remainingTokens)
        remainingHeadToken = remainingTokens.popLast()

        var names = [String]()
        names.append(typeName)

        while let token = remainingHeadToken {
            if case let .Punctuator(type) = token where type == .Period {
                remainingTokens = skipWhitespacesForTokens(remainingTokens)
                remainingHeadToken = remainingTokens.popLast()
                if let subTypeName = readIdentifier(includeContextualKeywords: true, forToken: remainingHeadToken) {
                    names.append(subTypeName)
                    remainingTokens = skipWhitespacesForTokens(remainingTokens)
                    remainingHeadToken = remainingTokens.popLast()

                    continue
                }
            }
            break
        }

        return (TypeIdentifier(names: names), tokens.count - remainingTokens.count)
    }

    /*
    - [x] type-inheritance-clause → : class-requirement , type-inheritance-list
    - [x] type-inheritance-clause → : class-requirement
    - [x] type-inheritance-clause → : type-inheritance-list
    - [x] type-inheritance-list → type-identifier | type-identifier , type-inheritance-list
    - [x] class-requirement → class
    */
    func parseTypeInheritanceClause() throws -> TypeInheritanceClause {
        guard let token = currentToken, case let .Punctuator(punctuatorType) = token where punctuatorType == .Colon else {
            return []
        }
        skipWhitespaces()

        guard let typeIdentifier = parseEachTypeInheritance() else {
            throw ParserError.MissingIdentifier
        }

        var list = TypeInheritanceClause()
        list.append(typeIdentifier)

        while let token = currentToken {
            if case let .Punctuator(type) = token where type == .Comma {
                skipWhitespaces()
                if let typeIdentifier = parseEachTypeInheritance() {
                    list.append(typeIdentifier)
                    //skipWhitespaces()
                    continue
                }
            }
            break
        }

        return list
    }

    private func parseEachTypeInheritance() -> String? {
        if let token = currentToken, case let .Keyword(keywordName, _) = token where keywordName == "class" {
            skipWhitespaces()
            return "class"
        }
        else if let typeIdentifier = try? parseTypeIdentifier() {
            return typeIdentifier.names.joinWithSeparator(".")
        }
        else {
            return nil
        }
    }
}
