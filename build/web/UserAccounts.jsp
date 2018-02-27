<%-- 
    Document   : UserAccounts
    Created on : Feb 24, 2018, 5:30:53 PM
    Author     : Owner
--%>

<%@page import="java.util.ArrayList"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.ResultSetMetaData"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<!DOCTYPE html>

<%!
    public class UserAccounts{

        String URL_CS499TruckingCompany = "jdbc:mysql://aa1wk12raqf2yoe.ca2f0nfwjqou.us-east-1.rds.amazonaws.com:3306/CS499TruckingCompany";
        String USERNAME = "SeniorProject";
        String PASSWORD = "password";
        String AccessCode = "";
        String DeleteStatementSignIn = "";
        String DeleteStatementCookie = "";

        Connection TruckingConnection = null;

        PreparedStatement GetCookiesTable = null;
        PreparedStatement GetSignInDataTable = null;
        PreparedStatement DeleteAccount = null;
        PreparedStatement DeleteCookieRecord = null;

        ResultSet RSCookiesTable = null;
        ResultSet RSSignInDataTable = null;

        ResultSetMetaData MDCookiesTable = null;
        ResultSetMetaData MDSignInDataTable = null;

        Map<String, Integer> UserCookiesColumns = new HashMap<String, Integer>();
        Map<String, Integer> SignInDataColumns = new HashMap<String, Integer>();
        Map<String, String> SignInDataColumnsText = new HashMap<String, String>();

        UserAccounts(){        
            try{
                TruckingConnection = DriverManager.getConnection(URL_CS499TruckingCompany, USERNAME, PASSWORD);
                GetCookiesTable = TruckingConnection.prepareStatement("SELECT * FROM user_cookies_data");
                GetSignInDataTable = TruckingConnection.prepareStatement("SELECT * FROM sign_in_data");
                RSCookiesTable = GetCookiesTable.executeQuery();
                RSSignInDataTable = GetSignInDataTable.executeQuery();
                MDCookiesTable = RSCookiesTable.getMetaData();
                MDSignInDataTable = RSSignInDataTable.getMetaData();
                for(int MetaIndex = 1; MetaIndex <= MDCookiesTable.getColumnCount(); MetaIndex++){
                    UserCookiesColumns.put(MDCookiesTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDSignInDataTable.getColumnCount(); MetaIndex++){
                    SignInDataColumns.put(MDSignInDataTable.getColumnName(MetaIndex), MetaIndex);
                    SignInDataColumnsText.put(MDSignInDataTable.getColumnName(MetaIndex), 
                        MDSignInDataTable.getColumnName(MetaIndex).toUpperCase().replaceAll("_", " "));
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

        public int deleteAccount(String UserName){
            DeleteStatementSignIn = "DELETE FROM sign_in_data WHERE user_name = '"+UserName+"'";
            DeleteStatementCookie = "DELETE FROM user_cookies_data WHERE user_name = '"+UserName+"'";
            try{
                DeleteAccount = TruckingConnection.prepareStatement(DeleteStatementSignIn);
                DeleteCookieRecord = TruckingConnection.prepareStatement(DeleteStatementCookie);;
                DeleteAccount.executeUpdate();
                DeleteCookieRecord.executeUpdate();
                return 1;
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
        String UserID = "";
        String AccessCode = "";
        UserAccounts UserAccountInfo = new UserAccounts();
        String UserNameInput = "";
        
        ResultSet CookiesTable = UserAccountInfo.getCookiesTable(); 
        ResultSet SignInDataTable = UserAccountInfo.getSignInDataTable();
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
                        break;
                    }
                }
                SignInDataTable = UserAccountInfo.getSignInDataTable();
            }catch(SQLException ex){
                ex.printStackTrace();
            }
        }

        if(SignedIn == false){
            response.sendRedirect("index.jsp");
        }
        
        if(AccessCode.contains("A") == false){
            response.sendRedirect("UserSignedIn.jsp");
        }
        
        if(request.getParameter("UserName") != null){
            UserNameInput = request.getParameter("UserName");
            try{
                while(SignInDataTable.next()){
                    if(UserNameInput.equals(SignInDataTable.getString(UserAccountInfo.SignInDataColumns.get("user_name")))){
                        UserAccountInfo.deleteAccount(UserNameInput);
                        SignInDataTable = UserAccountInfo.getSignInDataTable();
                        break;
                    }
                }
            }catch(SQLException ex){
                ex.printStackTrace();
            }
        }
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>User Accounts</title>
    </head>
    <body>
        <h1>User Accounts</h1>
        <table border="1">
            <thead>
                <tr>
                    <th><%=UserAccountInfo.SignInDataColumnsText.get("user_id")%></th>
                    <th><%=UserAccountInfo.SignInDataColumnsText.get("user_name")%></th>
                    <th><%=UserAccountInfo.SignInDataColumnsText.get("access_level")%></th>
                </tr>
            </thead>
            <tbody>
                <%try{
                    while(SignInDataTable.next()){%>
                        <tr>
                            <td><%=SignInDataTable.getString(UserAccountInfo.SignInDataColumns.get("user_id"))%></td>
                            <td><%=SignInDataTable.getString(UserAccountInfo.SignInDataColumns.get("user_name"))%></td>
                            <td><%=SignInDataTable.getString(UserAccountInfo.SignInDataColumns.get("access_level"))%></td>
                        </tr>
                    <%}%>
                <%}catch(SQLException ex){
                    ex.printStackTrace();
                }%>   
            </tbody>
        </table>
        
        <form name="DeleteAccount" action="UserAccounts.jsp">
            <table>
                <tr>
                    <td>Delete Account Name</td>
                    <td><input type="text" name="UserName" value="" /></td>
                    <td><input type="submit" value="Delete Account" name="DeleteAccountBtn" /></td>
                </tr>
            </table>
        </form>        
    </body>
</html>
