const User = require('../models/User'); // Import your User model

// Function to get the userId by email
const getUserIdByEmail = async (email) => {
    try {
        // Find the user by email
        const user = await User.findOne({ email: email });

        if (user) {
            // Return the userId if user is found
            return user._id;
        } else {
            // Return null if user is not found
            return null;
        }
    } catch (err) {
        console.error("Error fetching user:", err);
        return null;
    }
};

// Export the function so it can be used in other files
module.exports = { getUserIdByEmail };
