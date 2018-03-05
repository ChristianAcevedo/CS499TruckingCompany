<%-- 
    Document   : ShippingData
    Created on : Feb 9, 2018, 1:22:43 PM
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
    public class ShippingData{

        String URL_CS499TruckingCompany = "jdbc:mysql://aa1wk12raqf2yoe.ca2f0nfwjqou.us-east-1.rds.amazonaws.com:3306/CS499TruckingCompany";
        String USERNAME = "SeniorProject";
        String PASSWORD = "password";
        String AccessCode = "";

        Connection TruckingConnection = null;

        PreparedStatement GetCookiesTable = null;
        PreparedStatement GetSignInDataTable = null;
        PreparedStatement GetShippingDataTable = null;

        ResultSet RSCookiesTable = null;
        ResultSet RSSignInDataTable = null;
        ResultSet RSShippingDataTable = null;

        ResultSetMetaData MDCookiesTable = null;
        ResultSetMetaData MDSignInDataTable = null;
        ResultSetMetaData MDShippingDataTable = null;

        Map<String, Integer> UserCookiesColumns = new HashMap<String, Integer>();
        Map<String, Integer> SignInDataColumns = new HashMap<String, Integer>();
        Map<String, Integer> ShippingDataColumns = new HashMap<String, Integer>();

        Map<String, String> ShippingDataColumnsText = new HashMap<String, String>();

        ShippingData(){
        
            try{
                TruckingConnection = DriverManager.getConnection(URL_CS499TruckingCompany, USERNAME, PASSWORD);
                GetCookiesTable = TruckingConnection.prepareStatement("SELECT * FROM user_cookies_data");
                GetSignInDataTable = TruckingConnection.prepareStatement("SELECT * FROM sign_in_data");
                GetShippingDataTable = TruckingConnection.prepareStatement("SELECT * FROM shipping_data");
                RSCookiesTable = GetCookiesTable.executeQuery();
                RSSignInDataTable = GetSignInDataTable.executeQuery();
                RSShippingDataTable = GetShippingDataTable.executeQuery();
                MDCookiesTable = RSCookiesTable.getMetaData();
                MDSignInDataTable = RSSignInDataTable.getMetaData();
                MDShippingDataTable = RSShippingDataTable.getMetaData();
                for(int MetaIndex = 1; MetaIndex <= MDCookiesTable.getColumnCount(); MetaIndex++){
                    UserCookiesColumns.put(MDCookiesTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDSignInDataTable.getColumnCount(); MetaIndex++){
                    SignInDataColumns.put(MDSignInDataTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDShippingDataTable.getColumnCount(); MetaIndex++){
                    ShippingDataColumns.put(MDShippingDataTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDShippingDataTable.getColumnCount(); MetaIndex++){
                    ShippingDataColumns.put(MDShippingDataTable.getColumnName(MetaIndex), MetaIndex);
                    ShippingDataColumnsText.put(MDShippingDataTable.getColumnName(MetaIndex), 
                        MDShippingDataTable.getColumnName(MetaIndex).toUpperCase().replaceAll("_", " "));
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

        public ResultSet getShippingDataTable(){
            try{
                RSShippingDataTable = GetShippingDataTable.executeQuery();
            }catch(SQLException ex){
                ex.printStackTrace();
            }
            return RSShippingDataTable;   
        }
}
%>

<%
    boolean SignedIn = false;    
        String UserName = "";   
        String UserID = "";
        String AccessCode = "";
        ShippingData UserAccountInfo = new ShippingData();
        
        ResultSet CookiesTable = UserAccountInfo.getCookiesTable(); 
        ResultSet SignInDataTable = UserAccountInfo.getSignInDataTable();
        ResultSet ShippingDataTable = UserAccountInfo.getShippingDataTable();
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
        }else if(AccessCode.contains("S") == false){
            response.sendRedirect("UserSignedIn.jsp");
        }
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Shipping Data</title>
    </head>
    <body>
        <h1>Shipping Data</h1>
        <table border="1">
            <thead>
                <tr>
                    <th><%=UserAccountInfo.ShippingDataColumnsText.get("shipment_id")%></th>
                    <th><%=UserAccountInfo.ShippingDataColumnsText.get("incoming_outgoing")%></th>
                    <th><%=UserAccountInfo.ShippingDataColumnsText.get("company")%></th>
                    <th><%=UserAccountInfo.ShippingDataColumnsText.get("street_address")%></th>
                    <th><%=UserAccountInfo.ShippingDataColumnsText.get("city")%></th>
                    <th><%=UserAccountInfo.ShippingDataColumnsText.get("state")%></th>
                    <th><%=UserAccountInfo.ShippingDataColumnsText.get("zip")%></th>
                    <th><%=UserAccountInfo.ShippingDataColumnsText.get("vehicle_id")%></th>
                    <th><%=UserAccountInfo.ShippingDataColumnsText.get("date_time")%></th>
                    <th><%=UserAccountInfo.ShippingDataColumnsText.get("confirmation_flag")%></th>
                    <th><%=UserAccountInfo.ShippingDataColumnsText.get("driver")%></th>
                    <th><%=UserAccountInfo.ShippingDataColumnsText.get("purchase_order")%></th>
                    <th><%=UserAccountInfo.ShippingDataColumnsText.get("shipment_manifest")%></th>
                </tr>
            </thead>
            <tbody>
                 <%try{
                    String Received = "Not Received";
                    while(ShippingDataTable.next()){
                        if(ShippingDataTable.getString(UserAccountInfo.ShippingDataColumns.get("confirmation_flag")).equals("1")){
                            Received = "Received";
                        }%>
                        <tr>
                            <td><%=ShippingDataTable.getString(UserAccountInfo.ShippingDataColumns.get("shipment_id"))%></td>
                            <td><%=ShippingDataTable.getString(UserAccountInfo.ShippingDataColumns.get("incoming_outgoing"))%></td>
                            <td><%=ShippingDataTable.getString(UserAccountInfo.ShippingDataColumns.get("company"))%></td>
                            <td><%=ShippingDataTable.getString(UserAccountInfo.ShippingDataColumns.get("street_address"))%></td>
                            <td><%=ShippingDataTable.getString(UserAccountInfo.ShippingDataColumns.get("city"))%></td>
                            <td><%=ShippingDataTable.getString(UserAccountInfo.ShippingDataColumns.get("state"))%></td>
                            <td><%=ShippingDataTable.getString(UserAccountInfo.ShippingDataColumns.get("zip"))%></td>
                            <td><%=ShippingDataTable.getString(UserAccountInfo.ShippingDataColumns.get("vehicle_id"))%></td>
                            <td><%=ShippingDataTable.getString(UserAccountInfo.ShippingDataColumns.get("date_time"))%></td>
                            <td><%=Received%>
                            <td><%=ShippingDataTable.getString(UserAccountInfo.ShippingDataColumns.get("driver"))%></td>
                            <td><%=ShippingDataTable.getString(UserAccountInfo.ShippingDataColumns.get("purchase_order"))%></td>
                            <td><%=ShippingDataTable.getString(UserAccountInfo.ShippingDataColumns.get("shipment_manifest"))%></td>
                        </tr>
                    <%}%>
                <%}catch(SQLException ex){
                    ex.printStackTrace();
                }%>   
            </tbody>
        </table>
    </body>
</html>
