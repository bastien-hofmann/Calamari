#!/usr/bin/env bash

FSharpVersion=4.0.1.10
ScriptCSVersion=0.16.1

ToolsFolder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

FSharpFolder=${ToolsFolder}/FSharp.Compiler.Tools.${FSharpVersion}/
if [ ! -d "$FSharpFolder" ]; then
    echo Copying FSharp to Tools folder
    cp -r ${HOME}/.nuget/packages/FSharp.Compiler.Tools/${FSharpVersion}/tools ${FSharpFolder}
fi

ScriptCSFolder=${ToolsFolder}/ScriptCS.${ScriptCSVersion}/
if [ ! -d "$ScriptCSFolder" ]; then
    echo Copying ScriptCS to Tools folder
    cp -r ${HOME}/.nuget/packages/ScriptCS/${ScriptCSVersion}/tools ${ScriptCSFolder}
fi

exit 0