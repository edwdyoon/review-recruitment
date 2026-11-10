# 원본 앱(04_app)을 index.html 로 복사한 뒤 GitHub 에 푸시합니다.
# 사용법: 이 폴더에서  .\update.ps1   (선택: .\update.ps1 "커밋 메시지")
param([string]$Message = "")

$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $here

$src = Join-Path (Split-Path -Parent $here) "04_app\입주기업_심사평가_앱_새디자인.html"
if (-not (Test-Path $src)) {
    Write-Host "[오류] 원본 파일을 찾을 수 없습니다: $src" -ForegroundColor Red
    exit 1
}

Copy-Item $src (Join-Path $here "index.html") -Force
Write-Host "[1/3] 원본 복사 완료" -ForegroundColor Cyan

git add -A
if ((git status --porcelain).Length -eq 0) {
    Write-Host "변경 사항이 없습니다. 종료합니다." -ForegroundColor Yellow
    exit 0
}

if ([string]::IsNullOrWhiteSpace($Message)) {
    $Message = "앱 업데이트 " + (Get-Date -Format "yyyy-MM-dd HH:mm")
}
git commit -m $Message
Write-Host "[2/3] 커밋 완료: $Message" -ForegroundColor Cyan

git push
if ($LASTEXITCODE -ne 0) {
    # 기본 로그인 방식이 안 되면 GitHub CLI(gh) 로그인으로 한 번 더 시도
    git -c credential.helper= -c 'credential.helper=!gh auth git-credential' push
}
if ($LASTEXITCODE -ne 0) {
    Write-Host "[오류] 푸시 실패 — 인터넷 연결 또는 GitHub 로그인(gh auth login)을 확인하세요. 커밋은 로컬에 남아 있어 다시 실행하면 됩니다." -ForegroundColor Red
    exit 1
}
Write-Host "[3/3] 푸시 완료" -ForegroundColor Green
Write-Host ""
Write-Host "1~2분 후 반영됩니다: https://edwdyoon.github.io/review-recruitment/" -ForegroundColor Green
