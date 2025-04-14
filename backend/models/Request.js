// models/Request.js
const mongoose = require('mongoose');

// Request Schema
const requestSchema = new mongoose.Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
    adminId: { type: mongoose.Schema.Types.ObjectId, ref: "Admin", default: null },
    assignedDriverId: { type: mongoose.Schema.Types.ObjectId, ref: "Driver", default: null },
    address: { type: String, required: true },
    request_type: { type: String, required: true },
    message: { type: String },
    email: { type: String },
    imageUrl: String,
    status: {
        type: String,
        enum: ["pending", "resolved", "rejected"],
        default: "pending"
    },
    time: { type: Date, default: Date.now },
    location: {
        type: {
            type: String,
            enum: ['Point'],
            default: 'Point'
        },
        coordinates: {
            type: [Number], // [longitude, latitude]
            required: true
        }
    }
}, { timestamps: true });

requestSchema.index({ location: "2dsphere" });

const Request = mongoose.model("Request", requestSchema);

// Export the Request model
module.exports = Request;
