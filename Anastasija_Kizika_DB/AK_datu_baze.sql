CREATE SCHEMA IF NOT EXISTS `nba_db`;
USE `nba_db`;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS PlayerAwards;
DROP TABLE IF EXISTS GameReferees;
DROP TABLE IF EXISTS PlayoffSerieGame;
DROP TABLE IF EXISTS Game;
DROP TABLE IF EXISTS PlayoffSerie;
DROP TABLE IF EXISTS Player;
DROP TABLE IF EXISTS Coach;
DROP TABLE IF EXISTS Referee;
DROP TABLE IF EXISTS Team;
DROP TABLE IF EXISTS Arena;
DROP TABLE IF EXISTS Person;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE Person (
    PersonID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Surname VARCHAR(100) NOT NULL,
    FullName VARCHAR(200) NOT NULL,
    DateOfBirth DATE NOT NULL,
    Gender VARCHAR(10),
    Nationality VARCHAR(50),
    YearSalary DECIMAL(10, 2) NOT NULL
) ENGINE = InnoDB;

CREATE TABLE Arena (
    ArenaID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    City VARCHAR(50) NOT NULL,
    State VARCHAR(50) NOT NULL,
    Capacity INT NOT NULL,
    OpenedYear YEAR NOT NULL, -- Using YEAR type for year
    GameValue DECIMAL(10, 2)
) ENGINE = InnoDB;

CREATE TABLE Referee (
    RefereeID INT PRIMARY KEY, -- FK to PersonID
    StartYear YEAR NOT NULL,
    CrewChiefStatus BOOLEAN NOT NULL,
    UniformNumber INT NOT NULL UNIQUE,
    IsActive BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_referee_person FOREIGN KEY (RefereeID) REFERENCES Person(PersonID)
) ENGINE = InnoDB;

CREATE TABLE Team (
    TeamID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL UNIQUE,
    City VARCHAR(50) NOT NULL,
    BalanceOfVictories DECIMAL(3, 3) NOT NULL, 
    ArenaID INT NOT NULL,
    YearOfLastWonChampionship YEAR,
    CONSTRAINT fk_team_arena FOREIGN KEY (ArenaID) REFERENCES Arena(ArenaID),
    CONSTRAINT chk_balance_of_victories CHECK (BalanceOfVictories BETWEEN 0 AND 1)
) ENGINE = InnoDB;

CREATE TABLE PlayoffSerie (
    PlayoffSerieID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Team1ID INT NOT NULL,
    Team2ID INT NOT NULL,
    PlayoffYear YEAR NOT NULL,
    RoundNumber INT NOT NULL,
    WinnerID INT,
    GameCount INT NOT NULL,
    CONSTRAINT fk_ps_team1 FOREIGN KEY (Team1ID) REFERENCES Team(TeamID),
    CONSTRAINT fk_ps_team2 FOREIGN KEY (Team2ID) REFERENCES Team(TeamID),
    CONSTRAINT fk_ps_winner FOREIGN KEY (WinnerID) REFERENCES Team(TeamID),
    CONSTRAINT chk_different_playoff_teams CHECK (Team1ID <> Team2ID) -- Constraint shown in diagram
) ENGINE = InnoDB;

CREATE TABLE Coach (
    CoachID INT PRIMARY KEY, 
    TeamID INT NOT NULL,
    Role VARCHAR(50) NOT NULL,
    StartYear YEAR NOT NULL,
    WasCoachOfTheYear BOOLEAN NOT NULL DEFAULT FALSE,
    NumberOfWonINTChampionship INT NOT NULL DEFAULT 0,
    CONSTRAINT fk_coach_person FOREIGN KEY (CoachID) REFERENCES Person(PersonID),
    CONSTRAINT fk_coach_team FOREIGN KEY (TeamID) REFERENCES Team(TeamID)
) ENGINE = InnoDB;

CREATE TABLE Player (
    PlayerID INT PRIMARY KEY, 
    TeamID INT NOT NULL,
    JerseyNumber INT NOT NULL,
    Position VARCHAR(2) NOT NULL, 
    Weight DECIMAL(5, 2) NOT NULL,
    Height DECIMAL(3, 2) NOT NULL,
    ArmSpan DECIMAL(3, 2) NOT NULL,
    VertJump DECIMAL(3, 2) NOT NULL,
    DraftYear YEAR NOT NULL,
    IsInjured BOOLEAN NOT NULL DEFAULT FALSE,
    IsTeamLead BOOLEAN NOT NULL DEFAULT FALSE,
    AllStarCount INT NOT NULL DEFAULT 0,
    CONSTRAINT fk_player_person FOREIGN KEY (PlayerID) REFERENCES Person(PersonID),
    CONSTRAINT fk_player_team FOREIGN KEY (TeamID) REFERENCES Team(TeamID)
) ENGINE = InnoDB;

CREATE TABLE PlayerAwards (
	RecordID INT PRIMARY KEY,
    PlayerID INT NOT NULL, 
    Award VARCHAR(255),
    awardYear YEAR NOT NULL,
    CONSTRAINT fk_award_player FOREIGN KEY (PlayerID) REFERENCES Player(PlayerID)
) ENGINE = InnoDB;

CREATE TABLE Game (
    GameID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    GameDate DATETIME NOT NULL,
    HomeTeamID INT NOT NULL,
    AwayTeamID INT NOT NULL,
    ArenaID INT NOT NULL,
    HomeScore INT,
    AwayScore INT,
    IsOvertime BOOLEAN DEFAULT FALSE,
    MinTicketPrice DECIMAL(10, 2) NOT NULL,
    MaxTicketPrice DECIMAL(10, 2) NOT NULL,
    IsPlayoffGame BOOLEAN NOT NULL DEFAULT FALSE,
    WinnerID INT,
    CONSTRAINT fk_game_home_team FOREIGN KEY (HomeTeamID) REFERENCES Team(TeamID),
    CONSTRAINT fk_game_away_team FOREIGN KEY (AwayTeamID) REFERENCES Team(TeamID),
    CONSTRAINT fk_game_arena FOREIGN KEY (ArenaID) REFERENCES Arena(ArenaID),
    CONSTRAINT fk_game_winner FOREIGN KEY (WinnerID) REFERENCES Team(TeamID),
    CONSTRAINT chk_different_teams CHECK (HomeTeamID <> AwayTeamID)
) ENGINE = InnoDB;

CREATE TABLE GameReferees (
    RecordID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    RefereeID INT NOT NULL,
    GameID INT NOT NULL,
    OfficialStatus VARCHAR(100),
    CONSTRAINT fk_game_referees_referee FOREIGN KEY (RefereeID) REFERENCES Referee(RefereeID),
    CONSTRAINT fk_game_referees_game FOREIGN KEY (GameID) REFERENCES Game(GameID),
    CONSTRAINT uq_referee_game UNIQUE (RefereeID, GameID)
) ENGINE = InnoDB;

CREATE TABLE PlayoffSerieGame (
    RecordID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    PlayoffSerieID INT NOT NULL,
    GameID INT NOT NULL,
    GameNr INT NOT NULL,
    CONSTRAINT fk_psg_serie FOREIGN KEY (PlayoffSerieID) REFERENCES PlayoffSerie(PlayoffSerieID),
    CONSTRAINT fk_psg_game FOREIGN KEY (GameID) REFERENCES Game(GameID),
    CONSTRAINT chk_game_number CHECK (GameNr BETWEEN 1 AND 7) 
) ENGINE = InnoDB;

-- --------------------------------INSERTS-------------------------------------------


-- Disable foreign key checks
SET FOREIGN_KEY_CHECKS = 0;
SET SQL_SAFE_UPDATES = 0;

-- Delete all records from tables in correct order to handle foreign key constraints
DELETE FROM GameReferees;
DELETE FROM PlayoffSerieGame;
DELETE FROM PlayerAwards;
DELETE FROM Player;
DELETE FROM Coach;
DELETE FROM Game;
DELETE FROM PlayoffSerie;
DELETE FROM Referee;
DELETE FROM Team;
DELETE FROM Arena;
DELETE FROM Person;

-- Enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;
SET SQL_SAFE_UPDATES = 1;

INSERT INTO Person (PersonID, Name, Surname, FullName, DateOfBirth, Gender, Nationality, YearSalary) VALUES
-- Coaches
(101, 'Steve', 'Kerr', 'Steve Kerr', '1965-09-27', 'Male', 'USA', 9500000),
(102, 'Gregg', 'Popovich', 'Gregg Popovich', '1949-01-28', 'Male', 'USA', 11500000),
(103, 'Erik', 'Spoelstra', 'Erik Spoelstra', '1970-11-01', 'Male', 'USA', 8500000),
(104, 'Tyronn', 'Lue', 'Tyronn Lue', '1977-05-03', 'Male', 'USA', 7000000),
(105, 'Michael', 'Malone', 'Michael Malone', '1971-09-15', 'Male', 'USA', 5000000),
(106, 'Jason', 'Kidd', 'Jason Kidd', '1973-03-23', 'Male', 'USA', 5500000),
(107, 'Tom', 'Thibodeau', 'Tom Thibodeau', '1958-01-17', 'Male', 'USA', 7000000),
(108, 'Monty', 'Williams', 'Monty Williams', '1971-10-08', 'Male', 'USA', 8100000),
(109, 'Rick', 'Carlisle', 'Rick Carlisle', '1959-10-27', 'Male', 'USA', 5200000),
(110, 'Nick', 'Nurse', 'Nick Nurse', '1967-07-24', 'Male', 'USA', 8000000),
(111, 'Darvin', 'Ham', 'Darvin Ham', '1973-07-23', 'Male', 'USA', 2000000),
(112, 'Willie', 'Green', 'Willie Green', '1981-07-28', 'Male', 'USA', 3000000),
(113, 'Mark', 'Daigneault', 'Mark Daigneault', '1985-11-20', 'Male', 'USA', 2500000),
(114, 'Joe', 'Mazzulla', 'Joe Mazzulla', '1988-06-30', 'Male', 'USA', 4000000),
(115, 'Taylor', 'Jenkins', 'Taylor Jenkins', '1984-06-21', 'Male', 'USA', 3500000),
(116, 'Will', 'Hardy', 'Will Hardy', '1988-01-21', 'Male', 'USA', 4000000),                 
(117, 'Brian', 'Keefe', 'Brian Keefe', '1976-09-15', 'Male', 'USA', 3500000),              
(118, 'Chauncey', 'Billups', 'Chauncey Billups', '1976-09-25', 'Male', 'USA', 2000000),   
(119, 'Chris', 'Finch', 'Chris Finch', '1969-11-06', 'Male', 'USA', 4500000),            
(120, 'Doc', 'Rivers', 'Doc Rivers', '1961-10-13', 'Male', 'USA', 10000000),              
(121, 'J.B.', 'Bickerstaff', 'J.B. Bickerstaff', '1979-03-10', 'Male', 'USA', 2500000),    
(122, 'Billy', 'Donovan', 'Billy Donovan', '1965-05-30', 'Male', 'USA', 6000000),          
(123, 'Quin', 'Snyder', 'Quin Snyder', '1966-10-30', 'Male', 'USA', 8000000),
(124, 'Alex', 'Jensen', 'Alex Jensen', '1976-05-16', 'Male', 'USA', 1200000),       
(125, 'David', 'Adkins', 'David Adkins', '1978-11-03', 'Male', 'USA', 900000),     
(126, 'Scott', 'Brooks', 'Scott Brooks', '1965-07-31', 'Male', 'USA', 1500000), 
(127, 'Elston', 'Turner', 'Elston Turner', '1959-06-10', 'Male', 'USA', 1100000), 
(128, 'Patrick', 'Mutombo', 'Patrick Mutombo', '1980-03-01', 'Male', 'DR Congo', 950000),
(129, 'Greg', 'Buckner', 'Greg Buckner', '1976-09-16', 'Male', 'USA', 1000000),    
(130, 'Maurice', 'Cheeks', 'Maurice Cheeks', '1956-09-08', 'Male', 'USA', 1600000),
(131, 'Igor', 'Kokoskov', 'Igor Kokoskov', '1971-12-17', 'Male', 'Serbia', 1300000),

-- Referees
(201, 'Scott', 'Foster', 'Scott Foster', '1967-04-08', 'Male', 'USA', 550000),
(202, 'Tony', 'Brothers', 'Tony Brothers', '1964-09-07', 'Male', 'USA', 500000),
(203, 'James', 'Capers', 'James Capers', '1965-02-03', 'Male', 'USA', 480000),
(204, 'Kane', 'Fitzgerald', 'Kane Fitzgerald', '1978-11-15', 'Male', 'USA', 420000),
(205, 'Marc', 'Davis', 'Marc Davis', '1967-06-06', 'Male', 'USA', 520000),
(206, 'David', 'Guthrie', 'David Guthrie', '1974-09-22', 'Male', 'USA', 450000),
(207, 'John', 'Goble', 'John Goble', '1972-03-14', 'Male', 'USA', 460000),
(208, 'Bill', 'Kennedy', 'Bill Kennedy', '1966-06-11', 'Male', 'USA', 490000),
(209, 'Courtney', 'Kirkland', 'Courtney Kirkland', '1973-05-31', 'Male', 'USA', 440000),
(210, 'Kevin', 'Cutler', 'Kevin Cutler', '1975-08-19', 'Male', 'USA', 430000),
(211, 'Ed', 'Malloy', 'Ed Malloy', '1971-09-02', 'Male', 'USA', 470000),
(212, 'Rodney', 'Mott', 'Rodney Mott', '1969-04-01', 'Male', 'USA', 410000),
(213, 'Tre', 'Maddox', 'Tre Maddox', '1976-12-08', 'Male', 'USA', 390000),
(214, 'Ben', 'Taylor', 'Ben Taylor', '1980-03-25', 'Male', 'USA', 380000),
(215, 'Josh', 'Tiven', 'Josh Tiven', '1979-07-29', 'Male', 'USA', 400000);

INSERT INTO Arena (ArenaID, Name, City, State, Capacity, OpenedYear, GameValue) VALUES
(1, 'Chase Center', 'San Francisco', 'California', 18064, 2019, 2500000),
(2, 'Staples Center', 'Los Angeles', 'California', 19060, 1999, 2800000),
(3, 'Madison Square Garden', 'New York', 'New York', 19812, 1968, 3200000),
(4, 'TD Garden', 'Boston', 'Massachusetts', 18624, 1995, 2200000),
(5, 'American Airlines Center', 'Dallas', 'Texas', 19200, 2001, 1800000),
(6, 'Fiserv Forum', 'Milwaukee', 'Wisconsin', 17500, 2018, 1600000),
(7, 'Ball Arena', 'Denver', 'Colorado', 19520, 1999, 1500000),
(8, 'FTX Arena', 'Miami', 'Florida', 19600, 1999, 1900000),
(9, 'United Center', 'Chicago', 'Illinois', 20917, 1994, 2100000),
(10, 'Wells Fargo Center', 'Philadelphia', 'Pennsylvania', 20478, 1996, 1700000),
(11, 'Rocket Mortgage FieldHouse', 'Cleveland', 'Ohio', 19432, 1994, 1400000),
(12, 'State Farm Arena', 'Atlanta', 'Georgia', 16600, 1999, 1300000),
(13, 'Footprint Center', 'Phoenix', 'Arizona', 17071, 1992, 1600000),
(14, 'Moda Center', 'Portland', 'Oregon', 19441, 1995, 1450000),
(15, 'Vivint Arena', 'Salt Lake City', 'Utah', 18306, 1991, 1200000),
(16, 'FedExForum', 'Memphis', 'Tennessee', 18119, 2004, 1100000),
(17, 'Gainbridge Fieldhouse', 'Indianapolis', 'Indiana', 17923, 1999, 1250000),
(18, 'Capital One Arena', 'Washington', 'District of Columbia', 20356, 1997, 1550000),
(19, 'Smoothie King Center', 'New Orleans', 'Louisiana', 16867, 1999, 1350000),
(20, 'Target Center', 'Minneapolis', 'Minnesota', 18978, 1990, 1280000);

