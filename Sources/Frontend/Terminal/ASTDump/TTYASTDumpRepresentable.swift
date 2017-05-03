/*
   Copyright 2017 Ryuichi Saito, LLC and the Yanagiba project contributors

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

import Source
import AST

protocol TTYASTDumpRepresentable {
  var ttyDump: String { get }

  func dump(_ nodeType: String, _ sourceRange: SourceRange) -> String
  func dump(_ exprs: ExpressionList) -> String
  func dump(_ funcResult: FunctionResult) -> String
  func dump(_ condition: Condition) -> String
  func dump(_ conditionList: ConditionList) -> String
}

extension TTYASTDumpRepresentable {
  func dump(_ nodeType: String, _ sourceRange: SourceRange) -> String {
    return nodeType.colored(with: .magenta) + " " +
      "<range: \(sourceRange.ttyDescription)>".colored(with: .yellow)
  }

  func dump(_ exprs: ExpressionList) -> String {
    return exprs.enumerated()
      .map { "\($0): \($1.ttyDump)" }
      .joined(separator: "\n")
  }

  func dump(_ funcResult: FunctionResult) -> String {
    let typeDump = "return_type: `\(funcResult.type.textDescription)`"
    if funcResult.attributes.isEmpty {
      return typeDump
    }
    return "\(typeDump) with attributes `\(funcResult.attributes.textDescription)`"
  }

  func dump(_ conditions: ConditionList) -> String {
    return "conditions:\n" + conditions.enumerated()
      .map { "\($0): \(dump($1))" }
      .joined(separator: "\n")
  }

  func dump(_ condition: Condition) -> String {
    switch condition {
    case .expression(let expr):
      return "kind: `expression`\n" + expr.ttyDump.indent
    case .availability(let availabilityCondition):
      return availabilityCondition.textDescription // TODO: postpone to `if` statement
    case let .case(pattern, expr):
      return "case \(pattern) = \(expr)" // TODO: postpone to `if` statement
    case let .let(pattern, expr):
      return "let \(pattern) = \(expr)" // TODO: postpone to `if` statement
    case let .var(pattern, expr):
      return "var \(pattern) = \(expr)" // TODO: postpone to `if` statement
    }
  }
}
