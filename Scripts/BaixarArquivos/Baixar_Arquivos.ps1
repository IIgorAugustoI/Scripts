<#
    Neste arquivo contém o script para baixar arquivos automaticamente via Powershell.
    Feito por -> https://github.com/IIgorAugustoI
#>

$diretorio = & 'C:\*'; # Você pode colocar um diretório fixo.

# Função para baixar automaticamente os arquivos
function baixaArquivo($arquivos){
    $wc = New-Object System.Net.WebClient
    foreach ($arquivo in $arquivos){
        $wc.DownloadFile($arquivo.uri, $arquivo.OutFile);
    }
}

# Criando Array com os links de dowloads dos arquivos 

$instaladores = @(
    @{
        Uri = "LINK DE DOWNLOD"
        OutFile = "$diretorio\NomeDoArquivo.rar"
    }
);  

baixaArquivo($instaladores);