INSERT INTO Team (TeamID, Name, City, BalanceOfVictories, ArenaID, YearOfLastWonChampionship) VALUES
(1, 'Golden State Warriors', 'San Francisco', 0.650, 1, 2022),
(2, 'Los Angeles Lakers', 'Los Angeles', 0.580, 2, 2020),
(3, 'New York Knicks', 'New York', 0.520, 3, 1973),
(4, 'Boston Celtics', 'Boston', 0.680, 4, 2008),
(5, 'Dallas Mavericks', 'Dallas', 0.550, 5, 2011),
(6, 'Milwaukee Bucks', 'Milwaukee', 0.620, 6, 2021),
(7, 'Denver Nuggets', 'Denver', 0.590, 7, 2023),
(8, 'Miami Heat', 'Miami', 0.540, 8, 2013),
(9, 'Chicago Bulls', 'Chicago', 0.480, 9, 1998),
(10, 'Philadelphia 76ers', 'Philadelphia', 0.570, 10, 1983),
(11, 'Cleveland Cavaliers', 'Cleveland', 0.510, 11, 2016),
(12, 'Atlanta Hawks', 'Atlanta', 0.450, 12, 1958),
(13, 'Phoenix Suns', 'Phoenix', 0.560, 13, NULL),
(14, 'Portland Trail Blazers', 'Portland', 0.420, 14, 1977),
(15, 'Utah Jazz', 'Salt Lake City', 0.530, 15, NULL),
(16, 'Memphis Grizzlies', 'Memphis', 0.580, 16, NULL),
(17, 'Indiana Pacers', 'Indianapolis', 0.470, 17, 1973),
(18, 'Washington Wizards', 'Washington', 0.390, 18, 1978),
(19, 'New Orleans Pelicans', 'New Orleans', 0.490, 19, NULL),
(20, 'Minnesota Timberwolves', 'Minneapolis', 0.510, 20, NULL);

INSERT INTO Referee (RefereeID, StartYear, CrewChiefStatus, UniformNumber, IsActive) VALUES
(201, 1994, TRUE, 48, TRUE),
(202, 1995, TRUE, 25, TRUE),
(203, 1997, TRUE, 19, TRUE),
(204, 2009, FALSE, 5, TRUE),
(205, 1998, TRUE, 8, TRUE),
(206, 2003, FALSE, 16, TRUE),
(207, 2008, FALSE, 30, TRUE),
(208, 1999, TRUE, 55, TRUE),
(209, 2000, FALSE, 61, TRUE),
(210, 2005, FALSE, 34, TRUE),
(211, 2001, FALSE, 14, TRUE),
(212, 2002, FALSE, 71, TRUE),
(213, 2010, FALSE, 23, TRUE),
(214, 2012, FALSE, 46, TRUE),
(215, 2007, FALSE, 58, TRUE);

INSERT INTO Coach (CoachID, TeamID, Role, StartYear, WasCoachOfTheYear, NumberOfWonINTChampionship) VALUES
(101, 1, 'Head Coach', 2014, TRUE, 4),
(102, 2, 'Head Coach', 1996, TRUE, 5),
(103, 8, 'Head Coach', 2008, FALSE, 2),
(104, 2, 'Head Coach', 2020, FALSE, 1),
(105, 7, 'Head Coach', 2015, FALSE, 1),
(106, 5, 'Head Coach', 2021, FALSE, 0),
(107, 3, 'Head Coach', 2020, TRUE, 0),
(108, 13, 'Head Coach', 2019, TRUE, 0),
(109, 17, 'Head Coach', 2021, FALSE, 1),
(110, 10, 'Head Coach', 2020, TRUE, 1),
(111, 2, 'Head Coach', 2022, FALSE, 0),
(112, 19, 'Head Coach', 2021, FALSE, 0),
(113, 16, 'Head Coach', 2020, FALSE, 0),
(114, 4, 'Head Coach', 2022, FALSE, 0),
(115, 16, 'Head Coach', 2019, FALSE, 0),
(116, 15, 'Head Coach', 2022, FALSE, 0),
(117, 18, 'Head Coach', 2024, FALSE, 0),  
(118, 14, 'Head Coach', 2021, FALSE, 0),   
(119, 20, 'Head Coach', 2021, FALSE, 0),  
(120, 6, 'Head Coach', 2024, TRUE, 1),    
(121, 11, 'Head Coach', 2019, FALSE, 0),   
(122, 9, 'Head Coach', 2020, TRUE, 0),    
(123, 12, 'Head Coach', 2023, FALSE, 0),
(124, 15, 'Assistant Coach', 2014, FALSE, 0),   
(125, 18, 'Assistant Coach', 2019, FALSE, 0),  
(126, 14, 'Assistant Coach', 2021, FALSE, 0), 
(127, 20, 'Assistant Coach', 2021, FALSE, 0), 
(128, 6, 'Assistant Coach', 2023, FALSE, 0),  
(129, 11, 'Assistant Coach', 2020, FALSE, 0),   
(130, 9, 'Assistant Coach', 2020, FALSE, 0),  
(131, 12, 'Assistant Coach', 2023, FALSE, 0);

INSERT INTO Game (GameID, GameDate, HomeTeamID, AwayTeamID, ArenaID, HomeScore, AwayScore, IsOvertime, MinTicketPrice, MaxTicketPrice, IsPlayoffGame, WinnerID) VALUES
-- Regular season games
(1, '2023-10-24 19:30:00', 1, 2, 1, 115, 108, FALSE, 89.00, 450.00, FALSE, 1),
(2, '2023-10-25 19:00:00', 4, 3, 4, 112, 105, FALSE, 75.00, 380.00, FALSE, 4),
(3, '2023-10-26 20:00:00', 6, 7, 6, 108, 102, FALSE, 65.00, 320.00, FALSE, 6),
(4, '2023-10-27 19:30:00', 8, 10, 8, 98, 101, TRUE, 70.00, 350.00, FALSE, 10),
(5, '2023-10-28 20:00:00', 13, 5, 13, 120, 118, FALSE, 60.00, 300.00, FALSE, 13),
(6, '2023-10-29 18:00:00', 11, 12, 11, 95, 92, FALSE, 55.00, 280.00, FALSE, 11),
(7, '2023-10-30 19:30:00', 15, 16, 15, 105, 99, FALSE, 50.00, 250.00, FALSE, 15),
(8, '2023-10-31 20:00:00', 17, 18, 17, 110, 107, TRUE, 45.00, 220.00, FALSE, 17),
(9, '2023-11-01 19:00:00', 19, 20, 19, 102, 98, FALSE, 40.00, 200.00, FALSE, 19),
(10, '2023-11-02 19:30:00', 2, 4, 2, 116, 114, FALSE, 120.00, 600.00, FALSE, 2),
(11, '2023-11-03 20:00:00', 3, 1, 3, 108, 112, FALSE, 95.00, 480.00, FALSE, 1),
(12, '2023-11-04 19:00:00', 5, 6, 5, 119, 121, TRUE, 70.00, 350.00, FALSE, 6),
(13, '2023-11-05 18:00:00', 7, 8, 7, 105, 103, FALSE, 65.00, 330.00, FALSE, 7),
(14, '2023-11-06 19:30:00', 9, 10, 9, 97, 102, FALSE, 60.00, 310.00, FALSE, 10),
(15, '2023-11-07 20:00:00', 12, 13, 12, 88, 95, FALSE, 55.00, 290.00, FALSE, 13),
(16, '2023-11-08 19:00:00', 14, 15, 14, 101, 99, FALSE, 50.00, 270.00, FALSE, 14),
(17, '2023-11-09 19:30:00', 16, 17, 16, 112, 108, FALSE, 48.00, 260.00, FALSE, 16),
(18, '2023-11-10 20:00:00', 18, 19, 18, 94, 96, FALSE, 42.00, 240.00, FALSE, 19),
(19, '2023-11-11 19:00:00', 20, 11, 20, 103, 101, TRUE, 46.00, 250.00, FALSE, 20),
(20, '2023-11-12 18:00:00', 1, 4, 1, 118, 115, FALSE, 85.00, 430.00, FALSE, 1),
(100, '2023-10-25 19:00:00', 1, 2, 1, 118, 112, FALSE, 85.00, 430.00, FALSE, 1),
(101, '2023-10-26 19:30:00', 3, 4, 3, 104, 110, FALSE, 70.00, 360.00, FALSE, 4),
(102, '2023-10-27 19:00:00', 5, 6, 5, 119, 121, FALSE, 72.00, 335.00, FALSE, 6),
(103, '2023-10-27 20:00:00', 7, 8, 7, 125, 120, FALSE, 74.00, 355.00, FALSE, 7),
(104, '2023-10-28 19:00:00', 9, 10, 9, 101, 111, FALSE, 60.00, 290.00, FALSE, 10),
(105, '2023-10-28 19:30:00', 11, 12, 11, 108, 104, FALSE, 63.00, 300.00, FALSE, 11),
(106, '2023-10-29 19:00:00', 13, 14, 13, 120, 115, FALSE, 66.00, 320.00, FALSE, 13),
(107, '2023-10-29 20:00:00', 15, 16, 15, 109, 107, FALSE, 59.00, 280.00, FALSE, 15),
(108, '2023-10-30 19:00:00', 17, 18, 17, 102, 97, FALSE, 55.00, 265.00, FALSE, 17),
(109, '2023-10-30 20:00:00', 19, 20, 19, 113, 116, FALSE, 57.00, 270.00, FALSE, 20),

(110, '2023-11-01 19:00:00', 2, 1, 2, 105, 111, FALSE, 78.00, 370.00, FALSE, 1),
(111, '2023-11-01 19:30:00', 4, 3, 4, 116, 113, FALSE, 80.00, 380.00, FALSE, 4),
(112, '2023-11-02 19:00:00', 6, 5, 6, 118, 109, FALSE, 69.00, 348.00, FALSE, 6),
(113, '2023-11-02 20:00:00', 8, 7, 8, 99, 101, FALSE, 65.00, 330.00, FALSE, 7),
(114, '2023-11-03 19:00:00', 10, 9, 10, 115, 104, FALSE, 62.00, 305.00, FALSE, 10),
(115, '2023-11-03 20:00:00', 12, 11, 12, 108, 111, FALSE, 63.00, 310.00, FALSE, 11),
(116, '2023-11-04 19:30:00', 14, 13, 14, 112, 114, FALSE, 55.00, 275.00, FALSE, 13),
(117, '2023-11-04 20:00:00', 16, 15, 16, 120, 118, FALSE, 61.00, 295.00, FALSE, 16),
(118, '2023-11-05 19:00:00', 18, 17, 18, 101, 99, FALSE, 52.00, 240.00, FALSE, 18),
(119, '2023-11-05 20:00:00', 20, 19, 20, 110, 108, FALSE, 56.00, 265.00, FALSE, 20),

(120, '2023-11-06 19:00:00', 1, 3, 1, 124, 118, FALSE, 90.00, 440.00, FALSE, 1),
(121, '2023-11-06 19:30:00', 2, 4, 2, 112, 107, FALSE, 75.00, 350.00, FALSE, 2),
(122, '2023-11-07 19:00:00', 5, 7, 5, 116, 118, FALSE, 68.00, 330.00, FALSE, 7),
(123, '2023-11-07 20:00:00', 6, 8, 6, 111, 109, FALSE, 66.00, 315.00, FALSE, 6),
(124, '2023-11-08 19:00:00', 9, 11, 9, 104, 112, FALSE, 60.00, 290.00, FALSE, 11),
(125, '2023-11-08 19:30:00', 10, 12, 10, 117, 111, FALSE, 63.00, 300.00, FALSE, 10),
(126, '2023-11-09 19:00:00', 13, 15, 13, 121, 119, FALSE, 64.00, 315.00, FALSE, 13),
(127, '2023-11-09 20:00:00', 14, 16, 14, 108, 112, FALSE, 59.00, 290.00, FALSE, 16),
(128, '2023-11-10 19:00:00', 17, 19, 17, 103, 107, FALSE, 57.00, 280.00, FALSE, 19),
(129, '2023-11-10 19:30:00', 18, 20, 18, 109, 101, FALSE, 53.00, 250.00, FALSE, 18),

(130, '2023-11-11 19:00:00', 1, 4, 1, 117, 109, FALSE, 92.00, 455.00, FALSE, 1),
(131, '2023-11-11 20:00:00', 2, 3, 2, 100, 104, FALSE, 72.00, 340.00, FALSE, 3),
(132, '2023-11-12 19:00:00', 5, 8, 5, 119, 110, FALSE, 70.00, 330.00, FALSE, 5),
(133, '2023-11-12 19:30:00', 6, 7, 6, 116, 121, FALSE, 68.00, 335.00, FALSE, 7),
(134, '2023-11-13 19:00:00', 9, 12, 9, 113, 115, FALSE, 58.00, 290.00, FALSE, 12),
(135, '2023-11-13 20:00:00', 10, 11, 10, 118, 114, FALSE, 62.00, 300.00, FALSE, 10),
(136, '2023-11-14 19:00:00', 13, 16, 13, 123, 117, FALSE, 65.00, 310.00, FALSE, 13),
(137, '2023-11-14 19:30:00', 14, 15, 14, 107, 110, FALSE, 55.00, 275.00, FALSE, 15),
(138, '2023-11-15 19:00:00', 17, 20, 17, 108, 112, FALSE, 56.00, 265.00, FALSE, 20),
(139, '2023-11-15 20:00:00', 18, 19, 18, 101, 103, FALSE, 53.00, 255.00, FALSE, 19),

(140, '2023-11-16 19:00:00', 3, 1, 3, 99, 102, FALSE, 72.00, 360.00, FALSE, 1),
(141, '2023-11-16 19:30:00', 4, 2, 4, 112, 106, FALSE, 80.00, 380.00, FALSE, 4),
(142, '2023-11-17 19:00:00', 7, 5, 7, 127, 119, FALSE, 70.00, 340.00, FALSE, 7),
(143, '2023-11-17 20:00:00', 8, 6, 8, 109, 114, FALSE, 67.00, 330.00, FALSE, 6),
(144, '2023-11-18 19:00:00', 11, 9, 11, 112, 105, FALSE, 62.00, 295.00, FALSE, 11),
(145, '2023-11-18 19:30:00', 12, 10, 12, 101, 98, FALSE, 60.00, 285.00, FALSE, 12),
(146, '2023-11-19 19:00:00', 15, 13, 15, 110, 117, FALSE, 57.00, 265.00, FALSE, 13),
(147, '2023-11-19 20:00:00', 16, 14, 16, 115, 112, FALSE, 59.00, 275.00, FALSE, 16),
(148, '2023-11-20 19:00:00', 19, 17, 19, 111, 108, FALSE, 54.00, 250.00, FALSE, 19),
(149, '2023-11-20 19:30:00', 20, 18, 20, 113, 116, FALSE, 52.00, 245.00, FALSE, 18),

