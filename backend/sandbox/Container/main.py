import os
from flask import Flask, request, jsonify
import subprocess
from flask_cors import CORS  # si vas a necesitar CORS

app = Flask(__name__)
CORS(app)  # si tu backend general o frontend hace llamadas directas; si solo tu servidor llama, quizá no haga falta.

@app.route('/', methods=['POST'])
def ejecutar_codigo():
    data = request.get_json()
    codigo = data.get('code')
    timeout = data.get('timeoutMs', 1000)/1000

    with open('code.py', 'w') as f:
        f.write(codigo)
    try:
        result = subprocess.run(
            ["python3", "code.py"],
            capture_output=True,
            text=True,
            timeout=timeout
        )
        return jsonify({
            "stdout": result.stdout,
            "stderr": result.stderr,
            "isError": result.returncode != 0,
            "timedOut": False
        })
    except subprocess.TimeoutExpired:
        return jsonify({
            "stdout": "",
            "stderr": "",
            "isError": True,
            "timedOut": True
        })

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 3000))
    app.run(host="0.0.0.0", port=port)
