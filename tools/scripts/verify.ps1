param(
    [switch]$NoBuild,
    [string]$ImageName = "nextbase-dev",
    [string]$ProxyUrl = "",
    [string]$AptMirror = ""
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw "docker 未安装或不可用，无法执行容器内验证。"
}

docker info | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "docker daemon 未启动，无法执行容器内验证。"
}

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")

$resolvedProxy = $ProxyUrl
if ([string]::IsNullOrWhiteSpace($resolvedProxy)) {
    $resolvedProxy = $env:DEV_CONTAINER_HTTP_PROXY
}
if ([string]::IsNullOrWhiteSpace($resolvedProxy)) {
    $resolvedProxy = $env:HTTP_PROXY
}

$resolvedHttpsProxy = $env:DEV_CONTAINER_HTTPS_PROXY
if ([string]::IsNullOrWhiteSpace($resolvedHttpsProxy)) {
    $resolvedHttpsProxy = $env:HTTPS_PROXY
}
if ([string]::IsNullOrWhiteSpace($resolvedHttpsProxy)) {
    $resolvedHttpsProxy = $resolvedProxy
}

$resolvedNoProxy = $env:DEV_CONTAINER_NO_PROXY
if ([string]::IsNullOrWhiteSpace($resolvedNoProxy)) {
    $resolvedNoProxy = $env:NO_PROXY
}
if ([string]::IsNullOrWhiteSpace($resolvedNoProxy)) {
    $resolvedNoProxy = "localhost,127.0.0.1,host.docker.internal"
}

if ([string]::IsNullOrWhiteSpace($AptMirror)) {
    $AptMirror = $env:DEV_CONTAINER_APT_MIRROR
}
if ([string]::IsNullOrWhiteSpace($AptMirror)) {
    $AptMirror = "mirrors.tuna.tsinghua.edu.cn"
}

Write-Host "[verify] HTTP代理: $resolvedProxy"
Write-Host "[verify] HTTPS代理: $resolvedHttpsProxy"
Write-Host "[verify] NO_PROXY: $resolvedNoProxy"
Write-Host "[verify] APT镜像: $AptMirror"

Write-Host "[verify] 构建 Dev Container 镜像: $ImageName"
$dockerBuildArgs = @(
    "build",
    "--build-arg", "NO_PROXY=$resolvedNoProxy",
    "--build-arg", "APT_MIRROR=$AptMirror",
    "-f", (Join-Path $repoRoot ".devcontainer\Dockerfile"),
    "-t", $ImageName,
    $repoRoot
)
if (-not [string]::IsNullOrWhiteSpace($resolvedProxy)) {
    $dockerBuildArgs = @("build", "--build-arg", "HTTP_PROXY=$resolvedProxy", "--build-arg", "HTTPS_PROXY=$resolvedHttpsProxy") + $dockerBuildArgs[1..($dockerBuildArgs.Count - 1)]
}
docker @dockerBuildArgs
if ($LASTEXITCODE -ne 0) {
    throw "Dev Container 镜像构建失败。"
}

$buildAndTest = "set -euo pipefail; bazel --version; "
if (-not $NoBuild) {
    $buildAndTest += "bazel build //...; "
}
$buildAndTest += "bazel test //..."

Write-Host "[verify] 在容器中执行 Bazel 验证"
$dockerRunArgs = @(
    "run", "--rm",
    "-e", "NO_PROXY=$resolvedNoProxy",
    "-e", "no_proxy=$resolvedNoProxy",
    "-v", "${repoRoot}:/workspaces/NextBase",
    "-w", "/workspaces/NextBase",
    $ImageName,
    "bash", "-lc", $buildAndTest
)
if (-not [string]::IsNullOrWhiteSpace($resolvedProxy)) {
    $dockerRunArgs = @(
        "run", "--rm",
        "-e", "HTTP_PROXY=$resolvedProxy",
        "-e", "HTTPS_PROXY=$resolvedHttpsProxy",
        "-e", "http_proxy=$resolvedProxy",
        "-e", "https_proxy=$resolvedHttpsProxy",
        "-e", "NO_PROXY=$resolvedNoProxy",
        "-e", "no_proxy=$resolvedNoProxy",
        "-v", "${repoRoot}:/workspaces/NextBase",
        "-w", "/workspaces/NextBase",
        $ImageName,
        "bash", "-lc", $buildAndTest
    )
}
docker @dockerRunArgs
if ($LASTEXITCODE -ne 0) {
    throw "容器内 Bazel 验证失败。"
}

Write-Host "verification passed (container)"