(150, '2023-12-01 19:00:00', 1, 5, 1, 124, 118, FALSE, 89.00, 445.00, FALSE, 1),
(151, '2023-12-01 19:30:00', 2, 6, 2, 107, 104, FALSE, 73.00, 350.00, FALSE, 2),
(152, '2023-12-02 19:00:00', 3, 7, 3, 113, 120, FALSE, 70.00, 345.00, FALSE, 7),
(153, '2023-12-02 20:00:00', 4, 8, 4, 119, 112, FALSE, 79.00, 385.00, FALSE, 4),
(154, '2023-12-03 19:00:00', 5, 9, 5, 108, 101, FALSE, 68.00, 330.00, FALSE, 5),
(155, '2023-12-03 19:30:00', 6, 10, 6, 111, 115, FALSE, 65.00, 320.00, FALSE, 10),
(156, '2023-12-04 19:00:00', 7, 11, 7, 129, 118, FALSE, 72.00, 350.00, FALSE, 7),
(157, '2023-12-04 20:00:00', 8, 12, 8, 106, 109, FALSE, 64.00, 310.00, FALSE, 12),
(158, '2023-12-05 19:00:00', 9, 13, 9, 104, 113, FALSE, 58.00, 285.00, FALSE, 13),
(159, '2023-12-05 19:30:00', 10, 14, 10, 117, 115, FALSE, 63.00, 310.00, FALSE, 10),

(160, '2023-12-06 19:00:00', 11, 15, 11, 114, 108, FALSE, 60.00, 300.00, FALSE, 11),
(161, '2023-12-06 20:00:00', 12, 16, 12, 101, 99, FALSE, 58.00, 295.00, FALSE, 12),
(162, '2023-12-07 19:00:00', 13, 17, 13, 116, 114, FALSE, 65.00, 320.00, FALSE, 13),
(163, '2023-12-07 19:30:00', 14, 18, 14, 110, 118, FALSE, 57.00, 280.00, FALSE, 18),
(164, '2023-12-08 19:00:00', 15, 19, 15, 109, 112, FALSE, 56.00, 275.00, FALSE, 19),
(165, '2023-12-08 20:00:00', 16, 20, 16, 119, 121, FALSE, 59.00, 290.00, FALSE, 20),
(166, '2023-12-09 19:00:00', 17, 1, 17, 95, 100, FALSE, 55.00, 270.00, FALSE, 1),
(167, '2023-12-09 19:30:00', 18, 2, 18, 101, 104, FALSE, 53.00, 260.00, FALSE, 2),
(168, '2023-12-10 19:00:00', 19, 3, 19, 113, 109, FALSE, 55.00, 275.00, FALSE, 19),
(169, '2023-12-10 20:00:00', 20, 4, 20, 108, 120, FALSE, 52.00, 250.00, FALSE, 4),

(170, '2023-12-12 19:00:00', 1, 6, 1, 121, 115, FALSE, 88.00, 430.00, FALSE, 1),
(171, '2023-12-12 19:30:00', 2, 7, 2, 109, 116, FALSE, 74.00, 350.00, FALSE, 7),
(172, '2023-12-13 19:00:00', 3, 8, 3, 118, 112, FALSE, 71.00, 340.00, FALSE, 3),
(173, '2023-12-13 20:00:00', 4, 9, 4, 112, 104, FALSE, 80.00, 380.00, FALSE, 4),
(174, '2023-12-14 19:00:00', 5, 10, 5, 113, 118, FALSE, 65.00, 320.00, FALSE, 10),
(175, '2023-12-14 19:30:00', 6, 11, 6, 120, 108, FALSE, 64.00, 315.00, FALSE, 6),
(176, '2023-12-15 19:00:00', 7, 12, 7, 122, 119, FALSE, 73.00, 350.00, FALSE, 7),
(177, '2023-12-15 20:00:00', 8, 13, 8, 110, 114, FALSE, 66.00, 320.00, FALSE, 13),
(178, '2023-12-16 19:00:00', 9, 14, 9, 104, 111, FALSE, 59.00, 285.00, FALSE, 14),
(179, '2023-12-16 19:30:00', 10, 15, 10, 117, 110, FALSE, 62.00, 305.00, FALSE, 10),

(180, '2023-12-18 19:00:00', 1, 2, 1, 128, 125, TRUE, 95.00, 480.00, FALSE, 1),
(181, '2023-12-18 19:30:00', 3, 4, 3, 122, 120, TRUE, 76.00, 365.00, FALSE, 3),
(182, '2023-12-19 19:00:00', 5, 6, 5, 133, 130, TRUE, 70.00, 340.00, FALSE, 5),
(183, '2023-12-19 20:00:00', 7, 8, 7, 129, 131, TRUE, 72.00, 350.00, FALSE, 8),
(184, '2023-12-20 19:00:00', 9, 10, 9, 118, 121, TRUE, 62.00, 300.00, FALSE, 10),
(185, '2023-12-20 19:30:00', 11, 12, 11, 126, 123, TRUE, 67.00, 330.00, FALSE, 11),
(186, '2023-12-21 19:00:00', 13, 14, 13, 132, 129, TRUE, 69.00, 335.00, FALSE, 13),
(187, '2023-12-21 20:00:00', 15, 16, 15, 119, 121, TRUE, 60.00, 290.00, FALSE, 16),
(188, '2023-12-22 19:00:00', 17, 18, 17, 111, 108, TRUE, 58.00, 270.00, FALSE, 17),
(189, '2023-12-22 20:00:00', 19, 20, 19, 125, 127, TRUE, 55.00, 265.00, FALSE, 20),

(190, '2023-12-23 19:00:00', 2, 1, 2, 121, 123, TRUE, 80.00, 400.00, FALSE, 1),
(191, '2023-12-23 19:30:00', 4, 3, 4, 117, 115, TRUE, 77.00, 365.00, FALSE, 4),
(192, '2023-12-24 19:00:00', 6, 5, 6, 130, 128, TRUE, 66.00, 330.00, FALSE, 6),
(193, '2023-12-24 20:00:00', 8, 7, 8, 112, 114, TRUE, 65.00, 325.00, FALSE, 7),
(194, '2023-12-26 19:00:00', 10, 9, 10, 124, 122, TRUE, 63.00, 300.00, FALSE, 10),
(195, '2023-12-26 19:30:00', 12, 11, 12, 118, 121, TRUE, 60.00, 295.00, FALSE, 11),
(196, '2023-12-27 19:00:00', 14, 13, 14, 129, 126, TRUE, 56.00, 285.00, FALSE, 14),
(197, '2023-12-27 20:00:00', 16, 15, 16, 133, 131, TRUE, 62.00, 305.00, FALSE, 16),
(198, '2023-12-28 19:00:00', 18, 17, 18, 112, 115, TRUE, 53.00, 250.00, FALSE, 17),
(199, '2023-12-28 20:00:00', 20, 19, 20, 111, 108, TRUE, 55.00, 260.00, FALSE, 20),

(200, '2023-12-29 19:00:00', 1, 3, 1, 130, 127, TRUE, 94.00, 470.00, FALSE, 1),
(201, '2023-12-29 19:30:00', 2, 4, 2, 125, 129, TRUE, 78.00, 360.00, FALSE, 4),
(202, '2023-12-30 19:00:00', 5, 7, 5, 138, 136, TRUE, 71.00, 340.00, FALSE, 5),
(203, '2023-12-30 20:00:00', 6, 8, 6, 131, 129, TRUE, 67.00, 330.00, FALSE, 6),
(204, '2024-01-02 19:00:00', 9, 11, 9, 115, 118, TRUE, 61.00, 305.00, FALSE, 11),
(205, '2024-01-02 19:30:00', 10, 12, 10, 129, 127, TRUE, 63.00, 310.00, FALSE, 10),
(206, '2024-01-03 19:00:00', 13, 16, 13, 133, 130, TRUE, 68.00, 325.00, FALSE, 13),
(207, '2024-01-03 20:00:00', 14, 15, 14, 120, 123, TRUE, 57.00, 285.00, FALSE, 15),
(208, '2024-01-04 19:00:00', 17, 20, 17, 119, 116, TRUE, 56.00, 275.00, FALSE, 17),
(209, '2024-01-04 19:30:00', 18, 19, 18, 123, 125, TRUE, 54.00, 260.00, FALSE, 19);


INSERT INTO GameReferees (RefereeID, GameID, OfficialStatus) VALUES
(201, 1, 'Crew Chief'),
(202, 1, 'Referee'),
(203, 1, 'Umpire'),
(204, 2, 'Crew Chief'),
(205, 2, 'Referee'),
(206, 2, 'Umpire'),
(207, 3, 'Crew Chief'),
(208, 3, 'Referee'),
(209, 3, 'Umpire'),
(210, 4, 'Crew Chief'),
(211, 4, 'Referee'),
(212, 4, 'Umpire'),
(213, 5, 'Crew Chief'),
(214, 5, 'Referee'),
(215, 5, 'Umpire'),
(201, 6, 'Crew Chief'),
(202, 6, 'Referee'),
(203, 7, 'Crew Chief'),
(204, 7, 'Referee'),
(205, 8, 'Crew Chief'),
(201, 180, 'Crew Chief'),
(202, 180, 'Referee'),
(203, 180, 'Umpire'),
(204, 181, 'Crew Chief'),
(205, 181, 'Referee'),
(206, 181, 'Umpire'),
(207, 182, 'Crew Chief'),
(208, 182, 'Referee'),
(209, 182, 'Umpire'),
(210, 183, 'Crew Chief'),
(211, 183, 'Referee'),
(212, 183, 'Umpire'),
(213, 184, 'Crew Chief'),
(214, 184, 'Referee'),
(215, 184, 'Umpire'),
(202, 185, 'Crew Chief'),
(203, 185, 'Referee'),
(204, 185, 'Umpire'),
(205, 186, 'Crew Chief'),
(206, 186, 'Referee'),
(207, 186, 'Umpire'),
(208, 187, 'Crew Chief'),
(209, 187, 'Referee'),
(210, 187, 'Umpire'),
(211, 188, 'Crew Chief'),
(212, 188, 'Referee'),
(213, 188, 'Umpire'),
(214, 189, 'Crew Chief'),
(215, 189, 'Referee'),
(201, 189, 'Umpire'),
(203, 190, 'Crew Chief'),
(204, 190, 'Referee'),
(205, 190, 'Umpire'),
(206, 191, 'Crew Chief'),
(207, 191, 'Referee'),
(208, 191, 'Umpire'),
(209, 192, 'Crew Chief'),
(210, 192, 'Referee'),
(211, 192, 'Umpire'),
(212, 193, 'Crew Chief'),
(213, 193, 'Referee'),
(214, 193, 'Umpire'),
(215, 194, 'Crew Chief'),
(201, 194, 'Referee'),
(202, 194, 'Umpire'),
(204, 195, 'Crew Chief'),
(205, 195, 'Referee'),
(206, 195, 'Umpire'),
(207, 196, 'Crew Chief'),
(208, 196, 'Referee'),
(209, 196, 'Umpire'),
(210, 197, 'Crew Chief'),
(211, 197, 'Referee'),
(212, 197, 'Umpire'),
(213, 198, 'Crew Chief'),
(214, 198, 'Referee'),
(215, 198, 'Umpire'),
(201, 199, 'Crew Chief'),
(202, 199, 'Referee'),
(203, 199, 'Umpire'),
(205, 200, 'Crew Chief'),
(206, 200, 'Referee'),
(207, 200, 'Umpire'),
(208, 201, 'Crew Chief'),
(209, 201, 'Referee'),
(210, 201, 'Umpire'),
(211, 202, 'Crew Chief'),
(212, 202, 'Referee'),
(213, 202, 'Umpire'),
(214, 203, 'Crew Chief'),
(215, 203, 'Referee'),
(201, 203, 'Umpire'),
(202, 204, 'Crew Chief'),
(203, 204, 'Referee'),
(204, 204, 'Umpire'),
(206, 205, 'Crew Chief'),
(207, 205, 'Referee'),
(208, 205, 'Umpire'),
(209, 206, 'Crew Chief'),
(210, 206, 'Referee'),
(211, 206, 'Umpire'),
(212, 207, 'Crew Chief'),
(213, 207, 'Referee'),
(214, 207, 'Umpire'),
(215, 208, 'Crew Chief'),
(201, 208, 'Referee'),
(202, 208, 'Umpire'),
(203, 209, 'Crew Chief'),
(204, 209, 'Referee'),
(205, 209, 'Umpire'),
(201, 100, 'Crew Chief'), (202, 100, 'Referee'),
(203, 101, 'Crew Chief'),
(204, 102, 'Crew Chief'), (205, 102, 'Referee'),
(206, 103, 'Crew Chief'),
(207, 104, 'Crew Chief'), (208, 104, 'Referee'),
(209, 105, 'Crew Chief'),
(210, 106, 'Crew Chief'), (211, 106, 'Referee'),
(212, 107, 'Crew Chief'),
(213, 108, 'Crew Chief'), (214, 108, 'Referee'),
(215, 109, 'Crew Chief'),
(201, 110, 'Crew Chief'), (202, 110, 'Referee'),
(203, 111, 'Crew Chief'),
(204, 112, 'Crew Chief'), (205, 112, 'Referee'),
(206, 113, 'Crew Chief'),
(207, 114, 'Crew Chief'), (208, 114, 'Referee'),
(209, 115, 'Crew Chief'),
(210, 116, 'Crew Chief'), (211, 116, 'Referee'),
(212, 117, 'Crew Chief'),
(213, 118, 'Crew Chief'), (214, 118, 'Referee'),
(215, 119, 'Crew Chief'),
(201, 120, 'Crew Chief'), (202, 120, 'Referee'),
(203, 121, 'Crew Chief'),
(204, 122, 'Crew Chief'), (205, 122, 'Referee'),
(206, 123, 'Crew Chief'),
(207, 124, 'Crew Chief'), (208, 124, 'Referee'),
(209, 125, 'Crew Chief'),
(210, 126, 'Crew Chief'), (211, 126, 'Referee'),
(212, 127, 'Crew Chief'),
(213, 128, 'Crew Chief'), (214, 128, 'Referee'),
(215, 129, 'Crew Chief'),
(201, 130, 'Crew Chief'), (202, 130, 'Referee'),
(203, 131, 'Crew Chief'),
(204, 132, 'Crew Chief'), (205, 132, 'Referee'),
(206, 133, 'Crew Chief'),
(207, 134, 'Crew Chief'), (208, 134, 'Referee'),
(209, 135, 'Crew Chief'),
(210, 136, 'Crew Chief'), (211, 136, 'Referee'),
(212, 137, 'Crew Chief'),
(213, 138, 'Crew Chief'), (214, 138, 'Referee'),
(215, 139, 'Crew Chief'),
(201, 140, 'Crew Chief'), (202, 140, 'Referee'),
(203, 141, 'Crew Chief'),
(204, 142, 'Crew Chief'), (205, 142, 'Referee'),
(206, 143, 'Crew Chief'),
(207, 144, 'Crew Chief'), (208, 144, 'Referee'),
(209, 145, 'Crew Chief'),
(210, 146, 'Crew Chief'), (211, 146, 'Referee'),
(212, 147, 'Crew Chief'),
(213, 148, 'Crew Chief'), (214, 148, 'Referee'),
(215, 149, 'Crew Chief'),
(201, 150, 'Crew Chief'), (202, 150, 'Referee'),
(203, 151, 'Crew Chief'),
(204, 152, 'Crew Chief'), (205, 152, 'Referee'),
(206, 153, 'Crew Chief'),
(207, 154, 'Crew Chief'), (208, 154, 'Referee'),
(209, 155, 'Crew Chief'),
(210, 156, 'Crew Chief'), (211, 156, 'Referee'),
(212, 157, 'Crew Chief'),
(213, 158, 'Crew Chief'), (214, 158, 'Referee'),
(215, 159, 'Crew Chief'),
(201, 160, 'Crew Chief'), (202, 160, 'Referee'),
(203, 161, 'Crew Chief'),
(204, 162, 'Crew Chief'), (205, 162, 'Referee'),
(206, 163, 'Crew Chief'),
(207, 164, 'Crew Chief'), (208, 164, 'Referee'),
(209, 165, 'Crew Chief'),
(210, 166, 'Crew Chief'), (211, 166, 'Referee'),
(212, 167, 'Crew Chief'),
(213, 168, 'Crew Chief'), (214, 168, 'Referee'),
(215, 169, 'Crew Chief'),
(201, 170, 'Crew Chief'), (202, 170, 'Referee'),
(203, 171, 'Crew Chief'),
(204, 172, 'Crew Chief'), (205, 172, 'Referee'),
(206, 173, 'Crew Chief'),
(207, 174, 'Crew Chief'), (208, 174, 'Referee'),
(209, 175, 'Crew Chief'),
(210, 176, 'Crew Chief'), (211, 176, 'Referee'),
(212, 177, 'Crew Chief'),
(213, 178, 'Crew Chief'), (214, 178, 'Referee'),
(215, 179, 'Crew Chief');

