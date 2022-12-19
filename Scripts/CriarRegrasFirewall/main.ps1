<#
    Neste arquivo contém o script para adicionar regras Firewall via Powershell.
    Feito por -> https://github.com/IIgorAugustoI
#>


# Verificando se o serviço do Windows Firewall está ativo.
$servico = [bool](Get-Service -Name mpssvc | Where-Object {$_.Status -eq "Running"});

if(!$servico){
    Set-Service -Name mpssvc -StartupType 'Automatic';
}

$portas = (
    # Portas que você deseja fazer a libreação
    3306,
    3389
);

foreach($porta in $portas){
    New-NetFirewallRule -DisplayName "FTP Port" -Direction Inbound -Profile Any -Action Allow -LocalPort $porta -Protocol TCP;
    New-NetFirewallRule -DisplayName "FTP Port" -Direction Outbound -Profile Any -Action Allow -LocalPort $porta -Protocol TCP;
}
