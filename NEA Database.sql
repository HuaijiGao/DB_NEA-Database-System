/*
The following commands are for initialising and testing use.
DROP TABLE CUSTOMER CASCADE CONSTRAINTS;
DROP TABLE STAFF CASCADE CONSTRAINTS;
DROP TABLE LOCATION CASCADE CONSTRAINTS;
DROP TABLE MODEL CASCADE CONSTRAINTS;
DROP TABLE AIRCRAFT CASCADE CONSTRAINTS;
DROP TABLE SH_AIRCRAFT CASCADE CONSTRAINTS;
DROP TABLE LH_AIRCRAFT CASCADE CONSTRAINTS;
DROP TABLE ROUTE CASCADE CONSTRAINTS;
DROP TABLE FLIGHT CASCADE CONSTRAINTS;
DROP TABLE IRREGULAR_EVENT CASCADE CONSTRAINTS;
DROP TABLE PILOT CASCADE CONSTRAINTS;
DROP TABLE PILOT_QUAL CASCADE CONSTRAINTS;
DROP TABLE FLIGHT_ATTENDANT CASCADE CONSTRAINTS;
DROP TABLE ADDITIONAL_PILOT CASCADE CONSTRAINTS;
DROP TABLE HOSTS CASCADE CONSTRAINTS;
DROP TABLE TICKET CASCADE CONSTRAINTS;
*/

/* 
=================
 Assumption list
=================

Length Constraints:
+ customerID is 10 digits alphanumeric
+ staffID is 6 digits alphanumeric
+ passport number is up to 9 digits alphanumeric
+ airportCode is 3 digits alphabetic only
+ modelID is up to 30 characters
+ aircraftID is 6 alphanumeric
+ routeID is 6 alphanumeric
+ flightID is 9 alphanumeric
+ ticketNum is 12 alphanumeric

Not Null Constraints (except for primary and foreign keys):
+ CUSTOMER(name)
+ STAFF(name, passportNum)
+ MODEL(cargoCapacity, fuelCapacity, serviceHours)
+ LH_AIRCRAFT(noOfMedPacks, noOfDefibrillators)
+ ADDITIONAL_PILOT(activityCode)
+ TICKET(seatNum, luggageLimit)

Domain Constraints:
+ FLIGHT(haulType IN('short_haul', 'long_haul')
+ TICKET(mealChoice IN('regular in-flight', 'vegan & gluten free'))
+ TICKET(classCode IN('E','B','F'))

*/

CREATE TABLE CUSTOMER (
    customerID CHAR(10) NOT NULL,
    name VARCHAR2(70),
    address VARCHAR2(200),
    country VARCHAR2(50),
    email VARCHAR2(50),
    phone VARCHAR2(20),
    passportNum VARCHAR2(9),
    DOB DATE,
    PRIMARY KEY (customerID)
);

CREATE TABLE STAFF (
    staffID CHAR(6) NOT NULL,
    name VARCHAR2(70),
    address VARCHAR2(200),
    email VARCHAR2(50),
    phone VARCHAR2(20),
    passportNum VARCHAR2(9),
    PRIMARY KEY (staffID)
);

CREATE TABLE LOCATION (
    airportCode CHAR(3) NOT NULL,
    CONSTRAINT alphaonly CHECK (regexp_like(airportCode,'^[[:alpha:]]+$')),
    country VARCHAR2(50),
    address VARCHAR2(200),
    phone VARCHAR2(20),
    PRIMARY KEY (airportCode)
);

CREATE TABLE MODEL (
    modelID VARCHAR2(30) NOT NULL,
    economySeats NUMBER(3),
    businessSeats NUMBER(3),
    firstClassSeats NUMBER(2),
    cargeCapacity NUMBER(6),
    fuelCapacity NUMBER(6),
    modelLength NUMBER(5,2),
    wingspan NUMBER(5,2),
    serviceHours NUMBER(8,2),
    PRIMARY KEY (modelID)
);

CREATE TABLE AIRCRAFT (
    aircraftID CHAR(6) NOT NULL,
    modelID VARCHAR2(30) NOT NULL,
    PRIMARY KEY (aircraftID),
    FOREIGN KEY (modelID) REFERENCES MODEL(modelID)
);

CREATE TABLE SH_AIRCRAFT (
    aircraftID CHAR(6) NOT NULL,
    mailCargoCapacity NUMBER(6),
    PRIMARY KEY (aircraftID),
    FOREIGN KEY (aircraftID) REFERENCES AIRCRAFT(aircraftID)
);

CREATE TABLE LH_AIRCRAFT (
    aircraftID CHAR(6) NOT NULL,
    noOfMedPacks NUMBER(1),
    noOfDefibrillators NUMBER(1),
    PRIMARY KEY (aircraftID),
    FOREIGN KEY (aircraftID) REFERENCES AIRCRAFT(aircraftID)
);