INSERT INTO PlayoffSerie (PlayoffSerieID, Team1ID, Team2ID, PlayoffYear, RoundNumber, WinnerID, GameCount) VALUES
(1, 1, 8, 2023, 1, 1, 6),
(2, 4, 11, 2022, 1, 4, 5),
(3, 6, 16, 2021, 1, 6, 7),
(4, 7, 13, 2020, 1, 7, 6),
(5, 1, 4, 2019, 2, 1, 7),
(6, 6, 7, 2018, 2, 7, 6),
(7, 1, 7, 2017, 3, 7, 5);

INSERT INTO Game (GameID, GameDate, HomeTeamID, AwayTeamID, ArenaID, HomeScore, AwayScore, IsOvertime, MinTicketPrice, MaxTicketPrice, IsPlayoffGame, WinnerID) VALUES
-- Playoff games
(21, '2023-04-15 19:30:00', 1, 8, 1, 112, 105, FALSE, 150.00, 850.00, TRUE, 1),
(22, '2023-04-17 19:30:00', 1, 8, 1, 108, 110, FALSE, 155.00, 870.00, TRUE, 8),
(23, '2023-04-20 19:00:00', 8, 1, 8, 103, 100, FALSE, 145.00, 820.00, TRUE, 8),
(24, '2023-04-22 19:00:00', 8, 1, 8, 98, 101, FALSE, 145.00, 820.00, TRUE, 1),
(25, '2023-04-24 19:30:00', 1, 8, 1, 116, 112, TRUE, 160.00, 900.00, TRUE, 1),
(26, '2023-04-26 19:00:00', 8, 1, 8, 107, 105, FALSE, 150.00, 860.00, TRUE, 8),
(27, '2023-04-28 19:30:00', 1, 8, 1, 118, 115, FALSE, 165.00, 950.00, TRUE, 1),

-- Celtics vs Cavaliers playoff series
(28, '2023-04-16 19:00:00', 4, 11, 4, 120, 108, FALSE, 130.00, 750.00, TRUE, 4),
(29, '2023-04-18 19:00:00', 4, 11, 4, 112, 105, FALSE, 135.00, 770.00, TRUE, 4),
(30, '2023-04-21 19:30:00', 11, 4, 11, 98, 102, FALSE, 120.00, 680.00, TRUE, 4),
(31, '2023-04-23 19:30:00', 11, 4, 11, 107, 110, TRUE, 125.00, 700.00, TRUE, 4),
(32, '2023-04-25 19:00:00', 4, 11, 4, 115, 112, FALSE, 140.00, 780.00, TRUE, 4),

-- Bucks vs Grizzlies playoff series
(33, '2023-04-15 20:00:00', 6, 16, 6, 108, 105, FALSE, 110.00, 650.00, TRUE, 6),
(34, '2023-04-17 20:00:00', 6, 16, 6, 112, 115, FALSE, 115.00, 670.00, TRUE, 16),
(35, '2023-04-20 20:30:00', 16, 6, 16, 101, 98, FALSE, 100.00, 580.00, TRUE, 16),
(36, '2023-04-22 20:30:00', 16, 6, 16, 105, 108, FALSE, 105.00, 600.00, TRUE, 6),
(37, '2023-04-24 20:00:00', 6, 16, 6, 116, 114, TRUE, 120.00, 690.00, TRUE, 6),
(38, '2023-04-26 20:30:00', 16, 6, 16, 112, 110, FALSE, 110.00, 630.00, TRUE, 16),
(39, '2023-04-28 20:00:00', 6, 16, 6, 121, 119, TRUE, 125.00, 720.00, TRUE, 6),

-- Nuggets vs Suns playoff series
(40, '2023-04-16 20:30:00', 7, 13, 7, 118, 112, FALSE, 95.00, 550.00, TRUE, 7),
(41, '2023-04-18 20:30:00', 7, 13, 7, 105, 108, FALSE, 100.00, 570.00, TRUE, 13),
(42, '2023-04-21 22:00:00', 13, 7, 13, 115, 120, FALSE, 110.00, 620.00, TRUE, 7),
(43, '2023-04-23 22:00:00', 13, 7, 13, 102, 98, FALSE, 115.00, 640.00, TRUE, 13),
(44, '2023-04-25 20:30:00', 7, 13, 7, 112, 105, FALSE, 105.00, 590.00, TRUE, 7),
(45, '2023-04-27 22:00:00', 13, 7, 13, 108, 115, FALSE, 120.00, 660.00, TRUE, 7),

-- Conference Semifinals: Warriors vs Celtics
(46, '2023-05-02 19:30:00', 1, 4, 1, 125, 122, TRUE, 180.00, 1100.00, TRUE, 4),
(47, '2023-05-04 19:30:00', 1, 4, 1, 112, 108, FALSE, 185.00, 1120.00, TRUE, 1),
(48, '2023-05-06 20:00:00', 4, 1, 4, 115, 118, FALSE, 170.00, 980.00, TRUE, 1),
(49, '2023-05-08 20:00:00', 4, 1, 4, 120, 115, FALSE, 175.00, 1000.00, TRUE, 4),
(50, '2023-05-10 19:30:00', 1, 4, 1, 108, 105, FALSE, 190.00, 1150.00, TRUE, 1),
(51, '2023-05-12 20:00:00', 4, 1, 4, 122, 120, TRUE, 180.00, 1080.00, TRUE, 4),
(52, '2023-05-14 19:30:00', 1, 4, 1, 130, 125, FALSE, 200.00, 1200.00, TRUE, 1),

-- Conference Semifinals: Bucks vs Nuggets
(53, '2023-05-03 20:00:00', 6, 7, 6, 108, 112, FALSE, 140.00, 850.00, TRUE, 7),
(54, '2023-05-05 20:00:00', 6, 7, 6, 115, 118, FALSE, 145.00, 870.00, TRUE, 7),
(55, '2023-05-07 20:30:00', 7, 6, 7, 105, 102, FALSE, 130.00, 750.00, TRUE, 7),
(56, '2023-05-09 20:30:00', 7, 6, 7, 112, 115, FALSE, 135.00, 770.00, TRUE, 6),
(57, '2023-05-11 20:00:00', 6, 7, 6, 98, 105, FALSE, 150.00, 880.00, TRUE, 7),
(58, '2023-05-13 20:30:00', 7, 6, 7, 118, 116, TRUE, 140.00, 820.00, TRUE, 7),

-- NBA Finals: Warriors vs Nuggets
(59, '2023-06-01 19:30:00', 1, 7, 1, 125, 128, FALSE, 250.00, 2000.00, TRUE, 7),
(60, '2023-06-04 19:30:00', 1, 7, 1, 118, 115, FALSE, 255.00, 2050.00, TRUE, 1),
(61, '2023-06-07 20:30:00', 7, 1, 7, 132, 130, TRUE, 220.00, 1800.00, TRUE, 7),
(62, '2023-06-09 20:30:00', 7, 1, 7, 115, 112, FALSE, 225.00, 1850.00, TRUE, 7),
(63, '2023-06-12 19:30:00', 1, 7, 1, 120, 125, FALSE, 260.00, 2100.00, TRUE, 7),

-- More regular season games to reach 300+ records
(64, '2023-11-14 19:30:00', 2, 5, 2, 112, 108, FALSE, 110.00, 580.00, FALSE, 2),
(65, '2023-11-15 19:00:00', 3, 6, 3, 105, 112, FALSE, 90.00, 460.00, FALSE, 6),
(66, '2023-11-16 20:00:00', 7, 9, 7, 118, 105, FALSE, 70.00, 360.00, FALSE, 7),
(67, '2023-11-17 19:30:00', 10, 11, 10, 98, 95, FALSE, 75.00, 380.00, FALSE, 10),
(68, '2023-11-18 20:00:00', 12, 13, 12, 102, 108, FALSE, 60.00, 320.00, FALSE, 13),
(69, '2023-11-19 18:00:00', 14, 15, 14, 95, 92, FALSE, 55.00, 290.00, FALSE, 14),
(70, '2023-11-20 19:30:00', 16, 17, 16, 112, 110, TRUE, 65.00, 340.00, FALSE, 16),
(71, '2023-11-21 20:00:00', 18, 19, 18, 88, 95, FALSE, 45.00, 240.00, FALSE, 19),
(72, '2023-11-22 19:00:00', 20, 1, 20, 105, 115, FALSE, 85.00, 420.00, FALSE, 1),
(73, '2023-11-23 19:30:00', 4, 2, 4, 122, 118, FALSE, 130.00, 680.00, FALSE, 4),
(74, '2023-11-24 20:00:00', 5, 3, 5, 116, 112, FALSE, 80.00, 400.00, FALSE, 5),
(75, '2023-11-25 19:00:00', 6, 7, 6, 108, 105, FALSE, 95.00, 480.00, FALSE, 6),
(76, '2023-11-26 18:00:00', 8, 9, 8, 98, 102, FALSE, 70.00, 350.00, FALSE, 9),
(77, '2023-11-27 19:30:00', 10, 12, 10, 115, 108, FALSE, 65.00, 330.00, FALSE, 10),
(78, '2023-11-28 20:00:00', 13, 14, 13, 125, 122, TRUE, 75.00, 380.00, FALSE, 13),
(79, '2023-11-29 19:00:00', 15, 16, 15, 98, 95, FALSE, 60.00, 310.00, FALSE, 15),
(80, '2023-11-30 19:30:00', 17, 18, 17, 112, 105, FALSE, 50.00, 270.00, FALSE, 17);

INSERT INTO PlayoffSerieGame (PlayoffSerieID, GameID, GameNr) VALUES
-- Warriors vs Heat series
(1, 21, 1),
(1, 22, 2),
(1, 23, 3),
(1, 24, 4),
(1, 25, 5),
(1, 26, 6),
(1, 27, 7),

-- Celtics vs Cavaliers series
(2, 28, 1),
(2, 29, 2),
(2, 30, 3),
(2, 31, 4),
(2, 32, 5),

-- Bucks vs Grizzlies series
(3, 33, 1),
(3, 34, 2),
(3, 35, 3),
(3, 36, 4),
(3, 37, 5),
(3, 38, 6),
(3, 39, 7),

-- Nuggets vs Suns series
(4, 40, 1),
(4, 41, 2),
(4, 42, 3),
(4, 43, 4),
(4, 44, 5),
(4, 45, 6),

-- Warriors vs Celtics conference finals
(5, 46, 1),
(5, 47, 2),
(5, 48, 3),
(5, 49, 4),
(5, 50, 5),
(5, 51, 6),
(5, 52, 7),

-- Bucks vs Nuggets conference finals
(6, 53, 1),
(6, 54, 2),
(6, 55, 3),
(6, 56, 4),
(6, 57, 5),
(6, 58, 6),

-- NBA Finals
(7, 59, 1),
(7, 60, 2),
(7, 61, 3),
(7, 62, 4),
(7, 63, 5);


INSERT INTO GameReferees (RefereeID, GameID, OfficialStatus) VALUES
(207, 8, 'Crew Chief'),
(208, 8, 'Referee'),
(209, 9, 'Crew Chief'),
(210, 9, 'Referee'),
(211, 10, 'Crew Chief'),
(212, 10, 'Referee'),
(213, 11, 'Crew Chief'),
(214, 11, 'Referee'),
(215, 12, 'Crew Chief'),
(201, 12, 'Referee'),
(202, 13, 'Crew Chief'),
(203, 13, 'Referee'),
(204, 14, 'Crew Chief'),
(205, 14, 'Referee'),
(206, 15, 'Crew Chief'),
(207, 15, 'Referee'),
(208, 16, 'Crew Chief'),
(209, 16, 'Referee'),
(210, 17, 'Crew Chief'),
(211, 17, 'Referee');

ALTER TABLE Person CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Person Table Inserts FOR PLAYERS!!!!
INSERT INTO Person (PersonID, Name, Surname, FullName, DateOfBirth, Gender, Nationality, YearSalary) VALUES
-- Golden State Warriors (TeamID 1)
(1000, 'Stephen', 'Curry', 'Stephen Curry', '1988-03-14', 'Male', 'USA', 51920000),
(1001, 'Klay', 'Thompson', 'Klay Thompson', '1990-02-08', 'Male', 'USA', 32740000),
(1002, 'Draymond', 'Green', 'Draymond Green', '1990-03-04', 'Male', 'USA', 23660000),
(1003, 'Andrew', 'Wiggins', 'Andrew Wiggins', '1995-02-23', 'Male', 'Canada', 31000000),
(1004, 'Jordan', 'Poole', 'Jordan Poole', '1999-06-19', 'Male', 'USA', 18000000),
(1005, 'Kevon', 'Looney', 'Kevon Looney', '1996-02-06', 'Male', 'USA', 12000000),
(1006, 'Jonathan', 'Kuminga', 'Jonathan Kuminga', '2002-10-06', 'Male', 'DR Congo', 8000000),
(1007, 'Moses', 'Moody', 'Moses Moody', '2002-05-31', 'Male', 'USA', 7500000),

