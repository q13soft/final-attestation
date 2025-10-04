package ru.rtk.q13;

import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.io.FileInputStream;
import java.io.IOException;
import java.sql.Connection;
import java.sql.Statement;
import java.util.Properties;

/**
 */
public class App 
{
    private Connection connection;

    public static void main( String[] args ) throws ClassNotFoundException
    {
        System.out.println( "final-attestation, version 1.0" );
        App app = new App();
        // app.testShowUser();
        app.start();
    } 
    public void start() {
        try {
            // load data for connection
            Properties props = loadProperties();

            // connect to db
            connectToDatabase(props);
            // CRUD are working 
            workingCRUD();

        } catch (SQLException | IOException e) {
            System.err.println("Ошибка: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeConnection();
        }    
    }

    private Properties loadProperties() throws IOException {
        Properties props = new Properties();
        try (FileInputStream in = new FileInputStream("src/main/resources/application.properties")) {
            props.load(in);
        }
        return props;
    } 

    private void connectToDatabase(Properties props) throws SQLException {
        String url = props.getProperty("db.url");
        String user = props.getProperty("db.username");
        String password = props.getProperty("db.password");

        this.connection = DriverManager.getConnection(url, user, password);
        System.out.println("Connect to db");
    }

    private void workingCRUD() throws SQLException {
        connection.setAutoCommit(false);

        try {
            System.out.println("Working CRUD");

            // Добавление нового товара
           addNewProduct("Гуава", 120.00, 100, "Фрукты");
           addNewProduct("Огурец", 70.00, 100, "Овощи");
            
            // Добавление нового покупателя
           addNewCustomer("Иван","Иванов","999-277-9871","ivan@mail.ru");

            // Топ-3 самых популярных товара
            top3();

            // прайс лист
            priceList();

            //журнал заказов
            orderList();

            // создание нового заказа и списание товара со склада


            // Удаление тестовых записей
         // deleteTest();

            connection.commit();
            System.out.println("The CRUD is over");

        } catch (SQLException e) {
            connection.rollback();
            System.err.println("Error for CRUD. Rollback");
            throw e;
        } finally {
            connection.setAutoCommit(true);
        }
    }


// показать прайс лист и остатки товаров на складе
    private void top3() throws SQLException {
        String strSQL = """
            select  p.prd_name, sum(o2.ord_quantity) as sum 
            from product p
            join order2 o2 on o2.prd_id = p.prd_id 
            group by p.prd_name
            order by sum desc
            limit 3;
        """;
            System.out.println("TOP3 products ");
       try (Statement stmt = connection.createStatement();
             ResultSet rs = stmt.executeQuery(strSQL)) {
            System.out.println("Наименование      Продано");
            while (rs.next()) {
                String name = rs.getString("prd_name");
                Integer sum = rs.getInt("sum");
                System.out.printf("%-18s %-4d",
                        name, sum);
                System.out.println();
            } 
        }
    }

    /**
     *  Журнал заказов
     * @throws SQLException
     */
    private void orderList() throws SQLException {
        String strSQL = """
            SELECT o2.ord_id, c.cst_firstname, c.cst_lastname, p.prd_name, p.prd_price, o2.ord_quantity ,p.prd_price*o2.ord_quantity as sum, os.ost_name, p.prd_quantity, o2.ord_date 
            FROM order2 o2  
            JOIN customer c ON o2.cst_id = c.cst_id
            join product p on o2.prd_id = p.prd_id 
            join order_status os on o2.ost_id = os.ost_id 
        """;
            System.out.println("Order List ");
       try (Statement stmt = connection.createStatement();
             ResultSet rs = stmt.executeQuery(strSQL)) {
            System.out.println("ном.  Покупатель        Покупка    Цена   Кол-во  Сумма      Статус                Остаток  Дата");
            while (rs.next()) { 
                Integer id = rs.getInt("ord_id");
                String fio = rs.getString("cst_firstname") +" "+ rs.getString("cst_lastname");
                String name = rs.getString("prd_name");
                double price = rs.getDouble("prd_price");
                Integer quantity = rs.getInt("ord_quantity");
                double sum = price * quantity;
                String status = rs.getString("ost_name");
                Integer ost = rs.getInt("prd_quantity");
                System.out.printf(" %-3d  %-17s %-10s %-10.2f %-3d %-10.2f %-23s %-4d ",
                        id, fio, name, price, quantity, sum, status, ost);
                System.out.println();
            } 
        }
    }

// показать прайс лист и остатки товаров на складе
    private void priceList() throws SQLException {
        String strSQL = """
            SELECT prd_id, prd_name, prd_price, prd_quantity
            FROM product p 
            WHERE prd_quantity > 0;
        """;
            System.out.println("Price List ");
       try (Statement stmt = connection.createStatement();
             ResultSet rs = stmt.executeQuery(strSQL)) {
            System.out.println("ID    Наименование       Цена        Остаток");
            while (rs.next()) {
                Integer id = rs.getInt("prd_id");
                String name = rs.getString("prd_name");
                double price = rs.getDouble("prd_price");
                Integer quantity = rs.getInt("prd_quantity");
                System.out.printf(" %-3d  %-18s %-10.2f  %-4d",
                        id, name, price, quantity);
                System.out.println();
            } 
        }
    }


    private void addNewCustomer(String firstname, String lasttname, String phone, String email ) throws SQLException {
        System.out.println("CRUD add new customer");
        String strSQL = """
            INSERT INTO public.customer (cst_firstname, cst_lastname, cst_phone, cst_email) 
            VALUES (?, ?, ?, ?)
        """;
        try (PreparedStatement pstmt = connection.prepareStatement(strSQL)) {
            pstmt.setString(1, firstname);
            pstmt.setString(2, lasttname);            
            pstmt.setString(3, phone);
            pstmt.setString(4, email);
            pstmt.executeUpdate();
            System.out.println("Add customer: "+firstname+" "+ lasttname);
        }
    }

    private void addNewProduct(String name, Double price, Integer quantity, String cat ) throws SQLException {
        System.out.println("CRUD add new product");
        String strSQL = """
            INSERT INTO public.product (prd_name, prd_price, prd_quantity, prd_category) 
            VALUES (?, ?, ?, ?)
        """;
        try (PreparedStatement pstmt = connection.prepareStatement(strSQL)) {
            pstmt.setString(1, name);
            pstmt.setDouble(2, price);            
            pstmt.setInt(3, quantity);
            pstmt.setString(4, cat);
            pstmt.executeUpdate();
            System.out.println("Add product: "+name);
        }
    }
    /**
     * Удаление тестовых записей
     */
    private void deleteTest() {
// "DELETE FROM public.product WHERE prd_name LIKE 'Гуава%';" 
// "DELETE FROM public.product WHERE prd_name LIKE 'Огурец%';"
    }


    private void closeConnection() {
        if (connection != null) {
            try {
                connection.close();
                System.out.println("Connect of db is closed");
            } catch (SQLException e) {
                System.err.println("Error connect db: " + e.getMessage());
            }
        }
    }

    public void testShowUser () {
        String url = "jdbc:postgresql://localhost:5432/innopolis_rtk"; 
        String user = "postgres"; 
        String password = "1111"; 

        String sql = "SELECT c.cst_firstname, c.cst_lastname FROM customer c;";

        try (Connection conn = DriverManager.getConnection(url, user, password);
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) { 

            // get result list of customer
            while (rs.next()) {
                // int id = rs.getInt("id");
                String firstname = rs.getString("cst_firstname");
                String lastname = rs.getString("cst_lastname");
                System.out.println("Покупатель: " + firstname + " " + lastname);
            }

        } catch (SQLException e) {
            System.err.println("Ошибка выполнения запроса: " + e.getMessage());
        }
    }
}
