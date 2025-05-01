# Get the addon name from the current directory
$ADDON_NAME = Split-Path -Leaf $PSScriptRoot
Write-Host "Deploying $ADDON_NAME..."

# Define the WoW addon directory
$WOW_ADDON_DIR = "C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\$ADDON_NAME"

# Create the directory if it doesn't exist
if (-not (Test-Path $WOW_ADDON_DIR)) {
    New-Item -ItemType Directory -Path $WOW_ADDON_DIR -Force
}

# Copy files
Copy-Item -Path "$PSScriptRoot\*" -Destination $WOW_ADDON_DIR -Recurse -Force

Write-Host "$ADDON_NAME has been deployed to $WOW_ADDON_DIR"