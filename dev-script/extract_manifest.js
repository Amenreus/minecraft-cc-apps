/**
 * Simple nodeJS script for extracting dependencies into an app manifest file.
 * It takes two arguments:
 *      First one is path to the main file of an app (e.g. apps/makej/makej.lua )
 *      The second one is for a repository path to files ( e.g. main or feature/xxx )
 * Script traverses through the files, parses require calls and prints them in a structure
 * required by downloader provided in lib/util/downloader and used by apps/installer/installer.lua
 *
 * Please note that this script is only able to find require in following formats:
 * require("xxxx")
 * require("xxx.xxx")
 * require("xxx/xxx") -- untested but possible
 */

const { argv } = require('node:process');
const fs = require('node:fs');
const path = require('node:path');

const requireRegex = /require\s*\(\s*["'](?<dependency>[^"']+)["']\s*\)/g

function getLuaTableString(file, path, repoPath){
    return `\n\t{ file = "${file}", path = "${path}", repoPath = "${repoPath}" },`;
}

function loadFile(filePath){
    filePath = "../" + filePath;
    if(!fs.existsSync(filePath)) return null;
    return fs.readFileSync(filePath, {"encoding": "utf-8"})
}

function searchForDependencies(filePath){
    let fileContent = loadFile(filePath);
    let result = [];
    for(const match of fileContent.matchAll(requireRegex)){
        let dep = match.groups.dependency
        if (dep.endsWith(".lua")){
            dep = dep.slice(0, -4)
        }
        dep = dep.replaceAll('.',"/") + ".lua"
        result.push(dep)
    }
    return result;
}

function process(file, branch){
    let result = "return {\n files = {";
    let filesToProcess = [file];
    let processed = [];

    while(filesToProcess.length > 0){
        let filePath = filesToProcess.shift();
        processed.push(filePath)

        let file = path.basename(filePath);
        let fsPath = path.dirname(filePath);
        let repoPath = [branch, fsPath].join("/");

        result += getLuaTableString(file, fsPath, repoPath)

        let dependencies = searchForDependencies(filePath)
        for (const dep of dependencies){
            if (!filesToProcess.includes(dep) && !processed.includes(dep)){
                filesToProcess.push(dep)
            }
        }
    }
    result += "\n }\n}"
    return result
}

let manifest = process(argv[2], argv[3]);

console.log(manifest);


