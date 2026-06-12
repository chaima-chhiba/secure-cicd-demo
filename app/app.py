from flask import Flask

app = Flask(__name__)

@app.route("/")
def hello():
    return {"status": "ok", "message": "Secure CI/CD Demo"}

@app.route("/health")
def health():
    return {"healthy": True}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)