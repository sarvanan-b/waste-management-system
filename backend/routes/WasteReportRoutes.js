const express = require("express");
const multer = require("multer");
const WasteReport = require("../models/WasteReport");
const router = express.Router();

// Multer config
const storage = multer.diskStorage({
    destination: (req, file, cb) => cb(null, "uploads/waste_reports/"),
    filename: (req, file, cb) => cb(null, Date.now() + "-" + file.originalname),
});
const upload = multer({ storage });

// POST route - submit report
router.post("/submit", upload.single("image"), async (req, res) => {
    try {
        const { wasteType, location, urgency, notes } = req.body;
        const latitude = parseFloat(req.body.latitude);   // ✅ Parse safely
        const longitude = parseFloat(req.body.longitude); 
        const imageUrl = req.file ? req.file.path : "";

        const newReport = new WasteReport({
            wasteType,
            location,
            urgency,
            notes,
            latitude,
            longitude,
            imageUrl: req.file ? req.file.path : null,
        });

        await newReport.save();
        res.status(201).json({ message: "Waste report submitted successfully" });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: "Something went wrong" });
    }
});

module.exports = router;
