# -*- coding: utf-8 -*-

import time
import paramiko
from flask import Flask, render_template, jsonify, request

app = Flask(__name__)

# Az SSH és port beállítások
SSH_PASSWORD = 'PASSWORD OF YOUR HOST USER'
SSH_HOST = 'IP ADDRESS OF YOUR HOST WHERE YOUR CONTAINERS RUNNING'
SSH_USER = 'USER OF YOU HOST WHO HAS PRIVILIGE FOR DOCKER'
PORT = 5434  # Itt sztatikusan 5434 van, ezt felülírjuk a telepítőből

# Állítsa vissza a portot a telepítőből
def set_port(port):
    global PORT
    PORT = port

containers_data = []

def get_ssh_connection():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(SSH_HOST, username=SSH_USER, password=SSH_PASSWORD)
    return ssh

def convert_to_mb(value_str):
    value_str = value_str.strip()
    if value_str == 'N/A':
        return 0.0
    unit = ''
    num_part = ''
    for c in value_str:
        if c.isdigit() or c == '.':
            num_part += c
        else:
            unit = c.upper()
            break
    if not num_part:
        return 0.0
    try:
        num = float(num_part)
    except ValueError:
        return 0.0
    return num / 1024 if unit == 'K' else num if unit == 'M' else num * 1024 if unit == 'G' else num * 1024 * 1024 if unit == 'T' else num

def parse_docker_stats(output):
    containers = []
    for line in output.strip().split('\n'):
        parts = line.split('|')
        if len(parts) != 7:
            continue
        cid, name, cpu, mem, net, io, pids = parts
        try:
            cpu_percent = float(cpu.replace('%', ''))
        except ValueError:
            cpu_percent = 0.0

        mem_parts = mem.split('/')
        if len(mem_parts) == 2:
            mem_used, mem_total = mem_parts
            mem_used = mem_used.strip()
            mem_total = mem_total.strip()
            used_mb = convert_to_mb(mem_used)
            total_mb = convert_to_mb(mem_total)
            mem_percent = (used_mb / total_mb * 100) if total_mb > 0 else 0
            mem_used_formatted = f"{used_mb:.1f} MB"
        else:
            mem_used_formatted = mem.strip() + " MB"
            mem_percent = 0

        containers.append({
            'name': name,
            'cid': cid[:12],
            'cpu': cpu_percent,
            'cpu_display': f"{cpu_percent:.1f} %",
            'mem': mem_used_formatted,
            'mem_percent': mem_percent,
            'net': net,
            'io': io,
            'status': 'unknown'
        })
    return containers

def parse_container_status(status_str):
    status_str = status_str.strip()
    if "Paused" in status_str:
        return "paused"
    elif status_str.startswith("Up"):
        return "running"
    elif status_str.startswith("Exited"):
        return "stopped"
    else:
        return status_str

def fetch_docker_data():
    global containers_data
    command_stats = """
    docker stats --all --no-stream --format "{{.Container}}|{{.Name}}|{{.CPUPerc}}|{{.MemUsage}}|{{.NetIO}}|{{.BlockIO}}|{{.PIDs}}"
    """
    try:
        ssh = get_ssh_connection()
        stdin, stdout, stderr = ssh.exec_command(command_stats)
        output_stats = stdout.read().decode()
        containers = parse_docker_stats(output_stats)
        ssh.close()
    except Exception as e:
        print(f"Hiba az adatlekérés során: {str(e)}")
        containers = []

    # Lekérjük a konténerek státuszát
    command_status = """ docker ps -a --format "{{.ID}}|{{.Status}}" """
    try:
        ssh = get_ssh_connection()
        stdin, stdout, stderr = ssh.exec_command(command_status)
        output_status = stdout.read().decode()
        ssh.close()
    except Exception as e:
        print(f"Hiba a status lekérés során: {str(e)}")
        output_status = ""

    statuses = {}
    for line in output_status.strip().split('\n'):
        if not line:
            continue
        parts = line.split('|')
        if len(parts) == 2:
            container_id, stat = parts
            statuses[container_id[:12]] = parse_container_status(stat)

    for container in containers:
        container['status'] = statuses.get(container['cid'], 'unknown')

    containers_data = containers

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/data')
def data():
    fetch_docker_data()
    return jsonify(containers_data)

@app.route('/manage', methods=['POST'])
def manage():
    action = request.json.get('action')
    container_id = request.json.get('cid')
    manage_container(action, container_id)
    return jsonify(success=True)

def manage_container(action, container_id):
    # A "RESUME" gombnál az "unpause" parancs szükséges
    if action.lower() == 'resume':
        action = 'unpause'
    command = f"docker {action} {container_id}"
    try:
        ssh = get_ssh_connection()
        ssh.exec_command(command)
        ssh.close()
    except Exception as e:
        print(f"Hiba a konténer {action} során: {str(e)}")

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=PORT)
