package test;

import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.io.IOException;
import java.io.PrintWriter;

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnitRunner;

import httpServlet.Servlet;
import jakarta.servlet.ServletConfig;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@RunWith(MockitoJUnitRunner.class)
public class ServletTest {
  // create 3 mock objects
  @Mock
  private HttpServletRequest request;   
  @Mock
  private HttpServletResponse response; 
  @Mock // getServletContext() is a method of ServletConfig, so the ServletConfig mock object needs to be created
  private ServletConfig config; 
  
  private Servlet servlet;
   
  @Before // run before any of the following test methods
  public void setup() throws ServletException, IOException {
	// create a mock object that simulates the behavior of a real ServletContext object
    ServletContext servletContext = mock(ServletContext.class);
    // when the getServletContext() method is called on the mock ServletConfig object, return the mock ServletContext object
    when(config.getServletContext()).thenReturn(servletContext);
    // initialize the servlet with mock ServletConfig object
    servlet = new Servlet();
    servlet.init(config);
    // mock behavior of getWriter() to return a non-null PrintWriter
    PrintWriter writer = mock(PrintWriter.class);
    when(response.getWriter()).thenReturn(writer);
  }
  
  @Test
  public void testInvalidFilePath() throws Exception {
    // no fileName parameter
    when(request.getParameter("fileName")).thenReturn(null);
    servlet.doGet(request, response);
    verify(response).setStatus(HttpServletResponse.SC_BAD_REQUEST);
    // empty fileName parameter
    when(request.getParameter("fileName")).thenReturn("");
    servlet.doGet(request, response);
    verify(response, times(2)).setStatus(HttpServletResponse.SC_BAD_REQUEST);
  }
  
  @Test
  public void testFileExistence() throws Exception {
      String folderName = "mockFolder/";
      String fileName = "mock1.txt";
      // mock request parameters
      when(request.getParameter("fileName")).thenReturn(fileName);
      when(request.getParameter("folderName")).thenReturn(folderName);
      // construct relative path
      String basePath = "WEB-INF/employeeFolders/";
      String relativePath = basePath + folderName + fileName;
      // mock getServletContext() method of ServletConfig
      ServletContext servletContext = mock(ServletContext.class);
      when(config.getServletContext()).thenReturn(servletContext);
      // mock getRealPath() method of ServletContext
      when(servletContext.getRealPath(anyString())).thenReturn(relativePath);      
      servlet.doGet(request, response);  
      verify(response).setStatus(HttpServletResponse.SC_NOT_FOUND); 
  }
}
