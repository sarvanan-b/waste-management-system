const mongoose = require("mongoose");

const UserSchema = new mongoose.Schema({
    name: String,
    email: { type: String, unique: true },
    password: String,
    phone: String,
    address: String,
    profileImage: String, // path to uploaded image (e.g., /uploads/image.jpg)
});

module.exports = mongoose.model("User", UserSchema);
