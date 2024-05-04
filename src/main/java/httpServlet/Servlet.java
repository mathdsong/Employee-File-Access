package httpServlet;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;

import org.apache.commons.io.FileUtils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/servlet/*")
public class Servlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	@Override
	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	    // retrieve two request parameters from the HttpServletRequest object
	    String fileName = request.getParameter("fileName");
	    String folderName = request.getParameter("folderName");

	    // get the  fullfile path based on the absolute file path
	    String fullFilePath = getServletContext().getRealPath("WEB-INF/employeeFolders/" + folderName + fileName);
	    System.out.println(fullFilePath);
	    // validate fileName parameter:
	    if (fileName == null || fileName.isEmpty()) {
	        response.setStatus(HttpServletResponse.SC_BAD_REQUEST); // 400
	        // write an error message to the response
	        response.getWriter().write("Error: Invalid or missing file name.");
	        return;
	    }

	    // check if the file exists
	    File downloadFile = new File(fullFilePath);
	    if (!downloadFile.exists()) {
	        response.setStatus(HttpServletResponse.SC_NOT_FOUND); // 404
	        response.getWriter().write("Error: Requested file not found.");
	        return;
	    }

	    String content = null;
	    try {
	    	// read file content
	        content = FileUtils.readFileToString(downloadFile, StandardCharsets.UTF_8);
		    // set the content type of the response
		    response.setContentType("text/html");
		    PrintWriter writer = response.getWriter();
		    // create the HTML string containing the file content
		    String htmlContent = "<html><body><pre>" + content + "</pre></body></html>"; // <pre> preserves the format
		    // Write the content to the HTTP response in the servlet
		    writer.write(htmlContent);
	        response.setStatus(HttpServletResponse.SC_OK); // 200
	    } catch (IOException e) {
	        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR); // 500
	        response.getWriter().write("Error occurred while reading the file.");
	        return;
	    }
	}

// Upload feature (Still working on it):
//    @Override
//    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
//        // Extract folder name from request parameter
//        String folderName = request.getParameter("folderName");
//
//        // Perform permission check (replace with your actual logic)
//        if (!hasPermission(request, folderName, "Upload")) {
//            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
//            response.getWriter().write("Error: You don't have permission to upload to this folder.");
//            return;
//        }
//
//        // Process file upload (using Apache Commons FileUpload)
//        try {
//            // Create a new file upload handler
//            DiskFileItemFactory fileItemFactory = new DiskFileItemFactory(null, 0, null, null);
//            ServletFileUpload upload = new ServletFileUpload(fileItemFactory);
//
//            // Parse the request to get uploaded items
//            List<FileItem> items = upload.parseRequest(request);
//
//            // Validate and process uploaded file
//            if (items != null && items.size() == 1) {
//                FileItem uploadedFileItem = items.get(0);
//
//                // Check if it's a file (not a form field)
//                if (uploadedFileItem.isFormField()) {
//                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
//                    response.getWriter().write("Error: Invalid upload request.");
//                    return;
//                }
//
//                // Get uploaded file name
//                String fileName = uploadedFileItem.getName();
//
//                // Construct full file path
//                String fullFilePath = getServletContext().getRealPath("WEB-INF/employeeFolders/" + folderName + fileName);
//
//                // Create a new file on the server
//                File uploadFile = new File(fullFilePath);
//                uploadFile.createNewFile();
//
//                // Write uploaded content to the file
//                uploadedFileItem.write(uploadFile);
//
//                // Success message (optional)
//                response.getWriter().write("File uploaded successfully!");
//            } else {
//                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
//                response.getWriter().write("Error: Invalid upload request.");
//            }
//        } catch (IOException e) {
//            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
//            response.getWriter().write("Error: An unexpected error occurred during upload.");
//        }
//    }
    
//    // based on request object or other mechanisms
//    private boolean hasPermission(HttpServletRequest request, String folderName, String permissionType) {
//        // Implement employee permission checking logic here
//        return true;
//    } 
}
