<%-- 
    Document   : MaintenanceData
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
 <%@page import="java.sql.Statement"%>
 <%@page import="java.sql.DriverManager"%>
<%@page import="javax.servlet.http.HttpServletRequest" %>
<%@page import="java.io.*,java.util.*"%>
<%@page import="java.sql.Connection"%>
<!DOCTYPE html>

<%!
    public class MaintenanceData{


        String URL_CS499TruckingCompany = "jdbc:mysql://aa1wk12raqf2yoe.ca2f0nfwjqou.us-east-1.rds.amazonaws.com:3306/CS499TruckingCompany";
        String USERNAME = "SeniorProject";
        String PASSWORD = "password";
        String AccessCode = "";

        Connection TruckingConnection = null;

        PreparedStatement GetCookiesTable = null;
        PreparedStatement GetSignInDataTable = null;
        PreparedStatement GetMaintenanceDataTable = null;

        ResultSet RSCookiesTable = null;
        ResultSet RSSignInDataTable = null;
        ResultSet RSMaintenanceDataTable = null;

        ResultSetMetaData MDCookiesTable = null;
        ResultSetMetaData MDSignInDataTable = null;
        ResultSetMetaData MDMaintenanceDataTable = null;

        Map<String, Integer> UserCookiesColumns = new HashMap<String, Integer>();
        Map<String, Integer> SignInDataColumns = new HashMap<String, Integer>();
        Map<String, Integer> MaintenanceDataColumns = new HashMap<String, Integer>();
        Map<String, Integer> MaintenanceDataColumnsPrecision = new HashMap<String, Integer>();

        Map<String, String> MaintenanceDataColumnsText = new HashMap<String, String>();

        MaintenanceData(){

            


            try{
                TruckingConnection = DriverManager.getConnection(URL_CS499TruckingCompany, USERNAME, PASSWORD);
                GetCookiesTable = TruckingConnection.prepareStatement("SELECT * FROM user_cookies_data");
                GetSignInDataTable = TruckingConnection.prepareStatement("SELECT * FROM sign_in_data");
                GetMaintenanceDataTable = TruckingConnection.prepareStatement("SELECT * FROM maintenance_data");
                RSCookiesTable = GetCookiesTable.executeQuery();
                RSSignInDataTable = GetSignInDataTable.executeQuery();
                RSMaintenanceDataTable = GetMaintenanceDataTable.executeQuery();
                MDCookiesTable = RSCookiesTable.getMetaData();
                MDSignInDataTable = RSSignInDataTable.getMetaData();
                MDMaintenanceDataTable = RSMaintenanceDataTable.getMetaData();
                for(int MetaIndex = 1; MetaIndex <= MDCookiesTable.getColumnCount(); MetaIndex++){
                    UserCookiesColumns.put(MDCookiesTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDSignInDataTable.getColumnCount(); MetaIndex++){
                    SignInDataColumns.put(MDSignInDataTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDMaintenanceDataTable.getColumnCount(); MetaIndex++){
                    MaintenanceDataColumns.put(MDMaintenanceDataTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDMaintenanceDataTable.getColumnCount(); MetaIndex++){
                    MaintenanceDataColumns.put(MDMaintenanceDataTable.getColumnName(MetaIndex), MetaIndex);
                    MaintenanceDataColumnsPrecision.put(MDMaintenanceDataTable.getColumnName(MetaIndex), MDMaintenanceDataTable.getPrecision(MetaIndex));
                    MaintenanceDataColumnsText.put(MDMaintenanceDataTable.getColumnName(MetaIndex), 
                        MDMaintenanceDataTable.getColumnName(MetaIndex).toUpperCase().replaceAll("_", " "));
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

        public ResultSet getMaintenanceDataTable(){
            try{
                RSMaintenanceDataTable = GetMaintenanceDataTable.executeQuery();
            }catch(SQLException ex){
                ex.printStackTrace();
            }
            return RSMaintenanceDataTable;   
        }
}
%>

<%
    
    String maintenance_id_param = request.getParameter("maintenance_id_param");
    
    boolean SignedIn = false;    
        String UserName = "";   
        String UserID = "";
        String AccessCode = "";
        MaintenanceData UserAccountInfo = new MaintenanceData();
        Map<String, String> NewMaintenanceDataInput = new HashMap<String, String>();
        
        
        ResultSet CookiesTable = UserAccountInfo.getCookiesTable(); 
        ResultSet SignInDataTable = UserAccountInfo.getSignInDataTable();
        ResultSet MaintenanceDataTable = UserAccountInfo.getMaintenanceDataTable();
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
        

     //ONLY PARTIALLY UPDATED, PROCEED WITH CAUTION   
     /*   
        
        boolean GoodInput = true;
        for (String key : UserAccountInfo.MaintenanceDataColumnsText.keySet()) {
            if(request.getParameter(UserAccountInfo.MaintenanceDataColumnsText.get(key) + " INPUT") == null ||
                    request.getParameter(UserAccountInfo.MaintenanceDataColumnsText.get(key) + " INPUT") == ""){
                if(key.equals("maintenance_id") == false){
                    GoodInput = false;
     //DID NOT UPDATE PAST HERE
                    break;}                
            }else{
                //if(key.equals())
                NewEquipmentDataInput.put(key,request.getParameter(UserAccountInfo.EquipmentDataColumnsText.get(key) + " INPUT"));
            }
        }
        int test = 0;
        String AddEquipmentRecord = "INSERT INTO equipment_data (";
        if(GoodInput == true){
            for(String key : UserAccountInfo.EquipmentDataColumnsText.keySet()){
                if(key.equals("equipment_id") == false){
                    AddEquipmentRecord = AddEquipmentRecord + key + ",";
                }
            }
            AddEquipmentRecord = AddEquipmentRecord.substring(0, AddEquipmentRecord.length() - 1) + ") VALUES (";
            for(String key : UserAccountInfo.EquipmentDataColumnsText.keySet()){
                if(key.equals("equipment_id") == false){
                    AddEquipmentRecord = AddEquipmentRecord + "'" + NewEquipmentDataInput.get(key) + "',";
                }
            }
            AddEquipmentRecord = AddEquipmentRecord.substring(0, AddEquipmentRecord.length() - 1) + ")";
            PreparedStatement AddEquipmentRecordStatement = 
                    UserAccountInfo.TruckingConnection.prepareStatement(AddEquipmentRecord);
            test = AddEquipmentRecordStatement.executeUpdate();
            EquipmentDataTable = UserAccountInfo.getEquipmentDataTable();
        }
        
        if(request.getParameter("RefreshUpdate") != null){
            if(request.getParameter("RefreshUpdate").equals("Update")){
                String RowID = "0";
                String UpdateStatement = "";
                String CurrentParameter = "";
                boolean MakeChange = false;
                while(EquipmentDataTable.next()){
                    UpdateStatement = "UPDATE equipment_data SET";
                    MakeChange = false;
                    RowID = EquipmentDataTable.getString(UserAccountInfo.EquipmentDataColumns.get("equipment_id"));
                    for(String key : UserAccountInfo.EquipmentDataColumnsText.keySet()){
                        if(request.getParameter(RowID + " " + UserAccountInfo.EquipmentDataColumnsText.get(key) + " UPDATE") != null){
                            CurrentParameter = request.getParameter(RowID + " " + UserAccountInfo.EquipmentDataColumnsText.get(key) + " UPDATE");
                            if(CurrentParameter.equals("") == false && 
                                CurrentParameter.equals(EquipmentDataTable.getString(UserAccountInfo.EquipmentDataColumns.get(key))) == false){
                                MakeChange = true;
                                UpdateStatement = UpdateStatement + " " + key + "='" + CurrentParameter + "',";
                            }
                        }
                    }
                    if(MakeChange == true){
                        UpdateStatement = UpdateStatement.substring(0, UpdateStatement.length() - 1) + " WHERE equipment_id = '" + RowID + "'";
                        PreparedStatement UpdateDatabase = UserAccountInfo.TruckingConnection.prepareStatement(UpdateStatement);
                        UpdateDatabase.executeUpdate();
                    }
                }
                EquipmentDataTable = UserAccountInfo.getEquipmentDataTable();
            }
        }
        String IncomingOutgoingText = "";

*/

        int PixelMultiplier = 8;
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Maintenance Data For Vehicle ID: <%=maintenance_id_param%> </title>
    </head>
    <body>
        <h1>Maintenance Data For Vehicle ID: <%=maintenance_id_param%> </h1>
        <form name="GoToMainMenu" action="UserSignedIn.jsp" method="POST">
            <input type="submit" value="Go to Main Menu" name="Main Menu" />
        </form>
        <form name="MaintenanceDataGetter" action="MaintenanceData.jsp" method="POST">
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
                        <th><%=UserAccountInfo.MaintenanceDataColumnsText.get("vehicle_inspection_id")%></th>
                        <th><%=UserAccountInfo.MaintenanceDataColumnsText.get("oil_change_id")%></th>
                        <th><%=UserAccountInfo.MaintenanceDataColumnsText.get("filter_change_id")%></th>
                        <th><%=UserAccountInfo.MaintenanceDataColumnsText.get("tire_rotation_id")%></th>
                        <th><%=UserAccountInfo.MaintenanceDataColumnsText.get("tire_changes_id")%></th>
                        <th><%=UserAccountInfo.MaintenanceDataColumnsText.get("fluid_checks_id")%></th>
                        <th><%=UserAccountInfo.MaintenanceDataColumnsText.get("spark_plugs_id")%></th>
                        <th><%=UserAccountInfo.MaintenanceDataColumnsText.get("timing_belt_id")%></th>
                        <th><%=UserAccountInfo.MaintenanceDataColumnsText.get("cleaning_interior_id")%></th>
                        <th><%=UserAccountInfo.MaintenanceDataColumnsText.get("lights_check_id")%></th>
                        <th><%=UserAccountInfo.MaintenanceDataColumnsText.get("repair_record_id")%></th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td><a href="VehicleInspection.jsp?vehicle_id_param=<%=maintenance_id_param%>">Inspections</a></td>
                        <td><a href="OilChange.jsp?vehicle_id_param=<%=maintenance_id_param%>">Oil Changes</a></td>
                        <td><a href="FilterChange.jsp?vehicle_id_param=<%=maintenance_id_param%>">Filter Changes</a></td>
                        <td><a href="TireRotation.jsp?vehicle_id_param=<%=maintenance_id_param%>">Tire Rotations</a></td>
                        <td><a href="TireChange.jsp?vehicle_id_param=<%=maintenance_id_param%>">Tire Changes</a></td>
                        <td><a href="FluidCheck.jsp?vehicle_id_param=<%=maintenance_id_param%>">Fluid Checks</a></td>
                        <td><a href="SparkPlug.jsp?vehicle_id_param=<%=maintenance_id_param%>">Spark Plug Checks</a></td>
                        <td><a href="TimingBelt.jsp?vehicle_id_param=<%=maintenance_id_param%>">Timing Belt Checks</a></td>
                        <td><a href="CleaningInterior.jsp?vehicle_id_param=<%=maintenance_id_param%>">Interior Cleaning</a></td>
                        <td><a href="LightsCheck.jsp?vehicle_id_param=<%=maintenance_id_param%>">Lights Checks</a></td>
                        <td><a href="RepairRecord.jsp?vehicle_id_param=<%=maintenance_id_param%>">Repairs</a></td>
                    </tr>
                </tbody>
            </table>
        </form>
        <a href="jasperSingleVehicleReport.jsp?vehicle_id_param=<%=maintenance_id_param%>">Vehicle Maintenance Report</a>
        <form name="DeleteUpdate" action="MaintenanceData.jsp" method="POST">
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
        var txt = "Refreshing Equipment Data Page";
        if (document.getElementsByName("RefreshUpdate")[0].value === "Update"){
            txt = "Updating database.  This will take a few moments."
        }
        alert(txt);
    }   
</script>
