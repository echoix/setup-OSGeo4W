'::group::Download OSGeo4W installer'
$exe = 'osgeo4w-setup.exe'
$url = $env:INPUT_SITE + $exe
$setup = '.\' + $exe
Write-Output "Starting download of $url..."
Invoke-WebRequest $url -OutFile $setup
Write-Output 'Download completed'
'::endgroup::'

# Array to store arguments to pass to the installer
$args_ = @(
    '--advanced'     # Advanced install (default)
    , '--autoaccept' # Accept all licenses
    , '--quiet-mode' # Unattended setup mode
)

Write-Output '::group::Ensure package dir exists'
$pkg_dir = $env:INPUT_PACKAGE_DIR
$pkg_dir = $pkg_dir.Trim()
if ($pkg_dir) {
    Write-Output "Creating local package directory: $pkg_dir"
    mkdir -Force $pkg_dir

    # add arguments
    $args_ += '--local-package-dir'
    $args_ += $pkg_dir
}
else {
    Write-Output 'Using default package directory'
}
Write-Output '::endgroup::'

# add arguments
$args_ += @(
    '--site', "$env:INPUT_SITE", # Download site
    '--root', "$env:INPUT_ROOT"  # Root installation directory
)
if ("$env:INPUT_UPGRADE_ALSO".ToLowerInvariant().Trim() -eq 'true') {
    $args_ += '--upgrade-also'
}

Write-Output '::group::Selected packages'
$packages = @($env:INPUT_PACKAGES -Split '[,\s\\]+' -match '\S')
$packages = $packages | Sort-Object | Get-Unique
if ($packages.Count -gt 0) {
    $args_ += '--packages' # Specify packages to install
    $args_ += $packages -Join (',')
}
Write-Output "$($PSStyle.Foreground.Blue)Selected $($packages.Count) packages:$($PSStyle.Reset)"
$packages | Format-Table
Write-Output '::endgroup::'

Write-Output '::group::Run setup'
Write-Output "Setup executable is $setup"
'Command to execute:'
Write-Output "$($PSStyle.Foreground.Blue)& $setup $args_ | Out-Default$($PSStyle.Reset)"
& $setup $args_ | Out-Default
Write-Output '::endgroup::'

$root_Path = "$env:INPUT_ROOT"
if (!(Test-Path -Path $root_Path -PathType Container)) {
    Write-Output '::error title=Invalid root directory::The root directory does not exist after a successful installation.'
    exit 1
}

$osgeo4w_shell_Path = Join-Path -Path $root_Path -ChildPath 'OSGeo4W.bat' -Resolve
if (!(Test-Path -Path $osgeo4w_shell_Path -PathType Leaf)) {
    Write-Output "::error title=Missing OSGeo4W shell::The OSGeo4W.bat file used for the OSGeo4W shell isn't found after a successful installation."
    exit 1
}

$root_from_OSGeo4W = & $osgeo4w_shell_Path echo %OSGEO4W_ROOT%
if (!(Test-Path -LiteralPath $root_from_OSGeo4W -PathType Container)) {
    Write-Output '::error title=Invalid root directory::The root directory returned by the OSGeo4W shell does not exist.'
    exit 1
}
$root_resolved = Resolve-Path -LiteralPath $root_from_OSGeo4W
if (!(Test-Path -LiteralPath $root_resolved -PathType Container)) {
    Write-Output '::error title=Invalid root directory::The root directory returned by the OSGeo4W shell could not be resolved.'
    exit 1
}

Write-Output "root=$($root_resolved)" >> $Env:GITHUB_OUTPUT
exit 0