-- Los Angeles Lakers (TeamID 2)
(1008, 'LeBron', 'James', 'LeBron James', '1984-12-30', 'Male', 'USA', 47610000),
(1009, 'Anthony', 'Davis', 'Anthony Davis', '1993-03-11', 'Male', 'USA', 35600000),
(1010, 'Russell', 'Westbrook', 'Russell Westbrook', '1988-11-12', 'Male', 'USA', 41160000),
(1011, 'Carmelo', 'Anthony', 'Carmelo Anthony', '1984-05-29', 'Male', 'USA', 2800000),
(1012, 'Austin', 'Reaves', 'Austin Reaves', '1998-05-29', 'Male', 'USA', 3500000),
(1013, 'D’Angelo', 'Russell', 'D’Angelo Russell', '1996-02-23', 'Male', 'USA', 17000000),
(1014, 'Troy', 'Brown Jr.', 'Troy Brown Jr.', '1999-07-28', 'Male', 'USA', 1500000),
(1015, 'Malik', 'Beasley', 'Malik Beasley', '1996-11-26', 'Male', 'USA', 11000000),

-- New York Knicks (TeamID 3)
(1016, 'Julius', 'Randle', 'Julius Randle', '1994-11-29', 'Male', 'USA', 28800000),
(1017, 'RJ', 'Barrett', 'RJ Barrett', '2000-06-14', 'Male', 'Canada', 10500000),
(1018, 'Jalen', 'Brunson', 'Jalen Brunson', '1996-08-31', 'Male', 'USA', 10000000),
(1019, 'Mitchell', 'Robinson', 'Mitchell Robinson', '1998-04-01', 'Male', 'USA', 8000000),
(1020, 'Immanuel', 'Quickley', 'Immanuel Quickley', '1999-06-17', 'Male', 'USA', 3500000),
(1021, 'Evan', 'Mobley', 'Evan Mobley', '2001-06-18', 'Male', 'USA', 9500000),
(1022, 'Obi', 'Toppin', 'Obi Toppin', '1998-03-04', 'Male', 'USA', 4200000),
(1023, 'Derrick', 'Rose', 'Derrick Rose', '1988-10-04', 'Male', 'USA', 2000000),

-- Boston Celtics (TeamID 4)
(1024, 'Jayson', 'Tatum', 'Jayson Tatum', '1998-03-03', 'Male', 'USA', 32950000),
(1025, 'Jaylen', 'Brown', 'Jaylen Brown', '1996-10-24', 'Male', 'USA', 30500000),
(1026, 'Marcus', 'Smart', 'Marcus Smart', '1994-03-06', 'Male', 'USA', 17000000),
(1027, 'Al', 'Horford', 'Al Horford', '1986-06-03', 'Male', 'Dominican Republic', 15000000),
(1028, 'Robert', 'Williams III', 'Robert Williams III', '1997-10-17', 'Male', 'USA', 8000000),
(1029, 'Derrick', 'White', 'Derrick White', '1994-07-02', 'Male', 'USA', 11000000),
(1030, 'Grant', 'Williams', 'Grant Williams', '1998-05-14', 'Male', 'USA', 5200000),
(1031, 'Malcolm', 'Brogdon', 'Malcolm Brogdon', '1992-12-11', 'Male', 'USA', 20000000),

-- Dallas Mavericks (TeamID 5)
(1032, 'Luka', 'Doncic', 'Luka Doncic', '1999-02-28', 'Male', 'Slovenia', 41000000),
(1033, 'Kristaps', 'Porzingis', 'Kristaps Porzingis', '1995-08-02', 'Male', 'Latvia', 32000000),
(1034, 'Dorian', 'Finney-Smith', 'Dorian Finney-Smith', '1993-05-04', 'Male', 'USA', 15000000),
(1035, 'Spencer', 'Dinwiddie', 'Spencer Dinwiddie', '1993-04-06', 'Male', 'USA', 15000000),
(1036, 'Reggie', 'Bullock', 'Reggie Bullock', '1991-03-16', 'Male', 'USA', 5000000),
(1037, 'Tim', 'Hardaway Jr.', 'Tim Hardaway Jr.', '1992-03-16', 'Male', 'USA', 19000000),
(1038, 'Maxi', 'Kleber', 'Maxi Kleber', '1992-01-29', 'Male', 'Germany', 6000000),
(1039, 'Jaden', 'Hardy', 'Jaden Hardy', '2002-09-08', 'Male', 'USA', 2500000),

-- Milwaukee Bucks (TeamID 6)
(1040, 'Giannis', 'Antetokounmpo', 'Giannis Antetokounmpo', '1994-12-06', 'Male', 'Greece', 45000000),
(1041, 'Khris', 'Middleton', 'Khris Middleton', '1991-08-12', 'Male', 'USA', 33000000),
(1042, 'Jrue', 'Holiday', 'Jrue Holiday', '1990-06-12', 'Male', 'USA', 26000000),
(1043, 'Brook', 'Lopez', 'Brook Lopez', '1988-04-01', 'Male', 'USA', 19000000),
(1044, 'Bobby', 'Portis', 'Bobby Portis', '1995-02-10', 'Male', 'USA', 6000000),
(1045, 'Grayson', 'Allen', 'Grayson Allen', '1995-10-08', 'Male', 'USA', 5000000),
(1046, 'Pat', 'Connaughton', 'Pat Connaughton', '1993-03-06', 'Male', 'USA', 3500000),
(1047, 'Semi', 'Ojeleye', 'Semi Ojeleye', '1994-02-05', 'Male', 'USA', 2000000),

-- Denver Nuggets (TeamID 7)
(1048, 'Nikola', 'Jokic', 'Nikola Jokic', '1995-02-19', 'Male', 'Serbia', 40000000),
(1049, 'Jamal', 'Murray', 'Jamal Murray', '1997-02-23', 'Male', 'Canada', 29000000),
(1050, 'Aaron', 'Gordon', 'Aaron Gordon', '1995-09-16', 'Male', 'USA', 20000000),
(1051, 'Michael', 'Porter Jr.', 'Michael Porter Jr.', '1998-06-29', 'Male', 'USA', 16000000),
(1052, 'Kentavious', 'Caldwell-Pope', 'Kentavious Caldwell-Pope', '1993-02-18', 'Male', 'USA', 13000000),
(1053, 'Bones', 'Hyland', 'Bones Hyland', '2000-06-12', 'Male', 'USA', 1500000),
(1054, 'JaMychal', 'Green', 'JaMychal Green', '1990-06-21', 'Male', 'USA', 1200000),
(1055, 'Jeff', 'Green', 'Jeff Green', '1986-08-28', 'Male', 'USA', 2000000),

-- Miami Heat (TeamID 8)
(1056, 'Jimmy', 'Butler', 'Jimmy Butler', '1989-09-14', 'Male', 'USA', 36000000),
(1057, 'Bam', 'Adebayo', 'Bam Adebayo', '1997-07-18', 'Male', 'USA', 30000000),
(1058, 'Kyle', 'Lowry', 'Kyle Lowry', '1986-03-25', 'Male', 'USA', 15000000),
(1059, 'Tyler', 'Herro', 'Tyler Herro', '2000-01-20', 'Male', 'USA', 8000000),
(1060, 'Duncan', 'Robinson', 'Duncan Robinson', '1994-04-22', 'Male', 'USA', 7000000),
(1061, 'Max', 'Strus', 'Max Strus', '1996-01-28', 'Male', 'USA', 3500000),
(1062, 'P.J.', 'Tucker', 'P.J. Tucker', '1985-05-05', 'Male', 'USA', 9000000),
(1063, 'Victor', 'Oladipo', 'Victor Oladipo', '1992-05-04', 'Male', 'USA', 17000000),

-- Chicago Bulls (TeamID 9)
(1064, 'Zach', 'LaVine', 'Zach LaVine', '1995-03-10', 'Male', 'USA', 28000000),
(1065, 'DeMar', 'DeRozan', 'DeMar DeRozan', '1989-08-07', 'Male', 'USA', 27000000),
(1066, 'Nikola', 'Vucevic', 'Nikola Vucevic', '1990-10-24', 'Male', 'Montenegro', 33000000),
(1067, 'Lonzo', 'Ball', 'Lonzo Ball', '1997-10-27', 'Male', 'USA', 12000000),
(1068, 'Patrick', 'Williams', 'Patrick Williams', '2001-08-26', 'Male', 'USA', 3800000),
(1069, 'Coby', 'White', 'Coby White', '2000-02-16', 'Male', 'USA', 4600000),
(1070, 'Alex', 'Caruso', 'Alex Caruso', '1994-02-28', 'Male', 'USA', 12000000),
(1071, 'Ayo', 'Dosunmu', 'Ayo Dosunmu', '1999-05-10', 'Male', 'USA', 3000000),

-- Philadelphia 76ers (TeamID 10)
(1072, 'Joel', 'Embiid', 'Joel Embiid', '1994-03-16', 'Male', 'Cameroon', 45000000),
(1073, 'James', 'Harden', 'James Harden', '1989-08-26', 'Male', 'USA', 41000000),
(1074, 'Tyrese', 'Maxey', 'Tyrese Maxey', '2000-11-04', 'Male', 'USA', 9000000),
(1075, 'Tobias', 'Harris', 'Tobias Harris', '1992-07-15', 'Male', 'USA', 33000000),
(1076, 'PJ', 'Tucker', 'PJ Tucker', '1985-05-05', 'Male', 'USA', 9000000),
(1077, 'Shakeem', 'Hands', 'Shakeem Hands', '1998-06-02', 'Male', 'USA', 1500000),
(1078, 'Danny', 'Green', 'Danny Green', '1987-06-22', 'Male', 'USA', 7000000),
(1079, 'DeAndre', 'Jordan', 'DeAndre Jordan', '1988-07-21', 'Male', 'USA', 5000000),

-- Cleveland Cavaliers (TeamID 11)
(1080, 'Darius', 'Garland', 'Darius Garland', '1999-01-26', 'Male', 'USA', 30000000),
(1081, 'Evan', 'Mobley', 'Evan Mobley', '2001-06-18', 'Male', 'USA', 9000000),
(1082, 'Jarrett', 'Allen', 'Jarrett Allen', '1998-04-21', 'Male', 'USA', 20000000),
(1083, 'Isaac', 'Okoro', 'Isaac Okoro', '2001-05-26', 'Male', 'USA', 3500000),
(1084, 'Kevin', 'Love', 'Kevin Love', '1988-09-07', 'Male', 'USA', 32000000),
(1085, 'Caris', 'LeVert', 'Caris LeVert', '1994-08-25', 'Male', 'USA', 16000000),
(1086, 'Malik', 'Fitts', 'Malik Fitts', '1996-08-04', 'Male', 'USA', 1000000),
(1087, 'Cedi', 'Osman', 'Cedi Osman', '1995-04-8', 'Male', 'Turkey', 7000000),

-- Atlanta Hawks (TeamID 12)
(1088, 'Trae', 'Young', 'Trae Young', '1998-09-19', 'Male', 'USA', 38000000),
(1089, 'John', 'Collins', 'John Collins', '1997-09-23', 'Male', 'USA', 12000000),
(1090, 'Clint', 'Capela', 'Clint Capela', '1994-05-18', 'Male', 'Switzerland', 15000000),
(1091, 'Bogdan', 'Bogdanovic', 'Bogdan Bogdanovic', '1992-08-18', 'Male', 'Serbia', 12000000),
(1092, 'Dejounte', 'Murray', 'Dejounte Murray', '1996-09-19', 'Male', 'USA', 20000000),
(1093, 'Kevin', 'Huerter', 'Kevin Huerter', '1998-08-27', 'Male', 'USA', 9000000),
(1094, 'Danilo', 'Gallinari', 'Danilo Gallinari', '1988-08-08', 'Male', 'Italy', 15000000),
(1095, 'Jabari', 'Smith', 'Jabari Smith', '2003-05-13', 'Male', 'USA', 8000000),

-- Phoenix Suns (TeamID 13)
(1096, 'Devin', 'Booker', 'Devin Booker', '1996-10-30', 'Male', 'USA', 33000000),
(1097, 'Kevin', 'Durant', 'Kevin Durant', '1988-09-29', 'Male', 'USA', 45000000),
(1098, 'Chris', 'Paul', 'Chris Paul', '1985-05-06', 'Male', 'USA', 43000000),
(1099, 'Mikal', 'Bridges', 'Mikal Bridges', '1996-08-30', 'Male', 'USA', 18000000),
(1100, 'Jae', 'Crowder', 'Jae Crowder', '1990-07-06', 'Male', 'USA', 15000000),
(1101, 'Cam', 'Johnson', 'Cam Johnson', '1996-03-03', 'Male', 'USA', 8000000),
(1102, 'Torrey', 'Craig', 'Torrey Craig', '1990-02-20', 'Male', 'USA', 3500000),
(1103, 'JaVale', 'McGee', 'JaVale McGee', '1988-01-19', 'Male', 'USA', 12000000),

-- Portland Trail Blazers (TeamID 14)
(1104, 'Damian', 'Lillard', 'Damian Lillard', '1990-07-15', 'Male', 'USA', 32000000),
(1105, 'CJ', 'McCollum', 'CJ McCollum', '1991-09-19', 'Male', 'USA', 27000000),
(1106, 'Jusuf', 'Nurkić', 'Jusuf Nurkić', '1994-08-23', 'Male', 'Bosnia', 12000000),
(1107, 'Anfernee', 'Simons', 'Anfernee Simons', '1999-06-08', 'Male', 'USA', 9000000),
(1108, 'Jerami', 'Grant', 'Jerami Grant', '1994-03-12', 'Male', 'USA', 16000000),
(1109, 'Shaedon', 'Sharpe', 'Shaedon Sharpe', '2003-02-01', 'Male', 'Canada', 5000000),
(1110, 'Trendon', 'Watts', 'Trendon Watts', '1995-10-15', 'Male', 'USA', 1000000),
(1111, 'Nassir', 'Little', 'Nassir Little', '2000-05-11', 'Male', 'USA', 3000000),

-- Utah Jazz (TeamID 15)
(1112, 'Lauri', 'Markkanen', 'Lauri Markkanen', '1997-05-22', 'Male', 'Finland', 18000000),
(1113, 'Jordan', 'Poole', 'Jordan Poole', '1999-06-19', 'Male', 'USA', 12000000),
(1114, 'Mike', 'Conley', 'Mike Conley', '1987-10-11', 'Male', 'USA', 20000000),
(1115, 'Collin', 'Sexton', 'Collin Sexton', '1999-01-04', 'Male', 'USA', 14000000),
(1116, 'Walker', 'Kessler', 'Walker Kessler', '2001-05-25', 'Male', 'USA', 4000000),
(1117, 'Rudy', 'Gobert', 'Rudy Gobert', '1992-06-26', 'Male', 'France', 35000000),
(1118, 'Jarrell', 'Brantley', 'Jarrell Brantley', '1996-01-14', 'Male', 'USA', 1200000),
(1119, 'Brad', 'Wanamaker', 'Brad Wanamaker', '1989-07-25', 'Male', 'USA', 1000000),

