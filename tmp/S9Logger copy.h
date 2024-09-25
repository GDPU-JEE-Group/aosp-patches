// S9Logger.h
#ifndef S9LOGGER_H
#define S9LOGGER_H

#include <log/log.h>
#include <cutils/properties.h>
#include <string>
#include <chrono>
#include <atomic>
#include <mutex>

namespace android {

class S9Logger {
public:
    S9Logger() : mEnabled(false), mLastCheckTime(0) {
        updateLogEnabled(); // 初始化时读取一次
    }

    // ALOGD 打印宏
    void logD(const char* tag, const char* fmt, ...) {
        if (isLogEnabled()) {
            va_list args;
            va_start(args, fmt);
            __android_log_vprint(ANDROID_LOG_DEBUG, tag, fmt, args);
            va_end(args);
        }
    }

    // ALOGW 打印宏
    void logW(const char* tag, const char* fmt, ...) {
        if (isLogEnabled()) {
            va_list args;
            va_start(args, fmt);
            __android_log_vprint(ANDROID_LOG_WARN, tag, fmt, args);
            va_end(args);
        }
    }

private:
    // 判断是否启用日志，5 秒更新一次
    bool isLogEnabled() {
        auto now = std::chrono::steady_clock::now();
        int64_t nowMs = std::chrono::duration_cast<std::chrono::milliseconds>(now.time_since_epoch()).count();

        // 每 5 秒（5000 毫秒）更新一次日志状态
        if (nowMs - mLastCheckTime.load() > 5000) {
            std::lock_guard<std::mutex> lock(mMutex); // 使用互斥锁防止并发问题
            // 再次检查时间，避免多线程环境下重复更新
            if (nowMs - mLastCheckTime.load() > 5000) {
                updateLogEnabled();
                mLastCheckTime.store(nowMs);
            }
        }
        return mEnabled;
    }

    // 更新日志开关状态
    void updateLogEnabled() {
        char value[PROPERTY_VALUE_MAX];
        // 读取系统属性，检查返回值确保无误
        if (property_get("debug.inputreader.log", value, "0") > 0) {
            mEnabled = (std::string(value) == "1");
        } else {
            mEnabled = false; // 读取失败时默认关闭日志
        }
    }

    std::atomic<bool> mEnabled;              // 缓存的日志状态
    std::atomic<int64_t> mLastCheckTime;     // 上次检查时间（毫秒）
    std::mutex mMutex;                       // 保护属性更新的互斥锁
};

} // namespace android

#endif // S9LOGGER_H
