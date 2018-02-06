<%-- 
    Document   : index
    Created on : Feb 1, 2017, 1:53:53 PM
    Author     : Owner
--%>

<!This is a simple HTML page for the user to sign into their account>
<!Any data input on this page is sent to signinattempt.java to validate the user>
<!The post method is used make the user sign in more secure>

<!This next line is required to be here in order to connect to MySQL>
<%Class.forName("com.mysql.jdbc.Driver");%> 
<!DO NOT REMOVE IT>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Bob's Shipping</title>
    </head>
    <body background="background1.jpg">
        <h1>Sign In to Bob's Shipping</h1>        
        <table border="0">
            <tbody>
                <form name="myForm" action="SignInAttempt" method="POST">
                    <tr>
                        <td>Username:</td> 
                        <td><input type="text" name="username" value="" style="width:204px"/><span>*</span></td>
                    </tr>
                    <tr>
                        <td>Password:</td>
                        <td><input type="password" name="password" value="" style="width:204px"/><span>*</span></td>
                    </tr>
                    <tr>
                        <td></td>
                        <td><input type="submit" value="Submit" name="submit" style="width:208px"/></td>
                    </tr>
                </form>                
                <tr>
                    <td></td>
                    <td>
                        <form action="signup.jsp">
                            <input type="submit" value="Create Account" style="width:208px"/>
                        </form>
                    </td>
                </tr>                    
            </tbody>
        </table>       
    </body>
</html>
