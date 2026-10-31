$ErrorActionPreference = "Stop"
$projectId = "nice-proposal-442209-n4"
$mailSender = "joshwoods9115@gmail.com"

$gcloudPaths = @(
    "$env:LOCALAPPDATA\Google\Cloud SDK\google-cloud-sdk\bin\gcloud.cmd",
    "C:\Program Files (x86)\Google\Cloud SDK\google-cloud-sdk\bin\gcloud.cmd"
)
$gcloud = $gcloudPaths | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $gcloud) {
    throw "Google Cloud CLI is installed but gcloud.cmd could not be found. Restart Windows and try again."
}

$activeAccount = & $gcloud auth list --filter=status:ACTIVE --format="value(account)"
if ([string]::IsNullOrWhiteSpace($activeAccount)) {
    & $gcloud auth login --brief
    if ($LASTEXITCODE -ne 0) {
        throw "Google Cloud login failed. Complete the browser sign-in and run this script again."
    }
}

$appPassword = Read-Host "Enter the Gmail App Password (16 characters)"

if ([string]::IsNullOrWhiteSpace($appPassword)) {
    throw "A Gmail App Password is required."
}

& $gcloud config set project $projectId
& $gcloud services enable run.googleapis.com cloudbuild.googleapis.com secretmanager.googleapis.com

$secretValues = @{
    SMTP_USER = $mailSender
    CONTACT_TO = $mailSender
    SMTP_PASSWORD = $appPassword.Trim()
}

foreach ($secretName in $secretValues.Keys) {
    $exists = & $gcloud secrets describe $secretName 2>$null
    if ($LASTEXITCODE -ne 0) {
        & $gcloud secrets create $secretName
    }

    $temporaryFile = Join-Path ([System.IO.Path]::GetTempPath()) "$secretName-$PID.txt"
    try {
        [System.IO.File]::WriteAllText($temporaryFile, $secretValues[$secretName])
        & $gcloud secrets versions add $secretName --data-file=$temporaryFile
    }
    finally {
        Remove-Item -Path $temporaryFile -Force -ErrorAction SilentlyContinue
    }
}

& $gcloud builds submit --config cloudbuild.yaml
