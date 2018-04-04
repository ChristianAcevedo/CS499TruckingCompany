<%-- 
    Document   : FluidChecks
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
    public class FluidChecks{

        String URL_CS499TruckingCompany = "jdbc:mysql://aa1wk12raqf2yoe.ca2f0nfwjqou.us-east-1.rds.amazonaws.com:3306/CS499TruckingCompany";
        String USERNAME = "SeniorProject";
        String PASSWORD = "password";
        String AccessCode = "";

        Connection TruckingConnection = null;

        PreparedStatement GetCookiesTable = null;
        PreparedStatement GetSignInDataTable = null;
        PreparedStatement GetFluidChecksTable = null;

        ResultSet RSCookiesTable = null;
        ResultSet RSSignInDataTable = null;
        ResultSet RSFluidChecksTable = null;

        ResultSetMetaData MDCookiesTable = null;
        ResultSetMetaData MDSignInDataTable = null;
        ResultSetMetaData MDFluidChecksTable = null;

        Map<String, Integer> UserCookiesColumns = new HashMap<String, Integer>();
        Map<String, Integer> SignInDataColumns = new HashMap<String, Integer>();
        Map<String, Integer> FluidChecksColumns = new HashMap<String, Integer>();
        Map<String, Integer> FluidChecksColumnsPrecision = new HashMap<String, Integer>();

        Map<String, String> FluidChecksColumnsText = new HashMap<String, String>();

        FluidChecks(String input_param){
        
            try{
                TruckingConnection = DriverManager.getConnection(URL_CS499TruckingCompany, USERNAME, PASSWORD);
                GetCookiesTable = TruckingConnection.prepareStatement("SELECT * FROM user_cookies_data");
                GetSignInDataTable = TruckingConnection.prepareStatement("SELECT * FROM sign_in_data");
                GetFluidChecksTable = TruckingConnection.prepareStatement("SELECT * FROM fluid_checks WHERE vehicle_id=" + input_param + "");
                RSCookiesTable = GetCookiesTable.executeQuery();
                RSSignInDataTable = GetSignInDataTable.executeQuery();
                RSFluidChecksTable = GetFluidChecksTable.executeQuery();
                MDCookiesTable = RSCookiesTable.getMetaData();
                MDSignInDataTable = RSSignInDataTable.getMetaData();
                MDFluidChecksTable = RSFluidChecksTable.getMetaData();
                for(int MetaIndex = 1; MetaIndex <= MDCookiesTable.getColumnCount(); MetaIndex++){
                    UserCookiesColumns.put(MDCookiesTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDSignInDataTable.getColumnCount(); MetaIndex++){
                    SignInDataColumns.put(MDSignInDataTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDFluidChecksTable.getColumnCount(); MetaIndex++){
                    FluidChecksColumns.put(MDFluidChecksTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDFluidChecksTable.getColumnCount(); MetaIndex++){
                    FluidChecksColumns.put(MDFluidChecksTable.getColumnName(MetaIndex), MetaIndex);
                    FluidChecksColumnsPrecision.put(MDFluidChecksTable.getColumnName(MetaIndex), MDFluidChecksTable.getPrecision(MetaIndex));
                    FluidChecksColumnsText.put(MDFluidChecksTable.getColumnName(MetaIndex), 
                        MDFluidChecksTable.getColumnName(MetaIndex).toUpperCase().replaceAll("_", " "));
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

        public ResultSet getFluidChecksTable(){
            try{
                RSFluidChecksTable = GetFluidChecksTable.executeQuery();
            }catch(SQLException ex){
                ex.printStackTrace();
            }
            return RSFluidChecksTable;   
        }
}
%>

<%
    
    String vehicle_id_param = request.getParameter("vehicle_id_param");
    
    boolean SignedIn = false;    
        String UserName = "";   
        String UserID = "";
        String AccessCode = "";
        FluidChecks UserAccountInfo = new FluidChecks(vehicle_id_param);
        Map<String, String> NewFluidChecksInput = new HashMap<String, String>();
        
        
        ResultSet CookiesTable = UserAccountInfo.getCookiesTable(); 
        ResultSet SignInDataTable = UserAccountInfo.getSignInDataTable();
        ResultSet FluidChecksTable = UserAccountInfo.getFluidChecksTable();
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
        for (String key : UserAccountInfo.FluidChecksColumnsText.keySet()) {
            if(request.getParameter(UserAccountInfo.FluidChecksColumnsText.get(key) + " INPUT") == null ||
                    request.getParameter(UserAccountInfo.FluidChecksColumnsText.get(key) + " INPUT") == ""){
                if(key.equals("fluid_checks_id") == false){
                    GoodInput = false;
                    break;
                }                
            }else{
                //if(key.equals())
                NewFluidChecksInput.put(key,request.getParameter(UserAccountInfo.FluidChecksColumnsText.get(key) + " INPUT"));
            }
        }
        
        int test = 0;
        String AddFluidChecksRecord = "INSERT INTO fluid_checks (";
        if(GoodInput == true){
            for(String key : UserAccountInfo.FluidChecksColumnsText.keySet()){
                if(key.equals("fluid_checks_id") == false) {
                    AddFluidChecksRecord = AddFluidChecksRecord + key + ",";
                }
            }
            
            AddFluidChecksRecord = AddFluidChecksRecord.substring(0, AddFluidChecksRecord.length() - 1) + ") VALUES (";
            for(String key : UserAccountInfo.FluidChecksColumnsText.keySet()){
                if((key.equals("fluid_checks_id") == false) && (key.equals("vehicle_id") == false)){
                    AddFluidChecksRecord = AddFluidChecksRecord + "'" + NewFluidChecksInput.get(key) + "',";
                }
                if(key.equals("vehicle_id") == true)
                {
                    AddFluidChecksRecord = AddFluidChecksRecord + "'" + vehicle_id_param + "',";
                }
            }
            
/*
            AddFluidChecksRecord = AddFluidChecksRecord.substring(0, AddFluidChecksRecord.length() - 1) + ") VALUES (";
            for(String key : UserAccountInfo.FluidChecksColumnsText.keySet()){
                if(key.equals("fluid_checks_id") == false){
                    AddFluidChecksRecord = AddFluidChecksRecord + "'" + NewFluidChecksInput.get(key) + "',";
                }
            }
*/
            AddFluidChecksRecord = AddFluidChecksRecord.substring(0, AddFluidChecksRecord.length() - 1) + ")";
            PreparedStatement AddFluidChecksRecordStatement = 
                    UserAccountInfo.TruckingConnection.prepareStatement(AddFluidChecksRecord);
            test = AddFluidChecksRecordStatement.executeUpdate();
            FluidChecksTable = UserAccountInfo.getFluidChecksTable();
        }
        
        if(request.getParameter("RefreshUpdate") != null){
            if(request.getParameter("RefreshUpdate").equals("Update")){
                String RowID = "0";
                String UpdateStatement = "";
                String CurrentParameter = "";
                boolean MakeChange = false;
                while(FluidChecksTable.next()){
                    UpdateStatement = "UPDATE fluid_checks SET";
                    MakeChange = false;
                    RowID = FluidChecksTable.getString(UserAccountInfo.FluidChecksColumns.get("fluid_checks_id"));
                    for(String key : UserAccountInfo.FluidChecksColumnsText.keySet()){
                        if(request.getParameter(RowID + " " + UserAccountInfo.FluidChecksColumnsText.get(key) + " UPDATE") != null){
                            CurrentParameter = request.getParameter(RowID + " " + UserAccountInfo.FluidChecksColumnsText.get(key) + " UPDATE");
                            if(CurrentParameter.equals("") == false && 
                                CurrentParameter.equals(FluidChecksTable.getString(UserAccountInfo.FluidChecksColumns.get(key))) == false){
                                MakeChange = true;
                                UpdateStatement = UpdateStatement + " " + key + "='" + CurrentParameter + "',";
                            }
                        }
                    }
                    if(MakeChange == true){
                        UpdateStatement = UpdateStatement.substring(0, UpdateStatement.length() - 1) + " WHERE fluid_checks_id = '" + RowID + "'";
                        PreparedStatement UpdateDatabase = UserAccountInfo.TruckingConnection.prepareStatement(UpdateStatement);
                        UpdateDatabase.executeUpdate();
                    }
                }
                FluidChecksTable = UserAccountInfo.getFluidChecksTable();
            }
        }
        String IncomingOutgoingText = "";
        int PixelMultiplier = 8;
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Fluid Checks</title>
    </head>
    <body>
        <h1>Fluid Checks</h1>
        <form name="GoToMainMenu" action="UserSignedIn.jsp" method="POST">
            <input type="submit" value="Go to Main Menu" name="Main Menu" />
        </form>
        <form name="FluidChecksGetter" action="FluidCheck.jsp" method="POST">
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
                        <th><%=UserAccountInfo.FluidChecksColumnsText.get("fluid_checks_id")%></th>
                        <th><%=UserAccountInfo.FluidChecksColumnsText.get("vehicle_id")%></th>
                        <th><%=UserAccountInfo.FluidChecksColumnsText.get("fluid_type")%></th>
                        <th><%=UserAccountInfo.FluidChecksColumnsText.get("date")%></th>
                    </tr>
                </thead>
                <tbody>
                    <form
                     <%try{
                        while(FluidChecksTable.next()){%>
                                <tr>
                                    <td><%=FluidChecksTable.getString(UserAccountInfo.FluidChecksColumns.get("fluid_checks_id"))%></td>
                                    <td><%=FluidChecksTable.getString(UserAccountInfo.FluidChecksColumns.get("vehicle_id"))%></td>
                                    <td><input style="width: <%=UserAccountInfo.MDFluidChecksTable.getPrecision(UserAccountInfo.FluidChecksColumns.get("fluid_type"))*PixelMultiplier%>px;" type="text" name="<%=FluidChecksTable.getString(UserAccountInfo.FluidChecksColumns.get("fluid_checks_id"))%> <%=UserAccountInfo.MDFluidChecksTable.getColumnName(UserAccountInfo.FluidChecksColumns.get("fluid_type")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=FluidChecksTable.getString(UserAccountInfo.FluidChecksColumns.get("fluid_type"))%>"/></td>
                                    <td><input style="width: <%=UserAccountInfo.MDFluidChecksTable.getPrecision(UserAccountInfo.FluidChecksColumns.get("date"))*PixelMultiplier%>px;" type="text" name="<%=FluidChecksTable.getString(UserAccountInfo.FluidChecksColumns.get("fluid_checks_id"))%> <%=UserAccountInfo.MDFluidChecksTable.getColumnName(UserAccountInfo.FluidChecksColumns.get("date")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=FluidChecksTable.getString(UserAccountInfo.FluidChecksColumns.get("date"))%>"/></td>
                                </tr> 
                        <%}%>
                    <%}catch(SQLException ex){
                        ex.printStackTrace();
                    }%>   
                    <tr>
                        <form action="VehicleInspection.jsp" method="POST">
                            <td><input type="submit" value="Add Data" name="AddDataBtn" /></td>
                            <%for(int MetaIndex = 2; MetaIndex <= FluidChecksTable.getMetaData().getColumnCount(); MetaIndex++){    
                                int size = UserAccountInfo.MDFluidChecksTable.getPrecision(MetaIndex) * PixelMultiplier;%>
                            <td><input style="width: <%=size%>px;" type="text" name="<%=UserAccountInfo.FluidChecksColumnsText.get(UserAccountInfo.MDFluidChecksTable.getColumnName(MetaIndex))%> INPUT" value="" /></td>
                            <input type="hidden" name="vehicle_id_param" value="<%=vehicle_id_param%>">
                            <%}%> 
                        </form>
                    </tr>                 
                </tbody>
            </table>
        </form>   
        <form name="DeleteUpdate" action="FluidCheck.jsp" method="POST">
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
