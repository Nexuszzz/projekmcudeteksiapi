# Clean all Twilio credentials from files before GitHub push

$oldAccountSid = "REDACTED_FOR_SECURITY"
$newAccountSid = "YOUR_ACCOUNT_SID_HERE"

$oldAuthToken = "REDACTED_FOR_SECURITY"
$newAuthToken = "YOUR_AUTH_TOKEN_HERE"

$files = Get-ChildItem -Path . -Recurse -Include *.md,*.bat,*.env.example -File

$totalReplaced = 0

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
    
    if ($content) {
        $originalContent = $content
        
        # Replace Account SID
        $content = $content -replace [regex]::Escape($oldAccountSid), $newAccountSid
        
        # Replace Auth Token  
        $content = $content -replace [regex]::Escape($oldAuthToken), $newAuthToken
        
        if ($content -ne $originalContent) {
            Set-Content -Path $file.FullName -Value $content -NoNewline
            Write-Host "✅ Cleaned: $($file.FullName)" -ForegroundColor Green
            $totalReplaced++
        }
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "✅ Cleaning Complete!" -ForegroundColor Green
Write-Host "Files cleaned: $totalReplaced" -ForegroundColor Yellow
Write-Host "========================================`n" -ForegroundColor Cyan
