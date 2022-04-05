CREATE TABLE user_profile (
    user_id text,
    phone_no text,
    username text,
    upi_id text,
    PRIMARY KEY (user_id)
);

CREATE TABLE event_details (
    event_id text,
    event_detail text,
    event_participants tuple<text, int>,
    event_time int,
    PRIMARY KEY (event_id)
);

CREATE TABLE split_bills (
    from_user_id text,
    to_user_id text,
    event_ids list<text>,
    PRIMARY KEY ((from_user_id, to_user_id))
);

CREATE TABLE transaction_history (
    transaction_id text,
    transaction_time int,
    amount int,
    PRIMARY KEY (transaction_id)
);

CREATE TABLE personal_expense (
    username text,
    amount int,
    event_id text,
    PRIMARY KEY (event_id)
);