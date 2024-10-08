@echo off
setlocal

:: Definicao de Variaveis
set "java_url=https://javadl.oracle.com/webapps/download/AutoDL?BundleId=250111_d8aa705069af427f9b83e66b34f5e380"
set "installer_path=%TEMP%\JavaSetup8u421.exe"
set "install_path=C:\Program Files\Java\jre1.8.0_421"

set "fabric_installer_url=https://maven.fabricmc.net/net/fabricmc/fabric-installer/1.0.1/fabric-installer-1.0.1.jar"
set "minecraft_version=1.20.1"
set "mods_zip_url=https://drive.google.com/uc?export=download&id=1y7jDMrf2edKTNHHqqV1DLG9YRZgRpG_J"
set "minecraft_dir=%appdata%\.minecraft"
set "mods_dir=%minecraft_dir%\mods"
set "fabric_installer_path=%minecraft_dir%\fabric-installer-1.0.1.jar"

:: Checando Java
for /f "tokens=2 delims==" %%I in ('wmic product where "name like 'Java%%'" get version /value 2^>nul') do set "installed_java_version=%%I"

:: Instalacao Java
if defined installed_java_version (
    echo Versao do Java instalada: %installed_java_version%.
    if "%installed_java_version:~0,1%" GEQ "8" (
        echo Parabens! O Java 8 esta instalado!
    ) else (
        echo Versao inferior detectada, prosseguindo para instalacao do Java 8!
        set "install_java=true"
    )
) else (
    echo Porra menor, nem Java ce tem! Prosseguindo para instalacao do Java 8!
    set "install_java=true"
)

if "%install_java%"=="true" (
    echo Baixando Java 8 - JRE Oracle...
    powershell -Command "Invoke-WebRequest -Uri '%java_url%' -OutFile '%installer_path%'"

    echo Instalando...
    start /wait "" "%installer_path%" /s

    echo Configurando JAVA_HOME e atualizando PATH...
    setx JAVA_HOME "%install_path%" /M
    setx PATH "%PATH%;%install_path%\bin" /M

    echo ======== INSTALACAO DO JAVA COMPLETA =======
)

:: Preparacao de Diretorios
echo Gerando diretorios do Fabric...
if not exist "%minecraft_dir%" mkdir "%minecraft_dir%"
if not exist "%mods_dir%" mkdir "%mods_dir%"

echo Baixando o instalador Jar do Fabric ...
powershell -Command "Invoke-WebRequest -Uri '%fabric_installer_url%' -OutFile '%fabric_installer_path%'"

:: Instalar Fabric Mod Loader
echo Instalando o Fabric Mod Loader...
java -jar "%fabric_installer_path%" --mcversion %minecraft_version% --noprofile --dir "%minecraft_dir%"

:: Baixar Modpack
echo Baixando modpack (.zip)...
powershell -Command "Invoke-WebRequest -Uri '%mods_zip_url%' -OutFile '%minecraft_dir%\mods.zip'"

echo Extraindo mods...
powershell -Command "Expand-Archive -Path '%minecraft_dir%\mods.zip' -DestinationPath '%mods_dir%' -Force"

echo Limpando...
del "%fabric_installer_path%"
del "%minecraft_dir%\mods.zip"

echo ===== Instalacao completa! =====

endlocal
