<#
    Neste arquivo contém o script para adicionar permissão e compartilhamento de pasta via Powershell.
    Feito por -> https://github.com/IIgorAugustoI
#>

# Adicionando permissão na pasta para todos

$ACL = Get-Acl -Path $EscolhaODiretorio
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule("todos","FullControl","ContainerInherit, ObjectInherit","None","Allow")
$ACL.SetAccessRule($ACE)
$ACL.SetOwner([System.Security.Principal.NTAccount] "todos")
Set-Acl -Path "$EscolhaODiretorio" -AclObject $ACL

<#
    Compartilhando a pasta  
#>

New-SmbShare -Name "Sua Pasta" -Path "C:\$EscolhaODiretorio" -FullAccess "todos"
