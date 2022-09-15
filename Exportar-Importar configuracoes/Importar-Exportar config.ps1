<#  Script para Importação e Exportação das Config's AtivaDaruma     #>
<#  Verificação se o script está sendo executado como Administrador  #>

param([switch]$Elevated)
function Test-Admin {
  $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
if ((Test-Admin) -eq $false)  {
    if ($elevated) 
    {
        # tried to elevate, did not work, aborting
    } else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -ExecutionPolicy Bypass -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition));   
}
exit
}
function verificaWinrar {
    $winrar = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName;
    $winrar += Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName;
    return [bool]( $winrar | Where-Object DisplayName -like "WinRAR*");
  }

function baixaArquivo($arquivos){
    $wc = New-Object System.Net.WebClient
    foreach ($arquivo in $arquivos){
        $wc.DownloadFile($arquivo.uri, $arquivo.OutFile);
    }
}

function ImportarAtivaDaruma($diretorio) {

    Write-Output "@echo off 
    start AtivaDaruma.exe" > $diretorio\AtivaDaruma.bat;
    Copy-Item $diretorio\AtivaDaruma.bat 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\';

    $hostname = 'HOSTNAME=' + (Get-Content env:computername) + '"';
    $caminhoServidor = ((Get-Content -Path $diretorio\Backup_AtivaDaruma\Config_AtivaDaruma.reg) | Select-String '"Caminho_servidor"="') -replace '"Caminho_servidor"="','';

    if ($caminhoServidor -match 'HOSNTAME=*' -or $caminhoServidor -match 'hostname=*'){
        (Get-Content -Path $diretorio\Backup_AtivaDaruma\Config_AtivaDaruma.reg) -replace $caminhoServidor, $hostname | Set-Content -Path $diretorio\NovaConfig_AtivaDaruma.reg;
            reg IMPORT $diretorio\NovaConfig_AtivaDaruma.reg;
    } else{
            reg IMPORT $diretorio\Backup_AtivaDaruma\Config_AtivaDaruma.reg;
    }

    Set-Location $diretorio;
    Copy-Item $diretorio\Backup_AtivaDaruma\Local.ini $diretorio;

    $files = @(
    @{
        Uri = "https://ip225.ip-149-56-155.net/owncloud/s/N8N9tXRy4GRrwXw/download"
        OutFile = "$diretorio\CHNetDLL_Instalacao.rar"
    },
    @{
        Uri = "https://ip225.ip-149-56-155.net/owncloud/s/SMzu2IssIw26P1U/download"
        OutFile = "$diretorio\RegAsm.rar"
    },
    @{
        Uri = "https://www.dropbox.com/s/yhhvmgxv3tqyfvm/AtivaDaruma.rar?dl=1"
        OutFile = "$diretorio\AtivaDaruma.rar"
    },
    @{
        Uri = "https://www.dropbox.com/s/frggbfd17ufusu1/CHNetDLL_Instalacao.rar?dl=1"
        OutFile = "$diretorio\CHNetDLL.rar"
    }
    )
     
    $testeWinrar = verificaWinrar;
    $winrarBaixado = $false;

    if(!$testeWinrar){

        $files += @(
            @{
                Uri = "https://www.win-rar.com/fileadmin/winrar-versions/winrar/winrar-x64-611br.exe"
                OutFile = "${diretorio}\Winrar.exe"
            }
        )
        $winrarBaixado = $true;
    }
    
    baixaArquivo($files); 

    if ($winrarBaixado) {
        Start-Process -FilePath "${diretorio}\Winrar.exe" -ArgumentList "/S";
        Start-Sleep -s 30;
    }

    for ($i = 0; $i -lt $files.Count; $i++) {
        C:\'Program Files'\WinRAR\rar.exe x -y $files.OutFile[$i];
        if($i -eq 1){
            RegAsm.exe CHNetDLL.DLL /tlb:chnetdll.tlb
        }
    }
    Clear-Host;
    
    .\AtivaDaruma.exe;
    'Importação foi concluída.'
    exit
}

function ExportarAtivaDaruma($diretorio) {

    $ativaDaruma = [bool](Get-Process | Where-Object Name -eq 'AtivaDaruma');   
    if ($ativaDaruma){
        Stop-Process -Name AtivaDaruma -Force;
    };
    
    Remove-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\AtivaDaruma.*" -Recurse;
    Set-Location $diretorio;
    New-Item -Path "${diretorio}\" -Name Backup_AtivaDaruma -ItemType "directory" -Force;

    reg export "HKCU\SOFTWARE\VB and VBA Program Settings\Chianca Softwares\Memória" $diretorio\Backup_AtivaDaruma\Config_AtivaDaruma.reg /y;
    Copy-Item $diretorio\local.ini $diretorio\Backup_AtivaDaruma;
    Remove-Item -Path $diretorio\AtivaDaruma*;

    $pastaBkp = [bool](Get-ChildItem C:\Chianca | Where-Object Name -eq Backup_AtivaDaruma.zip);
    if($pastaBkp){
        Remove-Item -Path $diretorio\Backup_AtivaDaruma.zip
    }

    Compress-Archive -Path $diretorio\Backup_AtivaDaruma -DestinationPath Backup_AtivaDaruma.zip;
    Remove-Item $diretorio\Backup_AtivaDaruma -Recurse
    'Backup Concluído';   
}

'INFORME O CAMINHO DA INSTALAÇÃO DO ATIVADARUMA';

[int]$caminho = Read-Host "# Digite 1 para Chianca # # Digite 2 para Chianca Softwares #";

if($caminho -eq 1) {
    $diretorio = 'C:\Chianca';
} elseif ($caminho -eq 2){
    $diretorio = 'C:\Program Files (x86)\Chianca Softwares';
}elseif ($caminho -ne 1 -and 2) {
    'Write-Host Selecione uma opção correta.'
    exit;
};

verificaWinrar {
    $winrar = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName;
    $winrar += Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName;
    $winrar = [bool]( $winrar | Where-Object DisplayName -like "WinRAR*");
}

$opcao = Read-Host '# Digite 1 para importar as configurações # # Digite 2 para exportar as configurações #';

switch ($opcao) {
    1 { 
        ImportarAtivaDaruma($diretorio);
        break;
     }
     2 {
        ExportarAtivaDaruma($diretorio);
        break;
     }
    Default {
        'Selecione a opção correta.';
        Return;
    }
}
exit;