CREATE TABLE ROUTE (
    routeID CHAR(6) NOT NULL,
    description VARCHAR2(300),
    deptAirportCode CHAR(3) NOT NULL,
    CONSTRAINT alphaonly1 CHECK (regexp_like(deptAirportCode,'^[[:alpha:]]+$')),
    arrivAirportCode CHAR(3) NOT NULL,
    CONSTRAINT alphaonly2 CHECK (regexp_like(arrivAirportCode,'^[[:alpha:]]+$')),
    PRIMARY KEY (routeID),
    FOREIGN KEY (deptAirportCode) REFERENCES LOCATION(airportCode),
    FOREIGN KEY (arrivAirportCode) REFERENCES LOCATION(airportCode)
);

CREATE TABLE FLIGHT (
    flightID CHAR(9) NOT NULL, 
    estDeptDateTime DATE, 
    actDeptDateTime DATE, 
    actArrivDateTime DATE, 
    avgSpeed NUMBER(3,2), 
    avgHeight NUMBER(5), 
    estDuration NUMBER(4), 
    estFuel NUMBER(6), 
    haulType VARCHAR2(10) 
    CHECK(haulType IN('short_haul', 'long_haul')),
    routeID CHAR(6) NOT NULL,
    aircraftID CHAR(6) NOT NULL, 
    captainStaffID CHAR(6) NOT NULL, 
    firstOfficerStaffID CHAR(6) NOT NULL,
    PRIMARY KEY (flightID),
    FOREIGN KEY (routeID) REFERENCES ROUTE(routeID),
    FOREIGN KEY (aircraftID) REFERENCES AIRCRAFT(aircraftID),
    FOREIGN KEY (captainStaffID) REFERENCES STAFF(staffID),
    FOREIGN KEY (firstOfficerStaffID) REFERENCES STAFF(staffID)
);

CREATE TABLE IRREGULAR_EVENT (
    flightID CHAR(9) NOT NULL,
    eventNumber NUMBER(2),
    eventDateTime DATE,
    evnetDescription VARCHAR2(300),
    PRIMARY KEY (flightID),
    FOREIGN KEY (flightID) REFERENCES FLIGHT(flightID)
);

CREATE TABLE PILOT (
    staffID CHAR(6) NOT NULL,
    prevHrsPilotExp NUMBER(8,2),
    PRIMARY KEY (staffID),
    FOREIGN KEY (staffID) REFERENCES STAFF(staffID)
);

CREATE TABLE PILOT_QUAL (
    staffID CHAR(6) NOT NULL,
    qualifications VARCHAR2(100),
    PRIMARY KEY (staffID),
    FOREIGN KEY (staffID) REFERENCES STAFF(staffID)
);

CREATE TABLE FLIGHT_ATTENDANT (
    staffID CHAR(6) NOT NULL,
    PRIMARY KEY (staffID),
    FOREIGN KEY (staffID) REFERENCES STAFF(staffID)
);

CREATE TABLE ADDITIONAL_PILOT (
    flightID CHAR(9) NOT NULL,
    staffID CHAR(6) NOT NULL,
    activityCode CHAR(2) NOT NULL,
    CONSTRAINT alphaonly3 CHECK (regexp_like(activityCode,'^[[:alpha:]]+$')),
    activityDesc VARCHAR2(100),
    PRIMARY KEY (flightID, staffID),
    FOREIGN KEY (flightID) REFERENCES FLIGHT(flightID),
    FOREIGN KEY (staffID) REFERENCES STAFF(staffID)
);

CREATE TABLE HOSTS (
    flightID CHAR(9) NOT NULL,
    staffID CHAR(6) NOT NULL,
    PRIMARY KEY (flightID, staffID),
    FOREIGN KEY (flightID) REFERENCES FLIGHT(flightID),
    FOREIGN KEY (staffID) REFERENCES STAFF(staffID)
);

CREATE TABLE TICKET (
    ticketNum CHAR(12) NOT NULL,
    mealChoice VARCHAR2(22) 
    CHECK(mealChoice IN('regular in-flight', 'vegan & gluten free')),
    medicalCondition VARCHAR2(50),
    seatNum CHAR(3) NOT NULL,
    classCode CHAR(1) NOT NULL 
    CHECK(classCode IN('E','B','F')),
    luggageLimit NUMBER(2),
    flightID CHAR(9) NOT NULL,
    customerID CHAR(10) NOT NULL,
    PRIMARY KEY (ticketNum),
    FOREIGN KEY (flightID) REFERENCES FLIGHT(flightID),
    FOREIGN KEY (customerID) REFERENCES CUSTOMER(customerID)
);

/*
The following commands are to insert sample records.
*/

-- sample customer
INSERT INTO CUSTOMER
VALUES (
    'CS10002578', 
    'Oliver Jones', 
    '114 Sherborne Street, St Albans, Christchurch 8014', 
    'New Zealand', 
    'oliverjo1999@gmail.com',
    '+64 21345678',
    'LA008566',
    '01-Sep-1999'
);

