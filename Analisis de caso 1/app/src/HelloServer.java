import com.sun.net.httpserver.HttpServer;
import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.Headers;

import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.Executors;

public class HelloServer {
    private static void respond(HttpExchange exchange, int code, String body, String contentType) throws IOException {
        byte[] bytes = body.getBytes(StandardCharsets.UTF_8);
        Headers headers = exchange.getResponseHeaders();
        headers.add("Content-Type", contentType + "; charset=utf-8");
        exchange.sendResponseHeaders(code, bytes.length);
        try (OutputStream os = exchange.getResponseBody()) {
            os.write(bytes);
        }
    }

    public static void main(String[] args) throws Exception {
        int port = Integer.parseInt(System.getenv().getOrDefault("PORT", "8080"));
        HttpServer server = HttpServer.create(new InetSocketAddress(port), 0);

        server.createContext("/", exchange -> {
            String html = "<!doctype html><html><head><meta charset='utf-8'><title>Hola</title></head>"
                        + "<body style='font-family: system-ui; text-align:center; margin-top:10vh'>"
                        + "<h1>Hola mundo desde Java \u2615</h1>"
                        + "<p>Podrás ver el balanceo con HAProxy refrescando esta página.</p>"
                        + "</body></html>";
            respond(exchange, 200, html, "text/html");
        });

        server.createContext("/health", exchange -> {
            respond(exchange, 200, "OK", "text/plain");
        });

        server.setExecutor(Executors.newFixedThreadPool(4));
        server.start();
        System.out.println("HelloServer escuchando en puerto " + port);
    }
}
