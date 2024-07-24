from flask import Flask, request, jsonify, render_template
from flask_cors import CORS
import sounddevice as sd
import numpy as np
import threading
import wave
from pydub import AudioSegment

app = Flask(__name__)
CORS(app)

# Variable to hold the current status
current_status = "Not Listening"
recording = False
audio_thread = None
recording_number = 1

def record_audio():
    global recording, recording_number
    filename = f"recorded_audio_{recording_number}.wav"
    sample_rate = 44100  # 44.1kHz sample rate
    channels = 1  # Mono
    dtype = 'int16'  # 16-bit audio

    audio_data = []

    def callback(indata, frames, time, status):
        if status:
            print(status)
        audio_data.append(indata.copy())

    with sd.InputStream(samplerate=sample_rate, channels=channels, dtype=dtype, callback=callback):
        while recording:
            sd.sleep(100)

    audio_array = np.concatenate(audio_data, axis=0)
    
    audio_segment = AudioSegment(
        audio_array.tobytes(),
        frame_rate=sample_rate,
        sample_width=audio_array.dtype.itemsize,  # Automatically detects sample width
        channels=channels
    )

    # Normalize the audio to reduce background noise
    audio_segment = audio_segment.normalize()

    audio_segment.export(filename, format="wav")
    print(f"Saved recording to {filename}")
    recording_number += 1

@app.route('/')
def home():
    return render_template('index.html', status=current_status)

@app.route('/api/action', methods=['POST'])
def handle_action():
    global current_status, recording, audio_thread
    data = request.json
    # Update the current status based on the received data
    if data.get("isListening"):
        current_status = "Listening"
        if not recording:
            recording = True
            audio_thread = threading.Thread(target=record_audio)
            audio_thread.start()
    else:
        current_status = "Not Listening"
        if recording:
            recording = False
            if audio_thread:
                audio_thread.join()
                audio_thread = None
    print(current_status)
    # Send a response back to the client
    return jsonify({"message": "Action received!", "data": data}), 200

@app.route('/api/status', methods=['GET'])
def get_status():
    global current_status
    return jsonify({"status": current_status}), 200

if __name__ == '__main__':
    app.run(debug=True)
