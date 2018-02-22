<%-- 
    Document   : UserSignedIn
    Created on : Feb 2, 2018, 7:25:45 PM
    Author     : Owner
--%>

<%@page import="java.sql.ResultSetMetaData"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%!
    public class UserSignedIn{

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

        UserSignedIn(){
        
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
        UserSignedIn UserAccountInfo = new UserSignedIn();
        
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

        if(SignedIn == false){
            response.sendRedirect("index.jsp");
        }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <%=AccessCode%>
    
    <body>
        <h1><%=UserName%> SignedIn</h1>
    </body>
    <table border="0">
            <tbody>
                <%if(AccessCode.contains("E")){%>
                    <form name="GoToEquipmentData" action="EquipmentData.jsp" method="POST">
                        <tr>
                            <td><input type="submit" value="View/Update Equipment Data" name="ViewUpdateEquipmentData" /></td>
                        </tr>
                    </form>
                <%}%>
                <%if(AccessCode.contains("D")){%>
                <form name="GoToDriverData" action="DriverData.jsp" method="POST">
                    <tr>
                        <td><input type="submit" value="View/Update Driver Data" name="ViewUpdateDriverData" /></td>
                    </tr>
                </form>
                <%}%>
                <%if(AccessCode.contains("M")){%>
                <form name="GoToMaintenanceData" action="MaintenanceData.jsp" method="POST">
                    <tr>
                        <td><input type="submit" value="View/Update Maintenance Data" name="ViewUpdateMaintenanceData" /></td>
                    </tr>
                </form>
                <%}%>
                <%if(AccessCode.contains("P")){%>
                <form name="GoToPersonnelData" action="PersonnelData.jsp" method="POST">
                    <tr>
                        <td><input type="submit" value="View/Update Personnel Data" name="ViewUpdatePersonnelData" /></td>
                    </tr>
                </form>
                <%}%>
                <%if(AccessCode.contains("S")){%>
                <form name="GoToShippingData" action="ShippingData.jsp" method="POST">
                    <tr>
                        <td><input type="submit" value="View/Update Shipping Data" name="ViewUpdateShippingData" /></td>
                    </tr>
                </form>
                <%}%>
            </tbody>
        </table>
</html>
