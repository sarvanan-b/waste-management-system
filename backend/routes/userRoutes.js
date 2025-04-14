const express = require("express");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const User = require("../models/User");
const router = express.Router();
const SECRET_KEY = "your_jwt_secret"; 
const multer = require('multer');
const uploadProfile = require("../middleware/uploadProfile");
const authenticateUser = require("../middleware/authMiddleware");
const { requestImageStorage } = require('../config/cloudinaryConfig');
const upload = require('../config/multerConfig');

// REGISTER
router.post("/register", async (req, res) => {
    try {
        const { name, email, password } = req.body;

        // Check if email exists
        let user = await User.findOne({ email });
        if (user) return res.status(400).json({ msg: "User already exists" });

        // Hash password
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        user = new User({ name, email, password: hashedPassword });
        await user.save();

        res.json({ msg: "User registered successfully!" });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// LOGIN
router.post("/login", async (req, res) => {
    try {
        const { email, password } = req.body;

        const user = await User.findOne({ email });
        if (!user) return res.status(400).json({ msg: "User not found" });

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) return res.status(400).json({ msg: "Invalid credentials" });

        const token = jwt.sign({ id: user._id }, SECRET_KEY, { expiresIn: "1h" });

        res.json({ token, user: { id: user._id, name: user.name, email: user.email } });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});


// const storage = multer.diskStorage({
//     destination: function (req, file, cb) {
//         cb(null, 'uploads/profile_pics/');
//     },
//     filename: function (req, file, cb) {
//         cb(null, Date.now() + '-' + file.originalname);
//     },
// });
// const upload = multer({ storage: storage });



// PUT /api/user/profile/:email
// router.put('/profile', upload.single('profileImage'), async (req, res) => {
//     try {
//         const { name, phone, address,email } = req.body;
//         // const profileImage = req.file ? `/uploads/profile_pics/${req.file.filename}` : undefined;
//         const imageUrl = req.file ? req.file.path : "";
//         const updateData = { name, phone, address };
//         if (profileImage) updateData.profileImage = profileImage;

//         const updatedUser = await User.findOneAndUpdate(
//             { email: email },
//             { $set: updateData },
//             { new: true }
//         );

//         if (!updatedUser) {
//             return res.status(404).json({ success: false, message: "User not found" });
//         }

//         res.json({ success: true, user: updatedUser });
//     } catch (error) {
//         console.error(error);
//         res.status(500).json({ success: false, message: "Something went wrong" });
//     }
// });
router.put('/profile', upload.single('profileImage'), async (req, res) => {
    try {
        const { name, phone, address, email } = req.body;
        const profileImage = req.file?.path;

        const updateData = { name, phone, address };
        if (profileImage) updateData.profileImage = profileImage;

        const updatedUser = await User.findOneAndUpdate(
            { email },
            { $set: updateData },
            { new: true }
        );

        if (!updatedUser) {
            return res.status(404).json({ success: false, message: "User not found" });
        }

        res.json({ success: true, user: updatedUser });
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: "Something went wrong" });
    }
});

// Route to get user profile data by email
router.get('/get_profile', async (req, res) => {
    const { email } = req.query;  // Get email from query parameter

    if (!email) {
        return res.status(400).json({ message: 'Email is required' });
    }

    try {
        // Find user by email in the database
        const user = await User.findOne({ email: email });

        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        // Return the user profile data
        res.status(200).json({
            name: user.name,
            email: user.email,
            phone: user.phone,
            address: user.address,
            profileImage: user.profileImage,  // Assuming the profile image URL is stored in user.profileImage
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
});
module.exports = router;

