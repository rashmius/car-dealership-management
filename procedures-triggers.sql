DROP PROCEDURE IF EXISTS dbo.p_upsert_appointment
GO
CREATE PROCEDURE dbo.p_upsert_appointment(
    @CUSTOMER_ID int,
    @APP_TYPE varchar(20),
    @APP_DATE date
)
AS 
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
        -- get random emp id from customer serivce department
            DECLARE @EMP_ID int
            set @EMP_ID = (select top 1 employee_id from employees where employee_department='customer_service' )
        -- insert into appointment requests
            insert into appointments values (@CUSTOMER_ID, @EMP_ID, @APP_TYPE, @APP_DATE, 'Pending')
        COMMIT
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW 5001, 'Error',1
    END CATCH
END

GO


DROP PROCEDURE IF EXISTS dbo.p_upsert_maintenance_request
GO

CREATE PROCEDURE dbo.p_upsert_maintenance_request(
    @CUSTOMER_ID int,
    @REQ_TYPE VARCHAR(50),
    @REQ_DATE DATE,
    @REQ_AMOUNT money
)
AS 
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
        -- get random emp id from maintenance department
            DECLARE @EMP_ID int
            set @EMP_ID = (select top 1 employee_id from employees where employee_department='maintenance' )
        -- insert into maintenance requests
            insert into maintenance_requests values (@CUSTOMER_ID, @REQ_TYPE, @REQ_DATE, 'PENDING', @EMP_ID, @REQ_AMOUNT)
        COMMIT
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW 5001, 'Error',1
    END CATCH
END


DROP PROCEDURE IF EXISTS dbo.p_upsert_order 

GO
CREATE PROCEDURE dbo.p_upsert_order(
    @CAR_ID int,
    @CUSTOMER_ID int,
    @ORDER_STATUS VARCHAR(10),
    @DELIVERY_STATUS VARCHAR(20),
    @ORDER_TOTAL money,
    @FINANCE_OPTION_ID int,
    @FINANCE_AMOUNT money,
    @FINANCE_TERM date,
    @INSURANCE_TYPE VARCHAR(20),
    @INSURANCE_COST money,
    @PAYMENT_TYPE VARCHAR(20),
    @INSURANCE_ST_DATE date,
    @INSURANCE_END_DATE date,
    @CAR_ACC_ID int
)
AS
BEGIN
    BEGIN TRY
    BEGIN TRANSACTION

        DECLARE @QUANT_AVAILABLE int
        DECLARE @FINANCE_ID int
        DECLARE @ORDER_ID_TABLE table (ID int)
        DECLARE @ORDER_ID int
        DECLARE @FINANCE_ID_TABLE table (ID int)
        DECLARE @INSURANCE_ID int
        DECLARE @INSURANCE_ID_TABLE table (ID int)

        set @QUANT_AVAILABLE = (select inventory_car_quantity
    from inventories
    where inventory_car_id = @CAR_ID)
        PRINT @QUANT_AVAILABLE
        -- if quantity available in inventory then only place order
        if (@QUANT_AVAILABLE > 0) BEGIN

        update inventories SET inventory_car_quantity = inventory_car_quantity - 1 where inventory_car_id = @CAR_ID
        insert into orders
        OUTPUT INSERTED.order_id into  @ORDER_ID_TABLE
        values
            (@CUSTOMER_ID, @FINANCE_OPTION_ID, null, null, @PAYMENT_TYPE, @CAR_ID, @CAR_ACC_ID, 'Pending', @ORDER_TOTAL, 'Pending')
        SET @ORDER_ID = (select *
        from @ORDER_ID_TABLE)

        -- if finance is taken, insert into finances, and update order with finance id
        if (@PAYMENT_TYPE = 'Financed' and @FINANCE_OPTION_ID is not null) BEGIN
            insert into finances
            OUTPUT INSERTED.finance_id INTO @FINANCE_ID_TABLE
            values
                (@CUSTOMER_ID, @FINANCE_OPTION_ID, @FINANCE_AMOUNT, @FINANCE_TERM, @ORDER_ID)
            SET @FINANCE_ID = (select *
            from @FINANCE_ID_TABLE)
            update orders SET order_finance_id = @FINANCE_ID WhERE order_id = @ORDER_ID
        END

        -- if insurance is taken, insert into insurances, and update orders with insurance id
        IF (@INSURANCE_COST is not NULL and @INSURANCE_TYPE is not NULL)
                insert into insurances
        OUTPUT INSERTED.insurance_id INTO @INSURANCE_ID_TABLE
        values
            (@ORDER_ID, @INSURANCE_TYPE, @INSURANCE_COST, @INSURANCE_ST_DATE, @INSURANCE_END_DATE)
        SET @INSURANCE_ID = (select *
        from @INSURANCE_ID_TABLE)
        update orders SET order_insurance_id = @INSURANCE_ID WhERE order_id = @ORDER_ID

    end
    COMMIT
