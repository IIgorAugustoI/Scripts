<#
    Neste arquivo contém o script para baixar as funções do Windows Server automaticamente via Powershell.
    Feito por -> https://github.com/IIgorAugustoI
#>

function instalarFuncoes($funcoes) {
    foreach ($funcao in $funcoes){
        Install-WindowsFeature $funcao
    };
}

$funcoesParaInstalar = @(
    <#
        Nome das funções. Ex:
    #>
    'NET-Framework-Core',
    'Web-Server'
);

instalarFuncoes($funcoesParaInstalar);
