import sounddevice as sd
import wavio
import numpy as np
import os

class AudioRecorder:
    def __init__(self, samplerate=44100):
        self.samplerate = samplerate
        self.recording = None
        self.is_recording = False

    def start_recording(self):
        if not self.is_recording:
            self.recording = sd.rec(int(10 * self.samplerate), samplerate=self.samplerate, channels=1, dtype=np.int16)
            self.is_recording = True
            print("Recording started...")
        else:
            print("Already recording...")

    def stop_recording(self, path):
        if self.is_recording:
            sd.wait()
            duration_ms = int(len(self.recording) / self.samplerate * 1000)
            filename = f"sound_file_demo_{duration_ms}_ms.wav"
            filepath = os.path.join(path, filename)
            wavio.write(filepath, self.recording, self.samplerate, sampwidth=2)
            print(f"Recording stopped. Audio saved to {filepath}")
            self.is_recording = False
        else:
            print("No recording in progress...")

recorder = AudioRecorder()

def start_recording():
    recorder.start_recording()

def stop_recording(path):
    recorder.stop_recording(path)

if __name__ == "__main__":
    import platform
    if platform.system() in ["Windows", "Darwin"]:
        recorder.start_recording()
    else:
        print("This script is designed to work on Windows and macOS systems only.")
