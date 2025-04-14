// models/WasteReport.js
const mongoose = require('mongoose');

const wasteReportSchema = new mongoose.Schema({
    wasteType: String,
    location: String,
    urgency: String,
    notes: String,
    imageUrl: String,
    latitude: Number,   // ✅ add this
    longitude: Number,  // ✅ add this
    createdAt: {
        type: Date,
        default: Date.now,
    },
});

module.exports = mongoose.model('WasteReport', wasteReportSchema);
