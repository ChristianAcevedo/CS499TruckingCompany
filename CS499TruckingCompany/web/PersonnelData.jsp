<%-- 
    Document   : PersonnelData
    Created on : Feb 9, 2018, 1:24:52 PM
    Author     : Owner
--%>

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
    public class PersonnelData{

        String URL_CS499TruckingCompany = "jdbc:mysql://aa1wk12raqf2yoe.ca2f0nfwjqou.us-east-1.rds.amazonaws.com:3306/CS499TruckingCompany";
        String USERNAME = "SeniorProject";
        String PASSWORD = "password";
        String AccessCode = "";

        Connection TruckingConnection = null;

        PreparedStatement GetCookiesTable = null;
        PreparedStatement GetSignInDataTable = null;

        ResultSet RSCookiesTable = null;
        ResultSet RSSignInDataTable = null;

        ResultSetMetaData MDCookiesTable = null;
        ResultSetMetaData MDSignInDataTable = null;

        Map<String, Integer> UserCookiesColumns = new HashMap<String, Integer>();
        Map<String, Integer> SignInDataColumns = new HashMap<String, Integer>();

        PersonnelData(){
        
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
}
%>

<%
    boolean SignedIn = false;    
        String UserName = "";   
        String UserID = "";
        String AccessCode = "";
        PersonnelData UserAccountInfo = new PersonnelData();
        
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
                    }
                }
            }catch(SQLException ex){
                ex.printStackTrace();
            }
        }
        
        if(AccessCode.contains("P") == false){
            response.sendRedirect("UserSignedIn.jsp");
        }

        if(SignedIn == false){
            response.sendRedirect("index.jsp");
        }
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Personnel Data</title>
    </head>
    <body>
        <h1>Personnel Data</h1>
    </body>
</html>
