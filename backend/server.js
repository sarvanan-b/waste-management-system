require("dotenv").config();
const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const bodyParser = require("body-parser");
const userRoutes = require("./routes/userRoutes");
const wasteReportRoutes = require("./routes/WasteReportRoutes");
const settingsRoute = require("./routes/settings");





const app = express();
// app.use(cors());
app.use(cors({
    origin: '*', // or better: origin: 'http://<your-phone-ip>:<port>'
}));
app.use(bodyParser.json());

// Connect to MongoDB
mongoose.connect(process.env.MONGO_URI, {
}).then(() => console.log("MongoDB connected"))
.catch(err => console.log(err));

// Routes
app.use("/api/users", userRoutes);
app.use("/api/settings", settingsRoute);
app.use("/api/waste", wasteReportRoutes);

const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => console.log(`Server running on port ${PORT}`));
