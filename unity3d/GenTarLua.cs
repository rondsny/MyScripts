using System.IO;
using UnityEditor;
using UnityEngine;

public class GenTarLua : MonoBehaviour {

    public static void conv(string path, string luaScriptPath, string targetRootDir)
    {

        var origDirInfo = new DirectoryInfo(path);

        DirectoryInfo[] dirInfo = origDirInfo.GetDirectories();
        //遍历文件夹
        foreach (DirectoryInfo NextFolder in dirInfo)
            conv(path + "\\" + NextFolder.Name, luaScriptPath, targetRootDir);

        FileInfo[] fileInfo = origDirInfo.GetFiles();
        //遍历文件
        foreach (FileInfo fInfo in fileInfo)
        { 
            var inlPath = fInfo.FullName.Substring(luaScriptPath.Length);
            
            var inlDir = "";
            var name = inlPath;

            if (inlPath.LastIndexOf('\\') >= 0) { 
                inlDir = inlPath.Substring(0, inlPath.LastIndexOf('\\'));
                name = inlPath.Substring(inlPath.LastIndexOf('\\'));
            }
            name = name.Substring(0, name.LastIndexOf('.'));

            var targetDir = targetRootDir + "\\" + inlDir;
            if (!Directory.Exists(targetDir))
                Directory.CreateDirectory(targetDir);

            var targetPath = targetRootDir + "\\" + inlDir + "\\" + name + ".txt";
            File.Copy(fInfo.FullName, targetPath, true);

            Debug.LogWarning(string.Format("convert {0}", targetPath));
        }
    }

    [MenuItem("MyProj/txt2lua")]
    public static void OnMenu_GenTarLuaFiles()
    {
        var luaScriptDirectoryName = "Assets\\Slua\\Resources\\LuaScripts";
        var luaScriptPath = "E:\\unity_test\\LuaScripts";

        var targetRootDir = Application.dataPath + "\\Resources\\" +  luaScriptDirectoryName;
        if (!Directory.Exists(targetRootDir))
            Directory.CreateDirectory(targetRootDir);

        conv(luaScriptPath, luaScriptPath, luaScriptDirectoryName);
    }
}