END TRY
BEGIN CATCH
ROLLBACK;
THROW
END CATCH
END



DROP PROCEDURE IF EXISTS dbo.p_upsert_rental_requests

GO

CREATE PROCEDURE dbo.p_upsert_rental_requests(
    @CUSTOMER_ID int,
    @CAR_ID int,
    @START_DATE DATE,
    @END_DATE DATE,
    @PICKUP_ADD VARCHAR(50),
    @DROP_ADD VARCHAR(50),
    @REQ_TOTAL_MILES int,
    @REQ_FUEL_INC bit
)
AS 
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            -- check end date > start date
            if (@START_DATE<=@END_DATE) begin
                DECLARE @TOTAL_M_S int
                DECLARE @TOTAL_A INT
                DECLARE @INIT_A int
                DECLARE @PRICE_PER_MILE int

                SET @PRICE_PER_MILE = (select cppml_price_per_mile from car_price_per_mile_lookup where cppml_car_id = @CAR_ID)
                SET @INIT_A = @PRICE_PER_MILE * @REQ_TOTAL_MILES
                SET @TOTAL_A = @INIT_A
                SET @TOTAL_M_S = 0
                insert into car_rental_requests values (@CUSTOMER_ID, @CAR_ID, @START_DATE, @END_DATE, @PICKUP_ADD, @DROP_ADD, 'ORDERED', @REQ_TOTAL_MILES
            , @REQ_FUEL_INC, @TOTAL_M_S, @TOTAL_A, @INIT_A)
            end
        COMMIT
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW 5001, 'Error',1
    END CATCH
END

DROP TRIGGER IF EXISTS update_rental_total_amount
GO

CREATE TRIGGER update_rental_total_amount
ON car_rental_requests
AFTER UPDATE AS
BEGIN
DECLARE @TOTAL_AMOUNT int
DECLARE @PRICE_PER_MILE int
DECLARE @TOTAL_MILES_SPENT int
DECLARE @REQUEST_ID INT
DECLARE @CAR_ID int
SELECT @REQUEST_ID = request_id from inserted
SELECT @CAR_ID = request_car_id from inserted
SET @PRICE_PER_MILE = (select cppml_price_per_mile from car_price_per_mile_lookup where car_price_per_mile_lookup.cppml_car_id=@CAR_ID)
SET @TOTAL_AMOUNT = (select request_initial_amount from car_rental_requests where car_rental_requests.request_id = @REQUEST_ID)
SET @TOTAL_MILES_SPENT = (select  request_total_miles_spent from car_rental_requests where car_rental_requests.request_id = @REQUEST_ID)
SET @TOTAL_AMOUNT = @TOTAL_AMOUNT + @TOTAL_MILES_SPENT * @PRICE_PER_MILE
UPDATE car_rental_requests
SET request_total_amount = @TOTAL_AMOUNT
FROM INSERTED where car_rental_requests.request_id = @REQUEST_ID 
END
GO

DROP VIEW IF EXISTS ALL_ORDERS

GO

CREATE VIEW ALL_ORDERS
AS
SELECT car_model, car_brand, order_total, finance_customer_amount, cname, order_payment_type, order_status, delivery_status FROM
(SELECT order_customer_id, order_finance_id, order_insurance_id, order_payment_type, order_car_id, order_status, order_total, delivery_status
FROM orders) as ord INNER JOIN (select car_id, car_model, car_brand from cars) as crs ON ord.order_car_id = crs.car_id 
INNER JOIN (select finance_customer_amount, finance_id from finances) AS fn ON ord.order_finance_id = fn.finance_id
INNER JOIN (select CONCAT(CONCAT(customer_firstname, ' '), customer_lastname) as cname, customer_id from customers ) as cs ON cs.customer_id = ord.order_customer_id ;

GO 

SELECT * from ALL_ORDERS

DROP VIEW IF EXISTS ALL_APPOINTMENTS

GO

CREATE VIEW ALL_APPOINTMENTS
AS 
SELECT cname, ename, appointment_type, appointment_datetime, appointment_status FROM 
(SELECT appointment_customer_id, appointment_employee_id, appointment_type, appointment_datetime, appointment_status from appointments) as app
INNER JOIN (select CONCAT(CONCAT(customer_firstname, ' '), customer_lastname) as cname, customer_id from customers) as cs 
ON cs.customer_id = app.appointment_customer_id
INNER JOIN (select CONCAT(CONCAT(employee_firstname, ' '), employee_lastname) as ename, employee_id from employees) as es 
ON es.employee_id = app.appointment_employee_id

