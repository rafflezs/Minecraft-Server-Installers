# Definindo variaveis
$javaUrl = "https://javadl.oracle.com/webapps/download/AutoDL?BundleId=250111_d8aa705069af427f9b83e66b34f5e380"
$installerPath = "$env:TEMP\JavaSetup8u421.exe"
$installPath = "C:\Program Files\Java\jre1.8.0_421"

$fabricInstallerUrl = "https://maven.fabricmc.net/net/fabricmc/fabric-installer/1.0.1/fabric-installer-1.0.1.jar"
$minecraftVersion = "1.20.1"
$modsZipUrl = "https://drive.google.com/uc?export=download&id=1y7jDMrf2edKTNHHqqV1DLG9YRZgRpG_J"
$minecraftDir = "$env:APPDATA\.minecraft"
$modsDir = "$minecraftDir\mods"
$fabricInstallerPath = "$minecraftDir\fabric-installer-1.0.1.jar"

# Checando Java
function Get-JavaVersion {
    try {
        $javaVersion = & java -version 2>&1 | Select-String "version" | ForEach-Object { $_.Line -replace '.*version "', '' -replace '".*', '' }
        return $javaVersion
    } catch {
        return $null
    }
}

$javaVersion = Get-JavaVersion

if ($javaVersion) {
    Write-Output "Versao do Java instalada: $javaVersion."
    
    if ([version]$javaVersion -ge [version]"1.8") {
        Write-Output "Parabens! O Java 8 esta instalado!"
    } else {
        Write-Output "Versao inferior detectada, prosseguindo para instalacao do Java 8!"
        $installJava = $true
    }
} else {
    Write-Output "Porra menor, nem Java ce tem! Prosseguindo para instalacao do Java 8!"
    $installJava = $true
}

# Instalando Java
if ($installJava) {
    Write-Output "Baixando Java 8 - JRE Oracle..."
    Invoke-WebRequest -Uri $javaUrl -OutFile $installerPath

    Write-Output "Instalando..."
    Start-Process -FilePath $installerPath -ArgumentList "/s" -Wait

    Write-Output "Configurando JAVA_HOME e atualizando PATH..."
    [System.Environment]::SetEnvironmentVariable('JAVA_HOME', $installPath, [System.EnvironmentVariableTarget]::Machine)
    $env:Path += ";$($installPath)\bin"
    [System.Environment]::SetEnvironmentVariable('PATH', $env:Path, [System.EnvironmentVariableTarget]::Machine)

    Write-Output "======== INSTALACAO DO JAVA COMPLETA ======="
}

# Preparando Diretorios
Write-Output "Gerando diretorios do Fabric..."
if (-not (Test-Path $minecraftDir)) { New-Item -Path $minecraftDir -ItemType Directory }
if (-not (Test-Path $modsDir)) { New-Item -Path $modsDir -ItemType Directory }

Write-Output "Baixando o instalador Jar do Fabric ..."
Invoke-WebRequest -Uri $fabricInstallerUrl -OutFile $fabricInstallerPath

# Instalando Fabric Mod Loader
Write-Output "Instalando o Fabric Mod Loader..."
& java -jar $fabricInstallerPath --mcversion $minecraftVersion --noprofile --dir $minecraftDir

# Baixando Modpack
Write-Output "Baixando modpack (.zip)..."
Invoke-WebRequest -Uri $modsZipUrl -OutFile "$minecraftDir\mods.zip"

Write-Output "Extraindo mods..."
if (Test-Path "$minecraftDir\mods.zip") {
    Expand-Archive -Path "$minecraftDir\mods.zip" -DestinationPath $modsDir -Force
} else {
    Write-Output "Arquivo mods.zip não encontrado. Verifique o download."
}

Write-Output "Limpando..."
Remove-Item -Path $fabricInstallerPath
Remove-Item -Path "$minecraftDir\mods.zip"

Write-Output "===== Instalacao completa! ====="
