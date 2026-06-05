$ErrorActionPreference = 'Stop'

# Static checks only. This script does not modify project files.
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

function Assert-Contains {
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)][string]$Pattern,
    [Parameter(Mandatory = $true)][string]$Label
  )

  $FullPath = Join-Path $Root $Path
  if (-not (Test-Path $FullPath)) {
    throw "Missing file: $Path"
  }

  $Content = Get-Content -LiteralPath $FullPath -Raw
  if (-not [regex]::IsMatch($Content, $Pattern)) {
    throw "Check failed: $Label ($Path)"
  }

  Write-Host "OK: $Label"
}

Assert-Contains `
  -Path 'src/frontend/components/layout/MainLayout.vue' `
  -Pattern 'name="logs"' `
  -Label 'MainLayout includes logs tab'

Assert-Contains `
  -Path 'src/frontend/components/tabs/LogsTab.vue' `
  -Pattern 'copyRecentLogs' `
  -Label 'Global logs page exists'

Assert-Contains `
  -Path 'src/frontend/components/tools/AcemcpLogViewerDrawer.vue' `
  -Pattern 'count:\s*filteredItems\.value\.length' `
  -Label 'Log drawer uses numeric virtualizer count'

Assert-Contains `
  -Path 'src/frontend/components/tools/AcemcpLogViewerDrawer.vue' `
  -Pattern 'filteredItems\.length === 0' `
  -Label 'Log drawer has empty state'

Assert-Contains `
  -Path 'src/frontend/components/tabs/McpToolsTab.vue' `
  -Pattern 'config-modal-body' `
  -Label 'Config modal has inner scroll container'

Assert-Contains `
  -Path 'src/rust/utils/logger.rs' `
  -Pattern 'chrono::Local::now\(\)' `
  -Label 'Logger uses local time'

$SouConfig = Get-Content -LiteralPath (Join-Path $Root 'src/frontend/components/tools/SouConfig.vue') -Raw
if ([regex]::IsMatch($SouConfig, 'viewLogs|loadLogFilePath|openLogViewer|useLogViewer')) {
  throw 'Check failed: SouConfig still contains old global log entry or old functions'
}
Write-Host 'OK: SouConfig removed old global log entry'

Write-Host 'All static checks passed'
