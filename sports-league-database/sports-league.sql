-- ====================================================================
-- PROJECT: Relational Database Design & Sports Analytics
-- DBMS: Oracle SQL
-- ====================================================================

-- 1. DROP TABLES (Ensures script can be re-run cleanly)
DROP TABLE AllocatedCard CASCADE CONSTRAINTS;
DROP TABLE GameReferee CASCADE CONSTRAINTS;
DROP TABLE ScoredGoal CASCADE CONSTRAINTS;
DROP TABLE TeamGameResult CASCADE CONSTRAINTS;
DROP TABLE GamePlayer CASCADE CONSTRAINTS;
DROP TABLE ClubGame CASCADE CONSTRAINTS;
DROP TABLE Player CASCADE CONSTRAINTS;
DROP TABLE Team CASCADE CONSTRAINTS;
DROP TABLE Game CASCADE CONSTRAINTS;
DROP TABLE Ground CASCADE CONSTRAINTS;
DROP TABLE Club CASCADE CONSTRAINTS;
DROP TABLE Referee CASCADE CONSTRAINTS;
DROP TABLE Coach CASCADE CONSTRAINTS;
DROP TABLE Lesson CASCADE CONSTRAINTS;
DROP TABLE Result CASCADE CONSTRAINTS;

-- 2. CREATE TABLES
CREATE TABLE Lesson (
    weekID            CHAR(7) PRIMARY KEY,
    weekDescript      VARCHAR2(10),
    weekStartDate     DATE,
    weekEndDate       DATE
);

CREATE TABLE Coach (
    coachID           CHAR(8) PRIMARY KEY,
    coachFirstName    VARCHAR2(10),
    coachLastName     VARCHAR2(12),
    phoneNo           VARCHAR2(10)
);

CREATE TABLE Club (
    clubID            CHAR(7) PRIMARY KEY,
    clubName          VARCHAR2(30),
    suburb            VARCHAR2(15),
    postcode          CHAR(4)
);

CREATE TABLE Ground (
    groundID          CHAR(6) PRIMARY KEY,
    groundName        VARCHAR2(30),
    groundCapacity    NUMBER(5),
    clubID            CHAR(7),
    CONSTRAINT fk_ground_club FOREIGN KEY (clubID) REFERENCES Club(clubID)
);

CREATE TABLE Game (
    gameID            CHAR(7) PRIMARY KEY,
    gameDate          DATE,
    weekID            CHAR(7),
    groundID          CHAR(6),
    CONSTRAINT fk_game_week FOREIGN KEY (weekID) REFERENCES Lesson(weekID),
    CONSTRAINT fk_game_ground FOREIGN KEY (groundID) REFERENCES Ground(groundID)
);

CREATE TABLE Team (
    teamID            CHAR(5) PRIMARY KEY,
    teamName          VARCHAR2(20),
    teamGender        CHAR(1),
    clubID            CHAR(7),
    coachID           CHAR(8),
    CONSTRAINT fk_team_club FOREIGN KEY (clubID) REFERENCES Club(clubID),
    CONSTRAINT fk_team_coach FOREIGN KEY (coachID) REFERENCES Coach(coachID)
);

CREATE TABLE Player (
    playerID          CHAR(6) PRIMARY KEY,
    playerFirstName   VARCHAR2(10),
    playerLastName    VARCHAR2(12),
    teamID            CHAR(5),
    CONSTRAINT fk_player_team FOREIGN KEY (teamID) REFERENCES Team(teamID)
);

CREATE TABLE GamePlayer (
    gamePlayerID      CHAR(9) PRIMARY KEY,
    role              VARCHAR2(25),
    gameID            CHAR(7),
    playerID          CHAR(6),
    CONSTRAINT fk_gp_game FOREIGN KEY (gameID) REFERENCES Game(gameID),
    CONSTRAINT fk_gp_player FOREIGN KEY (playerID) REFERENCES Player(playerID)
);

