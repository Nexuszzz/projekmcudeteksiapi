/**
 * Authentication Routes for Fire Force - Fire Detection System
 * Handles user registration, login, and token verification
 */

import express from 'express';
import crypto from 'crypto';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const router = express.Router();

// Get directory path for ES modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Users data file path
const USERS_FILE = path.join(__dirname, '..', 'data', 'users.json');

// Ensure data directory exists
const dataDir = path.join(__dirname, '..', 'data');
if (!fs.existsSync(dataDir)) {
    fs.mkdirSync(dataDir, { recursive: true });
}

// Initialize users file if doesn't exist
if (!fs.existsSync(USERS_FILE)) {
    fs.writeFileSync(USERS_FILE, JSON.stringify({ users: [] }, null, 2));
}

/**
 * Load users from file
 */
function loadUsers() {
    try {
        const data = fs.readFileSync(USERS_FILE, 'utf8');
        return JSON.parse(data);
    } catch (error) {
        console.error('Error loading users:', error);
        return { users: [] };
    }
}

/**
 * Save users to file
 */
function saveUsers(data) {
    try {
        fs.writeFileSync(USERS_FILE, JSON.stringify(data, null, 2));
        return true;
    } catch (error) {
        console.error('Error saving users:', error);
        return false;
    }
}

/**
 * Hash password with salt
 */
function hashPassword(password, salt = null) {
    if (!salt) {
        salt = crypto.randomBytes(16).toString('hex');
    }
    const hash = crypto.pbkdf2Sync(password, salt, 10000, 64, 'sha512').toString('hex');
    return { hash, salt };
}

/**
 * Generate JWT-like token (simple implementation)
 */
function generateToken(user) {
    const payload = {
        id: user.id,
        username: user.username,
        exp: Date.now() + (24 * 60 * 60 * 1000) // 24 hours
    };
    const base64Payload = Buffer.from(JSON.stringify(payload)).toString('base64');
    const signature = crypto.createHmac('sha256', 'fireforce-secret-key')
        .update(base64Payload)
        .digest('hex');
    return `${base64Payload}.${signature}`;
}

/**
 * Verify token
 */
function verifyToken(token) {
    try {
        const [base64Payload, signature] = token.split('.');
        const expectedSignature = crypto.createHmac('sha256', 'fireforce-secret-key')
            .update(base64Payload)
            .digest('hex');
        
        if (signature !== expectedSignature) {
            return null;
        }
        
        const payload = JSON.parse(Buffer.from(base64Payload, 'base64').toString());
        
        if (payload.exp < Date.now()) {
            return null; // Token expired
        }
        
        return payload;
    } catch (error) {
        return null;
    }
}

/**
 * POST /api/auth/register
 * Register a new user
 */
router.post('/register', (req, res) => {
    try {
        const { fullname, username, email, password } = req.body;
        
        // Validate required fields
        if (!fullname || !username || !email || !password) {
            return res.status(400).json({
                success: false,
                error: 'All fields are required'
            });
        }
        
        // Validate email format
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            return res.status(400).json({
                success: false,
                error: 'Invalid email format'
            });
        }
        
        // Validate password length
        if (password.length < 6) {
            return res.status(400).json({
                success: false,
                error: 'Password must be at least 6 characters'
            });
        }
        
        // Validate username (alphanumeric, 3-20 chars)
        const usernameRegex = /^[a-zA-Z0-9_]{3,20}$/;
        if (!usernameRegex.test(username)) {
            return res.status(400).json({
                success: false,
                error: 'Username must be 3-20 characters (letters, numbers, underscore)'
            });
        }
        
        // Load existing users
        const data = loadUsers();
        
        // Check if username exists
        if (data.users.find(u => u.username.toLowerCase() === username.toLowerCase())) {
            return res.status(400).json({
                success: false,
                error: 'Username already exists'
            });
        }
        
        // Check if email exists
        if (data.users.find(u => u.email.toLowerCase() === email.toLowerCase())) {
            return res.status(400).json({
                success: false,
                error: 'Email already registered'
            });
        }
        
        // Hash password
        const { hash, salt } = hashPassword(password);
        
        // Create new user
        const newUser = {
            id: crypto.randomBytes(8).toString('hex'),
            fullname: fullname.trim(),
            username: username.toLowerCase().trim(),
            email: email.toLowerCase().trim(),
            passwordHash: hash,
            passwordSalt: salt,
            createdAt: new Date().toISOString(),
            role: 'user' // Default role
        };
        
        // Add to users array
        data.users.push(newUser);
        
        // Save to file
        if (!saveUsers(data)) {
            return res.status(500).json({
                success: false,
                error: 'Failed to save user data'
            });
        }
        
        console.log(`🔥 New user registered: ${username}`);
        
        res.json({
            success: true,
            message: 'Registration successful',
            user: {
                id: newUser.id,
                username: newUser.username,
                fullname: newUser.fullname,
                email: newUser.email
            }
        });
        
    } catch (error) {
        console.error('Registration error:', error);
        res.status(500).json({
            success: false,
            error: 'Server error during registration'
        });
    }
});

