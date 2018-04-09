<%-- 
    Document   : Repair Records
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
    public class RepairRecord{

        String URL_CS499TruckingCompany = "jdbc:mysql://aa1wk12raqf2yoe.ca2f0nfwjqou.us-east-1.rds.amazonaws.com:3306/CS499TruckingCompany";
        String USERNAME = "SeniorProject";
        String PASSWORD = "password";
        String AccessCode = "";

        Connection TruckingConnection = null;

        PreparedStatement GetCookiesTable = null;
        PreparedStatement GetSignInDataTable = null;
        PreparedStatement GetRepairRecordTable = null;

        ResultSet RSCookiesTable = null;
        ResultSet RSSignInDataTable = null;
        ResultSet RSRepairRecordTable = null;

        ResultSetMetaData MDCookiesTable = null;
        ResultSetMetaData MDSignInDataTable = null;
        ResultSetMetaData MDRepairRecordTable = null;

        Map<String, Integer> UserCookiesColumns = new HashMap<String, Integer>();
        Map<String, Integer> SignInDataColumns = new HashMap<String, Integer>();
        Map<String, Integer> RepairRecordColumns = new HashMap<String, Integer>();
        Map<String, Integer> RepairRecordColumnsPrecision = new HashMap<String, Integer>();

        Map<String, String> RepairRecordColumnsText = new HashMap<String, String>();

        RepairRecord(String input_param){
        
            try{
                TruckingConnection = DriverManager.getConnection(URL_CS499TruckingCompany, USERNAME, PASSWORD);
                GetCookiesTable = TruckingConnection.prepareStatement("SELECT * FROM user_cookies_data");
                GetSignInDataTable = TruckingConnection.prepareStatement("SELECT * FROM sign_in_data");
                GetRepairRecordTable = TruckingConnection.prepareStatement("SELECT * FROM repair_data WHERE vehicle_id=" + input_param + "");
                RSCookiesTable = GetCookiesTable.executeQuery();
                RSSignInDataTable = GetSignInDataTable.executeQuery();
                RSRepairRecordTable = GetRepairRecordTable.executeQuery();
                MDCookiesTable = RSCookiesTable.getMetaData();
                MDSignInDataTable = RSSignInDataTable.getMetaData();
                MDRepairRecordTable = RSRepairRecordTable.getMetaData();
                for(int MetaIndex = 1; MetaIndex <= MDCookiesTable.getColumnCount(); MetaIndex++){
                    UserCookiesColumns.put(MDCookiesTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDSignInDataTable.getColumnCount(); MetaIndex++){
                    SignInDataColumns.put(MDSignInDataTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDRepairRecordTable.getColumnCount(); MetaIndex++){
                    RepairRecordColumns.put(MDRepairRecordTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDRepairRecordTable.getColumnCount(); MetaIndex++){
                    RepairRecordColumns.put(MDRepairRecordTable.getColumnName(MetaIndex), MetaIndex);
                    RepairRecordColumnsPrecision.put(MDRepairRecordTable.getColumnName(MetaIndex), MDRepairRecordTable.getPrecision(MetaIndex));
                    RepairRecordColumnsText.put(MDRepairRecordTable.getColumnName(MetaIndex), 
                        MDRepairRecordTable.getColumnName(MetaIndex).toUpperCase().replaceAll("_", " "));
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

        public ResultSet getRepairRecordTable(){
            try{
                RSRepairRecordTable = GetRepairRecordTable.executeQuery();
            }catch(SQLException ex){
                ex.printStackTrace();
            }
            return RSRepairRecordTable;   
        }
}
%>

<%
    
    String vehicle_id_param = request.getParameter("vehicle_id_param");
    
    boolean SignedIn = false;    
        String UserName = "";   
        String UserID = "";
        String AccessCode = "";
        RepairRecord UserAccountInfo = new RepairRecord(vehicle_id_param);
        Map<String, String> NewRepairRecordInput = new HashMap<String, String>();
        
        
        ResultSet CookiesTable = UserAccountInfo.getCookiesTable(); 
        ResultSet SignInDataTable = UserAccountInfo.getSignInDataTable();
        ResultSet RepairRecordTable = UserAccountInfo.getRepairRecordTable();
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
        for (String key : UserAccountInfo.RepairRecordColumnsText.keySet()) {
            if(request.getParameter(UserAccountInfo.RepairRecordColumnsText.get(key) + " INPUT") == null ||
                    request.getParameter(UserAccountInfo.RepairRecordColumnsText.get(key) + " INPUT") == ""){
                if(key.equals("repair_id") == false){
                    GoodInput = false;
                    break;
                }                
            }else{
                //if(key.equals())
                NewRepairRecordInput.put(key,request.getParameter(UserAccountInfo.RepairRecordColumnsText.get(key) + " INPUT"));
            }
        }
        
        int test = 0;
        String AddRepairRecordRecord = "INSERT INTO repair_data (";
        if(GoodInput == true){
            for(String key : UserAccountInfo.RepairRecordColumnsText.keySet()){
                if(key.equals("repair_id") == false) {
                    AddRepairRecordRecord = AddRepairRecordRecord + key + ",";
                }
            }
            
            AddRepairRecordRecord = AddRepairRecordRecord.substring(0, AddRepairRecordRecord.length() - 1) + ") VALUES (";
            for(String key : UserAccountInfo.RepairRecordColumnsText.keySet()){
                if((key.equals("repair_id") == false) && (key.equals("vehicle_id") == false)){
                    AddRepairRecordRecord = AddRepairRecordRecord + "'" + NewRepairRecordInput.get(key) + "',";
                }
                if(key.equals("vehicle_id") == true)
                {
                    AddRepairRecordRecord = AddRepairRecordRecord + "'" + vehicle_id_param + "',";
                }
            }
            
/*
            AddVehicleInspectionRecord = AddVehicleInspectionRecord.substring(0, AddVehicleInspectionRecord.length() - 1) + ") VALUES (";
            for(String key : UserAccountInfo.VehicleInspectionColumnsText.keySet()){
                if(key.equals("inspection_id") == false){
                    AddVehicleInspectionRecord = AddVehicleInspectionRecord + "'" + NewVehicleInspectionInput.get(key) + "',";
                }
            }
*/
            AddRepairRecordRecord = AddRepairRecordRecord.substring(0, AddRepairRecordRecord.length() - 1) + ")";
            PreparedStatement AddRepairRecordRecordStatement = 
                    UserAccountInfo.TruckingConnection.prepareStatement(AddRepairRecordRecord);
            test = AddRepairRecordRecordStatement.executeUpdate();
            RepairRecordTable = UserAccountInfo.getRepairRecordTable();
        }
        
        if(request.getParameter("RefreshUpdate") != null){
            if(request.getParameter("RefreshUpdate").equals("Update")){
                String RowID = "0";
                String UpdateStatement = "";
                String CurrentParameter = "";
                boolean MakeChange = false;
                while(RepairRecordTable.next()){
                    UpdateStatement = "UPDATE repair_data SET";
                    MakeChange = false;
                    RowID = RepairRecordTable.getString(UserAccountInfo.RepairRecordColumns.get("repair_id"));
                    for(String key : UserAccountInfo.RepairRecordColumnsText.keySet()){
                        if(request.getParameter(RowID + " " + UserAccountInfo.RepairRecordColumnsText.get(key) + " UPDATE") != null){
                            CurrentParameter = request.getParameter(RowID + " " + UserAccountInfo.RepairRecordColumnsText.get(key) + " UPDATE");
                            if(CurrentParameter.equals("") == false && 
                                CurrentParameter.equals(RepairRecordTable.getString(UserAccountInfo.RepairRecordColumns.get(key))) == false){
                                MakeChange = true;
                                UpdateStatement = UpdateStatement + " " + key + "='" + CurrentParameter + "',";
                            }
                        }
                    }
                    if(MakeChange == true){
                        UpdateStatement = UpdateStatement.substring(0, UpdateStatement.length() - 1) + " WHERE repair_id = '" + RowID + "'";
                        PreparedStatement UpdateDatabase = UserAccountInfo.TruckingConnection.prepareStatement(UpdateStatement);
                        UpdateDatabase.executeUpdate();
                    }
                }
                RepairRecordTable = UserAccountInfo.getRepairRecordTable();
            }
        }
        String IncomingOutgoingText = "";
        int PixelMultiplier = 8;
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Repair Record</title>
    </head>
    <body>
        <h1>Repair Record</h1>
        <form name="GoToMainMenu" action="UserSignedIn.jsp" method="POST">
            <input type="submit" value="Go to Main Menu" name="Main Menu" />
        </form>
        <form name="RepairRecordGetter" action="RepairRecord.jsp" method="POST">
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
                        <th><%=UserAccountInfo.RepairRecordColumnsText.get("repair_id")%></th>
                        <th><%=UserAccountInfo.RepairRecordColumnsText.get("vehicle_id")%></th>
                        <th><%=UserAccountInfo.RepairRecordColumnsText.get("description")%></th>
                        <th><%=UserAccountInfo.RepairRecordColumnsText.get("parts_list")%></th>
                        <th><%=UserAccountInfo.RepairRecordColumnsText.get("date")%></th>
                        <th><%=UserAccountInfo.RepairRecordColumnsText.get("came_from_company_stocks")%></th>
                        <th><%=UserAccountInfo.RepairRecordColumnsText.get("ordered_from")%></th>
                        <th><%=UserAccountInfo.RepairRecordColumnsText.get("price")%></th>
                    </tr>
                </thead>
                <tbody>
                    <form
                     <%try{
                        while(RepairRecordTable.next()){%>
                                <tr>
                                    <td><%=RepairRecordTable.getString(UserAccountInfo.RepairRecordColumns.get("repair_id"))%></td>
                                    <td><%=RepairRecordTable.getString(UserAccountInfo.RepairRecordColumns.get("vehicle_id"))%></td>
                                    <td><input style="width: <%=UserAccountInfo.MDRepairRecordTable.getPrecision(UserAccountInfo.RepairRecordColumns.get("description"))*PixelMultiplier%>px;" type="text" name="<%=RepairRecordTable.getString(UserAccountInfo.RepairRecordColumns.get("repair_id"))%> <%=UserAccountInfo.MDRepairRecordTable.getColumnName(UserAccountInfo.RepairRecordColumns.get("description")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=RepairRecordTable.getString(UserAccountInfo.RepairRecordColumns.get("description"))%>"/></td>
                                    <td><input style="width: <%=UserAccountInfo.MDRepairRecordTable.getPrecision(UserAccountInfo.RepairRecordColumns.get("parts_list"))*PixelMultiplier%>px;" type="text" name="<%=RepairRecordTable.getString(UserAccountInfo.RepairRecordColumns.get("repair_id"))%> <%=UserAccountInfo.MDRepairRecordTable.getColumnName(UserAccountInfo.RepairRecordColumns.get("parts_list")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=RepairRecordTable.getString(UserAccountInfo.RepairRecordColumns.get("parts_list"))%>"/></td>
                                    <td><input style="width: <%=UserAccountInfo.MDRepairRecordTable.getPrecision(UserAccountInfo.RepairRecordColumns.get("date"))*PixelMultiplier%>px;" type="text" name="<%=RepairRecordTable.getString(UserAccountInfo.RepairRecordColumns.get("repair_id"))%> <%=UserAccountInfo.MDRepairRecordTable.getColumnName(UserAccountInfo.RepairRecordColumns.get("date")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=RepairRecordTable.getString(UserAccountInfo.RepairRecordColumns.get("date"))%>"/></td>
                                    <td><input style="width: <%=UserAccountInfo.MDRepairRecordTable.getPrecision(UserAccountInfo.RepairRecordColumns.get("came_from_company_stocks"))*PixelMultiplier%>px;" type="text" name="<%=RepairRecordTable.getString(UserAccountInfo.RepairRecordColumns.get("repair_id"))%> <%=UserAccountInfo.MDRepairRecordTable.getColumnName(UserAccountInfo.RepairRecordColumns.get("came_from_company_stocks")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=RepairRecordTable.getString(UserAccountInfo.RepairRecordColumns.get("came_from_company_stocks"))%>"/></td>
                                    <td><input style="width: <%=UserAccountInfo.MDRepairRecordTable.getPrecision(UserAccountInfo.RepairRecordColumns.get("ordered_from"))*PixelMultiplier%>px;" type="text" name="<%=RepairRecordTable.getString(UserAccountInfo.RepairRecordColumns.get("repair_id"))%> <%=UserAccountInfo.MDRepairRecordTable.getColumnName(UserAccountInfo.RepairRecordColumns.get("ordered_from")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=RepairRecordTable.getString(UserAccountInfo.RepairRecordColumns.get("ordered_from"))%>"/></td>
                                    <td><input style="width: <%=UserAccountInfo.MDRepairRecordTable.getPrecision(UserAccountInfo.RepairRecordColumns.get("price"))*PixelMultiplier%>px;" type="text" name="<%=RepairRecordTable.getString(UserAccountInfo.RepairRecordColumns.get("repair_id"))%> <%=UserAccountInfo.MDRepairRecordTable.getColumnName(UserAccountInfo.RepairRecordColumns.get("price")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=RepairRecordTable.getString(UserAccountInfo.RepairRecordColumns.get("price"))%>"/></td>
                                </tr> 
                        <%}%>
                    <%}catch(SQLException ex){
                        ex.printStackTrace();
                    }%>   
                    <tr>
                        <form action="RepairRecord.jsp" method="POST">
                            <td><input type="submit" value="Add Data" name="AddDataBtn" /></td>
                            <%for(int MetaIndex = 2; MetaIndex <= RepairRecordTable.getMetaData().getColumnCount(); MetaIndex++){    
                                int size = UserAccountInfo.MDRepairRecordTable.getPrecision(MetaIndex) * PixelMultiplier;%>
                            <td><input style="width: <%=size%>px;" type="text" name="<%=UserAccountInfo.RepairRecordColumnsText.get(UserAccountInfo.MDRepairRecordTable.getColumnName(MetaIndex))%> INPUT" value="" /></td>
                            <input type="hidden" name="vehicle_id_param" value="<%=vehicle_id_param%>">
                            <%}%> 
                        </form>
                    </tr>                 
                </tbody>
            </table>
        </form>   
        <form name="DeleteUpdate" action="RepairRecord.jsp" method="POST">
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
