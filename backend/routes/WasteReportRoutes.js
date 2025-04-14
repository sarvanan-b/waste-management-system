
const express = require("express");
const router = express.Router();
const multer = require("multer");
const  Request  = require('../models/Request');
const { getUserIdByEmail } = require('../utils/utils');
const { requestImageStorage } = require('../config/cloudinaryConfig');

const upload = multer({ storage: requestImageStorage });

router.post('/submit', upload.single("image"), async (req, res) => {
    try {
        const { email, request_type, address, message } = req.body;
        const imageUrl = req.file ? req.file.path : "";

        const userId = await getUserIdByEmail(email);
        if (!userId) {
            return res.status(400).json({ message: 'User not found' });
        }

        const location = req.body.location;
        const longitude = parseFloat(location.coordinates[0]);
        const latitude = parseFloat(location.coordinates[1]);

        if (isNaN(longitude) || isNaN(latitude)) {
            return res.status(400).json({ message: 'Invalid location coordinates' });
        }

        const locationObj = {
            type: 'Point',
            coordinates: [longitude, latitude],
        };

        const newRequest = new Request({
            userId,
            request_type,
            address,
            message,
            imageUrl,
            email,
            location: locationObj,
        });

        await newRequest.save();

        res.status(201).json({ message: 'Request submitted successfully', request: newRequest });
    } catch (err) {
        console.error('Error creating request:', err);
        res.status(500).json({ message: 'Internal server error' });
    }
});

module.exports = router;
