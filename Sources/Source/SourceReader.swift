/*
   Copyright 2016 Ryuichi Laboratories and the Yanagiba project contributors

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

import Foundation
import Bocho

public struct SourceReader {
  static public func read(at path: String) throws -> SourceFile {
    let absolutePath = path.absolutePath
    guard let content = try? absolutePath.readFile() else {
      throw SourceError.cannotReadFile(absolutePath)
    }
    return SourceFile(path: absolutePath, content: content)
  }
}

fileprivate extension String {
  func readFile() throws -> String {
    return try String(contentsOfFile: self, encoding: .utf8)
  }
}
