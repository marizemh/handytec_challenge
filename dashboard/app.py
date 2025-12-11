from flask import Flask, jsonify, render_template_string
import random
import time
import psutil

app = Flask(__name__)

# HTML Template
HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
    <title>DevOps Challenge Dashboard</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px; }
        .card { background: white; padding: 20px; margin: 10px 0; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        h1 { color: #333; }
        .metric { font-size: 1.2em; margin: 5px 0; }
        .status-ok { color: green; font-weight: bold; }
        .status-critical { color: red; font-weight: bold; }
    </style>
    <meta http-equiv="refresh" content="5">
</head>
<body>
    <h1>System Health Dashboard</h1>
    <div class="card">
        <h2>Server Metrics</h2>
        <div class="metric">CPU Usage: {{ cpu }}%</div>
        <div class="metric">Memory Usage: {{ memory }}%</div>
        <div class="metric">Disk Usage: {{ disk }}%</div>
    </div>
    <div class="card">
        <h2>Service Status: <span class="{{ 'status-ok' if status == 'Healthy' else 'status-critical' }}">{{ status }}</span></h2>
        <p>Last Updated: {{ timestamp }}</p>
    </div>
</body>
</html>
"""

@app.route('/')
def home():
    cpu = psutil.cpu_percent()
    memory = psutil.virtual_memory().percent
    disk = psutil.disk_usage('/').percent
    
    # Simulate health logic
    status = "Healthy"
    if cpu > 90 or memory > 90:
        status = "Critical (High Load)"
    
    return render_template_string(HTML_TEMPLATE, cpu=cpu, memory=memory, disk=disk, status=status, timestamp=time.ctime())

@app.route('/health')
def health():
    return jsonify({"status": "healthy", "cpu": psutil.cpu_percent()})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
