<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>File Access Page</title>
		<style>
			body {
  				background-color: purple;
  				color: white;
  				font-family: consolas;
  				text-align: left;
  				font-size: 20px;
			}
			
			table {
  				font-family: arial, sans-serif;
  				border-collapse: collapse;
 				width: 100%;
			}

			td, th {
				 border: 1px solid #dddddd;
				 text-align: left;
				 padding: 8px;
			}

			.button {
  				background-color: yellow;
			  	border: none;
				color: white;
				padding: 3px 10px;
				text-align: left;
				text-decoration: none;
				display: inline-block;
				font-size: 20px;
				font-family: consolas;
				margin: 4px 2px;
				cursor: pointer;
			}

			h2{
				color: white;
  				font-family: consolas;
  				font-size: 30px;
			}
			
			footer, header {
  				color: white;
  				font-family: consolas;
  				text-align: center;
  				font-size: 20px;
			}
			
			p, a, h1{
				color: white;
  				font-family: consolas;
  				font-size: 20px;
			}
		</style>
	
	</head>
	<body>
		<h2>You are logged in as <%= request.getParameter("employeeEmail")%>!<br></h2>
		<p><b>Folders</b></p>
		<%@ page import="java.io.File" %>
		<%@ page import="org.apache.commons.io.FileUtils" %>
		<%@ page import="java.nio.charset.StandardCharsets" %>
		<%@ page import="java.util.ArrayList" %>
		<% ArrayList<String> folderList = new ArrayList<>();
		   folderList.add("bond");
		   folderList.add("money");
		   folderList.add("stock");
		   for (int i = 0; i < folderList.size(); i++) {
			   String currFolder = folderList.get(i);
			   // Read permission:
			   if (Boolean.TRUE == request.getAttribute(currFolder + "Read")) { %>
				   <p>
  					<% if (!currFolder.substring(0, 1).equals("m")) { %>
    						<%= currFolder.substring(0, 1).toUpperCase() + currFolder.substring(1) + "s" %>
  					<% } else { %>
    						<%= currFolder.substring(0, 1).toUpperCase() + currFolder.substring(1) %>
  					<% } %>
					</p>
				    <ul>
					<%
					// Display the folder		
					String foldersPath = application.getRealPath("WEB-INF/employeeFolders/" + currFolder + "Folder/");
					File folder = new File(foldersPath);
					String[] fileNames = folder.list();
					File[] folderItems = folder.listFiles();
					if (folderItems != null) {
						for (int j = 0; j < folderItems.length; j++) {
							if (!folderItems[j].isDirectory()) {
								String filePath = foldersPath+fileNames[j];
								File currentFile = new File(filePath);
								String content = FileUtils.readFileToString(currentFile, StandardCharsets.UTF_8); 
								%>
								<li>
									<a href="servlet?folderName=<%= currFolder + "Folder/" %>&fileName=<%= fileNames[j] %>"  download="<%=fileNames[j] %>">
    									<%= fileNames[j] %>
									</a>
								</li>
							<%
							}     
						}
					}%>
					</ul>
					<% 
					// Upload permission check (still working on it)
      				if (Boolean.TRUE == request.getAttribute(currFolder + "Write")) { %>
        			<form action="servlet" method="post" enctype="multipart/form-data">
          				<input type="hidden" name="folderName" value="<%= currFolder + "Folder/" %>">
          				<input type="file" id="uploadFile" name="uploadFile" required>
          				<button type="submit">Upload</button>
        				</form>
        			<%
     				}
			   } 
		   }
		%>
		
		<footer>
			<a href = "employeeLogin.html">Return To Employee Login</a>
		</footer>
		
	</body>
</html>