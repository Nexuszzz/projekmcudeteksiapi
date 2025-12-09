$body = @{
    phoneNumber = "+628967175597"
    name = "zak"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://localhost:3001/api/voice-call/numbers" `
    -Method Post `
    -ContentType "application/json" `
    -Body $body

Write-Host "Response:" -ForegroundColor Green
$response | ConvertTo-Json -Depth 5
