require('dotenv').config({ path: './backend/.env' });

const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const morgan = require('morgan'); // ✅ Middleware logging
const { Resend } = require('resend');
const mongoose = require('mongoose');
const bcrypt = require('bcrypt');

const resend = new Resend(process.env.RESEND_API_KEY);
const FROM_EMAIL = 'Nuurosman77@email.com'; 

mongoose.connect('mongodb://localhost:27017/nomzbank');

const codeSchema = new mongoose.Schema({
  email: String,
  code: String,
  expires: Date,
});
const Code = mongoose.model('Code', codeSchema);

const userSchema = new mongoose.Schema({
  email: { type: String, unique: true },
  name: String,
  password: String,
  phone: String,
});
const User = mongoose.model('User', userSchema);

const app = express();

// ✅ Middlewares
app.use(cors());
app.use(bodyParser.json());
app.use(morgan('dev')); // Log every request in the terminal

// 🔢 Generate 6-digit code
function generateCode() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// 📤 Send Verification Code
app.post('/send-code', async (req, res) => {
  const { email } = req.body;
  if (!email || !/^[^@]+@[^@]+\.[^@]+$/.test(email)) {
    return res.status(400).json({ error: 'Invalid email' });
  }

  const code = generateCode();
  const expires = new Date(Date.now() + 5 * 60 * 1000); // 5 daqiiqo

  try {
    await Code.findOneAndUpdate({ email }, { code, expires }, { upsert: true });
  } catch (err) {
    return res.status(500).json({ error: 'Failed to save code', details: err.message });
  }

  try {
    await resend.emails.send({
      from: FROM_EMAIL,
      to: email,
      subject: 'Your Nomzbank Verification Code',
      html: `<p>Your verification code is: <strong>${code}</strong></p>`,
    });
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: 'Failed to send email', details: err.message });
  }
});

// ✅ Verify Code & Register User
app.post('/verify-code', async (req, res) => {
  const { email, code, name, password, phone } = req.body;

  const record = await Code.findOne({ email });
  if (!record) return res.status(400).json({ error: 'No code sent to this email' });
  if (record.expires < new Date()) return res.status(400).json({ error: 'Code expired' });
  if (record.code !== code) return res.status(400).json({ error: 'Invalid code' });

  await Code.deleteOne({ email });

  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    await User.create({ email, name, password: hashedPassword, phone });
    res.json({ success: true });
  } catch (e) {
    return res.status(500).json({ error: 'Failed to save user', details: e.message });
  }
});

// 🔍 Check if email is already registered
app.post('/check-email', async (req, res) => {
  console.log('✅ POST /check-email route hit');
  console.log('Body:', req.body);

  const { email } = req.body;
  if (!email || !/^[^@]+@[^@]+\.[^@]+$/.test(email)) {
    return res.status(400).json({ error: 'Invalid email' });
  }

  const user = await User.findOne({ email });
  return res.json({ exists: !!user });
});

// Test Route
app.get('/', (req, res) => {
  res.send('🚀 Server is up and running!');
});

// Log all registered routes before starting the server
app._router && app._router.stack.forEach(r => {
  if (r.route && r.route.path) {
    console.log('Registered route:', r.route.path);
  }
});

const PORT = process.env.PORT || 7000;
app.listen(PORT, () => {
  console.log(`Nomzbank Auth API running on port ${PORT}`);
  // Log all registered routes after server starts
  app._router && app._router.stack.forEach(r => {
    if (r.route && r.route.path) {
      console.log('Registered route:', r.route.path);
    }
  });
});