-- Memphis Grizzlies (TeamID 16)
(1120, 'Ja', 'Morant', 'Ja Morant', '1999-08-10', 'Male', 'USA', 30000000),
(1121, 'Jaren', 'Jackson Jr.', 'Jaren Jackson Jr.', '1999-09-15', 'Male', 'USA', 25000000),
(1122, 'Desmond', 'Bane', 'Desmond Bane', '1998-06-25', 'Male', 'USA', 12000000),
(1123, 'Tyus', 'Jones', 'Tyus Jones', '1996-01-10', 'Male', 'USA', 7000000),
(1124, 'Steven', 'Adams', 'Steven Adams', '1993-07-20', 'Male', 'New Zealand', 15000000),
(1125, 'Brandon', 'Clark', 'Brandon Clark', '1996-10-22', 'Male', 'USA', 1500000),
(1126, 'John', 'Konchar', 'John Konchar', '1996-07-28', 'Male', 'USA', 2000000),
(1127, 'Santi', 'Arias', 'Santi Arias', '1998-04-14', 'Male', 'Spain', 1000000),

-- Indiana Pacers (TeamID 17)
(1128, 'Tyrese', 'Haliburton', 'Tyrese Haliburton', '2000-02-29', 'Male', 'USA', 22000000),
(1129, 'Myles', 'Turner', 'Myles Turner', '1996-03-24', 'Male', 'USA', 21000000),
(1130, 'Bennedict', 'Mathurin', 'Bennedict Mathurin', '2002-06-19', 'Male', 'Canada', 8000000),
(1131, 'Buddy', 'Hield', 'Buddy Hield', '1992-12-17', 'Male', 'Bahamas', 15000000),
(1132, 'Chris', 'Duarte', 'Chris Duarte', '1997-05-13', 'Male', 'Canada', 2000000),
(1133, 'Andrew', 'Nembhard', 'Andrew Nembhard', '2000-05-19', 'Male', 'Canada', 1200000),
(1134, 'Aaron', 'Holiday', 'Aaron Holiday', '1996-09-30', 'Male', 'USA', 4000000),
(1135, 'Isaiah', 'Jackson', 'Isaiah Jackson', '2001-01-04', 'Male', 'USA', 2000000),

-- Washington Wizards (TeamID 18)
(1136, 'Bradley', 'Beal', 'Bradley Beal', '1993-06-28', 'Male', 'USA', 35000000),
(1137, 'Kristaps', 'Porzingis', 'Kristaps Porzingis', '1995-08-02', 'Male', 'Latvia', 32000000),
(1138, 'Kyle', 'Kuzma', 'Kyle Kuzma', '1997-07-24', 'Male', 'USA', 15000000),
(1139, 'Davis', 'Bertans', 'Davis Bertans', '1992-11-12', 'Male', 'Latvia', 11000000),
(1140, 'Rui', 'Hachimura', 'Rui Hachimura', '1998-02-08', 'Male', 'Japan', 9000000),
(1141, 'Monte', 'Morris', 'Monte Morris', '1995-06-27', 'Male', 'USA', 4000000),
(1142, 'Aaron', 'Wiggins', 'Aaron Wiggins', '1997-09-14', 'Male', 'USA', 2000000),
(1143, 'Johnny', 'Davis', 'Johnny Davis', '2002-01-04', 'Male', 'USA', 1500000),

-- New Orleans Pelicans (TeamID 19)
(1144, 'Zion', 'Williamson', 'Zion Williamson', '2000-07-06', 'Male', 'USA', 35000000),
(1145, 'Brandon', 'Ingram', 'Brandon Ingram', '1997-09-02', 'Male', 'USA', 28000000),
(1146, 'CJ', 'McCollum', 'CJ McCollum', '1991-09-19', 'Male', 'USA', 27000000),
(1147, 'Jonas', 'Valanciunas', 'Jonas Valanciunas', '1992-05-06', 'Male', 'Lithuania', 15000000),
(1148, 'Herbert', 'Jones', 'Herbert Jones', '1998-02-3', 'Male', 'USA', 4000000),
(1149, 'Trey', 'Murphy', 'Trey Murphy', '2000-03-18', 'Male', 'USA', 3000000),
(1150, 'Jose', 'Alvarado', 'Jose Alvarado', '1998-07-21', 'Male', 'USA', 2000000),
(1151, 'Garrett', 'Temple', 'Garrett Temple', '1986-06-06', 'Male', 'USA', 5000000),

-- Minnesota Timberwolves (TeamID 20)
(1152, 'Anthony', 'Edwards', 'Anthony Edwards', '2001-08-05', 'Male', 'USA', 12000000),
(1153, 'Karl-Anthony', 'Towns', 'Karl-Anthony Towns', '1995-11-15', 'Male', 'Dominican Republic', 37000000),
(1154, 'Rudy', 'Gobert', 'Rudy Gobert', '1992-06-26', 'Male', 'France', 35000000),
(1155, 'Jaden', 'McDaniels', 'Jaden McDaniels', '2000-09-23', 'Male', 'USA', 4500000),
(1156, 'Malik', 'Beasley', 'Malik Beasley', '1996-11-26', 'Male', 'USA', 14000000),
(1157, 'Naz', 'Reid', 'Naz Reid', '1999-06-16', 'Male', 'USA', 3000000),
(1158, 'Jaylen', 'Nowell', 'Jaylen Nowell', '1999-07-09', 'Male', 'USA', 2000000),
(1159, 'Tyus', 'Jones', 'Tyus Jones', '1996-01-10', 'Male', 'USA', 7000000);


INSERT INTO Player (PlayerID, TeamID, JerseyNumber, Position, Weight, Height, ArmSpan, VertJump, DraftYear, IsInjured, IsTeamLead, AllStarCount) VALUES
-- Golden State Warriors
(1000, 1, 30, 'PG', 86, 1.88, 1.92, 0.90, 2009, FALSE, TRUE, 8),
(1001, 1, 11, 'SG', 98, 1.98, 2.03, 0.88, 2011, FALSE, FALSE, 5),
(1002, 1, 23, 'PF', 104, 1.98, 2.05, 0.95, 2012, FALSE, TRUE, 3),
(1003, 1, 22, 'SF', 92, 2.01, 2.08, 0.93, 2014, FALSE, FALSE, 1),
(1004, 1, 3, 'SG', 88, 1.93, 1.98, 0.85, 2019, FALSE, FALSE, 0),
(1005, 1, 5, 'C', 109, 2.06, 2.15, 0.89, 2015, FALSE, FALSE, 0),
(1006, 1, 0, 'SF', 102, 2.03, 2.09, 0.92, 2021, FALSE, FALSE, 0),
(1007, 1, 4, 'SG', 95, 1.98, 2.02, 0.87, 2021, FALSE, FALSE, 0),

-- Los Angeles Lakers
(1008, 2, 6, 'SF', 113, 2.06, 2.11, 0.95, 2003, FALSE, TRUE, 18),
(1009, 2, 3, 'PF', 115, 2.08, 2.14, 0.96, 2012, FALSE, TRUE, 8),
(1010, 2, 0, 'PG', 91, 1.91, 1.97, 0.92, 2008, FALSE, FALSE, 9),
(1011, 2, 7, 'SF', 103, 2.01, 2.08, 0.89, 2003, TRUE, FALSE, 10),
(1012, 2, 15, 'SG', 88, 1.96, 2.00, 0.85, 2021, FALSE, FALSE, 0),
(1013, 2, 1, 'PG', 86, 1.93, 1.97, 0.88, 2015, FALSE, FALSE, 0),
(1014, 2, 22, 'SF', 98, 2.01, 2.06, 0.87, 2018, TRUE, FALSE, 0),
(1015, 2, 5, 'SG', 92, 1.98, 2.02, 0.86, 2016, FALSE, FALSE, 0),

-- New York Knicks
(1016, 3, 30, 'PF', 109, 2.06, 2.12, 0.93, 2014, TRUE, TRUE, 1),
(1017, 3, 9, 'SG', 98, 1.98, 2.03, 0.88, 2019, FALSE, FALSE, 0),
(1018, 3, 13, 'PG', 86, 1.88, 1.92, 0.90, 2018, FALSE, FALSE, 0),
(1019, 3, 23, 'C', 113, 2.11, 2.17, 0.95, 2018, TRUE, FALSE, 0),
(1020, 3, 25, 'SG', 88, 1.93, 1.98, 0.85, 2020, TRUE, FALSE, 0),
(1021, 3, 4, 'PF', 105, 2.08, 2.13, 0.90, 2021, FALSE, FALSE, 0),
(1022, 3, 1, 'SF', 101, 2.03, 2.08, 0.87, 2020, FALSE, FALSE, 0),
(1023, 3, 0, 'PG', 86, 1.88, 1.92, 0.86, 2008, FALSE, FALSE, 1),

-- Boston Celtics
(1024, 4, 0, 'SF', 103, 2.01, 2.06, 0.92, 2017, TRUE, TRUE, 3),
(1025, 4, 7, 'SG', 100, 1.98, 2.03, 0.91, 2016, FALSE, FALSE, 2),
(1026, 4, 36, 'PG', 95, 1.91, 1.96, 0.89, 2014, FALSE, FALSE, 1),
(1027, 4, 42, 'C', 109, 2.06, 2.12, 0.94, 2007, TRUE, FALSE, 3),
(1028, 4, 44, 'C', 108, 2.08, 2.14, 0.95, 2018, FALSE, FALSE, 0),
(1029, 4, 12, 'SG', 91, 1.95, 2.00, 0.87, 2017, FALSE, FALSE, 0),
(1030, 4, 12, 'PF', 104, 2.03, 2.08, 0.88, 2019, FALSE, FALSE, 0),
(1031, 4, 13, 'SG', 102, 2.01, 2.06, 0.87, 2016, FALSE, FALSE, 1),

-- Dallas Mavericks (TeamID 5)
(1032, 5, 77, 'PG', 86, 1.88, 1.93, 0.90, 2008, FALSE, TRUE, 5),
(1033, 5, 41, 'SG', 92, 1.96, 2.01, 0.88, 2012, FALSE, FALSE, 1),
(1034, 5, 6, 'SF', 100, 2.03, 2.08, 0.94, 2011, FALSE, FALSE, 0),
(1035, 5, 13, 'PF', 105, 2.08, 2.13, 0.97, 2013, FALSE, FALSE, 1),
(1036, 5, 5, 'C', 110, 2.13, 2.20, 1.01, 2010, FALSE, FALSE, 2),
(1037, 5, 24, 'SG', 90, 1.95, 2.00, 0.88, 2015, FALSE, FALSE, 0),
(1038, 5, 21, 'SF', 97, 2.03, 2.08, 0.92, 2016, FALSE, FALSE, 0),
(1039, 5, 12, 'PF', 104, 2.08, 2.13, 0.96, 2017, FALSE, FALSE, 0),

-- Milwaukee Bucks (TeamID 6)
(1040, 6, 34, 'PF', 108, 2.08, 2.15, 1.00, 2013, TRUE, TRUE, 5),
(1041, 6, 22, 'PG', 86, 1.88, 1.92, 0.90, 2009, FALSE, FALSE, 2),
(1042, 6, 7, 'SG', 92, 1.96, 2.01, 0.88, 2014, FALSE, FALSE, 1),
(1043, 6, 12, 'SF', 100, 2.03, 2.08, 0.93, 2015, FALSE, FALSE, 0),
(1044, 6, 0, 'C', 110, 2.13, 2.20, 1.02, 2011, FALSE, FALSE, 2),
(1045, 6, 21, 'SG', 90, 1.95, 2.00, 0.88, 2016, FALSE, FALSE, 0),
(1046, 6, 31, 'SF', 98, 2.03, 2.08, 0.91, 2017, FALSE, FALSE, 0),
(1047, 6, 13, 'PF', 106, 2.08, 2.13, 0.95, 2018, FALSE, FALSE, 0),

-- Denver Nuggets (TeamID 7)
(1048, 7, 15, 'PG', 86, 1.88, 1.92, 0.90, 2011, FALSE, TRUE, 3),
(1049, 7, 27, 'SG', 92, 1.96, 2.01, 0.88, 2012, FALSE, FALSE, 1),
(1050, 7, 5, 'SF', 100, 2.03, 2.08, 0.93, 2013, FALSE, FALSE, 0),
(1051, 7, 1, 'PF', 105, 2.08, 2.13, 0.97, 2014, FALSE, FALSE, 1),
(1052, 7, 8, 'C', 110, 2.13, 2.20, 1.01, 2010, FALSE, FALSE, 2),
(1053, 7, 24, 'SG', 90, 1.95, 2.00, 0.88, 2015, FALSE, FALSE, 0),
(1054, 7, 20, 'SF', 98, 2.03, 2.08, 0.92, 2016, FALSE, FALSE, 0),
(1055, 7, 35, 'PF', 104, 2.08, 2.13, 0.96, 2017, FALSE, FALSE, 0),

-- Miami Heat (TeamID 8)
(1056, 8, 6, 'PG', 86, 1.88, 1.92, 0.90, 2003, TRUE, TRUE, 3),
(1057, 8, 7, 'SG', 92, 1.96, 2.01, 0.88, 2006, FALSE, FALSE, 2),
(1058, 8, 13, 'SF', 100, 2.03, 2.08, 0.93, 2010, FALSE, FALSE, 1),
(1059, 8, 1, 'PF', 105, 2.08, 2.13, 0.97, 2012, FALSE, FALSE, 0),
(1060, 8, 34, 'C', 110, 2.13, 2.20, 1.01, 2011, FALSE, FALSE, 1),
(1061, 8, 14, 'SG', 90, 1.95, 2.00, 0.88, 2013, TRUE, FALSE, 0),
(1062, 8, 22, 'SF', 98, 2.03, 2.08, 0.92, 2014, FALSE, FALSE, 0),
(1063, 8, 21, 'PF', 104, 2.08, 2.13, 0.96, 2015, FALSE, FALSE, 0),

-- Chicago Bulls (TeamID 9)
(1064, 9, 23, 'PG', 86, 1.88, 1.92, 0.90, 2003, FALSE, TRUE, 6),
(1065, 9, 91, 'SG', 92, 1.96, 2.01, 0.88, 2010, FALSE, FALSE, 2),
(1066, 9, 7, 'SF', 100, 2.03, 2.08, 0.93, 2011,TRUE, FALSE, 1),
(1067, 9, 34, 'PF', 105, 2.08, 2.13, 0.97, 2012, FALSE, FALSE, 0),
(1068, 9, 5, 'C', 110, 2.13, 2.20, 1.01, 2009, TRUE, FALSE, 2),
(1069, 9, 9, 'SG', 90, 1.95, 2.00, 0.88, 2013, FALSE, FALSE, 0),
(1070, 9, 8, 'SF', 98, 2.03, 2.08, 0.92, 2014, FALSE, FALSE, 0),
(1071, 9, 12, 'PF', 104, 2.08, 2.13, 0.96, 2015, FALSE, FALSE, 0), 