-- sample staff 1: captain
INSERT INTO STAFF
VALUES (
    'P50093', 
    'Eli David Murphy', 
    '206 Point Chevalier Road, Point Chevalier, Auckland 1022, New Zealand', 
    'elidmu@airnea.nz', 
    '+64 25335556',
    'RA157800'
);

-- sample staff 2: first officer
INSERT INTO STAFF
VALUES (
    'P14747', 
    'Jeff Davis', 
    '85A Redcastle Drive, East Tamaki, Auckland 2013, New Zealand', 
    'jeffda2@airnea.nz', 
    '+64 25780328',
    'LA257802'
);

-- sample staff 3: additional pilot
INSERT INTO STAFF
VALUES (
    'I90097', 
    'Muller James', 
    '43 Carlton Gore Road, Grafton, Auckland 1023, New Zealand', 
    'mullerj@airnea.nz', 
    '+64 24135433',
    'LA498764'
);

-- sample staff 4: flight attendant
INSERT INTO STAFF
VALUES (
    'A11127', 
    'Nicole Leister', 
    '5 Second Avenue, Kingsland, Auckland 1021, New Zealand', 
    'nicolel3@airnea.nz', 
    '+64 20981273',
    'LA190874'
);

-- sample location 1
INSERT INTO LOCATION
VALUES (
    'AKL', 
    'New Zealand', 
    'Ray Emery Drive, Māngere, Auckland 2022', 
    '+64 92750789'
);

-- sample location 2
INSERT INTO LOCATION
VALUES (
    'CHC', 
    'New Zealand', 
    '30 Durey Road, Harewood, Christchurch 8053', 
    '+64 33537777'
);

-- sample model: short haul
INSERT INTO MODEL
VALUES (
    'Airbus A320',
    170,
    10,
    0,
    23000,
    23860,
    37.57,
    35.80,
    912.55
);

-- sample model: long haul
INSERT INTO MODEL
VALUES (
    'Boeing 787-9',
    131,
    70,
    39,
    228000,
    91377,
    61.37,
    51.92,
    1560.17
);

-- sample aircraft: short haul
INSERT INTO AIRCRAFT
VALUES (
    'S07680',
    'Airbus A320'
);

-- sample aircraft: long haul
INSERT INTO AIRCRAFT
VALUES (
    'L57790',
    'Boeing 787-9'
);

-- sample short haul aircraft
INSERT INTO SH_AIRCRAFT
VALUES (
    'S07680',
    6000
);

-- sample long haul aircraft
INSERT INTO LH_AIRCRAFT
VALUES (
    'L57790',
    6,
    2
);

-- sample route
INSERT INTO ROUTE
VALUES (
    'NZ1130',
    'flight from Auckland to Christchurch',
    'AKL',
    'CHC'
);

-- sample flight
INSERT INTO FLIGHT
VALUES (
    'NZ1130151',
    --to_char(to_date('18-Jan-2022 10:20:00','DD-MON-YYYY HH24:MI:SS'),'DD-MON-YYYY HH24:MI:SS'),
    to_date('18-Jan-2022 10:20:00','DD-MON-YYYY HH24:MI:SS'),
    to_date('18-Jan-2022 10:21:05', 'DD-MON-YYYY HH24:MI:SS'),
    to_date('18-Jan-2022 11:55:13', 'DD-MON-YYYY HH24:MI:SS'),
    0.78,
    39000,
    85,
    2100,
    'short_haul',
    'NZ1130',
    'S07680',
    'P50093',
    'P14747'
);

-- sample irregular event
INSERT INTO IRREGULAR_EVENT
VALUES (
    'NZ1130151',
    1,
    to_date('18-Jan-2022 11:49:00', 'DD-MON-YYYY HH24:MI:SS'),
    'Operation requiring a runway closure'
);

-- sample pilot 1
INSERT INTO PILOT
VALUES (
    'P50093',
    3111
);

-- sample pilot 2
INSERT INTO PILOT
VALUES (
    'P14747',
    1560
);

-- sample pilot qualification 1
INSERT INTO PILOT_QUAL
VALUES (
    'P50093',
    'Bachelor of Aviation'
);

-- sample pilot qualification 2
INSERT INTO PILOT_QUAL
VALUES (
    'P14747',
    'Bachelor of Science in Aviation Technology'
);

-- sample pilot qualification 3
INSERT INTO PILOT_QUAL
VALUES (
    'I90097',
    'Bachelor of Aviation'
);

-- sample flight attendant
INSERT INTO FLIGHT_ATTENDANT
VALUES (
    'A11127'
);

-- sample additional pilot
INSERT INTO ADDITIONAL_PILOT
VALUES (
    'NZ1130151',
    'I90097',
    'CI',
    'commercial intern'
);

-- sample hosts
INSERT INTO HOSTS
VALUES (
    'NZ1130151',
    'A11127'
);

-- sample ticket
INSERT INTO TICKET
VALUES (
    'D00057684897',
    'regular in-flight',
    'none',
    '18F',
    'E',
    20,
    'NZ1130151',
    'CS10002578'
);