# Lego Storage App MVP Plan

This plan outlines the steps to build a Minimum Viable Product (MVP) for a Lego storage app using Swift and SwiftData for iOS. The app will manage 5-10 bins with QR codes, support basic search, and store instruction links locally. The goal is a functional prototype for organizing Lego sets and loose pieces.

## Step 1: Project Setup
- Add dependencies via Swift Package Manager:
  - QR code scanning: `code-scanner` (https://github.com/twostraws/CodeScanner).
  - QR code generation: `QRCode` (https://github.com/dagronf/QRCode).
- Configure SwiftData model:
  - Create a `Bin` model with properties:
    - `id`: String (UUID for QR code).
    - `type`: String (e.g., "Set" or "Loose").
    - `description`: String (e.g., "Millennium Falcon #75192" or "2x4 Bricks").
    - `instructionLink`: String? (URL or empty for loose pieces).
    - `createdAt`: Date (for sorting).
  - Example schema:

```swift
@Model
class Bin {
    @Attribute(.unique) var id: String
    var type: String
    var description: String
    var instructionLink: String?
    var createdAt: Date
    
    init(id: String = UUID().uuidString, type: String, description: String, instructionLink: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.type = type
        self.description = description
        self.instructionLink = instructionLink
        self.createdAt = createdAt
    }
}
```

- Set up the model container in `LegoStorageApp.swift`:

```swift
import SwiftUI
import SwiftData

@main
struct LegoStorageApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Bin.self)
    }
}
```

## Step 2: Basic UI Structure
**Objective**: Build a SwiftUI interface with navigation and core views.

- Create `ContentView.swift` as the main view:
  - Use a `TabView` with two tabs: "Inventory" and "Scan".
  - Inventory tab: List of bins.
  - Scan tab: QR code scanner.
- Implement `InventoryView.swift`:
  - Fetch bins using `@Query`:

```swift
@Query(sort: \Bin.createdAt, order: .reverse) private var bins: [Bin]
```

- Display bins in a `List` with `NavigationLink` to a detail view.
- Add a "+" button to create new bins.
- Implement `ScanView.swift`:
  - Integrate `CodeScannerView` from `code-scanner`.
  - On scan, query SwiftData for a bin with matching `id` and navigate to its detail view.
- Create `BinDetailView.swift`:
  - Show bin details (`type`, `description`, `instructionLink`).
  - If `instructionLink` exists, add a button to open it in Safari.
- Create `AddBinView.swift`:
  - Form with fields: type (picker: "Set" or "Loose"), description, instruction link (optional).
  - Generate a QR code for the bin’s `id` using `QRCode` library.
  - Save to SwiftData.

## Step 3: SwiftData Integration
**Objective**: Enable CRUD operations for bins.

- In `AddBinView`:
  - Save new bins to SwiftData:

```swift
@Environment(\.modelContext) private var modelContext
func saveBin(type: String, description: String, instructionLink: String?) {
    let bin = Bin(type: type, description: description, instructionLink: instructionLink)
    modelContext.insert(bin)
}
```

- In `BinDetailView`:
  - Allow editing/deleting bins:

```swift
func deleteBin(_ bin: Bin) {
    modelContext.delete(bin)
}
```

- In `InventoryView`:
  - Ensure `@Query` updates the list dynamically.
- Test persistence:
  - Add a few bins (e.g., "Set: X-Wing #75301", "Loose: 2x4 Bricks").
  - Close and reopen the app to verify data persists.

## Step 4: QR Code Functionality
**Objective**: Implement QR code scanning and generation.

- In `ScanView`:
  - Use `CodeScannerView` to scan QR codes:

```swift
import CodeScanner

struct ScanView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var isShowingScanner = false
    
    var body: some View {
        Button("Scan QR Code") {
            isShowingScanner = true
        }
        .sheet(isPresented: $isShowingScanner) {
            CodeScannerView(codeTypes: [.qr]) { result in
                if case let .success(code) = result {
                    handleScan(code.string)
                    isShowingScanner = false
                }
            }
        }
    }
    
    private func handleScan(_ code: String) {
        // Query SwiftData for bin with matching id
        let fetchDescriptor = FetchDescriptor<Bin>(predicate: #Predicate { $0.id == code })
        if let bin = try? modelContext.fetch(fetchDescriptor).first {
            // Navigate to BinDetailView
        }
    }
}
```

- In `AddBinView`:
  - Generate QR code for new bins:

```swift
import QRCode

func generateQRCode(for id: String) -> UIImage? {
    let qr = QRCode(id)
    return qr.image()
}
```

- Display QR code in the form and allow saving as an image for printing.
- Test QR flow:
  - Create a bin, generate its QR code, print it (or display on another device).
  - Scan with the app to verify it loads the correct bin.

## Step 5: Search Functionality
**Objective**: Add basic search to filter bins.

- In `InventoryView`:
  - Add a `searchable` modifier:

```swift
struct InventoryView: View {
    @Query private var bins: [Bin]
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredBins) { bin in
                    NavigationLink(bin.description, destination: BinDetailView(bin: bin))
                }
            }
            .navigationTitle("Inventory")
            .searchable(text: $searchText)
        }
    }
    
    private var filteredBins: [Bin] {
        if searchText.isEmpty {
            return bins
        }
        return bins.filter { $0.description.lowercased().contains(searchText.lowercased()) || $0.type.lowercased().contains(searchText.lowercased()) }
    }
}
```

- Test search:
  - Add 5-10 bins (mix of sets and loose pieces).
  - Search for terms like “Falcon” or “Loose” to verify filtering.

## Step 6: Instruction Links
**Objective**: Handle instruction links for Lego sets.

- In `AddBinView`:
  - Validate URLs in the instruction link field (e.g., ensure it starts with "https").
- In `BinDetailView`:
  - Display a clickable button for valid links:

```swift
if let link = bin.instructionLink, let url = URL(string: link) {
    Link("View Instructions", destination: url)
}
```

## Notes
- **Edge Cases**:
  - Handle invalid QR scans (show an alert).
  - Validate URLs before saving.
  - Cap description length to avoid UI overflow (\~100 chars).
- **Testing Data**: I am organizing my own collection, so I will use my own data for testing.