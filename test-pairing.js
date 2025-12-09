// Test pairing code generation
import http from 'http';

const data = JSON.stringify({
  method: 'pairing',
  phoneNumber: '6282139940606'
});

const options = {
  hostname: 'localhost',
  port: 3001,
  path: '/api/whatsapp/connect',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': data.length
  }
};

console.log('🧪 Testing pairing code generation...\n');

const req = http.request(options, (res) => {
  let responseData = '';

  res.on('data', (chunk) => {
    responseData += chunk;
  });

  res.on('end', () => {
    console.log('Response Status:', res.statusCode);
    console.log('Response Body:', responseData);
    try {
      const json = JSON.parse(responseData);
      console.log('\n✅ Parsed Response:', JSON.stringify(json, null, 2));
    } catch (e) {
      console.log('\n❌ Failed to parse JSON:', e.message);
    }
    process.exit(0);
  });
});

req.on('error', (error) => {
  console.error('❌ Request error:', error);
  process.exit(1);
});

req.write(data);
req.end();