-- Philadelphia 76ers (TeamID 10)
(1072, 10, 21, 'PG', 86, 1.88, 1.92, 0.90, 2011, TRUE, TRUE, 4),
(1073, 10, 12, 'SG', 92, 1.96, 2.01, 0.88, 2013, FALSE, FALSE, 1),
(1074, 10, 17, 'SF', 100, 2.03, 2.08, 0.93, 2012, FALSE, FALSE, 0),
(1075, 10, 0, 'PF', 105, 2.08, 2.13, 0.97, 2010, FALSE, FALSE, 2),
(1076, 10, 8, 'C', 110, 2.13, 2.20, 1.01, 2009, FALSE, FALSE, 1),
(1077, 10, 23, 'SG', 90, 1.95, 2.00, 0.88, 2015, TRUE, FALSE, 0),
(1078, 10, 14, 'SF', 98, 2.03, 2.08, 0.92, 2014, TRUE, FALSE, 0),
(1079, 10, 7, 'PF', 104, 2.08, 2.13, 0.96, 2016, FALSE, FALSE, 0),

-- Cleveland Cavaliers (TeamID 11)
(1080, 11, 23, 'PG', 86, 1.88, 1.92, 0.90, 2003, FALSE, TRUE, 6),
(1081, 11, 0, 'SG', 92, 1.96, 2.01, 0.88, 2007, FALSE, FALSE, 2),
(1082, 11, 34, 'SF', 100, 2.03, 2.08, 0.93, 2010, FALSE, FALSE, 1),
(1083, 11, 5, 'PF', 105, 2.08, 2.13, 0.97, 2012, FALSE, FALSE, 0),
(1084, 11, 9, 'C', 110, 2.13, 2.20, 1.01, 2009, TRUE, FALSE, 2),
(1085, 11, 7, 'SG', 90, 1.95, 2.00, 0.88, 2013, FALSE, FALSE, 0),
(1086, 11, 8, 'SF', 98, 2.03, 2.08, 0.92, 2014, FALSE, FALSE, 0),
(1087, 11, 14, 'PF', 104, 2.08, 2.13, 0.96, 2015, FALSE, FALSE, 0),

-- Atlanta Hawks (TeamID 12)
(1088, 12, 11, 'PG', 86, 1.88, 1.92, 0.90, 2010, FALSE, TRUE, 3),
(1089, 12, 20, 'SG', 92, 1.96, 2.01, 0.88, 2011, FALSE, FALSE, 1),
(1090, 12, 12, 'SF', 100, 2.03, 2.08, 0.93, 2013, FALSE, FALSE, 0),
(1091, 12, 6, 'PF', 105, 2.08, 2.13, 0.97, 2014, TRUE, FALSE, 0),
(1092, 12, 21, 'C', 110, 2.13, 2.20, 1.01, 2012, FALSE, FALSE, 2),
(1093, 12, 3, 'SG', 90, 1.95, 2.00, 0.88, 2015, FALSE, FALSE, 0),
(1094, 12, 5, 'SF', 98, 2.03, 2.08, 0.92, 2016, TRUE, FALSE, 0),
(1095, 12, 15, 'PF', 104, 2.08, 2.13, 0.96, 2017, FALSE, FALSE, 0),

-- Phoenix Suns (TeamID 13)
(1096, 13, 1, 'PG', 86, 1.88, 1.92, 0.90, 2015, FALSE, TRUE, 3),
(1097, 13, 3, 'SG', 92, 1.96, 2.01, 0.88, 2016, FALSE, FALSE, 1),
(1098, 13, 32, 'SF', 100, 2.03, 2.08, 0.93, 2013, FALSE, FALSE, 0),
(1099, 13, 22, 'PF', 105, 2.08, 2.13, 0.97, 2014, FALSE, FALSE, 0),
(1100, 13, 34, 'C', 110, 2.13, 2.20, 1.01, 2012, TRUE, FALSE, 2),
(1101, 13, 23, 'SG', 90, 1.95, 2.00, 0.88, 2017, FALSE, FALSE, 0),
(1102, 13, 4, 'SF', 98, 2.03, 2.08, 0.92, 2018, FALSE, FALSE, 0),
(1103, 13, 21, 'PF', 104, 2.08, 2.13, 0.96, 2019, FALSE, FALSE, 0),

-- Portland Trail Blazers (TeamID 14)
(1104, 14, 0, 'PG', 86, 1.88, 1.92, 0.90, 2008, FALSE, TRUE, 3),
(1105, 14, 3, 'SG', 92, 1.96, 2.01, 0.88, 2010, FALSE, FALSE, 1),
(1106, 14, 24, 'SF', 100, 2.03, 2.08, 0.93, 2011, TRUE, FALSE, 0),
(1107, 14, 33, 'PF', 105, 2.08, 2.13, 0.97, 2012, FALSE, FALSE, 0),
(1108, 14, 21, 'C', 110, 2.13, 2.20, 1.01, 2009, FALSE, FALSE, 2),
(1109, 14, 8, 'SG', 90, 1.95, 2.00, 0.88, 2013, FALSE, FALSE, 0),
(1110, 14, 5, 'SF', 98, 2.03, 2.08, 0.92, 2014, FALSE, FALSE, 0),
(1111, 14, 15, 'PF', 104, 2.08, 2.13, 0.96, 2015, FALSE, FALSE, 0),

-- Utah Jazz (TeamID 15)
(1112, 15, 45, 'PG', 86, 1.88, 1.92, 0.90, 2011, FALSE, TRUE, 2),
(1113, 15, 27, 'SG', 92, 1.96, 2.01, 0.88, 2012, TRUE, FALSE, 1),
(1114, 15, 12, 'SF', 100, 2.03, 2.08, 0.93, 2013, FALSE, FALSE, 0),
(1115, 15, 0, 'PF', 105, 2.08, 2.13, 0.97, 2014, FALSE, FALSE, 0),
(1116, 15, 21, 'C', 110, 2.13, 2.20, 1.01, 2015, FALSE, FALSE, 2),
(1117, 15, 3, 'SG', 90, 1.95, 2.00, 0.88, 2016, FALSE, FALSE, 0),
(1118, 15, 5, 'SF', 98, 2.03, 2.08, 0.92, 2017, TRUE, FALSE, 0),
(1119, 15, 14, 'PF', 104, 2.08, 2.13, 0.96, 2018, FALSE, FALSE, 0),


-- Memphis Grizzlies (TeamID 16)
(1120, 16, 12, 'PG', 86, 1.88, 1.92, 0.90, 2018, FALSE, TRUE, 2),
(1121, 16, 24, 'SG', 92, 1.96, 2.01, 0.88, 2019, TRUE, FALSE, 1),
(1122, 16, 1, 'SF', 100, 2.03, 2.08, 0.93, 2017, TRUE, FALSE, 0),
(1123, 16, 7, 'PF', 105, 2.08, 2.13, 0.97, 2016, FALSE, FALSE, 0),
(1124, 16, 33, 'C', 110, 2.13, 2.20, 1.01, 2015, FALSE, FALSE, 2),
(1125, 16, 3, 'SG', 90, 1.95, 2.00, 0.88, 2020, FALSE, FALSE, 0),
(1126, 16, 5, 'SF', 98, 2.03, 2.08, 0.92, 2021, FALSE, FALSE, 0),
(1127, 16, 15, 'PF', 104, 2.08, 2.13, 0.96, 2022, FALSE, FALSE, 0),

-- Indiana Pacers (TeamID 17)
(1128, 17, 4, 'PG', 86, 1.88, 1.92, 0.90, 2015, TRUE, TRUE, 2),
(1129, 17, 7, 'SG', 92, 1.96, 2.01, 0.88, 2016, TRUE, FALSE, 1),
(1130, 17, 11, 'SF', 100, 2.03, 2.08, 0.93, 2014, TRUE, FALSE, 0),
(1131, 17, 10, 'PF', 105, 2.08, 2.13, 0.97, 2013, FALSE, FALSE, 0),
(1132, 17, 33, 'C', 110, 2.13, 2.20, 1.01, 2012, FALSE, FALSE, 2),
(1133, 17, 15, 'SG', 90, 1.95, 2.00, 0.88, 2017, FALSE, FALSE, 0),
(1134, 17, 8, 'SF', 98, 2.03, 2.08, 0.92, 2018, FALSE, FALSE, 0),
(1135, 17, 22, 'PF', 104, 2.08, 2.13, 0.96, 2019, FALSE, FALSE, 0),

-- Washington Wizards (TeamID 18)
(1136, 18, 3, 'PG', 86, 1.88, 1.92, 0.90, 2010, FALSE, TRUE, 3),
(1137, 18, 6, 'SG', 92, 1.96, 2.01, 0.88, 2012, FALSE, FALSE, 1),
(1138, 18, 9, 'SF', 100, 2.03, 2.08, 0.93, 2011, FALSE, FALSE, 0),
(1139, 18, 13, 'PF', 105, 2.08, 2.13, 0.97, 2013, FALSE, FALSE, 0),
(1140, 18, 21, 'C', 110, 2.13, 2.20, 1.01, 2014, FALSE, FALSE, 2),
(1141, 18, 4, 'SG', 90, 1.95, 2.00, 0.88, 2016, FALSE, FALSE, 0),
(1142, 18, 1, 'SF', 98, 2.03, 2.08, 0.92, 2017, FALSE, FALSE, 0),
(1143, 18, 22, 'PF', 104, 2.08, 2.13, 0.96, 2018, FALSE, FALSE, 0),

-- New Orleans Pelicans (TeamID 19)
(1144, 19, 1, 'PG', 86, 1.88, 1.92, 0.90, 2017, FALSE, TRUE, 2),
(1145, 19, 14, 'SG', 92, 1.96, 2.01, 0.88, 2018, FALSE, FALSE, 1),
(1146, 19, 5, 'SF', 100, 2.03, 2.08, 0.93, 2016, FALSE, FALSE, 0),
(1147, 19, 3, 'PF', 105, 2.08, 2.13, 0.97, 2015, FALSE, FALSE, 0),
(1148, 19, 17, 'C', 110, 2.13, 2.20, 1.01, 2014, FALSE, FALSE, 2),
(1149, 19, 23, 'SG', 90, 1.95, 2.00, 0.88, 2020, FALSE, FALSE, 0),
(1150, 19, 12, 'SF', 98, 2.03, 2.08, 0.92, 2019, FALSE, FALSE, 0),
(1151, 19, 34, 'PF', 104, 2.08, 2.13, 0.96, 2021, FALSE, FALSE, 0),

-- Minnesota Timberwolves (TeamID 20)
(1152, 20, 32, 'PG', 86, 1.88, 1.92, 0.90, 2015, FALSE, TRUE, 2),
(1153, 20, 22, 'SG', 92, 1.96, 2.01, 0.88, 2016, FALSE, FALSE, 1),
(1154, 20, 1, 'SF', 100, 2.03, 2.08, 0.93, 2017, FALSE, FALSE, 0),
(1155, 20, 5, 'PF', 105, 2.08, 2.13, 0.97, 2018, FALSE, FALSE, 0),
(1156, 20, 33, 'C', 110, 2.13, 2.20, 1.01, 2014, FALSE, FALSE, 2),
(1157, 20, 9, 'SG', 90, 1.95, 2.00, 0.88, 2019, FALSE, FALSE, 0),
(1158, 20, 8, 'SF', 98, 2.03, 2.08, 0.92, 2020, FALSE, FALSE, 0),
(1159, 20, 14, 'PF', 104, 2.08, 2.13, 0.96, 2021, FALSE, FALSE, 0);


INSERT INTO PlayerAwards (RecordID, PlayerID, Award, AwardYear) VALUES
-- Curry
(1, 1000, 'NBA MVP', 2015),
(2, 1000, 'NBA Three-Point Contest Champion', 2015),

-- Klay Thompson
(3, 1001, 'NBA Three-Point Contest Champion', 2016),
(4, 1001, 'NBA All-Star Selection', 2017),

-- Draymond Green
(5, 1002, 'NBA Defensive Player of the Year', 2017),
(6, 1002, 'NBA All-Defensive First Team', 2016),

-- Andrew Wiggins
(7, 1003, 'NBA All-Star Selection', 2022),
(8, 1003, 'NBA Champion', 2022),

-- Jordan Poole
(9, 1004, 'NBA Sixth Man of the Year Finalist', 2022),
(10, 1004, 'NBA Champion', 2022),

-- Kevon Looney
(11, 1005, 'NBA Champion', 2018),
(12, 1005, 'NBA Champion', 2022),

-- Jonathan Kuminga
(13, 1006, 'NBA Rising Stars Selection', 2022),
(14, 1006, 'All-Rookie Second Team', 2022),

-- Moses Moody
(15, 1007, 'NBA Rising Stars Selection', 2022),
(16, 1007, 'NBA Champion', 2022),

-- LeBron James
(17, 1008, 'NBA MVP', 2013),
(18, 1008, 'NBA Finals MVP', 2020),

-- Anthony Davis
(19, 1009, 'NBA All-Star Selection', 2021),
(20, 1009, 'NBA Champion', 2020),

-- Russell Westbrook
(21, 1010, 'NBA MVP', 2017),
(22, 1010, 'NBA All-Star Game MVP', 2015),

-- Carmelo Anthony
(23, 1011, 'NBA Scoring Champion', 2013),
(24, 1011, 'NBA All-Star Selection', 2016),

-- Austin Reaves
(25, 1012, 'NBA Rising Stars Selection', 2023),
(26, 1012, 'Team USA Selection', 2023),

-- D’Angelo Russell
(27, 1013, 'NBA All-Star Selection', 2019),
(28, 1013, 'NBA Skills Challenge Champion', 2019),

-- Troy Brown Jr.
(29, 1014, 'NBA Community Assist Nominee', 2021),
(30, 1014, 'NBA Rising Stars Participant', 2020),

-- Malik Beasley
(31, 1015, 'NBA Most Improved Finalist', 2020),
(32, 1015, 'NBA Three-Point Contest Participant', 2023),

-- Julius Randle
(33, 1016, 'NBA Most Improved Player', 2021),
(34, 1016, 'NBA All-Star Selection', 2023),

-- RJ Barrett
(35, 1017, 'NBA Rising Stars Selection', 2020),
(36, 1017, 'All-Rookie First Team', 2020),

-- Jalen Brunson
(37, 1018, 'NBA Sportsmanship Award', 2022),
(38, 1018, 'NBA All-Star Selection', 2024),

-- Mitchell Robinson
(39, 1019, 'NBA Blocks Leader Candidate', 2022),
(40, 1019, 'All-Defensive Second Team', 2023),

-- Immanuel Quickley
(41, 1020, 'NBA Sixth Man of the Year Finalist', 2022),
(42, 1020, 'NBA Skills Challenge Participant', 2022),

-- Evan Mobley
(43, 1021, 'NBA Rookie of the Year Runner-Up', 2022),
(44, 1021, 'NBA All-Defensive First Team', 2023),

-- Obi Toppin
(45, 1022, 'NBA Dunk Contest Champion', 2022),
(46, 1022, 'Rising Stars Selection', 2021),

