@echo off

SET FSharpVersion=4.0.1.10
SET ScriptCSVersion=0.16.1
SET AzurePowershellVersion=1.6.0

SET ToolsFolder=%~dp0

SET FSharpFolder=%ToolsFolder%FSharp.Compiler.Tools.%FSharpVersion%\
IF EXIST %FSharpFolder% GOTO FSHARPEXISTS
   echo Copying FSharp to Tools folder
   xcopy /E %userprofile%\.nuget\packages\FSharp.Compiler.Tools\%FSharpVersion%\tools %FSharpFolder%
:FSHARPEXISTS

SET ScriptCSFolder=%ToolsFolder%ScriptCS.%ScriptCSVersion%\
IF EXIST %ScriptCSFolder% GOTO SCRIPTCSEXISTS
   echo Copying ScriptCS to Tools folder
   xcopy /E %userprofile%\.nuget\packages\ScriptCS\%ScriptCSVersion%\tools %ScriptCSFolder%
:SCRIPTCSEXISTS

IF "%1" NEQ "azure" GOTO DONE
SET AzurePowershellFolder=%ToolsFolder%Octopus.Dependencies.AzureCmdlets.%AzurePowershellVersion%\
IF EXIST %AzurePowershellFolder% GOTO AZUREPOWERSHELLEXISTS
   echo Copying Azure PowerShell to Tools folder
   xcopy /E %userprofile%\.nuget\packages\Octopus.Dependencies.AzureCmdlets\%AzurePowershellVersion%\PowerShell %AzurePowershellFolder%
:AZUREPOWERSHELLEXISTS

:DONE
exit 0