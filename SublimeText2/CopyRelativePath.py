import sublime
import sublime_plugin
import os

class CopyRelativePathCommand(sublime_plugin.TextCommand):
    def run(self, edit):
        # 获取活动视图
        view = self.view
        # 获取当前文件的完整路径
        full_path = view.file_name()
        
        if full_path is None:
            sublime.message_dialog("File is not saved yet.")
            return
        
        # 获取工作区的路径
        project_data = sublime.active_window().project_data()
        if project_data and 'folders' in project_data:
            project_folder = project_data['folders'][0]['path']
            # 计算相对路径
            relative_path = os.path.relpath(full_path, project_folder)
            # 将反斜杠替换为斜杠
            relative_path = relative_path.replace('\\', '/')
            
            # 将路径复制到系统剪贴板
            sublime.set_clipboard(relative_path)
            sublime.status_message("Copied relative path: " + relative_path)
        else:
            sublime.message_dialog("No project folder found.")
