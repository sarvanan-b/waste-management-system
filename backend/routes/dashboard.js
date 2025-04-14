const express = require("express");
const router = express.Router();
const Request = require("../models/Request"); // Adjust path if needed
const User = require("../models/User"); // Assuming you have a User model

// Route: GET /api/dashboard/user/email
router.get("/user/email", async (req, res) => {
    try {
        const { email } = req.query;  // Use req.query to access query parameters

        if (!email) {
            return res.status(400).json({ error: "Email is required" });
        }

        const user = await User.findOne({ email });

        if (!user) {
            return res.status(404).json({ error: "User not found" });
        }

        // Update the query to use the correct field `userId`
        const totalReports = await Request.countDocuments({ userId: user._id });
        const pending = await Request.countDocuments({ userId: user._id, status: "pending" });
        const recycled = await Request.countDocuments({ userId: user._id, status: "resolved" });

        // Check if urgencyLevel exists in your model before querying
        const alerts = await Request.countDocuments({ userId: user._id, urgencyLevel: "High" });

        res.json({ totalReports, pending, recycled, alerts });
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ error: "Server error" });
    }
});


// Route: GET /api/reports?email=abc@example.com&type=pending
router.get("/reports", async (req, res) => {
    try {
        const { email, type } = req.query;

        if (!email || !type) {
            return res.status(400).json({ error: "Email and type are required" });
        }

        const user = await User.findOne({ email });

        if (!user) {
            return res.status(404).json({ error: "User not found" });
        }

        // Base query
        let query = { userId: user._id };

        // Add condition based on type
        if (type === "pending" || type === "resolved" || type === "rejected") {
            query.status = type;
        } else if (type === "alerts") {
            query.urgencyLevel = "High";
        }

        const reports = await Request.find(query).sort({ createdAt: -1 });
        res.json(reports);
    } catch (err) {
        console.error("Error fetching reports:", err.message);
        res.status(500).json({ error: "Server error" });
    }
});

module.exports = router;
