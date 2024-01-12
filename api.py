import os
import argparse
import json
from datetime import datetime
from http.server import BaseHTTPRequestHandler, HTTPServer

def runCommand(command):
    return os.popen(command).read().strip()

def days_difference(date_string):
    date_object = datetime.strptime(date_string, '%d/%m/%Y')
    today = datetime.now()
    difference = today - date_object
    days_difference = abs(difference.days)

    return days_difference

def format_date_for_anymod(date_string):
    date = datetime.strptime(date_string, "%d/%m/%Y")
    formatted_date = date.strftime("%Y-%m-%d-")
    return formatted_date
class HttpHandler(BaseHTTPRequestHandler):

    def do_GET(self):
        if self.path.startswith('/user='):
            try:
                username = self.path.split("user=")[1]

                userExists = int(runCommand(f"/bin/grep -wc {username} /etc/passwd")) != 0
                
                if(userExists):
                    # Data
                    expirationDate = runCommand(f"chage -l {username} | grep -i co | awk -F : '{{print $2}}'")
                    formattedExpirationDate = datetime.strptime(expirationDate, '%b %d, %Y').strftime('%d/%m/%Y')
                    formatted_expiration_date_for_anymod = format_date_for_anymod(formattedExpirationDate)
                    
                    # Limite Ssh
                    limit = runCommand(f"grep -w {username}  /root/usuarios.db | cut -d' ' -f2")

                    # Conexões ssh
                    sshConnections = runCommand(f"ps -u {username}  | grep sshd | wc -l")

                    days = days_difference(formattedExpirationDate)


                    user_info = {
                        "username": username,
                        "user_connected": sshConnections,
                        "user_limit": limit,
                        "expiration_date": expirationDate,
                        "formatted_expiration_date": formattedExpirationDate,
                        "formatted_expiration_date_for_anymod": formatted_expiration_date_for_anymod,
                        "remaining_days": days
                    }
                    self.send_response(200)
                    self.send_header('Content-type', 'application/json')
                    self.end_headers()
                    self.wfile.write(json.dumps(user_info).encode())
                else:
                    self.send_response(200)
                    self.end_headers()
                    self.wfile.write(str(f"O Usuario [{username}] não foi encontrado").encode())  # Added parentheses here

            except Exception as e:
                self.send_response(500)
                self.end_headers()
                self.wfile.write(str(e).encode())


            


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Servidor HTTP com porta personalizável")
    parser.add_argument('--port', type=int, default=5555, help="Porta do servidor (padrão: 5555)")
    args = parser.parse_args()

    porta = args.port
    server = HTTPServer(('0.0.0.0', porta), HttpHandler)
    print(f"Servidor iniciado na porta {porta}")
    server.serve_forever()
