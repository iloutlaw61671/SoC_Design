# Build the report with pdfLaTeX from any working directory.
$ErrorActionPreference = 'Stop'
$engine = (Get-Command pdflatex -CommandType Application -ErrorAction Stop).Source

Push-Location $PSScriptRoot
try {
    New-Item -ItemType Directory -Force -Path 'build' | Out-Null
    for ($pass = 1; $pass -le 2; $pass++) {
        & $engine '-interaction=nonstopmode' '-halt-on-error' '-file-line-error' `
            '-no-shell-escape' '-output-directory=build' '-jobname=SoC-Lab-Report' 'main.tex'
        if ($LASTEXITCODE -ne 0) {
            throw "LaTeX build failed on pass $pass. See Report/build/SoC-Lab-Report.log."
        }
    }
    Write-Output (Join-Path $PSScriptRoot 'build/SoC-Lab-Report.pdf')
}
finally {
    Pop-Location
}
