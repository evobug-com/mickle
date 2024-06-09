#include "audio_manager.h"

#include <Audioclient.h>
#include <mmdeviceapi.h>
#include <endpointvolume.h>
#include <comdef.h>
#include <iostream>
#include <vector>
#include <string>
#include <Windows.h>
#include <propvarutil.h>
#include <functiondiscoverykeys_devpkey.h>
#include <thread>
#include <winrt/base.h>

// Link against the required libraries
#pragma comment(lib, "ole32.lib")
#pragma comment(lib, "propsys.lib")

// Helper function to convert WCHAR* to std::string (UTF-8)
std::string WideStringToUTF8(const std::wstring& wstr)
{
    if (wstr.empty()) return std::string();
    int size_needed = WideCharToMultiByte(CP_UTF8, 0, &wstr[0], (int)wstr.size(), NULL, 0, NULL, NULL);
    std::string strTo(size_needed, 0);
    WideCharToMultiByte(CP_UTF8, 0, &wstr[0], (int)wstr.size(), &strTo[0], size_needed, NULL, NULL);
    return strTo;
}

// Helper function to enumerate audio devices
flutter::EncodableList EnumerateAudioDevices(EDataFlow dataFlow)
{
    HRESULT hr;
    IMMDeviceEnumerator* pEnumerator = nullptr;
    IMMDeviceCollection* pCollection = nullptr;
    IMMDevice* pEndpoint = nullptr;
    IMMDevice* pDefaultDevice = nullptr;
    IPropertyStore* pProps = nullptr;
    LPWSTR pwszID = nullptr;

    hr = CoInitialize(nullptr);
    if (FAILED(hr))
    {
        std::cerr << "CoInitialize failed." << '\n';
        return {};
    }

    flutter::EncodableList devices;

    hr = CoCreateInstance(
        __uuidof(MMDeviceEnumerator), nullptr,
        CLSCTX_ALL, __uuidof(IMMDeviceEnumerator),
        (void**)&pEnumerator);
    if (FAILED(hr))
    {
        std::cerr << "CoCreateInstance failed." << '\n';
        CoUninitialize();
        return {};
    }

    hr = pEnumerator->GetDefaultAudioEndpoint(dataFlow, eConsole, &pDefaultDevice);
    if (FAILED(hr))
    {
        std::cerr << "GetDefaultAudioEndpoint failed." << '\n';
        pEnumerator->Release();
        CoUninitialize();
        return {};
    }

    hr = pEnumerator->EnumAudioEndpoints(dataFlow, DEVICE_STATE_ACTIVE, &pCollection);
    if (FAILED(hr))
    {
        std::cerr << "EnumAudioEndpoints failed." << '\n';
        pEnumerator->Release();
        CoUninitialize();
        return {};
    }

    UINT count;
    hr = pCollection->GetCount(&count);
    if (FAILED(hr))
    {
        std::cerr << "GetCount failed." << '\n';
        pCollection->Release();
        pEnumerator->Release();
        CoUninitialize();
        return {};
    }

    for (UINT i = 0; i < count; i++)
    {
        hr = pCollection->Item(i, &pEndpoint);
        if (FAILED(hr))
        {
            std::cerr << "Item failed." << '\n';
            continue;
        }

        hr = pEndpoint->GetId(&pwszID);
        if (FAILED(hr))
        {
            std::cerr << "GetId failed." << '\n';
            pEndpoint->Release();
            continue;
        }

        hr = pEndpoint->OpenPropertyStore(STGM_READ, &pProps);
        if (FAILED(hr))
        {
            std::cerr << "OpenPropertyStore failed." << '\n';
            CoTaskMemFree(pwszID);
            pEndpoint->Release();
            continue;
        }

        PROPVARIANT varName;
        PropVariantInit(&varName);

        hr = pProps->GetValue(PKEY_Device_FriendlyName, &varName);
        if (SUCCEEDED(hr))
        {
            std::wstring wname(varName.pwszVal);
            std::string name = WideStringToUTF8(wname);
            std::string id = WideStringToUTF8(pwszID);

            flutter::EncodableMap device;
            device[flutter::EncodableValue("name")] = flutter::EncodableValue(name);
            device[flutter::EncodableValue("id")] = flutter::EncodableValue(id);

            LPWSTR defaultDeviceId = nullptr;
            hr = pDefaultDevice->GetId(&defaultDeviceId);
            if (SUCCEEDED(hr) && id == WideStringToUTF8(defaultDeviceId))
            {
                device[flutter::EncodableValue("isDefault")] = flutter::EncodableValue(true);
            }
            else
            {
                device[flutter::EncodableValue("isDefault")] = flutter::EncodableValue(false);
            }
            CoTaskMemFree(defaultDeviceId);

            devices.push_back(flutter::EncodableValue(device));

            PropVariantClear(&varName);
        }

        pProps->Release();
        CoTaskMemFree(pwszID);
        pEndpoint->Release();
    }

    pCollection->Release();
    pEnumerator->Release();
    pDefaultDevice->Release();
    CoUninitialize();

    return devices;
}