GO 

SELECT * FROM ALL_APPOINTMENTS;


DROP VIEW IF EXISTS ALL_MAINTENANCE_REQ

GO

CREATE VIEW ALL_MAINTENANCE_REQ
AS 
SELECT cname, ename, m_request_type, m_request_timestamp, m_request_status, m_request_total_amount FROM 
(SELECT m_customer_id, m_employee_id, m_request_type, m_request_timestamp, m_request_status, m_request_total_amount from maintenance_requests) as m
INNER JOIN (select CONCAT(CONCAT(customer_firstname, ' '), customer_lastname) as cname, customer_id from customers) as cs 
ON cs.customer_id = m.m_customer_id
INNER JOIN (select CONCAT(CONCAT(employee_firstname, ' '), employee_lastname) as ename, employee_id from employees) as es 
ON es.employee_id = m.m_employee_id

GO 

SELECT * FROM ALL_MAINTENANCE_REQ;


DROP VIEW IF EXISTS ALL_RENTAL_REQ

GO

CREATE VIEW ALL_RENTAL_REQ
AS 
SELECT cname, car_model, car_brand, request_start_datetime, request_end_datetime, request_pickup_address, request_drop_address, request_status,
request_total_miles, 
case when request_fuel_included=1 then 'Yes' else 'No' end as fuel_included,
request_total_miles_spent, request_total_amount, request_initial_amount FROM 
(SELECT request_customer_id, request_car_id, request_start_datetime, request_end_datetime, request_pickup_address, request_drop_address, request_status,
request_total_miles, request_fuel_included, request_total_miles_spent, request_total_amount, request_initial_amount  from car_rental_requests) as r
INNER JOIN (select CONCAT(CONCAT(customer_firstname, ' '), customer_lastname) as cname, customer_id from customers) as cs 
ON cs.customer_id = r.request_customer_id
INNER JOIN (select car_id, car_model, car_brand from cars) as crs ON r.request_car_id = crs.car_id 

GO 

SELECT * FROM ALL_RENTAL_REQ;


SELECT * FROM ALL_MAINTENANCE_REQ;


DROP VIEW IF EXISTS ALL_INVENTORIES
GO

CREATE VIEW ALL_INVENTORIES
AS 
SELECT inventory_name, inventory_location, car_model, inventory_car_quantity FROM 
(SELECT inventory_id, inventory_name, inventory_location, inventory_car_id, inventory_car_quantity from inventories) as r
INNER JOIN (select car_id, car_model, car_brand from cars) as crs ON r.inventory_car_id = crs.car_id 

GO 

SELECT * FROM ALL_INVENTORIES;

DROP VIEW IF EXISTS TOTAL_SALES

GO

CREATE VIEW TOTAL_SALES
AS
SELECT (sum(orders.order_total) + sum(maintenance_requests.m_request_total_amount) + sum(car_rental_requests.request_total_amount) ) as total
from orders, maintenance_requests, car_rental_requests

GO

SELECT * FROM TOTAL_SALES



DROP VIEW IF EXISTS TOTAL_SALES_CAR

GO

CREATE VIEW TOTAL_SALES_CAR
AS
SELECT sum(order_total) as total, car_model as total_car_sales
from ALL_ORDERS group by car_model

GO

SELECT * FROM TOTAL_SALES_CAR

DROP VIEW IF EXISTS TOTAL_CUSTOMERS

GO

CREATE VIEW TOTAL_CUSTOMERS
AS
SELECT count(*) as total_cust
from customers

GO

SELECT * FROM TOTAL_CUSTOMERS



-- slides
-- logical


create table car_price_per_mile_lookup (
    cppml_car_id int not null,
    cppml_price_per_mile int not null,
    constraint ck_cppml_price_per_mile check (cppml_price_per_mile > 0)
)

alter table car_price_per_mile_lookup add constraint 
    fk_cppml_car_id foreign key (cppml_car_id)
        references cars (car_id)
        
GO

alter table car_price_per_mile_lookup 
    drop constraint if exists fk_cppml_car_id


drop table if exists maintenance_type_lookup

create table maintenance_type_lookup (
    m_request_type VARCHAR(50) not null,
    m_request_amount money not null
)

drop table if exists insurance_type_lookup

create table insurance_type_lookup (
    i_type VARCHAR(20) not null,
    i_amount money not null
)

insert into insurance_type_lookup values ('Full Accidental', 2000)
insert into insurance_type_lookup values ('Liability', 200)
insert into insurance_type_lookup values ('Theft & Accidental', 3000)


select * from orders