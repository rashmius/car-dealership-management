use ist659hjpatil;

INSERT INTO CARS values ('Model 3', 'Tesla', 'Sedan', 'ivmqoure547kv9n', 0, 'Electric', 500, 'RED', 17, 'AUTOMATIC', 35000);
INSERT INTO CARS values ('Model S', 'Tesla', 'SUV', 'dmh5kky2vgyha2x', 0, 'Electric', 350, 'GREY', 19, 'AUTOMATIC', 55000);
INSERT INTO CARS values ('Urus', 'Lamborghini', 'Sports', 'skupfnq2asmj6bm', 0, 'Gas', 200, 'YELLOW', 15, 'AUTOMATIC', 225000);
INSERT INTO CARS values ('Camry', 'Toyota', 'Sedan', 'xy140rzif0z5yvd', 0, 'Gas', 800, 'BLACK', 16, 'AUTOMATIC', 30000);

-- check ph no constraint
INSERT INTO EMPLOYEES values ('Rashmi', 'Umashivaprakash', 'CEO', '551344013', 'rashmi@cars.com','517, Broad St.', 'Male', 'Leadership', 100000);
INSERT INTO EMPLOYEES values ('Lily', 'Thompson', 'Salesperson', '552233212', 'lily@cars.com','518, Westcott St.', 'Female', 'Sales', 50000);
INSERT INTO EMPLOYEES values ('Daniel', 'Martin', 'Salesperson', '784233222', 'daniel@cars.com','102 Peru St.', 'Male', 'Sales', 45000);
INSERT INTO EMPLOYEES values ('Emma', 'Johnson', 'Maintenance Person', '23985275', 'emma@cars.com','102 Asca St.', 'Female', 'Maintenance', 10000);
INSERT INTO EMPLOYEES values ('Olivia', 'Smith', 'Accountant', '551344601', 'olivia@cars.com','12, Broad St.', 'Female', 'Accounts', 45000);

-- check ph no constraint
INSERT INTO CUSTOMERS values ('Emma', 'Martin', '2000-01-15', 'emma@gmail.com', 'emma@123', 'Female', '1223 Appe St.', 654, '502012022');

-- allow nulls for ids
INSERT INTO INVENTORIES values ('A','DALLAS', 1, 10,null,0);

INSERT INTO FINANCE_OPTIONS values ('12 Months', 'Chase', 10,700);
INSERT INTO FINANCE_OPTIONS values ('6 Months', 'BOA', 8,720);
INSERT INTO FINANCE_OPTIONS values ('3 Months', 'Chase', 9,700);

-- remove serial number
INSERT INTO CAR_ACCESSORIES values ('Compact Vaccum Cleaner', 'Cleaning', 150, 'ALL', '1 year');
INSERT INTO CAR_ACCESSORIES values ('Rhinestone Steering Wheel Cover', 'Steering Wheel', 50, 'Tesla', '6 month');
INSERT INTO CAR_ACCESSORIES values ('Highway Kid Car Seat Protector', 'Seat Protector', 100, 'Toyota', '1 year');

INSERT INTO APPOINTMENTS values (2,4,'Test Drive','2022-12-01 12:00:00','PENDING');
INSERT INTO APPOINTMENTS values (2,6,'Car Sale','2022-12-02 13:30:00','PENDING');
INSERT INTO APPOINTMENTS values (2,6,'Test Drive','2022-12-09 12:00:00','PENDING');
INSERT INTO APPOINTMENTS values (2,7,'Other','2022-12-04 12:10:00','IN-PROGRESS');

INSERT INTO MAINTENANCE_REQUESTS VALUES (2, 'FILTER CHANGE','2022-12-08 18:00:00', 'PENDING', 4,100)
INSERT INTO MAINTENANCE_REQUESTS VALUES (2, 'BRAKE PAD CHANGE','2022-12-07 14:00:00', 'COMPLETED', 4,50)
INSERT INTO MAINTENANCE_REQUESTS VALUES (2, 'OIL CHANGE','2022-12-12 18:00:00', 'PENDING', 4,10)

insert into car_rental_requests values (1,1, '2022-12-09 20:00:00', '2022-12-10 12:00:00', '517 Broad St.', 'Syracuse International Airport', 'ORDERED',100,0,0,0,150);
insert into car_rental_requests values (1,1, '2022-12-12 20:00:00', '2022-12-13 12:00:00', 'Syracuse International Airport', 'Syracuse International Airport', 'ORDERED',200,0,0,0,300);
insert into car_rental_requests values (1,2, '2022-12-09 23:00:00', '2022-12-10 12:00:00', 'Syracuse University Bus Stop', 'Syracuse International Airport', 'IN-PROGRESS',100,1,0,0,150);


insert into car_price_per_mile_lookup values (1, 10);
insert into car_price_per_mile_lookup values (2, 10);
insert into car_price_per_mile_lookup values (, 10);
insert into car_price_per_mile_lookup values (1, 10);
insert into car_price_per_mile_lookup values (1, 10);

insert into inventories values('A1', 'DALLAS', 1,10,null,null)

insert into maintenance_type_lookup values ('Brake Pad Change', 50);
insert into maintenance_type_lookup values ('Oil Change', 10);
insert into maintenance_type_lookup values ('Full Cleaning', 100);
insert into maintenance_type_lookup values ('Alignment Fix', 50);

-- insurance lookup
-- form customer screens
-- SQL scripts insert and triggers




-- ER Requirements
-- Conceptual Model
-- Employee side screens
-- order place screen





select * from cars;
select * from employees;
select * from customers;
select * from inventories;
select * from finance_options;
select * from car_accessories;
select * from appointments;
select * from car_rental_requests;
select * from maintenance_requests;
select * from insurances;
select * from finances;
select * from orders;
select * from car_price_per_mile_lookup