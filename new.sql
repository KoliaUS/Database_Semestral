-- Create table for roles
CREATE TABLE Role (
    Role_ID INT PRIMARY KEY AUTO_INCREMENT,
    Role_Name VARCHAR(50) NOT NULL
);

-- Create table for person
CREATE TABLE Person (
    Person_ID INT PRIMARY KEY AUTO_INCREMENT,
    Doctor_ID INT,
    Role_ID INT,
    FOREIGN KEY (Doctor_ID) REFERENCES Person(Person_ID),
    FOREIGN KEY (Role_ID) REFERENCES Role(Role_ID)
);

-- Create table for contact information
CREATE TABLE Contact (
    Contact_ID INT PRIMARY KEY AUTO_INCREMENT,
    Person_ID INT,
    First_Name VARCHAR(50) NOT NULL,
    Last_Name VARCHAR(50) NOT NULL,
    Date_of_Birth DATE,
    Email VARCHAR(100),
    Phone VARCHAR(15),
    Insurance VARCHAR(50),
    Diabetes_Type VARCHAR(50),
    Address VARCHAR(255),
    City VARCHAR(100),
    State VARCHAR(100),
    Zip_Code VARCHAR(10),
    FOREIGN KEY (Person_ID) REFERENCES Person(Person_ID)
);

-- Create table for activity logs
CREATE TABLE ActivityLogs (
    Log_ID INT PRIMARY KEY AUTO_INCREMENT,
    Person_ID INT,
    Date_and_Time DATETIME NOT NULL,
    Action VARCHAR(255) NOT NULL,
    FOREIGN KEY (Person_ID) REFERENCES Person(Person_ID)
);

-- Create table for relatives
CREATE TABLE Relatives (
    Relative_ID INT PRIMARY KEY AUTO_INCREMENT,
    Patient_ID INT,
    Related_Person_ID INT,
    Relationship VARCHAR(50),
    Permissions VARCHAR(50),
    FOREIGN KEY (Patient_ID) REFERENCES Person(Person_ID),
    FOREIGN KEY (Related_Person_ID) REFERENCES Person(Person_ID)
);

-- Create table for glucose measurements
CREATE TABLE GlucoseMeasurements (
    Measurement_ID INT PRIMARY KEY AUTO_INCREMENT,
    Patient_ID INT,
    Date_and_Time DATETIME NOT NULL,
    Glucose_Value FLOAT,
    Measurement_Type VARCHAR(50),
    Note TEXT,
    FOREIGN KEY (Patient_ID) REFERENCES Person(Person_ID)
);

-- Create table for devices
CREATE TABLE Devices (
    Device_ID INT PRIMARY KEY AUTO_INCREMENT,
    Patient_ID INT,
    Device_Type VARCHAR(50),
    Model VARCHAR(50),
    Date_Added DATETIME,
    FOREIGN KEY (Patient_ID) REFERENCES Person(Person_ID)
);
