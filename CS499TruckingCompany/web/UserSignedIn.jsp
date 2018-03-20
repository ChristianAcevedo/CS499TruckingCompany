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
        String NewUserStatement = "";

        Connection TruckingConnection = null;

        PreparedStatement GetCookiesTable = null;
        PreparedStatement GetSignInDataTable = null;
        PreparedStatement GetAccessLevelsTable = null;
        PreparedStatement InsertNewAccount = null;

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
        
        public int addUser(String UserName, String Password, 
            String AccessLevel, String AccessCode){
            try{
                this.NewUserStatement = "INSERT INTO sign_in_data "
                    + "(user_name, "
                    + "password, "
                    + "access_level, "
                    + "access_code) "
                    + "VALUES ('"+UserName+"', "
                    + "'"+Password+"', "
                    + "'"+AccessLevel+"', "
                    + "'"+AccessCode+"')";
                InsertNewAccount = TruckingConnection.prepareStatement(NewUserStatement);
                return InsertNewAccount.executeUpdate();
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
        UserSignedIn UserAccountInfo = new UserSignedIn();
        
        String UserNameInput = "";
        String TemporaryPasswordInput = "";
        String AccessLevelInput = "";
        String AccessCodeInput = "";
        
        int ValidInputCount = 0;
        
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
                    }
                }
            }catch(SQLException ex){
                ex.printStackTrace();
            }
        }

        if(SignedIn == false){
            response.sendRedirect("index.jsp");
        }
        
        if(request.getParameter("UserNameInput") != null){
            UserNameInput = request.getParameter("UserNameInput");
            ValidInputCount++;
            try{
                while(SignInDataTable.next()){
                    if(UserNameInput.equals(SignInDataTable.getString(UserAccountInfo.SignInDataColumns.get("user_name"))) &&
                            UserNameInput.length() > 0){
                        ValidInputCount--;
                    }
                }   
                SignInDataTable = UserAccountInfo.getSignInDataTable();
            }catch(SQLException ex){
                ex.printStackTrace();
            }
        }
        
        if(request.getParameter("TemporaryPasswordInput") != null){
            TemporaryPasswordInput = request.getParameter("TemporaryPasswordInput");
            ValidInputCount++;
        }
        
        if(request.getParameter("AccessLevelInput") != null){
            AccessLevelInput = request.getParameter("AccessLevelInput");
            try{
                while(AccessLevelsTable.next()){
                    if(AccessLevelInput.equals(AccessLevelsTable.getString(UserAccountInfo.AccessLevelsColumns.get("access_level_name")))){
                        AccessCodeInput = AccessLevelsTable.getString(UserAccountInfo.AccessLevelsColumns.get("access_level_code"));
                    }
                }  
                AccessLevelsTable = UserAccountInfo.getAccessLevelsTable();
                ValidInputCount++;
            }catch(SQLException ex){
                ex.printStackTrace();
            }
        }
        
        if(ValidInputCount == 3){
            UserAccountInfo.addUser(UserNameInput, TemporaryPasswordInput, AccessLevelInput, AccessCodeInput);
        }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>User Signed In</title>
    </head>
    
    <body>
        <h1><%=UserName%> Signed In</h1>
        <%if(ValidInputCount == 3){%>
        <h2>New Account Successfully Created!</h2> 
        <%}%>
        <table border="0">
            <tbody>
                <col width="200">
                <%if(AccessCode.contains("E")){%>
                    <form name="GoToEquipmentData" action="EquipmentData.jsp" method="POST">
                        <tr>
                            <td><input type="submit" value="View/Update Equipment Data" name="ViewUpdateEquipmentData" style="width: 200px;"/></td>
                        </tr>
                    </form>
                <%}%>
                <%if(AccessCode.contains("D")){%>
                <form name="GoToDriverData" action="DriverData.jsp" method="POST">
                    <tr>
                        <td><input type="submit" value="View/Update Driver Data" name="ViewUpdateDriverData" style="width: 200px;"/></td>
                    </tr>
                </form>
                <%}%>
                <%if(AccessCode.contains("M")){%>
                <form name="GoToMaintenanceData" action="MaintenanceData.jsp" method="POST">
                    <tr>
                        <td><input type="submit" value="View/Update Maintenance Data" name="ViewUpdateMaintenanceData" style="width: 200px;"/></td>
                    </tr>
                </form>
                <%}%>
                <%if(AccessCode.contains("P")){%>
                <form name="GoToPersonnelData" action="PersonnelData.jsp" method="POST">
                    <tr>
                        <td><input type="submit" value="View/Update Personnel Data" name="ViewUpdatePersonnelData" style="width: 200px;"/></td>
                    </tr>
                </form>
                <%}%>
                <%if(AccessCode.contains("S")){%>
                <form name="GoToShippingData" action="ShippingData.jsp" method="POST">
                    <tr>
                        <td><input type="submit" value="View/Update Shipping Data" name="ViewUpdateShippingData" style="width: 200px;"/></td>
                    </tr>
                </form>
                <%}%>
                <%if(AccessCode.contains("A")){%>
                <form name =GoToUserAccounts" action="UserAccounts.jsp" method="POST">
                    <tr>
                        <td><input type="submit" value="View User Accounts" name="ViewUserAccounts" style="width: 200px;"/></td>
                    </tr>
                </form>
                <form name="GoToShippingData" action="UserSignedIn.jsp" method="POST">
                    <tr>
                        <td style = "text-align: center;">Create New Account</td>
                    </tr>
                    <tr>
                        <td><input type="text" name="UserNameInput" value="" style="width: 200px;" placeholder="New User Name"/></td>
                    </tr>
                    <tr>
                        <td><input type="password" name="TemporaryPasswordInput" value="" style="width: 200px;" placeholder="Temporary Password"/></td>
                    </tr>
                    <tr>
                        <td>
                            <select name="AccessLevelInput" style="width: 200px;">
                                <%while(AccessLevelsTable.next()){%>
                                    <option><%=AccessLevelsTable.getString(UserAccountInfo.AccessLevelsColumns.get("access_level_name"))%></option>
                                <%}%>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <td><input type="submit" value="Add New Account" name="AddNewAccount" style="width: 200px;"/></td>
                    </tr>                    
                </form>
                <%}%>
                <tr>
                    <td></td>
                    <td>
                        <form name="ChangePassword" action="ChangePassword.jsp" method="POST">
                            <input type="submit" value="Change Password" name="ChangePassword" />
                        </form>
                    </td>
                </tr>
            </tbody>
        </table>
    </body>
</html>
