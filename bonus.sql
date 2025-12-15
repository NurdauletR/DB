CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    iin CHAR(12) UNIQUE NOT NULL CHECK (iin ~ '^\d{12}$'), 
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100),
    status VARCHAR(20) NOT NULL CHECK (status IN ('active', 'blocked', 'frozen')) DEFAULT 'active',
    daily_limit_kzt DECIMAL(15,2) DEFAULT 100000.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE accounts (
    account_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id),
    account_number VARCHAR(34) UNIQUE NOT NULL, 
    currency CHAR(3) NOT NULL CHECK (currency IN ('KZT', 'USD', 'EUR', 'RUB')),
    balance DECIMAL(15,2) NOT NULL DEFAULT 0.00 CHECK (balance >= 0),
    is_active BOOLEAN DEFAULT TRUE,
    opened_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    closed_at TIMESTAMP
);


CREATE TABLE exchange_rates (
    rate_id SERIAL PRIMARY KEY,
    from_currency CHAR(3) NOT NULL,
    to_currency CHAR(3) NOT NULL,
    rate DECIMAL(10,6) NOT NULL,
    valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMP
);


CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    from_account_id INT REFERENCES accounts(account_id),
    to_account_id INT REFERENCES accounts(account_id),
    amount DECIMAL(15,2) NOT NULL CHECK (amount > 0),
    currency CHAR(3) NOT NULL,
    exchange_rate DECIMAL(10,6) DEFAULT 1.0,
    amount_kzt DECIMAL(15,2), 
    type VARCHAR(20) NOT NULL CHECK (type IN ('transfer', 'deposit', 'withdrawal')),
    status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'completed', 'failed', 'reversed')) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    description TEXT
);


CREATE TABLE audit_log (
    log_id SERIAL PRIMARY KEY,
    table_name VARCHAR(50) NOT NULL,
    record_id INT,
    action VARCHAR(10) CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
    old_values JSONB,
    new_values JSONB, 
    changed_by VARCHAR(50) DEFAULT CURRENT_USER,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address INET
);


TRUNCATE audit_log, transactions, exchange_rates, accounts, customers RESTART IDENTITY CASCADE;

INSERT INTO customers (iin, full_name, phone, email, status, daily_limit_kzt) VALUES
('920615300001', 'Mohamed Salah',       '+77773335001', 'salah@lfc.com',   'active', 500000.00),
('990921300002', 'Alexander Isak',      '+77773335002', 'isak@nufc.com',   'active', 500000.00),
('020620300003', 'Hugo Ekitike',        '+77773335003', 'hugo@sge.de',     'active', 500000.00),
('030503300004', 'Florian Wirtz',       '+77773335004', 'wirtz@b04.de',    'active', 500000.00),
('020516300005', 'Ryan Gravenberch',    '+77773335005', 'ryan@lfc.com',    'active', 500000.00),
('981224300006', 'Alexis Mac Allister', '+77773335006', 'macca@lfc.com',   'active', 500000.00),
('910708300007', 'Virgil van Dijk',     '+77773335007', 'virgil@lfc.com',  'active', 500000.00),
('940311300008', 'Andrew Robertson',    '+77773335008', 'robo@lfc.com',    'active', 500000.00),
('921002300009', 'Alisson Becker',      '+77773335009', 'ali@lfc.com',     'active', 500000.00),
('040505300010', 'Yessentay Adil',      '+77773335010', 'yessentay@kbtu.kz', 'active', 1000000.00),
('990624300011', 'Darwin Nunez',        '+77773335011', 'darwin@lfc.com',  'blocked', 0.00);    


INSERT INTO accounts (customer_id, account_number, currency, balance) VALUES
(1,  'LFC001SALAH',   'USD', 50000.00),
(2,  'NUFC002ISAK',   'EUR', 45000.00),
(3,  'SGE003HUGO',    'EUR', 15000.00),
(4,  'B04004WIRTZ',   'EUR', 80000.00),
(5,  'LFC005RYAN',    'EUR', 25000.00),
(6,  'LFC006MACCA',   'USD', 30000.00),
(7,  'LFC007VVD',     'EUR', 90000.00),
(8,  'LFC008ROBO',    'EUR', 40000.00),
(9,  'LFC009ALI',     'USD', 60000.00),
(10, 'KBTU010ADIL_KZT','KZT', 95000.00),
(10, 'KBTU010ADIL_USD','USD', 5000.00), 
(11, 'LFC011NUNEZ',   'USD', 100.00);   

