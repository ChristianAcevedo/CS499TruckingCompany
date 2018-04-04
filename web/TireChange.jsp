<%-- 
    Document   : TireChange
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
    public class TireChange{

        String URL_CS499TruckingCompany = "jdbc:mysql://aa1wk12raqf2yoe.ca2f0nfwjqou.us-east-1.rds.amazonaws.com:3306/CS499TruckingCompany";
        String USERNAME = "SeniorProject";
        String PASSWORD = "password";
        String AccessCode = "";

        Connection TruckingConnection = null;

        PreparedStatement GetCookiesTable = null;
        PreparedStatement GetSignInDataTable = null;
        PreparedStatement GetTireChangeTable = null;

        ResultSet RSCookiesTable = null;
        ResultSet RSSignInDataTable = null;
        ResultSet RSTireChangeTable = null;

        ResultSetMetaData MDCookiesTable = null;
        ResultSetMetaData MDSignInDataTable = null;
        ResultSetMetaData MDTireChangeTable = null;

        Map<String, Integer> UserCookiesColumns = new HashMap<String, Integer>();
        Map<String, Integer> SignInDataColumns = new HashMap<String, Integer>();
        Map<String, Integer> TireChangeColumns = new HashMap<String, Integer>();
        Map<String, Integer> TireChangeColumnsPrecision = new HashMap<String, Integer>();

        Map<String, String> TireChangeColumnsText = new HashMap<String, String>();

        TireChange(String input_param){
        
            try{
                TruckingConnection = DriverManager.getConnection(URL_CS499TruckingCompany, USERNAME, PASSWORD);
                GetCookiesTable = TruckingConnection.prepareStatement("SELECT * FROM user_cookies_data");
                GetSignInDataTable = TruckingConnection.prepareStatement("SELECT * FROM sign_in_data");
                GetTireChangeTable = TruckingConnection.prepareStatement("SELECT * FROM tire_changes WHERE vehicle_id=" + input_param + "");
                RSCookiesTable = GetCookiesTable.executeQuery();
                RSSignInDataTable = GetSignInDataTable.executeQuery();
                RSTireChangeTable = GetTireChangeTable.executeQuery();
                MDCookiesTable = RSCookiesTable.getMetaData();
                MDSignInDataTable = RSSignInDataTable.getMetaData();
                MDTireChangeTable = RSTireChangeTable.getMetaData();
                for(int MetaIndex = 1; MetaIndex <= MDCookiesTable.getColumnCount(); MetaIndex++){
                    UserCookiesColumns.put(MDCookiesTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDSignInDataTable.getColumnCount(); MetaIndex++){
                    SignInDataColumns.put(MDSignInDataTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDTireChangeTable.getColumnCount(); MetaIndex++){
                    TireChangeColumns.put(MDTireChangeTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDTireChangeTable.getColumnCount(); MetaIndex++){
                    TireChangeColumns.put(MDTireChangeTable.getColumnName(MetaIndex), MetaIndex);
                    TireChangeColumnsPrecision.put(MDTireChangeTable.getColumnName(MetaIndex), MDTireChangeTable.getPrecision(MetaIndex));
                    TireChangeColumnsText.put(MDTireChangeTable.getColumnName(MetaIndex), 
                        MDTireChangeTable.getColumnName(MetaIndex).toUpperCase().replaceAll("_", " "));
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

        public ResultSet getTireChangeTable(){
            try{
                RSTireChangeTable = GetTireChangeTable.executeQuery();
            }catch(SQLException ex){
                ex.printStackTrace();
            }
            return RSTireChangeTable;   
        }
}
%>

<%
    
    String vehicle_id_param = request.getParameter("vehicle_id_param");
    
    boolean SignedIn = false;    
        String UserName = "";   
        String UserID = "";
        String AccessCode = "";
        TireChange UserAccountInfo = new TireChange(vehicle_id_param);
        Map<String, String> NewTireChangeInput = new HashMap<String, String>();
        
        
        ResultSet CookiesTable = UserAccountInfo.getCookiesTable(); 
        ResultSet SignInDataTable = UserAccountInfo.getSignInDataTable();
        ResultSet TireChangeTable = UserAccountInfo.getTireChangeTable();
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
        for (String key : UserAccountInfo.TireChangeColumnsText.keySet()) {
            if(request.getParameter(UserAccountInfo.TireChangeColumnsText.get(key) + " INPUT") == null ||
                    request.getParameter(UserAccountInfo.TireChangeColumnsText.get(key) + " INPUT") == ""){
                if(key.equals("tire_changes_id") == false){
                    GoodInput = false;
                    break;
                }                
            }else{
                //if(key.equals())
                NewTireChangeInput.put(key,request.getParameter(UserAccountInfo.TireChangeColumnsText.get(key) + " INPUT"));
            }
        }
        
        int test = 0;
        String AddTireChangeRecord = "INSERT INTO tire_changes (";
        if(GoodInput == true){
            for(String key : UserAccountInfo.TireChangeColumnsText.keySet()){
                if(key.equals("tire_changes_id") == false) {
                    AddTireChangeRecord = AddTireChangeRecord + key + ",";
                }
            }
            
            AddTireChangeRecord = AddTireChangeRecord.substring(0, AddTireChangeRecord.length() - 1) + ") VALUES (";
            for(String key : UserAccountInfo.TireChangeColumnsText.keySet()){
                if((key.equals("tire_changes_id") == false) && (key.equals("vehicle_id") == false)){
                    AddTireChangeRecord = AddTireChangeRecord + "'" + NewTireChangeInput.get(key) + "',";
                }
                if(key.equals("vehicle_id") == true)
                {
                    AddTireChangeRecord = AddTireChangeRecord + "'" + vehicle_id_param + "',";
                }
            }
            
/*
            AddTireChangeRecord = AddTireChangeRecord.substring(0, AddTireChangeRecord.length() - 1) + ") VALUES (";
            for(String key : UserAccountInfo.TireChangeColumnsText.keySet()){
                if(key.equals("tire_changes_id") == false){
                    AddTireChangeRecord = AddTireChangeRecord + "'" + NewTireChangeInput.get(key) + "',";
                }
            }
*/
            AddTireChangeRecord = AddTireChangeRecord.substring(0, AddTireChangeRecord.length() - 1) + ")";
            PreparedStatement AddTireChangeRecordStatement = 
                    UserAccountInfo.TruckingConnection.prepareStatement(AddTireChangeRecord);
            test = AddTireChangeRecordStatement.executeUpdate();
            TireChangeTable = UserAccountInfo.getTireChangeTable();
        }
        
        if(request.getParameter("RefreshUpdate") != null){
            if(request.getParameter("RefreshUpdate").equals("Update")){
                String RowID = "0";
                String UpdateStatement = "";
                String CurrentParameter = "";
                boolean MakeChange = false;
                while(TireChangeTable.next()){
                    UpdateStatement = "UPDATE tire_changes SET";
                    MakeChange = false;
                    RowID = TireChangeTable.getString(UserAccountInfo.TireChangeColumns.get("tire_changes_id"));
                    for(String key : UserAccountInfo.TireChangeColumnsText.keySet()){
                        if(request.getParameter(RowID + " " + UserAccountInfo.TireChangeColumnsText.get(key) + " UPDATE") != null){
                            CurrentParameter = request.getParameter(RowID + " " + UserAccountInfo.TireChangeColumnsText.get(key) + " UPDATE");
                            if(CurrentParameter.equals("") == false && 
                                CurrentParameter.equals(TireChangeTable.getString(UserAccountInfo.TireChangeColumns.get(key))) == false){
                                MakeChange = true;
                                UpdateStatement = UpdateStatement + " " + key + "='" + CurrentParameter + "',";
                            }
                        }
                    }
                    if(MakeChange == true){
                        UpdateStatement = UpdateStatement.substring(0, UpdateStatement.length() - 1) + " WHERE tire_changes_id = '" + RowID + "'";
                        PreparedStatement UpdateDatabase = UserAccountInfo.TruckingConnection.prepareStatement(UpdateStatement);
                        UpdateDatabase.executeUpdate();
                    }
                }
                TireChangeTable = UserAccountInfo.getTireChangeTable();
            }
        }
        String IncomingOutgoingText = "";
        int PixelMultiplier = 8;
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Tire Changes</title>
    </head>
    <body>
        <h1>Tire Changes</h1>
        <form name="GoToMainMenu" action="UserSignedIn.jsp" method="POST">
            <input type="submit" value="Go to Main Menu" name="Main Menu" />
        </form>
        <form name="TireChangeGetter" action="TireChange.jsp" method="POST">
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
                        <th><%=UserAccountInfo.TireChangeColumnsText.get("tire_changes_id")%></th>
                        <th><%=UserAccountInfo.TireChangeColumnsText.get("vehicle_id")%></th>
                        <th><%=UserAccountInfo.TireChangeColumnsText.get("date")%></th>
                    </tr>
                </thead>
                <tbody>
                    <form
                     <%try{
                        while(TireChangeTable.next()){%>
                                <tr>
                                    <td><%=TireChangeTable.getString(UserAccountInfo.TireChangeColumns.get("tire_changes_id"))%></td>
                                    <td><%=TireChangeTable.getString(UserAccountInfo.TireChangeColumns.get("vehicle_id"))%></td>
                                    <td><input style="width: <%=UserAccountInfo.MDTireChangeTable.getPrecision(UserAccountInfo.TireChangeColumns.get("date"))*PixelMultiplier%>px;" type="text" name="<%=TireChangeTable.getString(UserAccountInfo.TireChangeColumns.get("tire_changes_id"))%> <%=UserAccountInfo.MDTireChangeTable.getColumnName(UserAccountInfo.TireChangeColumns.get("date")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=TireChangeTable.getString(UserAccountInfo.TireChangeColumns.get("date"))%>"/></td>
                                </tr> 
                        <%}%>
                    <%}catch(SQLException ex){
                        ex.printStackTrace();
                    }%>   
                    <tr>
                        <form action="TireChange.jsp" method="POST">
                            <td><input type="submit" value="Add Data" name="AddDataBtn" /></td>
                            <%for(int MetaIndex = 2; MetaIndex <= TireChangeTable.getMetaData().getColumnCount(); MetaIndex++){    
                                int size = UserAccountInfo.MDTireChangeTable.getPrecision(MetaIndex) * PixelMultiplier;%>
                            <td><input style="width: <%=size%>px;" type="text" name="<%=UserAccountInfo.TireChangeColumnsText.get(UserAccountInfo.MDTireChangeTable.getColumnName(MetaIndex))%> INPUT" value="" /></td>
                            <input type="hidden" name="vehicle_id_param" value="<%=vehicle_id_param%>">
                            <%}%> 
                        </form>
                    </tr>                 
                </tbody>
            </table>
        </form>   
        <form name="DeleteUpdate" action="TireChange.jsp" method="POST">
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

