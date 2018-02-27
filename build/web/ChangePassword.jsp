<%-- 
    Document   : ChangePassword
    Created on : Feb 24, 2018, 10:31:56 AM
    Author     : Owner
--%>

<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.sql.ResultSetMetaData"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<%!
    public class UserSignedIn{

        String URL_CS499TruckingCompany = "jdbc:mysql://aa1wk12raqf2yoe.ca2f0nfwjqou.us-east-1.rds.amazonaws.com:3306/CS499TruckingCompany";
        String USERNAME = "SeniorProject";
        String PASSWORD = "password";
        String AccessCode = "";
        String UpdateStatement = "";

        Connection TruckingConnection = null;

        PreparedStatement GetCookiesTable = null;
        PreparedStatement GetSignInDataTable = null;
        PreparedStatement GetAccessLevelsTable = null;
        PreparedStatement ChangePassword = null;

        ResultSet RSCookiesTable = null;
        ResultSet RSSignInDataTable = null;
        ResultSet RSAccessLevelsTable = null;

        ResultSetMetaData MDCookiesTable = null;
        ResultSetMetaData MDSignInDataTable = null;
        ResultSetMetaData MDAccessLevelsTable = null;

        Map<String, Integer> UserCookiesColumns = new HashMap<String, Integer>();
        Map<String, Integer> SignInDataColumns = new HashMap<String, Integer>();
        Map<String, Integer> AccessLevelsColumns = new HashMap<String, Integer>();

        UserSignedIn(){
        
            try{
                TruckingConnection = DriverManager.getConnection(URL_CS499TruckingCompany, USERNAME, PASSWORD);
                GetCookiesTable = TruckingConnection.prepareStatement("SELECT * FROM user_cookies_data");
                GetSignInDataTable = TruckingConnection.prepareStatement("SELECT * FROM sign_in_data");
                GetAccessLevelsTable = TruckingConnection.prepareStatement("SELECT * FROM access_levels");
                RSCookiesTable = GetCookiesTable.executeQuery();
                RSSignInDataTable = GetSignInDataTable.executeQuery();
                RSAccessLevelsTable = GetAccessLevelsTable.executeQuery();
                MDCookiesTable = RSCookiesTable.getMetaData();
                MDSignInDataTable = RSSignInDataTable.getMetaData();
                MDAccessLevelsTable = RSAccessLevelsTable.getMetaData();
                for(int MetaIndex = 1; MetaIndex <= MDCookiesTable.getColumnCount(); MetaIndex++){
                    UserCookiesColumns.put(MDCookiesTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDSignInDataTable.getColumnCount(); MetaIndex++){
                    SignInDataColumns.put(MDSignInDataTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDAccessLevelsTable.getColumnCount(); MetaIndex++){
                    AccessLevelsColumns.put(MDAccessLevelsTable.getColumnName(MetaIndex), MetaIndex);
                }
            }catch(SQLException ex){
                ex.printStackTrace();
            }

        }

        public ResultSet getCookiesTable(){
            try{
                RSCookiesTable = GetCookiesTable.executeQuery();
            }catch(SQLException ex){
                ex.printStackTrace();
            }
            return RSCookiesTable;   
        }

        public ResultSet getSignInDataTable(){
            try{
                RSSignInDataTable = GetSignInDataTable.executeQuery();
            }catch(SQLException ex){
                ex.printStackTrace();
            }
            return RSSignInDataTable;   
        }
        public ResultSet getAccessLevelsTable(){
            try{
                RSAccessLevelsTable = GetAccessLevelsTable.executeQuery();
            }catch(SQLException ex){
                ex.printStackTrace();
            }
            return RSAccessLevelsTable;   
        }
        
        public int changePassword(String UserName, String NewPassword){
            try{
                this.UpdateStatement = "UPDATE"
                    + " sign_in_data SET password = '" + NewPassword + "'"
                    + " WHERE user_name = '" + UserName + "'";
                ChangePassword = TruckingConnection.prepareStatement(UpdateStatement);
                return ChangePassword.executeUpdate();
            }catch(SQLException ex){
                ex.printStackTrace();
            }
            return 0;
        }
}
%>

<%
    boolean SignedIn = false;    
        String UserName = ""; 
        String Password = "";
        String UserID = "";
        String AccessCode = "";
        
        String UserNameInput = "";
        String CurrentPasswordInput = "";
        String NewPasswordInput = "";
        String ConfirmNewPasswordInput = "";
        
        int ValidInputCount = 0;
        UserSignedIn UserAccountInfo = new UserSignedIn();
        
        ResultSet CookiesTable = UserAccountInfo.getCookiesTable(); 
        ResultSet SignInDataTable = UserAccountInfo.getSignInDataTable();
        ResultSet AccessLevelsTable = UserAccountInfo.getAccessLevelsTable();
        Cookie cookies[] = request.getCookies();

        if(cookies != null){
            try{
                while(CookiesTable.next()){
                    for(Cookie c : cookies){
                        if(c.getName().equals(CookiesTable.getString(UserAccountInfo.UserCookiesColumns.get("cookie_name"))) &&
                                c.getValue().equals(CookiesTable.getString(UserAccountInfo.UserCookiesColumns.get("cookie_value")))){
                            SignedIn = true;
                            UserName = CookiesTable.getString(UserAccountInfo.UserCookiesColumns.get("user_name"));
                            UserID = CookiesTable.getString(UserAccountInfo.UserCookiesColumns.get("cookie_id"));    
                        }
                    }
                }
                while(SignInDataTable.next()){
                    if(SignInDataTable.getString(UserAccountInfo.SignInDataColumns.get("user_name")).equals(UserName)){
                        AccessCode = SignInDataTable.getString(UserAccountInfo.SignInDataColumns.get("access_code"));
                        Password = SignInDataTable.getString(UserAccountInfo.SignInDataColumns.get("password"));
                    }
                }
            }catch(SQLException ex){
                ex.printStackTrace();
            }
        }

        if(SignedIn == false){
            response.sendRedirect("index.jsp");
        }
        
        if(request.getParameter("UserName") != null){
            UserNameInput = request.getParameter("UserName");
            if(UserNameInput.equals(UserName)){
                ValidInputCount++;
            }
        }
        
        if(request.getParameter("CurrentPassword") != null){
            CurrentPasswordInput = request.getParameter("CurrentPassword");
            if(CurrentPasswordInput.equals(Password)){
                ValidInputCount++;
            }
        }
        
        if(request.getParameter("NewPassword") != null){
            if(NewPasswordInput.length() > 0){
                NewPasswordInput = request.getParameter("NewPassword");
                ValidInputCount++;
            }
        }
        
        if(request.getParameter("ConfirmNewPassword") != null){
            ConfirmNewPasswordInput = request.getParameter("ConfirmNewPassword");
            if(ConfirmNewPasswordInput.equals(NewPasswordInput)){
                ValidInputCount++;
            }
        }
        
        if(ValidInputCount == 4){
            UserAccountInfo.changePassword(UserNameInput, NewPasswordInput);
        }
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Change Password</title>
    </head>
    <body>
        <%if(ValidInputCount == 4){%>
            <h1>Password Changed Successfully!</h1>
        <%}%>
        <form action="ChangePassword.jsp" method="POST">
            <table border="0">
                <thead>
                    <tr>
                        <th></th>
                        <th>Change Password</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>User Name</td>
                        <td><input type="text" name="UserName" value="" /></td>
                    </tr>
                    <tr>
                        <td>Current Password</td>
                        <td><input type="password" name="CurrentPassword" value="" /></td>
                    </tr>
                    <tr>
                        <td>New Password</td>
                        <td><input type="password" name="NewPassword" value="" /></td>
                    </tr>
                    <tr>
                        <td>Confirm New Password</td>
                        <td><input type="password" name="ConfirmNewPassword" value="" /></td>
                    </tr>
                    <tr>
                        <td></td>
                        <td><input type="submit" value="Change Password" name="ChangePassword" /></td>
                    </tr>
                </tbody>
            </table>

            
        </form>
        
    </body>
</html>
