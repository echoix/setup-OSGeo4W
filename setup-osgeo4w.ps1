"::group::Download OSGeo4W installer"
$exe = 'osgeo4w-setup.exe'
$url = $env:INPUT_SITE + $exe
$setup = '.\' + $exe
echo "Starting download of $url..."
Invoke-WebRequest $url -OutFile $setup
echo "Download completed"
"::endgroup::"

# Array to store arguments to pass to the installer
$args_ = @(
    '--advanced'     # Advanced install (default)
    , '--autoaccept' # Accept all licenses
    , '--quiet-mode' # Unattended setup mode
)

echo "::group::Ensure package dir exists"
$pkg_dir = $env:INPUT_PACKAGE_DIR
$pkg_dir = $pkg_dir.Trim()
if ($pkg_dir) {
    echo "Creating local package directory: $pkg_dir"
    mkdir -Force $pkg_dir

    # add arguments
    $args_ += '--local-package-dir'
    $args_ += $pkg_dir
}
else {
    echo "Using default package directory"
}
echo "::endgroup::"

# add arguments
$args_ += @(
    '--site', "$env:INPUT_SITE", # Download site
    '--root', "$env:INPUT_ROOT"  # Root installation directory
)
if ("$env:INPUT_UPGRADE_ALSO".ToLowerInvariant().Trim() -eq "true") {
    $args_ += '--upgrade-also'
}

echo "::group::Selected packages"
$packages = @($env:INPUT_PACKAGES -Split '[,\s\\]+' -match '\S')
$packages = $packages | Sort-Object | Get-Unique
if ($packages.Count -gt 0) {
    $args_ += '--packages' # Specify packages to install
    $args_ += $packages -Join (',')
}
Write-Host "$($PSStyle.Foreground.Blue)Selected $($packages.Count) packages:$($PSStyle.Reset)"
$packages | Format-Table
echo "::endgroup::"
Get-PSReadLineOption

echo "::group::Run setup"
echo "Setup executable is $setup"
"Command to execute:"
Write-Host "$($PSStyle.Foreground.Blue)& $setup $args_ | Out-Default$($PSStyle.Reset)"
& $setup $args_ | Out-Default
echo "::endgroup::"