package android.util;

import java.io.*;
import java.nio.file.*;
import java.util.List;
import java.util.ArrayList;
import java.util.concurrent.ConcurrentHashMap;

    // String get(String filePath, String key, String defaultValue)
    // String set(String filePath, String key, String newValue)
    // String printAll()
public class S9Helper {
    private static final ConcurrentHashMap<String, String> map = new ConcurrentHashMap<>();
    private static final List<String> syncedFiles = new ArrayList<>();
    private static final WatchService watchService;
    private static boolean isInternalChange = false; // 用于标记内部修改

    static {
        try {
            watchService = FileSystems.getDefault().newWatchService();
        } catch (IOException e) {
            throw new RuntimeException("Failed to create WatchService", e);
        }
    }

    // 主控制方法，负责同步文件与map，并处理操作
    public static String ctl(String filePath, String operation, String key, String newValue) {
        // 参数校验
        if (filePath == null || filePath.isEmpty() || operation == null || operation.isEmpty() || key == null || key.isEmpty()) {
            Log.e("Snow", "Error: Invalid parameters - filePath: " + filePath + ", operation: " + operation + ", key: " + key + ", newValue: " + newValue);
            return "";
        }

        try {
            Path path = Paths.get(filePath);

            if (!operation.equals("get") && !operation.equals("set")) {
                Log.e("Snow", "Error: Invalid operation - " + operation);
                return "";
            }

            if (Files.notExists(path)) {
                if (operation.equals("get")) {
                    Log.e("Snow", "Error: File does not exist - " + filePath);
                    return "";
                }
                Log.d("Snow", "File not found, creating new file - " + filePath);
                Files.createFile(path);
            }

            List<String> lines = Files.readAllLines(path);
            boolean found = false;

            if (operation.equals("get")) {
                for (String line : lines) {
                    if (line.startsWith(key + "=")) {
                        String value = line.substring(line.indexOf('=') + 1);
                        map.put(key, value);
                        return value;
                    }
                }
                Log.e("Snow", "Info: Key not found - " + key);
                return "";
            }

            // 标记内部修改开始
            isInternalChange = true;

            for (int i = 0; i < lines.size(); i++) {
                if (lines.get(i).startsWith(key + "=")) {
                    lines.set(i, key + "=" + newValue);
                    found = true;
                    break;
                }
            }

            if (!found) {
                lines.add(key + "=" + newValue);
            }

            Files.write(path, lines);
            map.put(key, newValue);
            if (!syncedFiles.contains(filePath)) {
                syncedFiles.add(filePath);
            }

            // 标记内部修改结束
            isInternalChange = false;

            return newValue;

        } catch (IOException e) {
            Log.e("Snow", "Error: Could not update file " + filePath + ", operation: " + operation + ", key: " + key + ", newValue: " + newValue, e);
            isInternalChange = false; // 出错时重置标记
            return "";
        }
    }

    // 监视文件改动
    public static void monitorFileChanges() {
        Thread watchThread = new Thread(() -> {
            try {
                for (String filePath : syncedFiles) {
                    Path path = Paths.get(filePath);
                    path.getParent().register(watchService, StandardWatchEventKinds.ENTRY_MODIFY);
                }

                while (true) {
                    WatchKey key = watchService.take();
                    for (WatchEvent<?> event : key.pollEvents()) {
                        if (event.kind() == StandardWatchEventKinds.ENTRY_MODIFY) {
                            Path changed = (Path) event.context();
                            for (String filePath : syncedFiles) {
                                if (filePath.endsWith(changed.toString())) {
                                    if (!isInternalChange) { // 检查是否是内部修改
                                        Log.d("Snow", "File modified externally: " + filePath);
                                        ctl(filePath, "get", "", ""); // 只更新map, 不修改文件
                                    }
                                    break;
                                }
                            }
                        }
                    }
                    key.reset();
                }
            } catch (InterruptedException | IOException e) {
                Log.e("Snow", "Error monitoring file changes", e);
            }
        });
        watchThread.setDaemon(true);
        watchThread.start();
    }

    // get方法，快速从Map获取值，必要时同步文件
    public static String get(String filePath, String key, String defaultValue) {
        if (map.containsKey(key)) {
            return map.get(key);
        } else if (!syncedFiles.contains(filePath)) {
            String value = ctl(filePath, "get", key, null);
            if (value.isEmpty()) {
                return defaultValue;
            }
            syncedFiles.add(filePath);
            return value;
        } else {
            return defaultValue;
        }
    }

    // set方法，更新Map并同步文件
    public static String set(String filePath, String key, String newValue) {
        String result = ctl(filePath, "set", key, newValue);
        if (!syncedFiles.contains(filePath)) {
            syncedFiles.add(filePath);
        }
        return result;
    }

    public static String printAll() {
        String str="All key-value pairs in map:";
        for (Map.Entry<String, String> entry : map.entrySet()) {
            str=str+entry.getKey() + "=" + entry.getValue()+'\n';
        }

        str=str+"Synced files:\n";
        for (String file : syncedFiles) {
            str=str+file+'\n';
        }
        return str;
    }
}