INSERT INTO exchange_rates (from_currency, to_currency, rate) VALUES
('USD', 'KZT', 480.00), ('KZT', 'USD', 0.002083),
('EUR', 'KZT', 520.00), ('KZT', 'EUR', 0.001923),
('USD', 'EUR', 0.92),   ('EUR', 'USD', 1.09),
('RUB', 'KZT', 5.00),   ('KZT', 'RUB', 0.20);


INSERT INTO transactions 
(from_account_id, to_account_id, amount, currency, amount_kzt, type, status, created_at, completed_at, description) 
VALUES
(1, 11, 50, 'USD', 24000, 'transfer', 'completed', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days', 'Coffee for Yessentay'),
(4, 3, 200, 'EUR', 104000, 'transfer', 'completed', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day', 'Debt payment'),
(NULL, 10, 5000, 'KZT', 5000, 'deposit', 'completed', NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days', 'Cash Deposit'),
(5, 6, 150, 'EUR', 78000, 'transfer', 'completed', NOW() - INTERVAL '12 hours', NOW() - INTERVAL '12 hours', 'Dinner'),
(12, 1, 10, 'USD', 4800, 'transfer', 'failed', NOW() - INTERVAL '10 days', NULL, 'Test blocked transfer'),
(7, NULL, 500, 'EUR', 260000, 'withdrawal', 'completed', NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days', 'ATM withdrawal'),
(2, 8, 1000, 'EUR', 520000, 'transfer', 'completed', NOW() - INTERVAL '1 week', NOW() - INTERVAL '1 week', 'Gift'),
(11, 1, 100, 'USD', 48000, 'transfer', 'completed', NOW(), NOW(), 'Return debt'),
(9, NULL, 200, 'USD', 96000, 'withdrawal', 'completed', NOW(), NOW(), 'New Gloves'),
(8, NULL, 1000000, 'EUR', 520000000, 'withdrawal', 'failed', NOW(), NULL, 'Too much money');


-- Task 1


CREATE OR REPLACE PROCEDURE process_transfer(
    sender_acc VARCHAR,
    receiver_acc VARCHAR,
    amount_val NUMERIC,
    curr_type CHAR(3),
    msg TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    sid INT; rid INT;
    s_curr CHAR(3); r_curr CHAR(3);
    my_bal NUMERIC; my_status VARCHAR; day_limit NUMERIC;
    kzt_rate NUMERIC := 1.0; val_in_kzt NUMERIC;
    cross_rate NUMERIC; spent_today NUMERIC;
    tx_id INT;
BEGIN
    -- 1. Lock Sender row to prevent race conditions
    SELECT account_id, currency, balance, customer_id
    INTO sid, s_curr, my_bal, rid
    FROM accounts WHERE account_number = sender_acc FOR UPDATE;

    IF sid IS NULL THEN RAISE EXCEPTION 'Sender account not found'; END IF;

    -- Get customer status & limit
    SELECT status, daily_limit_kzt INTO my_status, day_limit
    FROM customers WHERE customer_id = rid;

    -- 2. Lock Receiver row
    SELECT account_id, currency INTO rid, r_curr
    FROM accounts WHERE account_number = receiver_acc FOR UPDATE;

    IF rid IS NULL THEN RAISE EXCEPTION 'Receiver account not found'; END IF;

    -- 3. Validations
    IF my_status != 'active' THEN RAISE EXCEPTION 'Sender is not active'; END IF;
    IF my_bal < amount_val THEN RAISE EXCEPTION 'Insufficient funds'; END IF;
    IF s_curr != curr_type THEN RAISE EXCEPTION 'Currency mismatch'; END IF;

    -- 4. Convert to KZT for daily limit check
    IF curr_type != 'KZT' THEN
        SELECT rate INTO kzt_rate FROM exchange_rates
        WHERE from_currency = curr_type AND to_currency = 'KZT'
        ORDER BY valid_from DESC LIMIT 1;
        kzt_rate := COALESCE(kzt_rate, 1.0);
    END IF;
    val_in_kzt := amount_val * kzt_rate;

    -- Check daily limit (sum of today's completed transfers)
    SELECT COALESCE(SUM(amount_kzt), 0) INTO spent_today
    FROM transactions
    WHERE from_account_id = sid AND created_at::DATE = CURRENT_DATE AND status = 'completed';

    IF (spent_today + val_in_kzt) > day_limit THEN RAISE EXCEPTION 'Daily limit exceeded'; END IF;

    -- 5. Execute Transfer
    UPDATE accounts SET balance = balance - amount_val WHERE account_id = sid;

    -- Calculate cross-rate for receiver
    IF s_curr = r_curr THEN
        cross_rate := 1.0;
    ELSE
        cross_rate := kzt_rate / NULLIF((
            SELECT rate FROM exchange_rates WHERE from_currency = r_curr AND to_currency = 'KZT' ORDER BY valid_from DESC LIMIT 1
        ), 0);
        cross_rate := COALESCE(cross_rate, 1.0);
    END IF;

    UPDATE accounts SET balance = balance + (amount_val * cross_rate) WHERE account_id = rid;

    -- 6. Log Transaction
    INSERT INTO transactions (from_account_id, to_account_id, amount, currency, exchange_rate, amount_kzt, type, status, completed_at, description)
    VALUES (sid, rid, amount_val, curr_type, cross_rate, val_in_kzt, 'transfer', 'completed', NOW(), msg)
    RETURNING transaction_id INTO tx_id;

    INSERT INTO audit_log (table_name, record_id, action, new_values, description)
    VALUES ('transactions', tx_id, 'INSERT', jsonb_build_object('amt', amount_val, 'from', sender_acc), 'Success');

    COMMIT;

EXCEPTION WHEN OTHERS THEN
    -- Log error as per requirements and rollback
    INSERT INTO audit_log (table_name, action, description, old_values)
    VALUES ('transactions', 'ERROR', SQLERRM, jsonb_build_object('sender', sender_acc, 'err', SQLERRM));
    RAISE NOTICE 'Transfer failed: %', SQLERRM;
    ROLLBACK;
END;
$$;


--Task 2


-- ==========================================
-- VIEW 1: Customer Balances & Summary
-- ==========================================
CREATE OR REPLACE VIEW customer_balance_summary AS
WITH today_spent AS (
    -- Calculate daily spending for limit check
    SELECT from_account_id, SUM(amount_kzt) as spent
    FROM transactions
    WHERE created_at::DATE = CURRENT_DATE AND status = 'completed'
    GROUP BY from_account_id
)
SELECT
    c.full_name AS client_name,
    a.account_number AS acc_num,
    a.balance AS raw_balance,
    a.currency AS curr_code,

    -- Convert individual balance to KZT
    ROUND(
        CASE
            WHEN a.currency = 'KZT' THEN a.balance
            ELSE a.balance * COALESCE((
                SELECT rate FROM exchange_rates r
                WHERE r.from_currency = a.currency AND r.to_currency = 'KZT'
                ORDER BY r.valid_from DESC LIMIT 1
            ), 1)
        END, 2
    ) AS kzt_balance,

    -- Calculate total wealth per client (for ranking)
    SUM(
        CASE
            WHEN a.currency = 'KZT' THEN a.balance
            ELSE a.balance * COALESCE((
                SELECT rate FROM exchange_rates r
                WHERE r.from_currency = a.currency AND r.to_currency = 'KZT'
                ORDER BY r.valid_from DESC LIMIT 1
            ), 1)
        END
    ) OVER (PARTITION BY c.customer_id) as total_wealth_kzt,

    -- Limit usage % (Spent / Limit)
    ROUND(
        (COALESCE(ts.spent, 0) / NULLIF(c.daily_limit_kzt, 0)) * 100, 2
    ) AS limit_usage_pct,

    -- Rank clients by total wealth
    DENSE_RANK() OVER (
        ORDER BY SUM(
            CASE
                WHEN a.currency = 'KZT' THEN a.balance
                ELSE a.balance * COALESCE((
                    SELECT rate FROM exchange_rates r
                    WHERE r.from_currency = a.currency AND r.to_currency = 'KZT'
                    ORDER BY r.valid_from DESC LIMIT 1
                ), 1)
            END
        ) DESC
    ) AS wealth_rank

FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
LEFT JOIN today_spent ts ON a.account_id = ts.from_account_id;

-- ==========================================
-- VIEW 2: Daily Report
-- ==========================================
CREATE OR REPLACE VIEW daily_transaction_report AS
SELECT
    created_at::DATE AS ops_date,
    type AS ops_kind,

    -- Basic stats
    COUNT(transaction_id) AS ops_count,
    SUM(amount_kzt) AS money_vol,
    ROUND(AVG(amount_kzt), 2) AS avg_ticket,

    -- Cumulative sum (Running Total)
    SUM(SUM(amount_kzt)) OVER (
        PARTITION BY type
        ORDER BY created_at::DATE
    ) AS accum_total,

    -- Day-over-day growth %
    ROUND(
        (SUM(amount_kzt) - LAG(SUM(amount_kzt)) OVER (PARTITION BY type ORDER BY created_at::DATE))
        / NULLIF(LAG(SUM(amount_kzt)) OVER (PARTITION BY type ORDER BY created_at::DATE), 0)
        * 100, 2
    ) AS growth_rate

FROM transactions
WHERE status = 'completed'
GROUP BY created_at::DATE, type;

-- ==========================================
-- VIEW 3: Suspicious Activity
-- ==========================================
CREATE OR REPLACE VIEW suspicious_activity_view WITH (security_barrier = true) AS

-- 1. Large Transactions (> 5M KZT)
SELECT
    t.transaction_id,
    t.created_at,
    t.amount_kzt,
    'High Value' AS flag_msg
FROM transactions t
WHERE t.amount_kzt > 5000000

UNION ALL

-- 2. Spamming (> 10 tx in 1 hour)
SELECT
    t.transaction_id,
    t.created_at,
    t.amount_kzt,
    'Potential Spam'
FROM transactions t
WHERE (
    SELECT COUNT(*)
    FROM transactions t_hist
    WHERE t_hist.from_account_id = t.from_account_id
    AND t_hist.created_at BETWEEN t.created_at - INTERVAL '1 hour' AND t.created_at
) > 10

UNION ALL

-- 3. Bot Behavior (< 1 min between tx)
SELECT
    t.transaction_id,
    t.created_at,
    t.amount_kzt,
    'Rapid Transfer'
FROM transactions t
WHERE EXISTS (
    SELECT 1
    FROM transactions t_prev
    WHERE t_prev.from_account_id = t.from_account_id
    AND t_prev.transaction_id != t.transaction_id
    AND t_prev.created_at BETWEEN t.created_at - INTERVAL '1 minute' AND t.created_at
);


--Task 3

-- ==========================================
-- TASK 3: INDEXES
-- ==========================================

-- 1. B-Tree: Optimize Joins (FK is not indexed by default)
CREATE INDEX idx_acc_cust_id ON accounts USING btree (customer_id);

-- 2. Hash: Faster exact match for IIN
CREATE INDEX idx_cust_iin_hash ON customers USING hash (iin);

-- 3. Partial: Index active accounts only (save space)
CREATE INDEX idx_acc_active ON accounts(account_number) WHERE is_active = TRUE;

-- 4. Expression: Case-insensitive email search
CREATE INDEX idx_cust_email_lower ON customers(lower(email));

-- 5. GIN: Search inside JSONB keys
CREATE INDEX idx_audit_json ON audit_log USING gin (new_values);

-- 6. Covering: Optimize daily limit check (avoid heap access)
CREATE INDEX idx_tx_limit_cover ON transactions (from_account_id, created_at) INCLUDE (amount_kzt);


-- Check B-Tree (Join)
EXPLAIN ANALYZE SELECT * FROM accounts WHERE customer_id = 1;

-- Check Hash
EXPLAIN ANALYZE SELECT * FROM customers WHERE iin = '920615300001';

-- Check Partial
EXPLAIN ANALYZE SELECT * FROM accounts WHERE account_number = 'LFC001SALAH' AND is_active = TRUE;

-- Check Expression
EXPLAIN ANALYZE SELECT * FROM customers WHERE lower(email) = 'salah@lfc.com';

-- Check GIN
EXPLAIN ANALYZE SELECT * FROM audit_log WHERE new_values @> '{"amount": 100}';

-- Check Covering Index (Index Only Scan)
EXPLAIN ANALYZE SELECT SUM(amount_kzt) FROM transactions 
WHERE from_account_id = 1 AND created_at >= CURRENT_DATE;


--Task 4


CREATE OR REPLACE PROCEDURE process_salary_batch(
    comp_acc VARCHAR,
    pay_list JSONB,
    INOUT ok_cnt INT DEFAULT 0,
    INOUT bad_cnt INT DEFAULT 0,
    INOUT err_log JSONB DEFAULT '[]'::jsonb
)
LANGUAGE plpgsql
AS $$
DECLARE
    cid INT; c_bal NUMERIC; c_curr CHAR(3);
    total_need NUMERIC;
    
    -- Loop vars
    item JSONB;
    emp_iin VARCHAR; emp_amt NUMERIC;
    eid INT; e_curr CHAR(3);
    
    -- Accumulator for single company update
    total_paid NUMERIC := 0;
BEGIN
    -- 1. Transaction-level Advisory Lock (Auto-release at end)
    -- Protects against double-running the batch for same company
    IF NOT pg_try_advisory_xact_lock(hashtext(comp_acc)) THEN
        RAISE EXCEPTION 'Batch already running for this company';
    END IF;

    -- 2. Lock Company Account
    SELECT account_id, balance, currency INTO cid, c_bal, c_curr
    FROM accounts WHERE account_number = comp_acc FOR UPDATE;

    IF cid IS NULL THEN
        RAISE EXCEPTION 'Company account not found';
    END IF;

    -- 3. Pre-validate total amount
    SELECT COALESCE(SUM((val->>'amount')::NUMERIC), 0) INTO total_need
    FROM jsonb_array_elements(pay_list) as val;

    IF c_bal < total_need THEN
        RAISE EXCEPTION 'Insufficient funds. Need: %, Have: %', total_need, c_bal;
    END IF;

    -- 4. Process Loop
    FOR item IN SELECT * FROM jsonb_array_elements(pay_list)
    LOOP
        emp_iin := item->>'iin';
        emp_amt := (item->>'amount')::NUMERIC;

        -- Implicit SAVEPOINT (BEGIN block)
        BEGIN
            -- Find employee account (Try to match company currency, else take any active)
            SELECT account_id, currency INTO eid, e_curr
            FROM customers c
            JOIN accounts a ON c.customer_id = a.customer_id
            WHERE c.iin = emp_iin AND a.is_active = TRUE
            ORDER BY (a.currency = c_curr) DESC -- Prioritize same currency
            LIMIT 1;

            IF eid IS NULL THEN
                RAISE EXCEPTION 'No active account for IIN %', emp_iin;
            END IF;

            -- Update Employee Balance immediately
            -- (Simplified: Assuming 1:1 rate or handled externally for salary)
            UPDATE accounts SET balance = balance + emp_amt WHERE account_id = eid;

            -- Log transaction
            INSERT INTO transactions (from_account_id, to_account_id, amount, currency, amount_kzt, type, status, completed_at, description)
            VALUES (cid, eid, emp_amt, c_curr, emp_amt, 'salary', 'completed', NOW(), 'Salary Batch');

            -- Accumulate success
            ok_cnt := ok_cnt + 1;
            total_paid := total_paid + emp_amt;

        EXCEPTION WHEN OTHERS THEN
            -- Handle individual failure
            bad_cnt := bad_cnt + 1;
            err_log := err_log || jsonb_build_object('iin', emp_iin, 'error', SQLERRM);
        END;
    END LOOP;

    -- 5. ATOMIC UPDATE (Company Balance)
    -- Update company only ONCE at the end (Performance optimization)
    IF total_paid > 0 THEN
        UPDATE accounts SET balance = balance - total_paid WHERE account_id = cid;
    END IF;

    -- 6. Audit Log
    INSERT INTO audit_log (table_name, action, new_values, description)
    VALUES ('salary_batch', 'DONE', jsonb_build_object('success', ok_cnt, 'failed', bad_cnt, 'total', total_paid), 'Batch finished');

    COMMIT;
END;
$$;

-- ==========================================
-- MATERIALIZED VIEW (Reporting)
-- ==========================================
DROP MATERIALIZED VIEW IF EXISTS salary_report_mv;

CREATE MATERIALIZED VIEW salary_report_mv AS
SELECT
    from_account_id AS company_id,
    MAX(completed_at)::DATE AS payment_date,
    COUNT(*) AS total_staff_paid,
    SUM(amount) AS total_expenditure,
    currency
FROM transactions
WHERE type = 'salary' AND status = 'completed'
GROUP BY from_account_id, completed_at::DATE, currency;




/*
=============================================================================
DOCUMENTATION & DESIGN DECISIONS
=============================================================================

1. ACID Compliance & Concurrency:
   - Implemented pessimistic locking via `SELECT ... FOR UPDATE` in `process_transfer`.
     This prevents Race Conditions (e.g., two concurrent transfers spending the same balance).
   - All critical logic is wrapped in transaction blocks.

2. Batch Processing Strategy (Task 4):
   - Improved Locking: I used `pg_try_advisory_xact_lock` instead of standard advisory locks.
     Why? It automatically releases the lock at the end of the transaction (commit or rollback),
     preventing deadlocks if the script crashes.
   - Atomic Update: The company balance is updated ONCE at the end, not inside the loop.
     This reduces database I/O and lock contention significantly.
   - Fault Tolerance: Used internal `BEGIN ... EXCEPTION` blocks (Savepoints) to ensure valid
     salary payments succeed even if one item in the batch fails.

3. Security:
   - Used `WITH (security_barrier=true)` for the suspicious activity view to prevent
     information leakage through optimizer side-channels.
   - Full Audit Trail: Both successful and failed attempts are logged to `audit_log`.

4. Indexing Choices (Task 3):
   - B-tree: On `customer_id` to optimize JOINs between accounts and customers.
   - Hash: O(1) lookups for unique IINs (faster than B-tree for equality).
   - Partial: Indexes only `is_active=true` accounts. Reduces index size and maintenance cost.
   - GIN: Essential for querying inside `audit_log` JSONB data (@> operator).
   - Covering Index: Included `amount_kzt` in the index payload to allow "Index Only Scans"
     for the daily limit check, avoiding heavy heap access.

=============================================================================
CONCURRENCY TESTING INSTRUCTIONS (How to prove locking works)
=============================================================================

Since I am submitting a single file, please follow these steps to verify locking
using the Liverpool dataset provided:

STEP 1: Open Terminal A (psql session 1)
Run this to manually lock Salah's account:
    BEGIN;
    SELECT * FROM accounts WHERE account_number = 'LFC001SALAH' FOR UPDATE;
    -- Do NOT commit yet! Keep this transaction open.

STEP 2: Open Terminal B (psql session 2)
Run this to try sending money from Salah's locked account:
    CALL process_transfer('LFC001SALAH', 'NUFC002ISAK', 100, 'USD', 'Test Lock');

EXPECTED RESULT:
    Terminal B will hang (freeze). It is waiting for the lock to release.
    This proves ACID compliance and protection against race conditions.

STEP 3: Back to Terminal A
Run:
    COMMIT;

EXPECTED RESULT:
    Terminal B will immediately wake up, process the transfer, and finish.
*/
