import socketserver
import getopt, sys
import json
import pipeline


REQUEST_LENGTH = 8192

def parse_json(data):
    opcode, prompt, choices = None, None, None

    opcode = data['opcode']
    if opcode == 1234:
        return None, True
    
    prompt = data['prompt']

    match opcode:
        case 0:
            choices = data['choices']
            reply = pipeline.completion(prompt, choices)
        case 1:
            reply = pipeline.question(prompt)
        case _:
            raise AssertionError

    response = {
        'status': 0,
        'response': reply
    }
    return response, False
    

class TCPRequestHandler(socketserver.BaseRequestHandler):

    def handle(self):
        print("Client connected.")
        shutdown = False

        while not shutdown:
            data = self.request.recv(REQUEST_LENGTH).strip()
            try:
                json_data = json.loads(data.decode('utf-8'))
                response, shutdown = parse_json(json_data)

            except KeyError:
                response = {
                    'status': -1,
                    'message' : 'json missing opcode',
                    'opcode' : -1
                }
            except AssertionError:
                response = {
                    'status': -1,
                    'message' : 'json opcode type error',
                    'opcode' : -1
                }
            except json.JSONDecodeError:
                response = {
                    'status': -1,
                    'message' : 'malformed json',
                    'opcode' : -1
                }
            
            if shutdown:
                self.server._BaseServer__shutdown_request = True
            else:
                self.request.sendall(json.dumps(response).encode('utf-8'))


if __name__ == "__main__":
    HOST = "localhost"
    port = None
    options, args = getopt.getopt(sys.argv[1:], "p:", ["port="])

    for opt, arg in options:
        if opt in ("-p", "--port"):
            port = int(arg)
        else:
            port = None
            break

    if port == None:
        print(f"Usage: python {sys.argv[0]} -p <port>")
        sys.exit()

    with socketserver.TCPServer((HOST, port), TCPRequestHandler) as server:
        print("Server starting up...")
        try:
            server.serve_forever()
        except KeyboardInterrupt:
            pass
        print("Server shutting down...")
