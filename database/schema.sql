-- OneShotBid – Apache Derby schema (reconstructed from the SQL the application runs).
-- Run against the network server database "auction_db" (user/password: app/app by default):
--   ij> connect 'jdbc:derby://localhost:1527/auction_db;create=true;user=app;password=app';
--   ij> run 'database/schema.sql';
-- Column names/types are inferred from the code, so compare with your existing database before using it on real data.

CREATE TABLE Users (
    User_ID        INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    User_Frame     VARCHAR(100) NOT NULL,   -- first name (spelling kept: the code uses it)
    User_Lname     VARCHAR(100) NOT NULL,
    Username       VARCHAR(50)  NOT NULL UNIQUE,
    User_Email     VARCHAR(150) NOT NULL,
    Password       VARCHAR(255) NOT NULL,
    User_Nphone    VARCHAR(30),
    User_address   VARCHAR(255),
    User_Street    VARCHAR(150),
    User_City      VARCHAR(100),
    User_State     VARCHAR(100),
    User_Postcode  VARCHAR(20),
    Is_Admin       BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE Products (
    Product_ID      INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Product_Name    VARCHAR(200) NOT NULL,
    Product_Decs    VARCHAR(2000),          -- description
    Edition_Count   INT NOT NULL DEFAULT 1,
    Image_URL       VARCHAR(255),
    Start_Bid_Price DECIMAL(12,2) NOT NULL,
    Seller_ID       INT REFERENCES Users(User_ID)
);

CREATE TABLE Auctions (
    Auction_ID  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Product_ID  INT NOT NULL REFERENCES Products(Product_ID),
    Start_Time  TIMESTAMP NOT NULL,
    End_Time    TIMESTAMP NOT NULL,
    Status      VARCHAR(20) NOT NULL DEFAULT 'pending'   -- pending | active | ended
);

CREATE TABLE Bids (
    Bid_ID      INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Auction_ID  INT NOT NULL REFERENCES Auctions(Auction_ID),
    User_ID     INT NOT NULL REFERENCES Users(User_ID),
    Bid_Amount  DECIMAL(12,2) NOT NULL,
    Bid_Time    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Notifications (
    Notification_ID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    User_ID   INT NOT NULL REFERENCES Users(User_ID),
    Message   VARCHAR(500) NOT NULL,
    Sent_At   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Is_Read   BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE Payments (
    Payment_ID     INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    User_ID        INT NOT NULL REFERENCES Users(User_ID),
    Auction_ID     INT NOT NULL REFERENCES Auctions(Auction_ID),
    Amount_Paid    DOUBLE NOT NULL,
    Payment_status VARCHAR(20) NOT NULL DEFAULT 'pending',  -- pending | completed
    Payment_date   TIMESTAMP
);

CREATE TABLE Payment_Methods (
    Payment_ID  INT NOT NULL REFERENCES Payments(Payment_ID),
    Method_Type VARCHAR(50) NOT NULL
);

CREATE INDEX idx_bids_auction ON Bids(Auction_ID);
CREATE INDEX idx_auctions_status_end ON Auctions(Status, End_Time);

-- Optional first admin (change the password!). Passwords are stored as plain text by the current code.
-- INSERT INTO Users (User_Frame, User_Lname, Username, User_Email, Password, Is_Admin)
--   VALUES ('Admin', 'User', 'admin', 'admin@example.com', 'change-me', TRUE);
