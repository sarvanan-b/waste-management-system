# ♻️ TrashNet - Waste Management System

A smart and efficient Waste Management System that streamlines citizen waste reporting, request management, and waste collection route optimization using machine learning and mobile/web technologies.

---

## 📱 Tech Stack

### 🚀 Web Application (Admin/Driver Panel)
- **Frontend**: React.js + Tailwind CSS
- **Backend**: Node.js + Express.js
- **Database**: MongoDB + Mongoose

### 📱 Mobile Application (Citizen App)
- **Framework**: Flutter
- **State Management**: Provider
- **Storage**: Shared Preferences

---

## 🌟 Features

### User Module (Mobile App)
- 📸 **Waste Report Submission**: Upload images, specify location, urgency, and waste type.
- 📝 **Request Management**: Create, track, and view detailed status history.
- 📊 **Dashboard**: Visual summary of request statuses and types.

### Admin/Driver Module (Web App)
- 📍 **Route Optimization**: ML-based clustering of request locations.
- 🚛 **Driver Assignment**: Assign optimized routes to drivers.
- 🛠️ **Request Handling**: View, update, and manage citizen requests.
- ⚙️ **User Settings**: Change password, enable dark mode, toggle notifications.

---

## 📸 Screenshots

> Add screenshots of your mobile UI, dashboard, and optimized route maps here.

---

## 🛠️ Setup Instructions

### 🌐 Web App (Admin/Backend)
1. Clone the repo:
    ```bash
    git clone https://github.com/YOUR_USERNAME/waste-management-system.git
    cd waste-management-system/backend
    ```
2. Install dependencies:
    ```bash
    npm install
    ```
3. Create `.env`:
    ```
    MONGO_URI=your_mongo_connection_string
    JWT_SECRET=your_jwt_secret
    ```
4. Run server:
    ```bash
    npm run dev
    ```

---

### 📱 Mobile App (Flutter)
1. Navigate to the mobile folder:
    ```bash
    cd waste-management-system/mobile
    ```
2. Install packages:
    ```bash
    flutter pub get
    ```
3. Run app:
    ```bash
    flutter run
    ```

---

## 🤖 ML Integration
- Optimizes waste collection routes using clustering algorithms like K-Means.
- Location-based route mapping using MongoDB geospatial indexing.

---

## 👨‍💻 Contributors

- **Saravanan** - Full Stack Developer  
*(Add more contributors if needed)*

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
