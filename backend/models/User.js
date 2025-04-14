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

// const userSchema = new mongoose.Schema({
//     name: { type: String, required: true },
//     number: { type: String, required: true },
//     email: { type: String, required: true, unique: true },
//     address: { type: String, required: true },
//     password: { type: String, required: true }
// }, { timestamps: true });

// userSchema.pre("save", async function (next) {
//     if (!this.isModified("password")) return next();
//     const salt = await bcrypt.genSalt(10);
//     this.password = await bcrypt.hash(this.password, salt);
//     next();
// });

// const User = mongoose.model("User", userSchema);

