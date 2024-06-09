//
// Created by jan on 6/2/2024.
//

#ifndef AUDIO_MANAGER_H
#define AUDIO_MANAGER_H

#include <flutter/encodable_value.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <string>
#include <map>
#include <thread>
#include <atomic>
#include <memory>


class AudioManager {
public:
    static flutter::EncodableList getInputDevices();
    static flutter::EncodableList getOutputDevices();
    static void startCaptureStream(const std::string &deviceId, std::shared_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel);
    static void stopCaptureStream(const std::string &deviceId);
    static void stopAllCaptureStreams();
private:
    static std::map<std::string, std::atomic<bool>> captureStreams;
    static std::map<std::string, std::thread> captureThreads;

    static void captureAudio(const std::string& deviceId,
                             std::shared_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel);
};



#endif //AUDIO_MANAGER_H
