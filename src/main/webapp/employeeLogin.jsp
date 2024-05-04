<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*" %>
<%@ page import="javax.sql.*" %>
<%@ page import="java.util.regex.Matcher" %>
<%@ page import="java.util.regex.Pattern" %>
<%@ page import="io.github.cdimascio.dotenv.Dotenv" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Employee Login</title>
		<style>
			table {
				position: absolute;
  				left: 50%;
  				top: 50%;
  				transform: translate(-50%, -50%);
			}
			body, a {
  				background-color: purple;
  				color: white;
  				font-family: consolas;
  				text-align: center;
  				font-size: 20px;
			}
		</style>
</head>
<body>
<%
Dotenv dotenv = Dotenv.load();
String db_url = dotenv.get("DB_URL");
String db_username = dotenv.get("DB_USERNAME");
String db_password = dotenv.get("DB_PASSWORD");
String EMAIL_PATTERN =
        "^(?=.{1,64}@)[A-Za-z0-9_-]+(\\.[A-Za-z0-9_-]+)*@"
        + "[^-][A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z]{2,})$";
Pattern pattern = Pattern.compile(EMAIL_PATTERN);
String email = request.getParameter("employeeEmail");
String passwd = request.getParameter("employeePassword");
Matcher matcher = pattern.matcher(email);
if(matcher.matches()){
	//Get session creation time.
	Date createTime = new Date(session.getCreationTime());
	session.setAttribute("employeeEmail", email);
	session.setMaxInactiveInterval(3600);  //1 hour session
	Class.forName("com.mysql.cj.jdbc.Driver");  
	Connection conn = DriverManager.getConnection(db_url, db_username, db_password);
	PreparedStatement prepStmt = conn.prepareStatement("select * from folders where employeeEmail=? and employeePassword=?");
	prepStmt.setString(1, email);
	prepStmt.setString(2, passwd);
	ResultSet rs = prepStmt.executeQuery();
	if(rs.next()){  //make sure the employee was found
		if(rs.getString(2).equals(passwd)){  // the employee password is the 2nd column
			// Grant access to the folders:
			prepStmt = conn.prepareStatement("select bondsFolderAccess, moneyFolderAccess, stockFolderAccess from folders where employeeEmail=? and employeePassword=?");
			prepStmt.setString(1, email);
			prepStmt.setString(2, passwd); 
			ResultSet queryResult = prepStmt.executeQuery();
			if (queryResult.next()) {
				// Get the folder access permission values
				// 0 means no access, 1 means read access, 2 means read and write access
			    int bondAccess = queryResult.getInt("bondsFolderAccess");
			    int moneyAccess = queryResult.getInt("moneyFolderAccess");
			    int stockAccess = queryResult.getInt("stockFolderAccess");
				// Read and write flags assigned default values
				boolean bondRead = bondAccess > 0;
				boolean bondWrite = bondAccess == 2;
				boolean moneyRead = moneyAccess > 0;
				boolean moneyWrite = moneyAccess == 2;
				boolean stockRead = stockAccess > 0;
				boolean stockWrite = stockAccess == 2;
				
				request.setAttribute("bondRead", bondRead);
				request.setAttribute("bondWrite", bondWrite);
				request.setAttribute("moneyRead", moneyRead);
				request.setAttribute("moneyWrite", moneyWrite);
				request.setAttribute("stockRead", stockRead);
				request.setAttribute("stockWrite", stockWrite);
				RequestDispatcher dispatcher = request.getRequestDispatcher("FileAccessPage.jsp");
				dispatcher.forward(request, response);
			} else {
				// Handle the case where no matching record is found in the 'folders' table
			    System.out.println("Error: No folder access permissions found for this employee.");
			}
			rs.close();
			prepStmt.close();
			conn.close();
		}
	}
	else{
		rs.close();
		prepStmt.close();
		conn.close();
		out.println("Invalid password or email not found, try again!");
	}
}
else{
	out.println("Bad email format, try again!");
}
%>
	<table>
		<tr><th><a href = "index.html">User Homepage</a></th></tr>
	</table>
</body>
</html>