# activatica
web api for activatica.org Независимое русскоязычное медиа: новости, истории, акции, дайджесты о сопротивлении войне, диктатуре и репрессиям.
# main
```swift
import Foundation
import activatica

let activatica = Activatica()

do {
    let searchSuggest = try await activatica.getSearchSuggest(q: "Свобода")
    print(searchSuggest)
} catch {
    print("Error: \(error)")
}
```

# Launch (your script)
```
swift run
```
