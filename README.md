# HornsTraffic (UT App)

> 🚧 _Work in Progress_ 🚧  
> This project is an iOS + Node.js/MongoDB app to display live graphs for how busy the two main university gyms are at The University of Texas at Austin (Gregory Gym & Recreational Center); It can be reused for other facilities or for other campuses as well. The admin staff can update the current head-count, and the mobile client will plot it in real time (with a fallback synthetic point if no update arrives after a set interval). A model is currently being developed to optimize this fallback and offer predictions on "business" which will be incorporated into the app in the near future.

**HornsTraffic** is an independent, student-led project. It is not sponsored, endorsed, or officially associated with The University of Texas at Austin
---
```bash
## 📂 Repository Structure
.
├── server.js # Express server & API routes
├── models/ # Mongoose schemas (User, DataPoint)
├── .env # env vars: MONGO_URI, JWT_SECRET
├── package.json # Node dependencies & scripts
└── iOS-App/ # SwiftUI iOS application
├── UT app.xcodeproj
├── Views/
├── ViewModels/
├── Models/
├── Services/
└── Assets.xcassets

```
---

## 🔧 Backend Setup (Node.js + MongoDB)

1. **Clone** this repo and `cd` into it:
   ```bash
   git clone https://github.com/your-username/gym-busy-api.git
   cd gym-busy-api
   ```
Install dependencies:
```bash
npm install
```
Create a .env file in the root with:
```bash
MONGO_URI=<your MongoDB connection string>
JWT_SECRET=<your JWT secret>
```
(Optional) Register your admin user once:
```bash
curl -X POST https://<your-domain>/api/register \
  -H "Content-Type: application/json" \
  -d '{"username":"master","password":"changeme"}'
```
Run the server locally:
```bash
npm start
```
---
```
API Endpoints

POST /api/login → { username, password } → returns { token }

GET /api/data?gym=<Gregory|Rec> → returns array of { _id, gym, count, timestamp } (+ synthetic fallback)

POST /api/data (auth) → { gym, count } → pushes new DataPoint
```
📱 iOS Client Setup (SwiftUI)
Open Xcode 15 (or later)

Open the workspace/project at iOS-App/UT app.xcodeproj

Set the API.base URL in Constants.swift (or Networking.swift) to your server’s URL:
```swift
struct API {
  static let base = "https://<your-domain>/api"
}
```
Build & run on Simulator or device (iOS 16+).

Use the Profile tab to log in as your admin, set the current count, and then switch to Home → tap a gym → see the chart update.

⚓️ Completed Features: 

1. SwiftUI + Apple Charts integration

2. Token-based admin authentication (JWT)

3. Live-fetch + auto-refresh every 15 minutes

4. Synthetic “fallback” point auto-plotted if no update arrives in time

5. Tab bar with Home, Feedback, Profile/Admin screens

---
🛠 In Progress / Roadmap

 1. Persist admin sessions & secure storage
 
 2. Deploy backend to Render (or similar) for 24/7 uptime
 
 3. Add unit tests & UI tests for critical flows
 
 4. Implement real-time WebSocket push updates
 
 5. Add Feedback form & backend endpoint
 
 6. Polish UI: loading states, error handling, dark mode
 
 7. Animate chart transitions & custom styling
 
 8. Optimize network caching / offline mode

 ---
<img width="291" alt="Screenshot 2025-07-07 at 10 45 55 PM" src="https://github.com/user-attachments/assets/6892ca4c-ec44-4432-93c1-425964775a22" />
<img width="340" height="571" alt="Screenshot 2025-10-18 at 11 19 03 PM" src="https://github.com/user-attachments/assets/f76e625b-d3ab-481d-8872-ab94c9a61d28" />

<!-- <img width="284" alt="Screenshot 2025-07-07 at 10 47 07 PM" src="https://github.com/user-attachments/assets/ef26e383-33d0-4fce-91c2-62a9ed7f53eb" /> -->

 
