import socket, json, time

COMPLETION = 0
QUESTION = 1

def send_json(requests : list[dict]):
    HOST, PORT = "localhost", 9999
    
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        # Connect to the server
        sock.connect((HOST, PORT))
        print("Connected to server!")

        for data in requests:
            json_data = json.dumps(data).encode('utf-8')
            sock.sendall(json_data)
            
            # Receive the response
            response = sock.recv(1024)
            print(f"Response from server: {response.decode('utf-8')}")
        
        print("Shutting down connection...")
        shutdown = json.dumps({"opcode": 1234}).encode('utf-8')
        sock.sendall(shutdown)


def request(data : list[dict]) -> None:
    t1 = time.time()
    send_json(data)
    t2 = time.time()
    print(f'elapsed: {t2-t1:.2f} sec')


if __name__ == "__main__":
    req1 = {
        "opcode": 0,
        "prompt": "I hate Mondays. This sentence is",
        "choices": [
            "positive",
            "negative"
        ]
    }
    req2 = {
        "opcode": 2,
        "prompt": "I hate Mondays. This sentence is",
        "choices": [
            "positive",
            "negative"
        ],
        "reply": "positive",
        "rating": 5,
        "time": 1
    }
    
    request([req1, req2])
