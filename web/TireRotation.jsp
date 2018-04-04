<%-- 
    Document   : TireRotation
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
    public class TireRotation{

        String URL_CS499TruckingCompany = "jdbc:mysql://aa1wk12raqf2yoe.ca2f0nfwjqou.us-east-1.rds.amazonaws.com:3306/CS499TruckingCompany";
        String USERNAME = "SeniorProject";
        String PASSWORD = "password";
        String AccessCode = "";

        Connection TruckingConnection = null;

        PreparedStatement GetCookiesTable = null;
        PreparedStatement GetSignInDataTable = null;
        PreparedStatement GetTireRotationTable = null;

        ResultSet RSCookiesTable = null;
        ResultSet RSSignInDataTable = null;
        ResultSet RSTireRotationTable = null;

        ResultSetMetaData MDCookiesTable = null;
        ResultSetMetaData MDSignInDataTable = null;
        ResultSetMetaData MDTireRotationTable = null;

        Map<String, Integer> UserCookiesColumns = new HashMap<String, Integer>();
        Map<String, Integer> SignInDataColumns = new HashMap<String, Integer>();
        Map<String, Integer> TireRotationColumns = new HashMap<String, Integer>();
        Map<String, Integer> TireRotationColumnsPrecision = new HashMap<String, Integer>();

        Map<String, String> TireRotationColumnsText = new HashMap<String, String>();

        TireRotation(String input_param){
        
            try{
                TruckingConnection = DriverManager.getConnection(URL_CS499TruckingCompany, USERNAME, PASSWORD);
                GetCookiesTable = TruckingConnection.prepareStatement("SELECT * FROM user_cookies_data");
                GetSignInDataTable = TruckingConnection.prepareStatement("SELECT * FROM sign_in_data");
                GetTireRotationTable = TruckingConnection.prepareStatement("SELECT * FROM tire_rotation WHERE vehicle_id=" + input_param + "");
                RSCookiesTable = GetCookiesTable.executeQuery();
                RSSignInDataTable = GetSignInDataTable.executeQuery();
                RSTireRotationTable = GetTireRotationTable.executeQuery();
                MDCookiesTable = RSCookiesTable.getMetaData();
                MDSignInDataTable = RSSignInDataTable.getMetaData();
                MDTireRotationTable = RSTireRotationTable.getMetaData();
                for(int MetaIndex = 1; MetaIndex <= MDCookiesTable.getColumnCount(); MetaIndex++){
                    UserCookiesColumns.put(MDCookiesTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDSignInDataTable.getColumnCount(); MetaIndex++){
                    SignInDataColumns.put(MDSignInDataTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDTireRotationTable.getColumnCount(); MetaIndex++){
                    TireRotationColumns.put(MDTireRotationTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDTireRotationTable.getColumnCount(); MetaIndex++){
                    TireRotationColumns.put(MDTireRotationTable.getColumnName(MetaIndex), MetaIndex);
                    TireRotationColumnsPrecision.put(MDTireRotationTable.getColumnName(MetaIndex), MDTireRotationTable.getPrecision(MetaIndex));
                    TireRotationColumnsText.put(MDTireRotationTable.getColumnName(MetaIndex), 
                        MDTireRotationTable.getColumnName(MetaIndex).toUpperCase().replaceAll("_", " "));
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

        public ResultSet getTireRotationTable(){
            try{
                RSTireRotationTable = GetTireRotationTable.executeQuery();
            }catch(SQLException ex){
                ex.printStackTrace();
            }
            return RSTireRotationTable;   
        }
}
%>

<%
    
    String vehicle_id_param = request.getParameter("vehicle_id_param");
    
    boolean SignedIn = false;    
        String UserName = "";   
        String UserID = "";
        String AccessCode = "";
        TireRotation UserAccountInfo = new TireRotation(vehicle_id_param);
        Map<String, String> NewTireRotationInput = new HashMap<String, String>();
        
        
        ResultSet CookiesTable = UserAccountInfo.getCookiesTable(); 
        ResultSet SignInDataTable = UserAccountInfo.getSignInDataTable();
        ResultSet TireRotationTable = UserAccountInfo.getTireRotationTable();
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
        for (String key : UserAccountInfo.TireRotationColumnsText.keySet()) {
            if(request.getParameter(UserAccountInfo.TireRotationColumnsText.get(key) + " INPUT") == null ||
                    request.getParameter(UserAccountInfo.TireRotationColumnsText.get(key) + " INPUT") == ""){
                if(key.equals("tire_rotation_id") == false){
                    GoodInput = false;
                    break;
                }                
            }else{
                //if(key.equals())
                NewTireRotationInput.put(key,request.getParameter(UserAccountInfo.TireRotationColumnsText.get(key) + " INPUT"));
            }
        }
        
        int test = 0;
        String AddTireRotationRecord = "INSERT INTO tire_rotation (";
        if(GoodInput == true){
            for(String key : UserAccountInfo.TireRotationColumnsText.keySet()){
                if(key.equals("tire_rotation_id") == false) {
                    AddTireRotationRecord = AddTireRotationRecord + key + ",";
                }
            }
            
            AddTireRotationRecord = AddTireRotationRecord.substring(0, AddTireRotationRecord.length() - 1) + ") VALUES (";
            for(String key : UserAccountInfo.TireRotationColumnsText.keySet()){
                if((key.equals("tire_rotation_id") == false) && (key.equals("vehicle_id") == false)){
                    AddTireRotationRecord = AddTireRotationRecord + "'" + NewTireRotationInput.get(key) + "',";
                }
                if(key.equals("vehicle_id") == true)
                {
                    AddTireRotationRecord = AddTireRotationRecord + "'" + vehicle_id_param + "',";
                }
            }
            
/*
            AddTireRotationRecord = AddTireRotationRecord.substring(0, AddTireRotationRecord.length() - 1) + ") VALUES (";
            for(String key : UserAccountInfo.TireRotationColumnsText.keySet()){
                if(key.equals("tire_rotation_id") == false){
                    AddTireRotationRecord = AddTireRotationRecord + "'" + NewTireRotationInput.get(key) + "',";
                }
            }
*/
            AddTireRotationRecord = AddTireRotationRecord.substring(0, AddTireRotationRecord.length() - 1) + ")";
            PreparedStatement AddTireRotationRecordStatement = 
                    UserAccountInfo.TruckingConnection.prepareStatement(AddTireRotationRecord);
            test = AddTireRotationRecordStatement.executeUpdate();
            TireRotationTable = UserAccountInfo.getTireRotationTable();
        }
        
        if(request.getParameter("RefreshUpdate") != null){
            if(request.getParameter("RefreshUpdate").equals("Update")){
                String RowID = "0";
                String UpdateStatement = "";
                String CurrentParameter = "";
                boolean MakeChange = false;
                while(TireRotationTable.next()){
                    UpdateStatement = "UPDATE tire_rotation SET";
                    MakeChange = false;
                    RowID = TireRotationTable.getString(UserAccountInfo.TireRotationColumns.get("tire_rotation_id"));
                    for(String key : UserAccountInfo.TireRotationColumnsText.keySet()){
                        if(request.getParameter(RowID + " " + UserAccountInfo.TireRotationColumnsText.get(key) + " UPDATE") != null){
                            CurrentParameter = request.getParameter(RowID + " " + UserAccountInfo.TireRotationColumnsText.get(key) + " UPDATE");
                            if(CurrentParameter.equals("") == false && 
                                CurrentParameter.equals(TireRotationTable.getString(UserAccountInfo.TireRotationColumns.get(key))) == false){
                                MakeChange = true;
                                UpdateStatement = UpdateStatement + " " + key + "='" + CurrentParameter + "',";
                            }
                        }
                    }
                    if(MakeChange == true){
                        UpdateStatement = UpdateStatement.substring(0, UpdateStatement.length() - 1) + " WHERE tire_rotation_id = '" + RowID + "'";
                        PreparedStatement UpdateDatabase = UserAccountInfo.TruckingConnection.prepareStatement(UpdateStatement);
                        UpdateDatabase.executeUpdate();
                    }
                }
                TireRotationTable = UserAccountInfo.getTireRotationTable();
            }
        }
        String IncomingOutgoingText = "";
        int PixelMultiplier = 8;
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Tire Rotation</title>
    </head>
    <body>
        <h1>Tire Rotation</h1>
        <form name="GoToMainMenu" action="UserSignedIn.jsp" method="POST">
            <input type="submit" value="Go to Main Menu" name="Main Menu" />
        </form>
        <form name="TireRotationGetter" action="TireRotation.jsp" method="POST">
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
                        <th><%=UserAccountInfo.TireRotationColumnsText.get("tire_rotation_id")%></th>
                        <th><%=UserAccountInfo.TireRotationColumnsText.get("vehicle_id")%></th>
                        <th><%=UserAccountInfo.TireRotationColumnsText.get("date")%></th>
                    </tr>
                </thead>
                <tbody>
                    <form
                     <%try{
                        while(TireRotationTable.next()){%>
                                <tr>
                                    <td><%=TireRotationTable.getString(UserAccountInfo.TireRotationColumns.get("tire_rotation_id"))%></td>
                                    <td><%=TireRotationTable.getString(UserAccountInfo.TireRotationColumns.get("vehicle_id"))%></td>
                                    <td><input style="width: <%=UserAccountInfo.MDTireRotationTable.getPrecision(UserAccountInfo.TireRotationColumns.get("date"))*PixelMultiplier%>px;" type="text" name="<%=TireRotationTable.getString(UserAccountInfo.TireRotationColumns.get("tire_rotation_id"))%> <%=UserAccountInfo.MDTireRotationTable.getColumnName(UserAccountInfo.TireRotationColumns.get("date")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=TireRotationTable.getString(UserAccountInfo.TireRotationColumns.get("date"))%>"/></td>
                                </tr> 
                        <%}%>
                    <%}catch(SQLException ex){
                        ex.printStackTrace();
                    }%>   
                    <tr>
                        <form action="TireRotation.jsp" method="POST">
                            <td><input type="submit" value="Add Data" name="AddDataBtn" /></td>
                            <%for(int MetaIndex = 2; MetaIndex <= TireRotationTable.getMetaData().getColumnCount(); MetaIndex++){    
                                int size = UserAccountInfo.MDTireRotationTable.getPrecision(MetaIndex) * PixelMultiplier;%>
                            <td><input style="width: <%=size%>px;" type="text" name="<%=UserAccountInfo.TireRotationColumnsText.get(UserAccountInfo.MDTireRotationTable.getColumnName(MetaIndex))%> INPUT" value="" /></td>
                            <input type="hidden" name="vehicle_id_param" value="<%=vehicle_id_param%>">
                            <%}%> 
                        </form>
                    </tr>                 
                </tbody>
            </table>
        </form>   
        <form name="DeleteUpdate" action="TireRotation.jsp" method="POST">
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

