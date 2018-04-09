<%-- 
    Document   : ShippingData
    Created on : Feb 9, 2018, 1:22:43 PM
    Author     : Mr. Mango
--%>

<%@page import="java.util.Calendar"%>
<%@page import="java.util.Date"%>
<%@page import="java.util.TimeZone"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Locale"%>
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
        Map<String, Integer> ShippingDataColumnsPrecision = new HashMap<String, Integer>();

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
                    ShippingDataColumnsPrecision.put(MDShippingDataTable.getColumnName(MetaIndex), MDShippingDataTable.getPrecision(MetaIndex));
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
        Map<String, String> NewShippingDataInput = new HashMap<String, String>();
        
        
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
        
        String IncomingOutgoingCode = "10";
        if(request.getParameter("IncomingOutgoing") != null){
            IncomingOutgoingCode = request.getParameter("IncomingOutgoing");
        }
        
        boolean GoodInput = true;
        for (String key : UserAccountInfo.ShippingDataColumnsText.keySet()) {
            if(request.getParameter(UserAccountInfo.ShippingDataColumnsText.get(key) + " INPUT") == null ||
                    request.getParameter(UserAccountInfo.ShippingDataColumnsText.get(key) + " INPUT") == ""){
                if(key.equals("shipment_id") == false){
                    GoodInput = false;
                    break;
                }                
            }else{
                //if(key.equals())
                NewShippingDataInput.put(key,request.getParameter(UserAccountInfo.ShippingDataColumnsText.get(key) + " INPUT"));
            }
        }
        int test = 0;
        String AddShippingRecord = "INSERT INTO shipping_data (";
        if(GoodInput == true){
            for(String key : UserAccountInfo.ShippingDataColumnsText.keySet()){
                if(key.equals("shipment_id") == false){
                    AddShippingRecord = AddShippingRecord + key + ",";
                }
            }
            AddShippingRecord = AddShippingRecord.substring(0, AddShippingRecord.length() - 1) + ") VALUES (";
            for(String key : UserAccountInfo.ShippingDataColumnsText.keySet()){
                if(key.equals("shipment_id") == false){
                    if(key.equals("date_time")){
                        SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd", Locale.US);
                        format.setTimeZone(TimeZone.getTimeZone("UTC"));
                        Date date2 = format.parse(NewShippingDataInput.get(key));
                        String timeInMillis = Long.toString(date2.getTime());
                        NewShippingDataInput.put(key, timeInMillis);
                    }
                    AddShippingRecord = AddShippingRecord + "'" + NewShippingDataInput.get(key) + "',";
                }
            }
            AddShippingRecord = AddShippingRecord.substring(0, AddShippingRecord.length() - 1) + ")";
            PreparedStatement AddShippingRecordStatement = 
                    UserAccountInfo.TruckingConnection.prepareStatement(AddShippingRecord);
            test = AddShippingRecordStatement.executeUpdate();
            ShippingDataTable = UserAccountInfo.getShippingDataTable();
        }
        
        if(request.getParameter("RefreshUpdate") != null){
            if(request.getParameter("RefreshUpdate").equals("Update")){
                String RowID = "0";
                String UpdateStatement = "";
                String CurrentParameter = "";
                boolean MakeChange = false;
                while(ShippingDataTable.next()){
                    UpdateStatement = "UPDATE shipping_data SET";
                    MakeChange = false;
                    RowID = ShippingDataTable.getString(UserAccountInfo.ShippingDataColumns.get("shipment_id"));
                    for(String key : UserAccountInfo.ShippingDataColumnsText.keySet()){
                        if(request.getParameter(RowID + " " + UserAccountInfo.ShippingDataColumnsText.get(key) + " UPDATE") != null){
                            CurrentParameter = request.getParameter(RowID + " " + UserAccountInfo.ShippingDataColumnsText.get(key) + " UPDATE");
                            if(key.equals("date_time")){
                                SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd", Locale.US);
                                format.setTimeZone(TimeZone.getTimeZone("UTC"));
                                Date date2 = format.parse(CurrentParameter);
                                CurrentParameter = Long.toString(date2.getTime());
                            }
                            if(CurrentParameter.equals("") == false && 
                                CurrentParameter.equals(ShippingDataTable.getString(UserAccountInfo.ShippingDataColumns.get(key))) == false){
                                MakeChange = true;
                                UpdateStatement = UpdateStatement + " " + key + "='" + CurrentParameter + "',";
                            }
                        }
                    }
                    if(MakeChange == true){
                        UpdateStatement = UpdateStatement.substring(0, UpdateStatement.length() - 1) + " WHERE shipment_id = '" + RowID + "'";
                        PreparedStatement UpdateDatabase = UserAccountInfo.TruckingConnection.prepareStatement(UpdateStatement);
                        UpdateDatabase.executeUpdate();
                    }
                }
                ShippingDataTable = UserAccountInfo.getShippingDataTable();
            }
        }
        String IncomingOutgoingText = "";
        int PixelMultiplier = 8;
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Shipping Data</title>
    </head>
    <body>
        <h1>Shipping Data</h1>
        <form name="GoToMainMenu" action="UserSignedIn.jsp" method="POST">
            <input type="submit" value="Go to Main Menu" name="Main Menu" />
        </form>
        <form name="ShippingDataGetter" action="ShippingData.jsp" method="POST">
            <table border="0">
                <tbody>
                    <tr>
                        <td>
                            <select name="IncomingOutgoing">
                                <option value="10">All Data</option>
                                <option value="1">Incoming</option>
                                <option value="0">Outgoing</option>
                            </select>
                        </td>
                        <td>
                            <select name="RefreshUpdate">
                                <option value="Refresh">Refresh Page</option>
                                <option value="Update">Update Page</option>
                            </select>
                        </td>
                        <td><input type="submit" value="View/Update Data" onclick="myFunction()"/></td>
                    </tr>
                </tbody>
            </table>
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
                    <form
                     <%try{
                        String Received = "Not Received";
                        while(ShippingDataTable.next()){
                            if(ShippingDataTable.getString(UserAccountInfo.ShippingDataColumns.get("confirmation_flag")).equals("1")){
                                Received = "Received";
                            }else{
                                Received = " Not Received";
                            }
                            if(ShippingDataTable.getString(UserAccountInfo.ShippingDataColumns.get("incoming_outgoing")).equals("1")){
                                IncomingOutgoingText = "Incoming (Going to)";
                            }else{
                                IncomingOutgoingText = "Outgoing (Departing from)";
                            }
                            Calendar calendar = Calendar.getInstance();
                            calendar.setTimeInMillis(ShippingDataTable.getLong(UserAccountInfo.ShippingDataColumns.get("date_time")));
                            String mYear = Integer.toString(calendar.get(Calendar.YEAR));
                            String mMonth = Integer.toString(calendar.get(Calendar.MONTH) +1);
                            String mDay = Integer.toString(calendar.get(Calendar.DAY_OF_MONTH));
                            if(mMonth.length() < 2){
                                mMonth = "0" + mMonth;
                            }
                            if(mDay.length() < 2){
                                mDay = "0" + mDay;
                            }
                            String DateOutput = mYear + "-" + mMonth + "-" + mDay;
                            
                            String IncomingSelect = "";
                            String OutgoingSelect = "";
                            String ReceivedSelect = "";
                            String NotReceivedSelect = "";
                            if(IncomingOutgoingText.contains("Incoming")){
                                IncomingSelect = "selected";
                            }else{
                                OutgoingSelect = "selected";
                            }
                            
                            if(Received.contains("Not")){
                                NotReceivedSelect = "selected";
                            }else{
                                ReceivedSelect = "selected";
                            }
                            
                            
                            
                            if(IncomingOutgoingCode.indexOf(
                                ShippingDataTable.getString(UserAccountInfo.ShippingDataColumns.get("incoming_outgoing")))!= -1){%>
                                <tr> 
                                    <td><%=ShippingDataTable.getString(UserAccountInfo.ShippingDataColumns.get("shipment_id"))%></td>
                                    <td>
                                        <select  name="<%=ShippingDataTable.getString(UserAccountInfo.ShippingDataColumns.get("shipment_id"))%> <%=UserAccountInfo.MDShippingDataTable.getColumnName(UserAccountInfo.ShippingDataColumns.get("incoming_outgoing")).toUpperCase().replaceAll("_", " ")%> UPDATE"/>
                                                <option <%=IncomingSelect%> value="1">Incoming</option>
                                                <option <%=OutgoingSelect%> value="0">Outgoing</option>
                                        </select>
                                    </td>
                                    <td>
                                        <input style="width: <%=UserAccountInfo.MDShippingDataTable.getPrecision(UserAccountInfo.ShippingDataColumns.get("company"))*PixelMultiplier%>px;" type="text" name="<%=ShippingDataTable.getString(UserAccountInfo.ShippingDataColumns.get("shipment_id"))%> <%=UserAccountInfo.MDShippingDataTable.getColumnName(UserAccountInfo.ShippingDataColumns.get("company")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=ShippingDataTable.getString(UserAccountInfo.ShippingDataColumns.get("company"))%>"/>
                                    </td>
                                    <td>
                                        <input style="width: <%=UserAccountInfo.MDShippingDataTable.getPrecision(UserAccountInfo.ShippingDataColumns.get("street_address"))*PixelMultiplier%>px;" type="text" name="<%=ShippingDataTable.getString(UserAccountInfo.ShippingDataColumns.get("shipment_id"))%> <%=UserAccountInfo.MDShippingDataTable.getColumnName(UserAccountInfo.ShippingDataColumns.get("street_address")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=ShippingDataTable.getString(UserAccountInfo.ShippingDataColumns.get("street_address"))%>"/>
                                    </td>
                                    <td>
                                        <input style="width: <%=UserAccountInfo.MDShippingDataTable.getPrecision(UserAccountInfo.ShippingDataColumns.get("city"))*PixelMultiplier%>px;" type="text" name="<%=ShippingDataTable.getString(UserAccountInfo.ShippingDataColumns.get("shipment_id"))%> <%=UserAccountInfo.MDShippingDataTable.getColumnName(UserAccountInfo.ShippingDataColumns.get("city")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=ShippingDataTable.getString(UserAccountInfo.ShippingDataColumns.get("city"))%>"/>
                                    </td>
                                    <td>
                                        <input style="width: <%=UserAccountInfo.MDShippingDataTable.getPrecision(UserAccountInfo.ShippingDataColumns.get("state"))*PixelMultiplier%>px;" type="text" name="<%=ShippingDataTable.getString(UserAccountInfo.ShippingDataColumns.get("shipment_id"))%> <%=UserAccountInfo.MDShippingDataTable.getColumnName(UserAccountInfo.ShippingDataColumns.get("state")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=ShippingDataTable.getString(UserAccountInfo.ShippingDataColumns.get("state"))%>"/>
                                    </td>
                                    <td>
                                        <input style="width: <%=UserAccountInfo.MDShippingDataTable.getPrecision(UserAccountInfo.ShippingDataColumns.get("zip"))*PixelMultiplier%>px;" type="text" name="<%=ShippingDataTable.getString(UserAccountInfo.ShippingDataColumns.get("shipment_id"))%> <%=UserAccountInfo.MDShippingDataTable.getColumnName(UserAccountInfo.ShippingDataColumns.get("zip")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=ShippingDataTable.getString(UserAccountInfo.ShippingDataColumns.get("zip"))%>"/>
                                    </td>
                                    <td>
                                        <input style="width: <%=UserAccountInfo.MDShippingDataTable.getPrecision(UserAccountInfo.ShippingDataColumns.get("vehicle_id"))*PixelMultiplier%>px;" type="text" name="<%=ShippingDataTable.getString(UserAccountInfo.ShippingDataColumns.get("shipment_id"))%> <%=UserAccountInfo.MDShippingDataTable.getColumnName(UserAccountInfo.ShippingDataColumns.get("vehicle_id")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=ShippingDataTable.getString(UserAccountInfo.ShippingDataColumns.get("vehicle_id"))%>"/>
                                    </td>
                                    <td>
                                        <input type="date" name="<%=ShippingDataTable.getString(UserAccountInfo.ShippingDataColumns.get("shipment_id"))%> <%=UserAccountInfo.MDShippingDataTable.getColumnName(UserAccountInfo.ShippingDataColumns.get("date_time")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=DateOutput%>"/>
                                    </td>
                                    <td>
                                        <select name="<%=ShippingDataTable.getString(UserAccountInfo.ShippingDataColumns.get("shipment_id"))%> <%=UserAccountInfo.MDShippingDataTable.getColumnName(UserAccountInfo.ShippingDataColumns.get("confirmation_flag")).toUpperCase().replaceAll("_", " ")%> UPDATE"/>
                                                <option <%=ReceivedSelect%> value="1">Received</option>
                                                <option <%=NotReceivedSelect%> value="0">Not Received</option>
                                        </select>
                                    </td>
                                    <td>
                                        <input style="width: <%=UserAccountInfo.MDShippingDataTable.getPrecision(UserAccountInfo.ShippingDataColumns.get("driver"))*PixelMultiplier%>px;" type="text" name="<%=ShippingDataTable.getString(UserAccountInfo.ShippingDataColumns.get("shipment_id"))%> <%=UserAccountInfo.MDShippingDataTable.getColumnName(UserAccountInfo.ShippingDataColumns.get("driver")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=ShippingDataTable.getString(UserAccountInfo.ShippingDataColumns.get("driver"))%>"/>
                                    </td>
                                    <td><a href="PurchaseOrder.jsp?shipping_id_param=<%=ShippingDataTable.getString(UserAccountInfo.ShippingDataColumns.get("shipment_id"))%>">Purchase Order</a></td>
                                    <td><a href="ShippingManifest.jsp?maintenance_id_param=<%=ShippingDataTable.getString(UserAccountInfo.ShippingDataColumns.get("shipment_id"))%>">Shipment Manifest</a></td>
                                </tr>
                            <%}
                        }%>
                    <%}catch(SQLException ex){
                        ex.printStackTrace();
                    }%>   
                    <tr>
                        <form action="ShippingData.jsp" method="POST">
                            <td><input type="submit" value="Add Data" name="AddDataBtn" /></td>
                            <%for(int MetaIndex = 2; MetaIndex <= ShippingDataTable.getMetaData().getColumnCount(); MetaIndex++){    
                                int size = UserAccountInfo.MDShippingDataTable.getPrecision(MetaIndex) * PixelMultiplier;
                                if(UserAccountInfo.MDShippingDataTable.getColumnName(MetaIndex).equals("incoming_outgoing")){%>
                                    <td>
                                        <select name="<%=UserAccountInfo.ShippingDataColumnsText.get(UserAccountInfo.MDShippingDataTable.getColumnName(MetaIndex))%> INPUT">
                                            <option value="1">Incoming</option>
                                            <option value="0">Outgoing</option>
                                        </select>
                                    </td>
                                <%}else if(UserAccountInfo.MDShippingDataTable.getColumnName(MetaIndex).equals("confirmation_flag")){%>
                                    <select name="<%=UserAccountInfo.ShippingDataColumnsText.get(UserAccountInfo.MDShippingDataTable.getColumnName(MetaIndex))%> INPUT">
                                        <option value="1">Received</option>
                                        <option value="0">Not Received</option>
                                    </select>

                                <%}else if(UserAccountInfo.MDShippingDataTable.getColumnName(MetaIndex).equals("date_time")){%>
                                    <td><input style="width: <%=size%>px;" name="<%=UserAccountInfo.ShippingDataColumnsText.get(UserAccountInfo.MDShippingDataTable.getColumnName(MetaIndex))%> INPUT" type="date" /><td>
                                <%}else{%>
                                    <td><input style="width: <%=size%>px;" type="text" name="<%=UserAccountInfo.ShippingDataColumnsText.get(UserAccountInfo.MDShippingDataTable.getColumnName(MetaIndex))%> INPUT" value="" /></td>
                                <%}%>
                            <%}%> 
                        </form>
                    </tr>                 
                </tbody>
            </table>
        </form>   
        <form name="DeleteUpdate" action="ShippingData.jsp" method="POST">
            <table border="0">
                <thead>
                    <tr>
                        <th></th>
                        <th></th>
                        <th></th>
                        <th></th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                    </tr>
                </tbody>
            </table>

        </form>
        <a href="jasperIncomingShippingSummary.jsp">Incoming Shipping Summary</a>
        <a href="jasperOutgoingShippingSummary.jsp">Outgoing Shipping Summary</a>
    </body>
</html>

<script>
    function myFunction() {
        var txt = "Refreshing Shipping Data Page";
        if (document.getElementsByName("RefreshUpdate")[0].value === "Update"){
            txt = "Updating database.  This will take a few moments."
        }
        alert(txt);
    }   
</script>
