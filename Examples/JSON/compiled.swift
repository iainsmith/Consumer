// Parser function generated by the Consumer compiler
func parseJSON3(_ input: String) throws -> Any? {
    indirect enum _Match {
        case token(String, Range<String.Index>)
        case node(String?, [_Match])
    }

    struct _Error: Swift.Error, CustomStringConvertible {
        var string: String
        var description: String { return string }
    }

    let input = input.unicodeScalars
    var index = input.startIndex

    var bestIndex = input.startIndex
    var expected: String?

    func _transform(_ match: _Match) throws -> Any? {
        do {
            switch match {
            case let .token(string, _):
                return string
            case let .node(name, matches):
                let values = try Array(matches.flatMap(_transform))
                return try name.map { JSONLabel(rawValue: $0)! }.map { try jsonTransform($0, values) } ?? values
            }
        } catch let error as _Error {
            throw error
        } catch {
            var match = match
            while case let .node(_, matches) = match, !matches.isEmpty {
                match = matches[0]
            }
            if case let .token(_, range) = match {
                throw _Error(string: "\(error) at \(_indexToOffset(range.lowerBound))")
            }
            throw _Error(string: "\(error)")
        }
    }
    func _tokenAtIndex(_ index: String.Index) -> String {
        var remaining = input[index...]
        var token = ""
        let whitespace = " \t\n\r".unicodeScalars
        if let first = remaining.first, whitespace.contains(first) {
            token = String(first)
        } else {
            while let char = remaining.popFirst(),
                !whitespace.contains(char) {
                token.append(Character(char))
            }
        }
        return token.isEmpty ? "" : " '\(token)'"
    }
    func _string5() -> _Match? { return _label("string", _sequence2()) }
    func _string(_ string: String) -> _Match? {
        let startIndex = index
        return _skipString(string) ? .token(string, startIndex ..< index) : nil
    }
    func _skipString(_ string: String) -> Bool {
        let scalars = string.unicodeScalars
        var newIndex = index
        for c in scalars {
            guard newIndex < input.endIndex, input[newIndex] == c else {
                return false
            }
            newIndex = input.index(after: newIndex)
        }
        index = newIndex
        return true
    }
    func _skipSequence4() -> Bool {
        _ = _skipCharacter([45 ... 45])
        guard _skipCharacter([48 ... 48]) || _skipSequence3() else { return false }
        _ = _skipSequence2()
        _ = _skipSequence()
        return true
    }
    func _skipSequence3() -> Bool {
        guard _skipCharacter([49 ... 57]) else { return false }
        _ = _skipCharacters3()
        return true
    }
    func _skipSequence2() -> Bool {
        let startIndex = index
        guard
            _skipAppend(_skipCharacter([46 ... 46]), "'.'"),
            _skipAppend3()
        else {
            index = startIndex
            return false
        }
        return true
    }
    func _skipSequence() -> Bool {
        let startIndex = index
        guard
            _skipAppend(_skipCharacter([69 ... 69, 101 ... 101]), "'E' or 'e'"),
            (_skipCharacter([43 ... 43, 45 ... 45]) || true),
            _skipAppend3()
        else {
            index = startIndex
            return false
        }
        return true
    }
    func _skipOptional() -> Bool { return (_skipCharacters([9 ... 10, 13 ... 13, 32 ... 32]) || true) }
    func _skipCharacters3() -> Bool { return _skipCharacters([48 ... 57]) }
    func _skipCharacters(_ ranges: [CountableClosedRange<UInt32>], inverted: Bool = false) -> Bool {
        let startIndex = index
        while _skipCharacter(ranges, inverted: inverted) {}
        return index > startIndex
    }
    func _skipCharacter(_ ranges: [CountableClosedRange<UInt32>], inverted: Bool = false) -> Bool {
        if index >= input.endIndex { return false }
        let value = input[index].value
        for range in ranges {
            if range.lowerBound > value { break }
            if range.upperBound >= value {
                if inverted { return false }
                index = input.index(after: index)
                return true
            }
        }
        if inverted {
            index = input.index(after: index)
            return true
        }
        return inverted
    }
    func _skipAppend5() -> Bool { return _skipAppend(_skipCharacter([34 ... 34]), "'\"'") }
    func _skipAppend3() -> Bool { return _skipAppend(_skipCharacters3(), "'0' – '9'") }
    func _skipAppend10() -> Bool { return _skipAppend(_skipCharacter([44 ... 44]), "','") }
    func _skipAppend(_ match: Bool, _ _expected: String) -> Bool {
        if !match {
            if index >= bestIndex {
                bestIndex = index
                expected = _expected
            }
            return false
        }
        return true
    }
    func _sequence9() -> _Match? {
        let startIndex = index
        var matches = [_Match]()
        guard
            _skipAppend(_skipCharacter([91 ... 91]), "'['"),
            _append((_sequence8() ?? .node(nil, []) as _Match?), &matches, "json"),
            _skipAppend(_skipCharacter([93 ... 93]), "']'")
        else {
            index = startIndex
            return nil
        }
        return .node(nil, matches)
    }
    func _sequence8() -> _Match? {
        let startIndex = index
        var matches = [_Match]()
        guard
            _append((_oneOrMore3() ?? .node(nil, []) as _Match?), &matches, "json"),
            _append6(&matches)
        else {
            index = startIndex
            return nil
        }
        return .node(nil, matches)
    }
    func _sequence7() -> _Match? {
        let startIndex = index
        var matches = [_Match]()
        guard
            _append6(&matches),
            _skipAppend10()
        else {
            index = startIndex
            return nil
        }
        return .node(nil, matches)
    }
    func _sequence6() -> _Match? {
        let startIndex = index
        var matches = [_Match]()
        guard
            _skipAppend(_skipCharacter([123 ... 123]), "'{'"),
            _append((_sequence5() ?? .node(nil, []) as _Match?), &matches, "keyValue"),
            _skipAppend(_skipCharacter([125 ... 125]), "'}'")
        else {
            index = startIndex
            return nil
        }
        return .node(nil, matches)
    }
    func _sequence5() -> _Match? {
        let startIndex = index
        var matches = [_Match]()
        guard
            _append((_oneOrMore2() ?? .node(nil, []) as _Match?), &matches, "keyValue"),
            _append7(&matches)
        else {
            index = startIndex
            return nil
        }
        return .node(nil, matches)
    }
    func _sequence4() -> _Match? {
        let startIndex = index
        var matches = [_Match]()
        guard
            _append7(&matches),
            _skipAppend10()
        else {
            index = startIndex
            return nil
        }
        return .node(nil, matches)
    }
    func _sequence3() -> _Match? {
        let startIndex = index
        var matches = [_Match]()
        guard
            _skipOptional(),
            _append(_string5(), &matches, "string"),
            _skipOptional(),
            _skipAppend(_skipCharacter([58 ... 58]), "':'"),
            _append6(&matches)
        else {
            index = startIndex
            return nil
        }
        return .node(nil, matches)
    }
    func _sequence2() -> _Match? {
        let startIndex = index
        var matches = [_Match]()
        guard
            _skipAppend5(),
            _append((_oneOrMore() ?? .node(nil, []) as _Match?), &matches, "'\\' or '\"' or '\\'"),
            _skipAppend5()
        else {
            index = startIndex
            return nil
        }
        return .node(nil, matches)
    }
    func _sequence10() -> _Match? {
        let startIndex = index
        var matches = [_Match]()
        guard
            _skipOptional(),
            _append(_any5(), &matches, "boolean, null, number, string, object or array"),
            _skipOptional()
        else {
            index = startIndex
            return nil
        }
        return .node(nil, matches)
    }
    func _sequence() -> _Match? {
        let startIndex = index
        var matches = [_Match]()
        guard
            _skipAppend(_skipCharacter([92 ... 92]), "'\\'"),
            _append(_any3(), &matches, "'\"', '\\', '/', 'b', 'f', 'n', 'r', 't' or unichar")
        else {
            index = startIndex
            return nil
        }
        return .node(nil, matches)
    }
    func _replace5() -> _Match? {
        let startIndex = index
        return _skipCharacter([116 ... 116]) ? .token("\t", startIndex ..< index) : nil
    }
    func _replace4() -> _Match? {
        let startIndex = index
        return _skipCharacter([114 ... 114]) ? .token("\r", startIndex ..< index) : nil
    }
    func _replace3() -> _Match? {
        let startIndex = index
        return _skipCharacter([110 ... 110]) ? .token("\n", startIndex ..< index) : nil
    }
    func _replace2() -> _Match? {
        let startIndex = index
        return _skipCharacter([102 ... 102]) ? .token("\u{C}", startIndex ..< index) : nil
    }
    func _replace() -> _Match? {
        let startIndex = index
        return _skipCharacter([98 ... 98]) ? .token("\u{8}", startIndex ..< index) : nil
    }
    func _oneOrMore3() -> _Match? {
        var matches = [_Match]()
        var matched = false
        var lastIndex = index
        while _append2(_sequence7(), &matches) {
            if index == lastIndex {
                return .node(nil, matches)
            }
            lastIndex = index
            matched = true
        }
        return matched ? .node(nil, matches) : nil
    }
    func _oneOrMore2() -> _Match? {
        var matches = [_Match]()
        var matched = false
        var lastIndex = index
        while _append2(_sequence4(), &matches) {
            if index == lastIndex {
                return .node(nil, matches)
            }
            lastIndex = index
            matched = true
        }
        return matched ? .node(nil, matches) : nil
    }
    func _oneOrMore() -> _Match? {
        var matches = [_Match]()
        var matched = false
        var lastIndex = index
        while _append2(_sequence() ?? _flatten6(), &matches) {
            if index == lastIndex {
                return .node(nil, matches)
            }
            lastIndex = index
            matched = true
        }
        return matched ? .node(nil, matches) : nil
    }
    func _label(_ name: String, _ match: _Match?) -> _Match? {
        return match.map { match in
            switch match {
            case let .node(_name, matches):
                return .node(name, _name == nil ? matches : [match])
            default:
                return .node(name, [match])
            }
        }
    }
    func _json() -> _Match? { return _label("json", _sequence10()) }
    func _indexToOffset(_ index: String.Index) -> String {
        var line = 1
        var column = 1
        var wasReturn = false
        for c in input[..<index] {
            switch c {
            case "\n" where wasReturn:
                continue
            case "\r", "\n":
                line += 1
                column = 1
            default:
                column += 1
            }
            wasReturn = (c == "\r")
        }
        return "\(line):\(column)"
    }
    func _flattenSequence() -> String? {
        let startIndex = index
        var result = ""
        guard
            _skipAppend(_skipCharacter([117 ... 117]), "'u'"),
            _appendString2(&result),
            _appendString2(&result),
            _appendString2(&result),
            _appendString2(&result)
        else {
            index = startIndex
            return nil
        }
        return result
    }
    func _flatten6() -> _Match? {
        let startIndex = index
        return _flatten5().map { _Match.token($0, startIndex ..< index) }
    }
    func _flatten5() -> String? {
        let startIndex = index
        return _skipCharacters([34 ... 34, 92 ... 92], inverted: true) ? String(input[startIndex ..< index]) : nil
    }
    func _flatten4() -> _Match? {
        let startIndex = index
        return _flattenSequence().map { _Match.token($0, startIndex ..< index) }
    }
    func _flatten3() -> String? {
        let startIndex = index
        return _skipCharacter([48 ... 57, 65 ... 70, 97 ... 102]) ? String(input[startIndex ..< index]) : nil
    }
    func _flatten2() -> _Match? {
        let startIndex = index
        return _flatten().map { _Match.token($0, startIndex ..< index) }
    }
    func _flatten() -> String? {
        let startIndex = index
        return _skipSequence4() ? String(input[startIndex ..< index]) : nil
    }
    func _character(_ ranges: [CountableClosedRange<UInt32>], inverted: Bool = false) -> String? {
        let startIndex = index
        return _skipCharacter(ranges, inverted: inverted) ? String(input[startIndex]) : nil
    }
    func _appendString2(_ result: inout String) -> Bool { return _appendString(_flatten3(), &result, "'0' – '9', 'A' – 'F' or 'a' – 'f'") }
    func _appendString(_ match: String?, _ result: inout String, _ _expected: String) -> Bool {
        if let match = match {
            result += match
            return true
        } else {
            if index >= bestIndex {
                bestIndex = index
                expected = _expected
            }
            return false
        }
    }
    func _append7(_ matches: inout [_Match]) -> Bool { return _append(_label("keyValue", _sequence3()), &matches, "keyValue") }
    func _append6(_ matches: inout [_Match]) -> Bool { return _append(_json(), &matches, "json") }
    func _append2(_ match: _Match?, _ matches: inout [_Match]) -> Bool {
        if let match = match {
            switch match {
            case let .node(name, _matches):
                if name != nil {
                    fallthrough
                }
                matches += _matches
            case .token:
                matches.append(match)
            }
            return true
        } else {
            return false
        }
    }
    func _append(_ match: _Match?, _ matches: inout [_Match], _ _expected: String) -> Bool {
        if let match = match {
            switch match {
            case let .node(name, _matches):
                if name != nil {
                    fallthrough
                }
                matches += _matches
            case .token:
                matches.append(match)
            }
            return true
        } else {
            if index >= bestIndex {
                bestIndex = index
                expected = _expected
            }
            return false
        }
    }
    func _any5() -> _Match? {
        if let match = _label("boolean", _string("true") ?? _string("false")) ?? _label("null", _string("null")) ?? _label("number", _flatten2()) ?? _string5() { return match }
        if let match = _label("object", _sequence6()) ?? _label("array", _sequence9()) { return match }
        return nil
    }
    func _any3() -> _Match? {
        if let match = (_character([34 ... 34]).map { _Match.token($0, input.index(before: index) ..< index) }) ?? (_character([92 ... 92]).map { _Match.token($0, input.index(before: index) ..< index) }) ?? (_character([47 ... 47]).map { _Match.token($0, input.index(before: index) ..< index) }) ?? _replace() { return match }
        if let match = _replace2() ?? _replace3() ?? _replace4() ?? _replace5() { return match }
        if let match = _label("unichar", _flatten4()) { return match }
        return nil
    }
    if let match = _json() {
        if index < input.endIndex {
            let index = max(index, bestIndex)
            let token = _tokenAtIndex(index)
            throw _Error(string: "Unexpected token\(token) at \(_indexToOffset(index))")
        }
        return try _transform(match)
    } else {
        let token = _tokenAtIndex(bestIndex)
        let expected = expected ?? "json"
        throw _Error(string: "Unexpected token\(token) at \(_indexToOffset(bestIndex)) (expected \(expected))")
    }
}