/**
 * POST /api/auth/login
 * Authenticate user and return token
 */
router.post('/login', (req, res) => {
    try {
        const { username, password } = req.body;
        
        // Validate required fields
        if (!username || !password) {
            return res.status(400).json({
                success: false,
                error: 'Username and password are required'
            });
        }
        
        // Load users
        const data = loadUsers();
        
        // Find user by username (case insensitive)
        const user = data.users.find(u => 
            u.username.toLowerCase() === username.toLowerCase()
        );
        
        if (!user) {
            return res.status(401).json({
                success: false,
                error: 'Invalid username or password'
            });
        }
        
        // Verify password
        const { hash } = hashPassword(password, user.passwordSalt);
        if (hash !== user.passwordHash) {
            return res.status(401).json({
                success: false,
                error: 'Invalid username or password'
            });
        }
        
        // Generate token
        const token = generateToken(user);
        
        // Update last login
        user.lastLogin = new Date().toISOString();
        saveUsers(data);
        
        console.log(`🔥 User logged in: ${username}`);
        
        res.json({
            success: true,
            message: 'Login successful',
            token: token,
            user: {
                id: user.id,
                username: user.username,
                fullname: user.fullname,
                email: user.email,
                role: user.role
            }
        });
        
    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({
            success: false,
            error: 'Server error during login'
        });
    }
});

/**
 * GET /api/auth/verify
 * Verify token and return user info
 */
router.get('/verify', (req, res) => {
    try {
        const authHeader = req.headers.authorization;
        
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(401).json({
                success: false,
                error: 'No token provided'
            });
        }
        
        const token = authHeader.split(' ')[1];
        const payload = verifyToken(token);
        
        if (!payload) {
            return res.status(401).json({
                success: false,
                error: 'Invalid or expired token'
            });
        }
        
        // Load user data
        const data = loadUsers();
        const user = data.users.find(u => u.id === payload.id);
        
        if (!user) {
            return res.status(401).json({
                success: false,
                error: 'User not found'
            });
        }
        
        res.json({
            success: true,
            user: {
                id: user.id,
                username: user.username,
                fullname: user.fullname,
                email: user.email,
                role: user.role
            }
        });
        
    } catch (error) {
        console.error('Token verification error:', error);
        res.status(500).json({
            success: false,
            error: 'Server error during verification'
        });
    }
});

/**
 * POST /api/auth/logout
 * Logout user (client-side token removal)
 */
router.post('/logout', (req, res) => {
    // Since we're using stateless tokens, logout is handled client-side
    // This endpoint just confirms the logout action
    res.json({
        success: true,
        message: 'Logged out successfully'
    });
});

/**
 * GET /api/auth/users
 * Get all users (admin only - for now just list)
 */
router.get('/users', (req, res) => {
    try {
        const authHeader = req.headers.authorization;
        
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(401).json({
                success: false,
                error: 'Authorization required'
            });
        }
        
        const token = authHeader.split(' ')[1];
        const payload = verifyToken(token);
        
        if (!payload) {
            return res.status(401).json({
                success: false,
                error: 'Invalid token'
            });
        }
        
        const data = loadUsers();
        
        // Return users without sensitive data
        const users = data.users.map(u => ({
            id: u.id,
            username: u.username,
            fullname: u.fullname,
            email: u.email,
            role: u.role,
            createdAt: u.createdAt,
            lastLogin: u.lastLogin
        }));
        
        res.json({
            success: true,
            users: users
        });
        
    } catch (error) {
        console.error('Get users error:', error);
        res.status(500).json({
            success: false,
            error: 'Server error'
        });
    }
});

export default router;
