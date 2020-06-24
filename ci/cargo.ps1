param(
    [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true, Mandatory = $true)]
    [string] $Version,
    [Parameter(Position = 1, ValueFromPipelineByPropertyName = $true)]
    [string] $Authors = "Finter Mobility As"
)

$RootDirectoryPath = Split-Path -parent (Split-Path -parent $MyInvocation.MyCommand.Definition)
$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False

@(
    Join-Path $RootDirectoryPath warp-runner\Cargo.toml
    Join-Path $RootDirectoryPath warp-packer\Cargo.toml
) | ForEach-Object {
    $TomlFilenamePath = $_
    
    if(-not (Test-Path $TomlFilenamePath)) {
        Write-Error "Unable to find: $TomlFilenamePath"
    }

    $InsidePackage = $false
    $TomlLines = Get-Content $TomlFilenamePath | ForEach-Object {
        $Line = $_

        if($Line.StartsWith("[")) {
            $InsidePackage = $Line.StartsWith("[package")
            return $Line
        }

        if($InsidePackage) {
            switch -regex ($Line) {
                "^version" {
                    $Line = "version = ""$Version"""
                }
                "^authors" {
                    $Line = "authors = [""$Authors""]"   
                }
                Default {}
            }
        }

        return $Line
    }

    $TomlLines | Out-File $TomlFilenamePath -Encoding $Utf8NoBomEncoding

    Write-Output "Updated cargo metadata: $TomlFilenamePath"
}