CREATE TABLE Result (
    resultID          CHAR(7) PRIMARY KEY,
    resDescript       VARCHAR2(10),
    resPoints         NUMBER(1)
);

CREATE TABLE Referee (
    refereeID         CHAR(6) PRIMARY KEY,
    refereeFirstName  VARCHAR2(10),
    refereeLastName   VARCHAR2(12)
);

CREATE TABLE GameReferee (
    gameRefereeID     CHAR(8) PRIMARY KEY,
    role              VARCHAR2(25),
    gameID            CHAR(7),
    refereeID         CHAR(6),
    CONSTRAINT fk_gr_game FOREIGN KEY (gameID) REFERENCES Game(gameID),
    CONSTRAINT fk_gr_referee FOREIGN KEY (refereeID) REFERENCES Referee(refereeID)
);

CREATE TABLE AllocatedCard (
    allocatedCardID       CHAR(7) PRIMARY KEY,
    allocatedCardDescript VARCHAR2(6),
    gamePlayerID          CHAR(9),
    gameRefereeID         CHAR(8),
    CONSTRAINT fk_ac_gp FOREIGN KEY (gamePlayerID) REFERENCES GamePlayer(gamePlayerID),
    CONSTRAINT fk_ac_gr FOREIGN KEY (gameRefereeID) REFERENCES GameReferee(gameRefereeID)
);

-- 3. INSERT MOCK DATA (DML - Fixed quotes & syntax)
INSERT INTO Referee VALUES ('ref001', 'Sam', 'Smith');
INSERT INTO Lesson VALUES ('week001', 'Week 1', TO_DATE('2024-07-01', 'YYYY-MM-DD'), TO_DATE('2024-07-07', 'YYYY-MM-DD'));
INSERT INTO Club VALUES ('club001', 'Perth Glory', 'East Perth', '6004');
INSERT INTO Ground VALUES ('grnd01', 'HBF Park', 20500, 'club001');
INSERT INTO Game VALUES ('game001', TO_DATE('2024-07-06', 'YYYY-MM-DD'), 'week001', 'grnd01');
INSERT INTO Team VALUES ('team1', 'Glory Men', 'M', 'club001', 'co000001');
INSERT INTO Player VALUES ('pl0001', 'John', 'Doe', 'team1');
INSERT INTO GamePlayer VALUES ('gplay0001', 'Striker', 'game001', 'pl0001');
INSERT INTO Referee VALUES ('ref008', 'Alex', 'Green');
INSERT INTO GameReferee VALUES ('gmref008', 'Main', 'game001', 'ref008');
INSERT INTO AllocatedCard VALUES ('card001', 'Yellow', 'gplay0001', 'gmref008');

-- 4. PRODUCTION READINESS: PERFORMANCE INDEXING (Highly valued in AU)
CREATE INDEX idx_gameplayer_game ON GamePlayer(gameID);
CREATE INDEX idx_allocatedcard_gp ON AllocatedCard(gamePlayerID);

-- 5. ADVANCED BI ANALYTICAL QUERIES
-- Query: Player Discipline Analysis (Most penalised player)
SELECT p.playerID AS "Player ID", 
       p.playerFirstName || ' ' || p.playerLastName AS "Player Name",
       SUM(CASE WHEN ac.allocatedCardDescript = 'Yellow' THEN 1 ELSE 0 END) AS "Yellow Cards",
       SUM(CASE WHEN ac.allocatedCardDescript = 'Red' THEN 1 ELSE 0 END) AS "Red Cards",
       COUNT(ac.allocatedCardID) AS "Total Cards"
FROM Player p
JOIN GamePlayer gp ON p.playerID = gp.playerID
JOIN AllocatedCard ac ON gp.gamePlayerID = ac.gamePlayerID
GROUP BY p.playerID, p.playerFirstName, p.playerLastName
ORDER BY "Total Cards" DESC
FETCH FIRST 1 ROWS ONLY;
