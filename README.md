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


![Image](https://github.com/user-attachments/assets/459e4ede-b32f-498f-b0bb-f177cb4807d5)
![Image](https://github.com/user-attachments/assets/f750c0fa-5141-4512-b1ed-7313dec90dad)
![Image](https://github.com/user-attachments/assets/1b6fca88-bfc6-4418-b275-eba7edf1e1c3)
![Image](https://github.com/user-attachments/assets/8dea48f0-a14c-4a49-95e0-b5f77ccdabaf)
![Image](https://github.com/user-attachments/assets/d5467a7d-f75c-4d63-a85b-7a582b3823f7)
![Image](https://github.com/user-attachments/assets/a1bb77d4-a05b-49b0-aa34-c4a6f1e3c665)
![Image](https://github.com/user-attachments/assets/c7fd5029-fa13-456c-9e11-acba91199df9)
![Image](https://github.com/user-attachments/assets/2e10f8d0-aad6-40eb-8b6d-d2b49c6bd08c)
