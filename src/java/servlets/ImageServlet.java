package servlets;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;

@WebServlet("/image/*")
public class ImageServlet extends HttpServlet {
    private static final String IMAGE_DIR = "C:\\auction-images";

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String fileName = request.getPathInfo().substring(1); // remove leading /
        File file = new File(IMAGE_DIR, fileName);

        if (!file.exists()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String mime = getServletContext().getMimeType(file.getName());
        if (mime == null) mime = "application/octet-stream";
        response.setContentType(mime);
        response.setContentLength((int) file.length());

        try (FileInputStream in = new FileInputStream(file);
             OutputStream out = response.getOutputStream()) {
            byte[] buffer = new byte[4096];
            int length;
            while ((length = in.read(buffer)) > 0) {
                out.write(buffer, 0, length);
            }
        }
    }
}