flutter::EncodableList AudioManager::getInputDevices()
{
    return EnumerateAudioDevices(eCapture);
}

flutter::EncodableList AudioManager::getOutputDevices()
{
    return EnumerateAudioDevices(eRender);
}

std::map<std::string, std::atomic<bool>> AudioManager::captureStreams;
std::map<std::string, std::thread> AudioManager::captureThreads;

void AudioManager::captureAudio(const std::string& deviceId,
                                std::shared_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel) {
    HRESULT hr;
    IMMDeviceEnumerator* pEnumerator = nullptr;
    IMMDevice* pDevice = nullptr;
    IAudioClient* pAudioClient = nullptr;
    IAudioCaptureClient* pCaptureClient = nullptr;
    WAVEFORMATEX* pwfx = nullptr;
    UINT32 bufferFrameCount;
    BYTE* pData;
    DWORD flags;

    hr = CoInitialize(nullptr);
    if (FAILED(hr)) {
        OutputDebugString((L"Error: CoInitialize failed: " + winrt::to_hstring(_com_error(hr).ErrorMessage()) + L"\n").c_str());
        std::cerr << "CoInitialize failed: " << _com_error(hr).ErrorMessage() << '\n';
        return;
    }

    hr = CoCreateInstance(
        __uuidof(MMDeviceEnumerator), nullptr,
        CLSCTX_ALL, __uuidof(IMMDeviceEnumerator),
        (void**)&pEnumerator);
    if (FAILED(hr)) {
        OutputDebugString((L"Error: CoCreateInstance failed: " + winrt::to_hstring(_com_error(hr).ErrorMessage()) + L"\n").c_str());
        std::cerr << "CoCreateInstance failed: " << _com_error(hr).ErrorMessage() << '\n';
        CoUninitialize();
        return;
    }

    hr = pEnumerator->GetDevice(std::wstring(deviceId.begin(), deviceId.end()).c_str(), &pDevice);
    if (FAILED(hr)) {
        OutputDebugString((L"Error: GetDevice failed: " + winrt::to_hstring(_com_error(hr).ErrorMessage()) + L"\n").c_str());
        std::cerr << "GetDevice failed: " << _com_error(hr).ErrorMessage() << '\n';
        pEnumerator->Release();
        CoUninitialize();
        return;
    }

    hr = pDevice->Activate(__uuidof(IAudioClient), CLSCTX_ALL, nullptr, (void**)&pAudioClient);
    if (FAILED(hr)) {
        OutputDebugString((L"Error: Activate failed: " + winrt::to_hstring(_com_error(hr).ErrorMessage()) + L"\n").c_str());
        std::cerr << "Activate failed: " << _com_error(hr).ErrorMessage() << '\n';
        pDevice->Release();
        pEnumerator->Release();
        CoUninitialize();
        return;
    }

    hr = pAudioClient->GetMixFormat(&pwfx);
    if (FAILED(hr)) {
        OutputDebugString((L"Error: GetMixFormat failed: " + winrt::to_hstring(_com_error(hr).ErrorMessage()) + L"\n").c_str());
        std::cerr << "GetMixFormat failed: " << _com_error(hr).ErrorMessage() << '\n';
        pAudioClient->Release();
        pDevice->Release();
        pEnumerator->Release();
        CoUninitialize();
        return;
    }

    hr = pAudioClient->Initialize(AUDCLNT_SHAREMODE_SHARED, 0, 10000000, 0, pwfx, nullptr);
    if (FAILED(hr)) {
        OutputDebugString((L"Error: Initialize failed: " + winrt::to_hstring(_com_error(hr).ErrorMessage()) + L"\n").c_str());
        std::cerr << "Initialize failed: " << _com_error(hr).ErrorMessage() << '\n';
        CoTaskMemFree(pwfx);
        pAudioClient->Release();
        pDevice->Release();
        pEnumerator->Release();
        CoUninitialize();
        return;
    }

    hr = pAudioClient->GetBufferSize(&bufferFrameCount);
    if (FAILED(hr)) {
        OutputDebugString((L"Error: GetBufferSize failed: " + winrt::to_hstring(_com_error(hr).ErrorMessage()) + L"\n").c_str());
        std::cerr << "GetBufferSize failed: " << _com_error(hr).ErrorMessage() << '\n';
        CoTaskMemFree(pwfx);
        pAudioClient->Release();
        pDevice->Release();
        pEnumerator->Release();
        CoUninitialize();
        return;
    }

    hr = pAudioClient->GetService(__uuidof(IAudioCaptureClient), (void**)&pCaptureClient);
    if (FAILED(hr)) {
        OutputDebugString((L"Error: GetService failed: " + winrt::to_hstring(_com_error(hr).ErrorMessage()) + L"\n").c_str());
        std::cerr << "GetService failed: " << _com_error(hr).ErrorMessage() << '\n';
        CoTaskMemFree(pwfx);
        pAudioClient->Release();
        pDevice->Release();
        pEnumerator->Release();
        CoUninitialize();
        return;
    }

    hr = pAudioClient->Start();
    if (FAILED(hr)) {
        OutputDebugString((L"Error: Start failed: " + winrt::to_hstring(_com_error(hr).ErrorMessage()) + L"\n").c_str());
        std::cerr << "Start failed: " << _com_error(hr).ErrorMessage() << '\n';
        pCaptureClient->Release();
        CoTaskMemFree(pwfx);
        pAudioClient->Release();
        pDevice->Release();
        pEnumerator->Release();
        CoUninitialize();
        return;
    }

    OutputDebugString((L"Successfully started capturing: " + winrt::to_hstring(deviceId) + L"\n").c_str());

    // Capture loop
    while (captureStreams[deviceId].load()) {
        UINT32 packetLength = 0;
        hr = pCaptureClient->GetNextPacketSize(&packetLength);
        if (FAILED(hr)) {
            OutputDebugString((L"Error: GetNextPacketSize failed: " + winrt::to_hstring(_com_error(hr).ErrorMessage()) + L"\n").c_str());
            std::cerr << "GetNextPacketSize failed: " << _com_error(hr).ErrorMessage() << '\n';
            break;
        }

        while (packetLength != 0) {
            UINT32 numFramesAvailable;
            hr = pCaptureClient->GetBuffer(&pData, &numFramesAvailable, &flags, nullptr, nullptr);
            if (FAILED(hr)) {
                OutputDebugString((L"Error: GetBuffer failed: " + winrt::to_hstring(_com_error(hr).ErrorMessage()) + L"\n").c_str());
                std::cerr << "GetBuffer failed: " << _com_error(hr).ErrorMessage() << '\n';
                break;
            }

            // Convert audio data to Uint8List (std::vector<uint8_t>)
            std::vector<uint8_t> audioData(pData, pData + numFramesAvailable * pwfx->nBlockAlign);
            flutter::EncodableValue encodableAudioData(audioData);
            
            flutter::EncodableMap audioDataMap;
            audioDataMap[flutter::EncodableValue("deviceId")] = flutter::EncodableValue(deviceId);
            audioDataMap[flutter::EncodableValue("data")] = encodableAudioData;

            // Send audio data to Flutter
            channel->InvokeMethod("onAudioData", std::make_unique<flutter::EncodableValue>(audioDataMap));

            hr = pCaptureClient->ReleaseBuffer(numFramesAvailable);
            if (FAILED(hr)) {
                OutputDebugString((L"Error: ReleaseBuffer failed: " + winrt::to_hstring(_com_error(hr).ErrorMessage()) + L"\n").c_str());
                std::cerr << "ReleaseBuffer failed: " << _com_error(hr).ErrorMessage() << '\n';
                break;
            }

            hr = pCaptureClient->GetNextPacketSize(&packetLength);
            if (FAILED(hr)) {
                OutputDebugString((L"Error: GetNextPacketSize failed: " + winrt::to_hstring(_com_error(hr).ErrorMessage()) + L"\n").c_str());
                std::cerr << "GetNextPacketSize failed: " << _com_error(hr).ErrorMessage() << '\n';
                break;
            }
        }
    }

    hr = pAudioClient->Stop();
    if (FAILED(hr)) {
        OutputDebugString((L"Error: Stop failed: " + winrt::to_hstring(_com_error(hr).ErrorMessage()) + L"\n").c_str());
        std::cerr << "Stop failed: " << _com_error(hr).ErrorMessage() << '\n';
    }

    pCaptureClient->Release();
    CoTaskMemFree(pwfx);
    pAudioClient->Release();
    pDevice->Release();
    pEnumerator->Release();
    CoUninitialize();
}


void AudioManager::startCaptureStream(const std::string& deviceId,
                                      std::shared_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel) {
    // If the device ID is not in the map, add it and start capturing
    if (!captureStreams[deviceId]) {
        // Ensure the entry is added to the map
        captureStreams[deviceId] = true;

        // Start a new thread to capture audio from the device
        captureThreads[deviceId] = std::thread(captureAudio, deviceId, channel);
    }
}

void AudioManager::stopCaptureStream(const std::string& deviceId) {
    if (captureStreams.find(deviceId) != captureStreams.end()) {
        captureStreams[deviceId] = false;
        if (captureThreads[deviceId].joinable()) {
            captureThreads[deviceId].join();
        }
        captureStreams.erase(deviceId);
        captureThreads.erase(deviceId);
    }
}

void AudioManager::stopAllCaptureStreams() {
    for (auto& pair : captureStreams) {
        pair.second = false;
    }
    for (auto& pair : captureThreads) {
        if (pair.second.joinable()) {
            pair.second.join();
        }
    }
    captureStreams.clear();
    captureThreads.clear();
}