-- Derrick Rose
(47, 1023, 'NBA MVP', 2011),
(48, 1023, 'NBA All-Star Selection', 2012),

-- Jayson Tatum
(49, 1024, 'NBA All-Star Game MVP', 2023),
(50, 1024, 'All-NBA First Team', 2022),

-- Jaylen Brown
(51, 1025, 'NBA All-Star Selection', 2023),
(52, 1025, 'All-NBA Second Team', 2023),

-- Marcus Smart
(53, 1026, 'NBA Defensive Player of the Year', 2022),
(54, 1026, 'All-Defensive First Team', 2020),

-- Al Horford
(55, 1027, 'NBA All-Star Selection', 2016),
(56, 1027, 'NBA All-Defensive Second Team', 2018),

-- Robert Williams
(57, 1028, 'All-Defensive Second Team', 2022),
(58, 1028, 'NBA Blocks Leader Candidate', 2022),

-- Derrick White
(59, 1029, 'All-Defensive Second Team', 2023),
(60, 1029, 'NBA Sportsmanship Award Nominee', 2022),

-- Grant Williams
(61, 1030, 'NBA Community Assist Award', 2022),
(62, 1030, 'NBA Three-Point Contest Participant', 2023),

-- Malcolm Brogdon
(63, 1031, 'NBA Rookie of the Year', 2017),
(64, 1031, 'NBA Sixth Man of the Year', 2023),

-- Luka Doncic
(65, 1032, 'NBA Rookie of the Year', 2019),
(66, 1032, 'All-NBA First Team', 2023),

-- Kristaps Porzingis
(67, 1033, 'NBA All-Star Selection', 2018),
(68, 1033, 'NBA Skills Challenge Participant', 2017),

-- Dorian Finney-Smith
(69, 1034, 'NBA Hustle Award Winner', 2021),
(70, 1034, 'All-Defensive Consideration', 2022),

-- Spencer Dinwiddie
(71, 1035, 'NBA Skills Challenge Champion', 2018),
(72, 1035, 'Sixth Man Candidate', 2020),

-- Reggie Bullock
(73, 1036, 'NBA Sportsmanship Award Finalist', 2021),
(74, 1036, 'NBA Social Justice Champion Finalist', 2022),

-- Tim Hardaway Jr.
(75, 1037, 'NBA Three-Point Contest Participant', 2021),
(76, 1037, 'NBA Most Improved Candidate', 2019),

-- Maxi Kleber
(77, 1038, 'NBA Blocks Leader Candidate', 2020),
(78, 1038, 'All-Defensive Consideration', 2021),

-- Jaden Hardy
(79, 1039, 'NBA Rising Stars Selection', 2023),
(80, 1039, 'G-League Ignite Recognition Award', 2022);


INSERT INTO PlayerAwards (RecordID, PlayerID, Award, AwardYear) VALUES
-- Giannis Antetokounmpo
(81, 1040, 'NBA MVP', 2020),
(82, 1040, 'NBA Defensive Player of the Year', 2020),

-- Khris Middleton
(83, 1041, 'NBA All-Star Selection', 2022),
(84, 1041, 'NBA Champion', 2021),

-- Jrue Holiday
(85, 1042, 'NBA All-Defensive First Team', 2022),
(86, 1042, 'NBA Sportsmanship Award', 2021),

-- Brook Lopez
(87, 1043, 'NBA All-Defensive First Team', 2023),
(88, 1043, 'NBA Blocks Leader', 2023),

-- Bobby Portis
(89, 1044, 'NBA Sixth Man of the Year Finalist', 2022),
(90, 1044, 'NBA Champion', 2021),

-- Pat Connaughton
(91, 1045, 'NBA Slam Dunk Contest Participant', 2020),
(92, 1045, 'NBA Champion', 2021),

-- Joe Ingles
(93, 1046, 'NBA Community Assist Award', 2021),
(94, 1046, 'NBA Teammate of the Year Finalist', 2020),

-- Grayson Allen
(95, 1047, 'NBA Three-Point Contest Participant', 2022),
(96, 1047, 'NBA Rising Stars Selection', 2019),

-- Nikola Jokic
(97, 1048, 'NBA MVP', 2022),
(98, 1048, 'NBA Finals MVP', 2023),

-- Jamal Murray
(99, 1049, 'NBA Playoffs Breakout Performance Award', 2020),
(100, 1049, 'NBA Champion', 2023),

-- Michael Porter Jr.
(101, 1050, 'NBA Rising Stars Selection', 2020),
(102, 1050, 'NBA Champion', 2023),

-- Aaron Gordon
(103, 1051, 'NBA Dunk Contest Legendary Performance', 2016),
(104, 1051, 'NBA Champion', 2023),

-- Kentavious Caldwell-Pope
(105, 1052, 'NBA Champion', 2020),
(106, 1052, 'NBA Champion', 2023),

-- Bruce Brown
(107, 1053, 'NBA Hustle Award', 2023),
(108, 1053, 'NBA Champion', 2023),

-- Jeff Green
(109, 1054, 'NBA Teammate of the Year Finalist', 2022),
(110, 1054, 'NBA Champion', 2023),

-- DeAndre Jordan
(111, 1055, 'NBA All-Star Selection', 2017),
(112, 1055, 'All-NBA First Team', 2016),

-- Kevin Durant
(113, 1056, 'NBA MVP', 2014),
(114, 1056, 'NBA Finals MVP', 2017),

-- Kyrie Irving
(115, 1057, 'NBA All-Star Game MVP', 2014),
(116, 1057, 'NBA Champion', 2016),

-- James Harden
(117, 1058, 'NBA MVP', 2018),
(118, 1058, 'NBA Scoring Champion', 2020),

-- Ben Simmons
(119, 1059, 'NBA Rookie of the Year', 2018),
(120, 1059, 'NBA All-Defensive First Team', 2020),

-- Joel Embiid
(121, 1060, 'NBA MVP', 2023),
(122, 1060, 'NBA Scoring Champion', 2023),

-- Tobias Harris
(123, 1061, 'NBA Sportsmanship Award Finalist', 2021),
(124, 1061, 'NBA Teammate of the Year Finalist', 2022),

-- Tyrese Maxey
(125, 1062, 'NBA Most Improved Player', 2024),
(126, 1062, 'NBA Rising Stars Selection', 2022),

-- Matisse Thybulle
(127, 1063, 'NBA All-Defensive Second Team', 2021),
(128, 1063, 'NBA Rising Stars Selection', 2020),

-- Jimmy Butler
(129, 1064, 'NBA Eastern Conference Finals MVP', 2022),
(130, 1064, 'All-NBA Second Team', 2021),

-- Bam Adebayo
(131, 1065, 'NBA All-Defensive First Team', 2023),
(132, 1065, 'NBA Skills Challenge Champion', 2020),

-- Tyler Herro
(133, 1066, 'NBA Sixth Man of the Year', 2022),
(134, 1066, 'NBA Rising Stars Selection', 2021),

-- Kyle Lowry
(135, 1067, 'NBA Champion', 2019),
(136, 1067, 'NBA All-Star Selection', 2020),

-- Victor Oladipo
(137, 1068, 'NBA Most Improved Player', 2018),
(138, 1068, 'NBA All-Defensive First Team', 2018),

-- Nikola Vucevic
(139, 1069, 'NBA All-Star Selection', 2021),
(140, 1069, 'NBA All-Star Selection', 2019),

-- Zach LaVine
(141, 1070, 'NBA Dunk Contest Champion', 2016),
(142, 1070, 'NBA All-Star Selection', 2022),

-- DeMar DeRozan
(143, 1071, 'All-NBA Second Team', 2018),
(144, 1071, 'NBA All-Star Selection', 2022),

-- Lonzo Ball
(145, 1072, 'NBA Rising Stars Selection', 2018),
(146, 1072, 'All-Rookie Second Team', 2018),

-- Alex Caruso
(147, 1073, 'NBA All-Defensive First Team', 2023),
(148, 1073, 'NBA Champion', 2020),

-- Nikola Mirotic
(149, 1074, 'NBA All-Rookie First Team', 2015),
(150, 1074, 'EuroLeague MVP', 2021),

-- Rudy Gobert
(151, 1075, 'NBA Defensive Player of the Year', 2021),
(152, 1075, 'NBA Rebounding Leader', 2022),

-- Donovan Mitchell
(153, 1076, 'NBA All-Star Selection', 2023),
(154, 1076, 'NBA Dunk Contest Champion', 2018),

-- Mike Conley
(155, 1077, 'NBA Sportsmanship Award', 2019),
(156, 1077, 'Teammate of the Year', 2023),

-- Danny Green
(157, 1078, 'NBA Champion', 2019),
(158, 1078, 'NBA Champion', 2020),

-- Bojan Bogdanovic
(159, 1079, 'NBA Three-Point Contest Participant', 2022),
(160, 1079, 'FIBA EuroBasket All-Tournament Team', 2013);


INSERT INTO PlayerAwards (RecordID, PlayerID, Award, AwardYear) VALUES
-- Karl-Anthony Towns
(161, 1080, 'NBA Three-Point Contest Champion', 2022),
(162, 1080, 'NBA All-Star Selection', 2023),

-- Anthony Edwards
(163, 1081, 'NBA Rising Stars Selection', 2021),
(164, 1081, 'NBA All-Star Selection', 2023),

-- Rudy Gay
(165, 1082, 'NBA All-Rookie First Team', 2007),
(166, 1082, 'NBA Sixth Man of the Year Finalist', 2017),

-- Mike Beasley
(167, 1083, 'NBA Rookie of the Month', 2009),
(168, 1083, 'NBA Rising Stars Selection', 2009),

-- D’Angelo Russell (Wolves era)
(169, 1084, 'NBA All-Star Selection', 2019),
(170, 1084, 'NBA Skills Challenge Participant', 2020),

-- Jaden McDaniels
(171, 1085, 'NBA Rising Stars Selection', 2023),
(172, 1085, 'NBA All-Defensive Second Team', 2024),

-- Naz Reid
(173, 1086, 'NBA Sixth Man of the Year', 2024),
(174, 1086, 'NBA Rising Stars Selection', 2022),

-- Taurean Prince
(175, 1087, 'NBA Rising Stars Selection', 2018),
(176, 1087, 'NBA Teammate of the Year Finalist', 2021),

-- Trae Young
(177, 1088, 'NBA All-Star Starter', 2022),
(178, 1088, 'NBA All-NBA Third Team', 2022),

-- Dejounte Murray
(179, 1089, 'NBA All-Star Selection', 2022),
(180, 1089, 'NBA Steals Leader', 2022),

-- Clint Capela
(181, 1090, 'NBA Rebounding Leader', 2021),
(182, 1090, 'NBA Blocks Leader', 2020),

-- Bogdan Bogdanovic
(183, 1091, 'NBA Rising Stars Challenge MVP', 2018),
(184, 1091, 'EuroBasket Champion', 2017),

-- De’Andre Hunter
(185, 1092, 'NBA Rising Stars Selection', 2020),
(186, 1092, 'NBA All-Rookie Second Team', 2020),

-- John Collins
(187, 1093, 'NBA Dunk Contest Participant', 2019),
(188, 1093, 'NBA Rising Stars Selection', 2018),

-- Onyeka Okongwu
(189, 1094, 'NBA Rising Stars Selection', 2022),
(190, 1094, 'Pac-12 All-Freshman Team', 2020),

-- Paul George
(191, 1095, 'NBA Most Improved Player', 2013),
(192, 1095, 'NBA All-Defensive First Team', 2014),

-- Kawhi Leonard
(193, 1096, 'NBA Finals MVP', 2019),
(194, 1096, 'NBA Defensive Player of the Year', 2016),

-- Russell Westbrook (Clippers era)
(195, 1097, 'NBA MVP', 2017),
(196, 1097, 'NBA Scoring Champion', 2015),

-- Ivica Zubac
(197, 1098, 'NBA Double-Double Leader (team)', 2023),
(198, 1098, 'NBA Rising Stars Selection', 2018),

-- Norman Powell
(199, 1099, 'NBA Champion', 2019),
(200, 1099, 'NBA Most Improved Player Finalist', 2021),

-- Pascal Siakam
(201, 1100, 'NBA Most Improved Player', 2019),
(202, 1100, 'NBA Champion', 2019),

-- Fred VanVleet
(203, 1101, 'NBA All-Star Selection', 2022),
(204, 1101, 'NBA Champion', 2019),

-- Scottie Barnes
(205, 1102, 'NBA Rookie of the Year', 2022),
(206, 1102, 'NBA Rising Stars Selection', 2023),

-- OG Anunoby
(207, 1103, 'NBA Steals Leader', 2023),
(208, 1103, 'NBA Champion', 2019),

-- Gary Trent Jr.
(209, 1104, 'NBA Steals Leader Finalist', 2022),
(210, 1104, 'NBA Most Improved Player Finalist', 2021),

-- Jakob Poeltl
(211, 1105, 'NBA Blocks Leader Finalist', 2022),
(212, 1105, 'NBA Hustle Award Finalist', 2022),

-- Bradley Beal
(213, 1106, 'NBA Scoring Leader', 2021),
(214, 1106, 'NBA All-Star Selection', 2022),

-- Kyle Kuzma
(215, 1107, 'NBA Rising Stars MVP', 2019),
(216, 1107, 'NBA Champion', 2020),

-- Kristaps Porzingis (Wizards era)
(217, 1108, 'NBA All-Star Selection', 2018),
(218, 1108, 'NBA Rising Stars Selection', 2016),

-- Montrezl Harrell
(219, 1109, 'NBA Sixth Man of the Year', 2020),
(220, 1109, 'NBA Hustle Award', 2021),

-- Rui Hachimura
(221, 1110, 'NBA Rising Stars Selection', 2020),
(222, 1110, 'NBA All-Rookie Second Team', 2020),

-- Corey Kispert
(223, 1111, 'NBA Rookie 3-PT Percentage Leader', 2022),
(224, 1111, 'NCAA First-Team All-American', 2021),

-- Buddy Hield
(225, 1112, 'NBA Three-Point Contest Winner', 2020),
(226, 1112, 'NBA Three-Point Leader', 2024),

-- Tyrese Haliburton
(227, 1113, 'NBA Assists Leader', 2024),
(228, 1113, 'NBA All-Star Starter', 2024),

-- Myles Turner
(229, 1114, 'NBA Blocks Leader', 2021),
(230, 1114, 'NBA Blocks Leader', 2019),

-- Benedict Mathurin
(231, 1115, 'NBA All-Rookie First Team', 2023),
(232, 1115, 'NBA Rising Stars Selection', 2023),

-- Andrew Nembhard
(233, 1116, 'NBA Rising Stars Selection', 2023),
(234, 1116, 'NCAA All-American Honorable Mention', 2022),

-- Jalen Smith
(235, 1117, 'NBA Rising Stars Selection', 2022),
(236, 1117, 'NBA All-Rookie Second Team', 2021),

-- TJ McConnell
(237, 1118, 'NBA Hustle Award', 2024),
(238, 1118, 'NBA Steals Leader Finalist', 2021),

-- Bruce Brown (Pacers era)
(239, 1119, 'NBA Champion', 2023),
(240, 1119, 'NBA Hustle Award Finalist', 2022);


-- Enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

