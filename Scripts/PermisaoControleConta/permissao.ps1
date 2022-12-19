<#
    Neste arquivo contém o script para remover o controle de contas de usuários automaticamente via Powershell.
    Feito por -> https://github.com/IIgorAugustoI
#>

Write-Output "
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System]
"EnableLUA"=dword:00000000
"ConsentPromptBehaviorAdmin"=dword:00000000
"PromptOnSecureDesktop"=dword:00000000

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit]
" > 'C:\permissao.reg';

reg import 'C:\permissao.reg'

Remove-Item 'C:\permissao.reg' -Force
