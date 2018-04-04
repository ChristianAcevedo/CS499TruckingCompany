<%-- 
    Document   : OilChange
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
    public class OilChange{

        String URL_CS499TruckingCompany = "jdbc:mysql://aa1wk12raqf2yoe.ca2f0nfwjqou.us-east-1.rds.amazonaws.com:3306/CS499TruckingCompany";
        String USERNAME = "SeniorProject";
        String PASSWORD = "password";
        String AccessCode = "";

        Connection TruckingConnection = null;

        PreparedStatement GetCookiesTable = null;
        PreparedStatement GetSignInDataTable = null;
        PreparedStatement GetOilChangeTable = null;

        ResultSet RSCookiesTable = null;
        ResultSet RSSignInDataTable = null;
        ResultSet RSOilChangeTable = null;

        ResultSetMetaData MDCookiesTable = null;
        ResultSetMetaData MDSignInDataTable = null;
        ResultSetMetaData MDOilChangeTable = null;

        Map<String, Integer> UserCookiesColumns = new HashMap<String, Integer>();
        Map<String, Integer> SignInDataColumns = new HashMap<String, Integer>();
        Map<String, Integer> OilChangeColumns = new HashMap<String, Integer>();
        Map<String, Integer> OilChangeColumnsPrecision = new HashMap<String, Integer>();

        Map<String, String> OilChangeColumnsText = new HashMap<String, String>();

        OilChange(String input_param){
        
            try{
                TruckingConnection = DriverManager.getConnection(URL_CS499TruckingCompany, USERNAME, PASSWORD);
                GetCookiesTable = TruckingConnection.prepareStatement("SELECT * FROM user_cookies_data");
                GetSignInDataTable = TruckingConnection.prepareStatement("SELECT * FROM sign_in_data");
                GetOilChangeTable = TruckingConnection.prepareStatement("SELECT * FROM oil_changes WHERE vehicle_id=" + input_param + "");
                RSCookiesTable = GetCookiesTable.executeQuery();
                RSSignInDataTable = GetSignInDataTable.executeQuery();
                RSOilChangeTable = GetOilChangeTable.executeQuery();
                MDCookiesTable = RSCookiesTable.getMetaData();
                MDSignInDataTable = RSSignInDataTable.getMetaData();
                MDOilChangeTable = RSOilChangeTable.getMetaData();
                for(int MetaIndex = 1; MetaIndex <= MDCookiesTable.getColumnCount(); MetaIndex++){
                    UserCookiesColumns.put(MDCookiesTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDSignInDataTable.getColumnCount(); MetaIndex++){
                    SignInDataColumns.put(MDSignInDataTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDOilChangeTable.getColumnCount(); MetaIndex++){
                    OilChangeColumns.put(MDOilChangeTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDOilChangeTable.getColumnCount(); MetaIndex++){
                    OilChangeColumns.put(MDOilChangeTable.getColumnName(MetaIndex), MetaIndex);
                    OilChangeColumnsPrecision.put(MDOilChangeTable.getColumnName(MetaIndex), MDOilChangeTable.getPrecision(MetaIndex));
                    OilChangeColumnsText.put(MDOilChangeTable.getColumnName(MetaIndex), 
                        MDOilChangeTable.getColumnName(MetaIndex).toUpperCase().replaceAll("_", " "));
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

        public ResultSet getOilChangeTable(){
            try{
                RSOilChangeTable = GetOilChangeTable.executeQuery();
            }catch(SQLException ex){
                ex.printStackTrace();
            }
            return RSOilChangeTable;   
        }
}
%>

<%
    
    String vehicle_id_param = request.getParameter("vehicle_id_param");
    
    boolean SignedIn = false;    
        String UserName = "";   
        String UserID = "";
        String AccessCode = "";
        OilChange UserAccountInfo = new OilChange(vehicle_id_param);
        Map<String, String> NewOilChangeInput = new HashMap<String, String>();
        
        
        ResultSet CookiesTable = UserAccountInfo.getCookiesTable(); 
        ResultSet SignInDataTable = UserAccountInfo.getSignInDataTable();
        ResultSet OilChangeTable = UserAccountInfo.getOilChangeTable();
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
        

        
        
        
        boolean GoodInput = true;
        for (String key : UserAccountInfo.OilChangeColumnsText.keySet()) {
            if(request.getParameter(UserAccountInfo.OilChangeColumnsText.get(key) + " INPUT") == null ||
                    request.getParameter(UserAccountInfo.OilChangeColumnsText.get(key) + " INPUT") == ""){
                if(key.equals("oil_change_id") == false){
                    GoodInput = false;
                    break;
                }                
            }else{
                //if(key.equals())
                NewOilChangeInput.put(key,request.getParameter(UserAccountInfo.OilChangeColumnsText.get(key) + " INPUT"));
            }
        }
        
        int test = 0;
        String AddOilChangeRecord = "INSERT INTO oil_changes (";
        if(GoodInput == true){
            for(String key : UserAccountInfo.OilChangeColumnsText.keySet()){
                if(key.equals("oil_change_id") == false) {
                    AddOilChangeRecord = AddOilChangeRecord + key + ",";
                }
            }
            
            AddOilChangeRecord = AddOilChangeRecord.substring(0, AddOilChangeRecord.length() - 1) + ") VALUES (";
            for(String key : UserAccountInfo.OilChangeColumnsText.keySet()){
                if((key.equals("oil_change_id") == false) && (key.equals("vehicle_id") == false)){
                    AddOilChangeRecord = AddOilChangeRecord + "'" + NewOilChangeInput.get(key) + "',";
                }
                if(key.equals("vehicle_id") == true)
                {
                    AddOilChangeRecord = AddOilChangeRecord + "'" + vehicle_id_param + "',";
                }
            }
            
/*
            AddOilChangeRecord = AddOilChangeRecord.substring(0, AddOilChangeRecord.length() - 1) + ") VALUES (";
            for(String key : UserAccountInfo.OilChangeColumnsText.keySet()){
                if(key.equals("oil_change_id") == false){
                    AddOilChangeRecord = AddOilChangeRecord + "'" + NewOilChangeInput.get(key) + "',";
                }
            }
*/
            AddOilChangeRecord = AddOilChangeRecord.substring(0, AddOilChangeRecord.length() - 1) + ")";
            PreparedStatement AddOilChangeRecordStatement = 
                    UserAccountInfo.TruckingConnection.prepareStatement(AddOilChangeRecord);
            test = AddOilChangeRecordStatement.executeUpdate();
            OilChangeTable = UserAccountInfo.getOilChangeTable();
        }
        
        if(request.getParameter("RefreshUpdate") != null){
            if(request.getParameter("RefreshUpdate").equals("Update")){
                String RowID = "0";
                String UpdateStatement = "";
                String CurrentParameter = "";
                boolean MakeChange = false;
                while(OilChangeTable.next()){
                    UpdateStatement = "UPDATE oil_changes SET";
                    MakeChange = false;
                    RowID = OilChangeTable.getString(UserAccountInfo.OilChangeColumns.get("oil_change_id"));
                    for(String key : UserAccountInfo.OilChangeColumnsText.keySet()){
                        if(request.getParameter(RowID + " " + UserAccountInfo.OilChangeColumnsText.get(key) + " UPDATE") != null){
                            CurrentParameter = request.getParameter(RowID + " " + UserAccountInfo.OilChangeColumnsText.get(key) + " UPDATE");
                            if(CurrentParameter.equals("") == false && 
                                CurrentParameter.equals(OilChangeTable.getString(UserAccountInfo.OilChangeColumns.get(key))) == false){
                                MakeChange = true;
                                UpdateStatement = UpdateStatement + " " + key + "='" + CurrentParameter + "',";
                            }
                        }
                    }
                    if(MakeChange == true){
                        UpdateStatement = UpdateStatement.substring(0, UpdateStatement.length() - 1) + " WHERE oil_change_id = '" + RowID + "'";
                        PreparedStatement UpdateDatabase = UserAccountInfo.TruckingConnection.prepareStatement(UpdateStatement);
                        UpdateDatabase.executeUpdate();
                    }
                }
                OilChangeTable = UserAccountInfo.getOilChangeTable();
            }
        }
        String IncomingOutgoingText = "";
        int PixelMultiplier = 8;
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Oil Changes</title>
    </head>
    <body>
        <h1>Oil Changes</h1>
        <form name="GoToMainMenu" action="UserSignedIn.jsp" method="POST">
            <input type="submit" value="Go to Main Menu" name="Main Menu" />
        </form>
        <form name="OilChangeGetter" action="OilChange.jsp" method="POST">
            <input type="hidden" name="vehicle_id_param" value="<%=vehicle_id_param%>">
            <table border="0">
                <tbody>
                    <tr>
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
                        <th><%=UserAccountInfo.OilChangeColumnsText.get("oil_change_id")%></th>
                        <th><%=UserAccountInfo.OilChangeColumnsText.get("vehicle_id")%></th>
                        <th><%=UserAccountInfo.OilChangeColumnsText.get("date")%></th>
                    </tr>
                </thead>
                <tbody>
                    <form
                     <%try{
                        while(OilChangeTable.next()){%>
                                <tr>
                                    <td><%=OilChangeTable.getString(UserAccountInfo.OilChangeColumns.get("oil_change_id"))%></td>
                                    <td><%=OilChangeTable.getString(UserAccountInfo.OilChangeColumns.get("vehicle_id"))%></td>
                                    <td><input style="width: <%=UserAccountInfo.MDOilChangeTable.getPrecision(UserAccountInfo.OilChangeColumns.get("date"))*PixelMultiplier%>px;" type="text" name="<%=OilChangeTable.getString(UserAccountInfo.OilChangeColumns.get("oil_change_id"))%> <%=UserAccountInfo.MDOilChangeTable.getColumnName(UserAccountInfo.OilChangeColumns.get("date")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=OilChangeTable.getString(UserAccountInfo.OilChangeColumns.get("date"))%>"/></td>
                                </tr> 
                        <%}%>
                    <%}catch(SQLException ex){
                        ex.printStackTrace();
                    }%>   
                    <tr>
                        <form action="OilChange.jsp" method="POST">
                            <td><input type="submit" value="Add Data" name="AddDataBtn" /></td>
                            <%for(int MetaIndex = 2; MetaIndex <= OilChangeTable.getMetaData().getColumnCount(); MetaIndex++){    
                                int size = UserAccountInfo.MDOilChangeTable.getPrecision(MetaIndex) * PixelMultiplier;%>
                            <td><input style="width: <%=size%>px;" type="text" name="<%=UserAccountInfo.OilChangeColumnsText.get(UserAccountInfo.MDOilChangeTable.getColumnName(MetaIndex))%> INPUT" value="" /></td>
                            <input type="hidden" name="vehicle_id_param" value="<%=vehicle_id_param%>">
                            <%}%> 
                        </form>
                    </tr>                 
                </tbody>
            </table>
        </form>   
        <form name="DeleteUpdate" action="OilChange.jsp" method="POST">
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
    </body>
</html>

<script>
    function myFunction() {
        var txt = "Refreshing Vehicle Data Page";
        if (document.getElementsByName("RefreshUpdate")[0].value === "Update"){
            txt = "Updating database.  This will take a few moments."
        }
        alert(txt);
    }   
</script>

