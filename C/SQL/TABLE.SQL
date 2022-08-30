CREATE TABLE telephely (
    tazon     NUMBER (2)   NOT NULL,
    tcim      CHAR   (30),
    ttel      CHAR   (7));

CREATE TABLE beosztas (
    bazon     NUMBER (2)   NOT NULL,
    bnev      CHAR   (30),
    bfizetes  NUMBER (8));

CREATE TABLE dolgozo (
    dszsz     CHAR   (11)  NOT NULL,
    dnev      CHAR   (30),
    dcim      CHAR   (30),
    dtel      CHAR   (7),
    tazon     NUMBER (2)   NOT NULL,
    bazon     NUMBER (2)   NOT NULL);

CREATE TABLE uzlet (
    dszsz     CHAR   (11)  NOT NULL,
    udatum    DATE,
    uazon     CHAR (10));
