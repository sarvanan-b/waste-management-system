const mongoose = require("mongoose");

const SettingsSchema = new mongoose.Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
    darkMode: { type: Boolean, default: false },
});

module.exports = mongoose.model("Settings", SettingsSchema);
    