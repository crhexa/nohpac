import socketserver
import getopt, sys


class TCPRequestHandler(socketserver.BaseRequestHandler):

    def handle(self):
        return


if __name__ == "__main__":
    HOST = "localhost"
    port = None
    options, args = getopt.getopt(sys.argv[1:], "p:", ["port="])

    for opt, arg in options:
        if opt in ("-p", "--port"):
            port = opt
        else:
            port = None
            break

    if port == None:
        print(f"Usage: python {sys.argv[0]} -p <port>")
        sys.exit()

    with socketserver.TCPServer((HOST, port), TCPRequestHandler) as server:
        server.serve_forever()

