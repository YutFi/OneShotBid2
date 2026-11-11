package servlets;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;

@WebServlet("/image/*")
public class ImageServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String info = request.getPathInfo();
        if (info == null || info.length() < 2) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        // Only the bare file name is allowed (blocks ../ path traversal).
        String fileName = new File(info.substring(1)).getName();
        File dir = new File(util.DBConnector.imageDir());
        File file = new File(dir, fileName);

        if (!file.isFile()) {
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
