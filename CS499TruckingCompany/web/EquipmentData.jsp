<%-- 
    Document   : EquipmentData
    Created on : Feb 9, 2018, 1:22:13 PM
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
<!DOCTYPE html>
<%!
    public class EquipmentData{

        String URL_CS499TruckingCompany = "jdbc:mysql://aa1wk12raqf2yoe.ca2f0nfwjqou.us-east-1.rds.amazonaws.com:3306/CS499TruckingCompany";
        String USERNAME = "SeniorProject";
        String PASSWORD = "password";
        String AccessCode = "";

        Connection TruckingConnection = null;

        PreparedStatement GetCookiesTable = null;
        PreparedStatement GetSignInDataTable = null;
        PreparedStatement GetEquipmentDataTable = null;

        ResultSet RSCookiesTable = null;
        ResultSet RSSignInDataTable = null;
        ResultSet RSEquipmentDataTable = null;

        ResultSetMetaData MDCookiesTable = null;
        ResultSetMetaData MDSignInDataTable = null;
        ResultSetMetaData MDEquipmentDataTable = null;

        Map<String, Integer> UserCookiesColumns = new HashMap<String, Integer>();
        Map<String, Integer> SignInDataColumns = new HashMap<String, Integer>();
        Map<String, Integer> EquipmentDataColumns = new HashMap<String, Integer>();

        Map<String, String> EquipmentDataColumnsText = new HashMap<String, String>();

        EquipmentData(){        
            try{
                TruckingConnection = DriverManager.getConnection(URL_CS499TruckingCompany, USERNAME, PASSWORD);
                GetCookiesTable = TruckingConnection.prepareStatement("SELECT * FROM user_cookies_data");
                GetSignInDataTable = TruckingConnection.prepareStatement("SELECT * FROM sign_in_data");
                GetEquipmentDataTable = TruckingConnection.prepareStatement("SELECT * FROM equipment_data");
                RSCookiesTable = GetCookiesTable.executeQuery();
                RSSignInDataTable = GetSignInDataTable.executeQuery();
                RSEquipmentDataTable = GetEquipmentDataTable.executeQuery();
                MDCookiesTable = RSCookiesTable.getMetaData();
                MDSignInDataTable = RSSignInDataTable.getMetaData();
                MDEquipmentDataTable = RSEquipmentDataTable.getMetaData();
                for(int MetaIndex = 1; MetaIndex <= MDCookiesTable.getColumnCount(); MetaIndex++){
                    UserCookiesColumns.put(MDCookiesTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDSignInDataTable.getColumnCount(); MetaIndex++){
                    SignInDataColumns.put(MDSignInDataTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDEquipmentDataTable.getColumnCount(); MetaIndex++){
                    EquipmentDataColumns.put(MDEquipmentDataTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDEquipmentDataTable.getColumnCount(); MetaIndex++){
                    EquipmentDataColumns.put(MDEquipmentDataTable.getColumnName(MetaIndex), MetaIndex);
                    EquipmentDataColumnsText.put(MDEquipmentDataTable.getColumnName(MetaIndex), 
                        MDEquipmentDataTable.getColumnName(MetaIndex).toUpperCase().replaceAll("_", " "));
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

        public ResultSet getEquipmentDataTable(){
            try{
                RSEquipmentDataTable = GetEquipmentDataTable.executeQuery();
            }catch(SQLException ex){
                ex.printStackTrace();
            }
            return RSEquipmentDataTable;   
        }
}
%>

<%
    boolean SignedIn = false;    
        String UserName = "";   
        String UserID = "";
        String AccessCode = "";
        EquipmentData UserAccountInfo = new EquipmentData();
        
        ResultSet CookiesTable = UserAccountInfo.getCookiesTable(); 
        ResultSet SignInDataTable = UserAccountInfo.getSignInDataTable();
        ResultSet EquipmentDataTable = UserAccountInfo.getEquipmentDataTable();
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
        }else if(AccessCode.contains("E") == false){
            response.sendRedirect("UserSignedIn.jsp");
        }
        
        
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Equipment Data</title>
    </head>
    <body>
        <h1>Equipment Data</h1>
        <form name="EquipmentDataGetter" action="ShippingData.jsp" method="POST">
            <table border="1">
                <thead>
                    <tr>
                        <th><%=UserAccountInfo.EquipmentDataColumnsText.get("equipment_id")%></th>
                        <th><%=UserAccountInfo.EquipmentDataColumnsText.get("brand")%></th>
                        <th><%=UserAccountInfo.EquipmentDataColumnsText.get("year")%></th>
                        <th><%=UserAccountInfo.EquipmentDataColumnsText.get("model")%></th>
                        <th><%=UserAccountInfo.EquipmentDataColumnsText.get("type")%></th>
                        <th><%=UserAccountInfo.EquipmentDataColumnsText.get("parts_list")%></th>
                        <th><%=UserAccountInfo.EquipmentDataColumnsText.get("maintenance_record_id")%></th>
                    </tr>
                </thead>
                <tbody>
                     <%try{
                        while(EquipmentDataTable.next()){%>              
                            <tr>
                                <td><%=EquipmentDataTable.getString(UserAccountInfo.EquipmentDataColumns.get("equipment_id"))%></td>
                                <td><%=EquipmentDataTable.getString(UserAccountInfo.EquipmentDataColumns.get("brand"))%></td>
                                <td><%=EquipmentDataTable.getString(UserAccountInfo.EquipmentDataColumns.get("year"))%></td>
                                <td><%=EquipmentDataTable.getString(UserAccountInfo.EquipmentDataColumns.get("model"))%></td>
                                <td><%=EquipmentDataTable.getString(UserAccountInfo.EquipmentDataColumns.get("type"))%></td>
                                <td><%=EquipmentDataTable.getString(UserAccountInfo.EquipmentDataColumns.get("parts_list"))%></td>
                                <td><%=EquipmentDataTable.getString(UserAccountInfo.EquipmentDataColumns.get("maintenance_record_id"))%></td>
                            </tr>                            
                        <%}%>
                    <%}catch(SQLException ex){
                        ex.printStackTrace();
                    }%>   
                </tbody>
            </table>
        </form>        
    </body>
</html>
