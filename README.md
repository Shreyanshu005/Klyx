# Kłyx: The Ultimate Unified Developer Dashboard 🚀

Klyx is a high-performance, visually aggressive iOS application designed to track, aggregate, and visualize a developer’s true skill level. It pulls live coding statistics from **LeetCode**, **GitHub**, and **Codeforces**, computes a unified "DevScore", and displays everything in a heavy, solid-color, flat-matte aesthetic inspired by elite sports dashboards.

## 🔥 Key Features
- **Unified DevScore:** An algorithmic compilation of your Github commits, LeetCode solves, and Codeforces rating into a single master tier.
- **Aggressive "Box Box" Aesthetic:** Completely customized Swift UI framework relying on heavy, un-droppable typography (`.black` weights) and intensely saturated pure solid colors. No gradients, no glass, no fluff.
- **Live Widgets Pipeline:** Contains native iOS Home Screen widgets (`DevWidget`, `StreakWidget`, `HeatmapWidget`) functioning on an App Group bridged data cache.
- **Dynamic Heatmaps:** Custom built SVG/Grid parsing to render your activity calendar directly onto your dashboard.

## 🖼️ Showcase
| | | |
|:---:|:---:|:---:|
| ![Klyx 1](https://i.ibb.co/LzQGb0tc/IMG-4075.jpg) | ![Klyx 2](https://i.ibb.co/S7H0c57/IMG-4076.png) | ![Klyx 3](https://i.ibb.co/RTSHHpvd/IMG-4077.png) |
| ![Klyx 4](https://i.ibb.co/mFdyXvH9/IMG-4078.png) | ![Klyx 5](https://i.ibb.co/WpMD7fBR/IMG-4080.png) | ![Klyx 6](https://i.ibb.co/8qxRTNJ/IMG-4084.png) |
| ![Klyx 7](https://i.ibb.co/Pzr4GSrM/IMG-4083.png) | ![Klyx 8](https://i.ibb.co/qYpVcTpy/IMG-4082.png) | ![Klyx 9](https://i.ibb.co/FkLLYpbr/IMG-4081.png) |

## 🏗️ Architecture & Data Flow 

Klyx utilizes a modernized MVVM architecture with strict, protocol-bound Service layers hitting high-throughput API Endpoints concurrently via Swift `async/await`.

```mermaid
graph TD
    %% Styling
    classDef ui fill:#FF2323,stroke:#fff,stroke-width:2px,color:#fff,font-weight:bold
    classDef model fill:#E0FF00,stroke:#000,stroke-width:2px,color:#000
    classDef service fill:#303CFF,stroke:#fff,stroke-width:2px,color:#fff
    classDef api fill:#00D166,stroke:#000,stroke-width:2px,color:#000
    classDef storage fill:#101010,stroke:#fff,stroke-width:2px,color:#fff

    subgraph User Interface
        Dashboard[DashboardView]:::ui
        Widgets[iOS Home Widgets]:::ui
    end

    subgraph ViewModels
        DashVM[DashboardViewModel]:::model
    end

    subgraph Service Layer
        Calc[ScoreCalculator]:::service
        LC[LeetCode Service]:::service
        GH[GitHub Service]:::service
        CF[Codeforces Service]:::service
    end

    subgraph Core Networking
        Client[APIClient]:::api
    end

    subgraph Persistence Layer
        Data[SwiftData Local Store]:::storage
        Cache[CacheManager + AppGroup]:::storage
        Key[KeychainManager]:::storage
    end

    %% Flow
    Dashboard -- triggers refresh --> DashVM
    DashVM -- executes concurrently --> Calc
    
    Calc --> LC
    Calc --> GH
    Calc --> CF

    LC --> Client
    GH --> Client
    CF --> Client

    Client -- REST / GraphQL --> ExternalAPIs((External APIs))

    DashVM -- fetches tokens --> Key
    Dashboard -- reads profiles --> Data

    Calc -- persists DevScore data --> Cache
    Cache -- WidgetKit Reload --> Widgets
```

## 🛠️ Project Structure
```text
Klyx/
├── Core/
│   ├── Auth/           # Keychain token preservation
│   ├── Config/         # Global endpoints / secrets
│   ├── Models/         # Codable targets for external APIs
│   ├── Networking/     # Central APIClient and URL Request dispatchers
│   └── Persistence/    # SwiftData Store and App Group UserDefault caches
├── Features/
│   ├── Dashboard/      # Main landing grid
│   ├── Competitive/    # LeetCode / Codeforces views
│   ├── GitHub/         # GitHub views
│   ├── Profile/        # Setup and Settings
│   └── Services/       # Business logic for platform parsing
├── Shared/
│   ├── Components/     # Base UI Elements (BentoCards, StatCards)
│   └── Theme/          # AppColors (The core palette)
└── KlyxWidget/         # Dedicated Target for Apple WidgetKit UI
```

## ⚠️ Building The App
To correctly compile Klyx and see the Home Screen Widgets functioning:
1. Open `Klyx.xcodeproj` in Xcode.
2. Select the `Klyx` target and navigate to **Signing & Capabilities**.
3. Ensure **App Groups** is enabled with `group.appminds.klyxx` selected.
4. Select the `KlyxWidgetExtension` target and ensure it possesses the exact same App Group.
5. If you do not enable the App Group, Sandbox restrictions will deliberately prevent the widgets from reading the DevScore.
6. **Tokens:** To populate the GitHub Heatmap, ensure you input a valid GitHub PAT (Personal Access Token) in the `ProfileSetupView`.
