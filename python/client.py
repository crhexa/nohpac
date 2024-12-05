import socket, json, time

COMPLETION = 0
QUESTION = 1

def send_json(data : dict):
    HOST, PORT = "localhost", 9999
    
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        # Connect to the server
        sock.connect((HOST, PORT))
        print("Connected to server!")
        
        # Send JSON data
        json_data = json.dumps(data).encode('utf-8')
        sock.sendall(json_data)
        
        # Receive the response
        response = sock.recv(1024)
        print(f"Response from server: {response.decode('utf-8')}")

def request(data : dict) -> None:
    t1 = time.time()
    send_json(data)
    t2 = time.time()
    print(f'elapsed: {t2-t1:.2f} sec')


if __name__ == "__main__":
    req1 = {
        "opcode": COMPLETION,
        "prompt": "I hate Mondays. This sentence is",
        "choices": [
            "positive",
            "negative"
        ]
    }
    req2 = {
        "opcode": COMPLETION,
        "prompt": "I love Tuesdays. This sentence is",
        "choices": [
            "positive",
            "negative"
        ]
    }
    stop = {
        "opcode": 1234
    }
    
    request(req1)
    request(req2)
    request(req1)
    request(req2)
    request(req1)
    request(req2)
    request(stop)
