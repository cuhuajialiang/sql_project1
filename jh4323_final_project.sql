##########################
#      Final Project     #
##########################

# Create schema
CREATE SCHEMA chronic_pain;

# Apply all code to the new schema
USE chronic_pain;

# Create participants table and indexes
CREATE TABLE participants (
	PRIMARY KEY (participant_id),
    participant_id SMALLINT UNSIGNED AUTO_INCREMENT,
    date_of_birth DATE,
    date_of_enroll DATE,
    gender TINYINT UNSIGNED,
    tx_group TINYINT UNSIGNED,
    edu_level TINYINT UNSIGNED,
    married TINYINT UNSIGNED,
    race TINYINT UNSIGNED,
    employment TINYINT UNSIGNED,
    socio_eco_sts TINYINT UNSIGNED,
    yrs_of_pain FLOAT
);

CREATE INDEX tx_group
	ON participants(tx_group);

# Create child table visits and indexes
CREATE TABLE visits (
	PRIMARY KEY (visit_id),
    visit_id SMALLINT UNSIGNED AUTO_INCREMENT,
    participant_id SMALLINT UNSIGNED,
    visit_date DATE,
    pain_intensity TINYINT UNSIGNED,
    pain_location VARCHAR(45),
    days_in_pain TINYINT UNSIGNED,
    exercise TINYINT UNSIGNED,
    curr_opioid VARCHAR(45),
    disab_index TINYINT UNSIGNED,
    depress_score TINYINT UNSIGNED,
    anger_score TINYINT UNSIGNED,
    anxiety_score TINYINT UNSIGNED,
    sleep_score TINYINT UNSIGNED,
    FOREIGN KEY (participant_id) REFERENCES participants(participant_id)
);

CREATE UNIQUE INDEX visit_unique
	ON visits(participant_id, visit_date);

CREATE INDEX visit_date
	ON visits(visit_date);
    
CREATE INDEX pain_intensity
	ON visits(pain_intensity);

CREATE INDEX days_in_pain
	ON visits(days_in_pain);

# Create brain locations lookup table
CREATE TABLE brain_locations (
	PRIMARY KEY (brain_loc_id),
    brain_loc_id TINYINT UNSIGNED AUTO_INCREMENT,
    location VARCHAR(45)
);

# Create second child table fmris and indexes
CREATE TABLE fmris (
	PRIMARY KEY (fmri_id),
    fmri_id SMALLINT UNSIGNED AUTO_INCREMENT,
    participant_id SMALLINT UNSIGNED,
    fmri_date DATE,
    brain_loc_id TINYINT UNSIGNED,
    activation_vol FLOAT,
    FOREIGN KEY (participant_id) REFERENCES participants(participant_id),
    FOREIGN KEY (brain_loc_id) REFERENCES brain_locations(brain_loc_id)
);

CREATE UNIQUE INDEX fmri_unique
	ON fmris(participant_id, fmri_date, brain_loc_id);
    
CREATE INDEX fmri_date
	ON fmris(fmri_date);
    
CREATE INDEX activation_vol
	ON fmris(activation_vol);


#####################################
#             TRIGGERS              #
#####################################

# Add trigger for the participants table
DELIMITER //

CREATE TRIGGER trigger_participants
	BEFORE INSERT ON participants
    FOR EACH ROW
BEGIN
	/* The trial began on 2013-01-01, and the age range of the patients is 21 to 70 years.
    So the DOB should be between 1943-01-01 and 1992-01-01 */
	IF NEW.date_of_birth NOT BETWEEN '1943-01-01' AND '1992-01-01' THEN
		SIGNAL SQLSTATE 'HY000'
        SET MESSAGE_TEXT = 'Error: birthday must be between 1943-01-01 and 1992-01-01';
	END IF;
    
    /* Limit date_of_enroll to dates between 1/1/2013 and today */
    IF NEW.date_of_enroll < '2013-01-01' OR NEW.date_of_enroll > CURDATE() THEN
		SIGNAL SQLSTATE 'HY000'
        SET MESSAGE_TEXT = 'Invalid Enrollment Date: Please enter a date between 1/1/2013 and today';
	END IF;
    
    /* Limit gender to values of 0 or 1, with 0 indicating female and 1 indicating male */
    IF NEW.gender NOT IN (0,1) THEN
		SIGNAL SQLSTATE 'HY000'
        SET MESSAGE_TEXT = 'Error: Please enter a gender value of 0 or 1';
	END IF;
    
    /* Limit tx_group to values of 0 or 1, with 0 indicating SOC and 1 indicating new treatment group */
    IF NEW.tx_group NOT IN (0,1) THEN
		SIGNAL SQLSTATE 'HY000'
        SET MESSAGE_TEXT = 'Error: Please enter a tx_group value of 0 or 1';
    END IF;
    
    /* Limit edu_level to 0,1,2, indicating high school or less, college and graduate, respectively */
    IF NEW.edu_level NOT IN (0,1,2) THEN
		SIGNAL SQLSTATE 'HY000'
        SET MESSAGE_TEXT = 'Error: Please enter a edu_level value of 0, 1, 2';
	END IF;
    
    /* Limit married to 0, 1, with 0 indicating unmarried and 1 indicating married */
    IF NEW.married NOT IN (0,1) THEN
		SIGNAL SQLSTATE 'HY000'
        SET MESSAGE_TEXT = 'Error: Please enter a married value of 0 or 1';
	END IF;
    
    /* Limit race to 0,1,2,3,4,5, indicating American Indian or Alaskan Native, 
    Asian/Pacific Islander, Black, White, Hispanic and Other, respectively */
    IF NEW.race NOT IN (0,1,2,3,4,5) THEN
		SIGNAL SQLSTATE 'HY000'
        SET MESSAGE_TEXT = 'Error: Please enter a race value of 0, 1, 2, 3, 4, 5';
	END IF;
    
    /* Limit employment to values of 0,1,2, indicating unemployed, part-time and full-time, respectively */
    IF NEW.employment NOT IN (0,1,2) THEN
		SIGNAL SQLSTATE 'HY000'
        SET MESSAGE_TEXT = 'Error: Please enter an employment value of 0, 1, 2';
	END IF;
    
    /* Limit socio_eco_sts to integer betwen 0 and 10 */
    IF NEW.socio_eco_sts NOT IN (0,1,2,3,4,5,6,7,8,9,10) THEN
		SIGNAL SQLSTATE 'HY000'
        SET MESSAGE_TEXT = 'Error: Subjective socioeconomic status must be an integer between 0 and 10';
	END IF;
    
    /* Limit yrs_of_pain to values betwen 0.5 and 70 */
    IF NEW.yrs_of_pain < 0.5 OR NEW.yrs_of_pain > 70 THEN
		SIGNAL SQLSTATE 'HY000'
        SET MESSAGE_TEXT = 'Error: years of pain must be between 0.5 and 70';
	END IF;

END //

# Add trigger for the visits table
DELIMITER //

CREATE TRIGGER trigger_visits
	BEFORE INSERT ON visits
    FOR EACH ROW
BEGIN
    /* Limit visit_date to dates between 1/1/2013 and today */
    IF NEW.visit_date < '2013-01-01' OR NEW.visit_date > CURDATE() THEN
		SIGNAL SQLSTATE 'HY000'
        SET MESSAGE_TEXT = 'Invalid Visit Date: Please enter a date between 1/1/2013 and today';
	END IF;
    
    /* Limit pain_intensity to integer values between 0 and 10 */
    IF NEW.pain_intensity NOT IN (0,1,2,3,4,5,6,7,8,9,10) THEN
		SIGNAL SQLSTATE 'HY000'
        SET MESSAGE_TEXT = 'Error: Please enter a pain_intensity value of 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10';
	END IF;
    
    /* Limit days_in_pain to values between 0 and 185 */
    IF NEW.days_in_pain < 0 OR NEW.days_in_pain > 185 THEN
		SIGNAL SQLSTATE 'HY000'
        SET MESSAGE_TEXT = 'Error: days_in_pain must be between 0 and 185';
    END IF;
    
    /* Limit exercise to 0,1,2,3,4 indicating (almost) none, 1h/wk, 3h/wk, 7h/wk and >=14h/wk respectively */
    IF NEW.exercise NOT IN (0,1,2,3,4) THEN
		SIGNAL SQLSTATE 'HY000'
        SET MESSAGE_TEXT = 'Error: Please enter a exercise value of 0, 1, 2, 3, 4';
	END IF;
    
    /* Limit disability index to values between 0 and 100 */
    IF NEW.disab_index NOT BETWEEN 0 AND 100 THEN
		SIGNAL SQLSTATE 'HY000'
        SET MESSAGE_TEXT = 'Error: disab_index must be between 0 and 100';
	END IF;
    
    /* Limit depression score to value between 8 and 40 */
    IF NEW.depress_score NOT BETWEEN 8 AND 40 THEN
		SIGNAL SQLSTATE 'HY000'
        SET MESSAGE_TEXT = 'Error: depress_score must be between 8 and 40';
	END IF;
    
    /* Limit anger score to value between 5 and 25 */
    IF NEW.anger_score NOT BETWEEN 5 AND 25 THEN
		SIGNAL SQLSTATE 'HY000'
        SET MESSAGE_TEXT = 'Error: anger_score must be between 5 and 25';
	END IF;

	/* Limit anxiety score to value between 7 and 35 */
    IF NEW.anxiety_score NOT BETWEEN 7 AND 35 THEN
		SIGNAL SQLSTATE 'HY000'
        SET MESSAGE_TEXT = 'Error: anxiety_score must be between 7 and 35';
	END IF;
    
    /* Limit sleep score to value between 8 and 40 */
    IF NEW.sleep_score NOT BETWEEN 8 AND 40 THEN
		SIGNAL SQLSTATE 'HY000'
        SET MESSAGE_TEXT = 'Error: sleep_score must be between 8 and 40';
	END IF;
    
END //

# Add trigger for the fmris table
DELIMITER //

CREATE TRIGGER trigger_fmris
	BEFORE INSERT ON fmris
    FOR EACH ROW
BEGIN
	/* Limit fmri_date to dates between 1/1/2013 and today */
	IF NEW.fmri_date < '2013-01-01' OR NEW.fmri_date > CURDATE() THEN
		SIGNAL SQLSTATE 'HY000'
        SET MESSAGE_TEXT = 'Invalid fMRI Date: Please enter a date between 1/1/2013 and today';
	END IF;

END //


#####################################
#          DATA ENTRY               #
#####################################
	
# Enter data into participants table
INSERT INTO participants (date_of_birth, date_of_enroll, gender, tx_group, edu_level, married, race, employment, socio_eco_sts, yrs_of_pain)
VALUES
	('1955-10-08', '2013-01-01', 1, 1, 1, 1, 3, 1, 7, 10),
    ('1982-03-09', '2013-01-02', 0, 1, 1, 1, 3, 2, 6, 3),
    ('1970-12-25', '2013-01-04', 1, 1, 2, 1, 3, 2, 5, 9),
    ('1951-01-14', '2013-01-04', 0, 1, 1, 1, 2, 0, 9, 8),
    ('1973-10-30', '2013-01-04', 1, 1, 0, 1, 3, 2, 6, 3.5),
    ('1967-12-21', '2013-01-09', 1, 0, 2, 1, 2, 2, 3, 15),
    ('1990-08-25', '2013-01-09', 0, 0, 1, 0, 3, 1, 9, 0.5),
    ('1988-04-06', '2013-01-12', 0, 0, 1, 0, 3, 0, 5, 1.5),
    ('1950-01-03', '2013-01-14', 1, 0, 2, 0, 1, 1, 2, 14),
    ('1946-02-12', '2013-01-17', 0, 0, 1, 1, 2, 0, 8, 22);

# Enter data into visits table
INSERT INTO visits (participant_id, visit_date, pain_intensity, pain_location, days_in_pain, exercise, curr_opioid, disab_index, depress_score, anger_score, anxiety_score, sleep_score)
VALUES
    (1,	'2013-02-01', 8, 'right hip', 83, 0, 'hydrocodone', 45, 30, 21, 25, 30),
	(1,	'2013-05-01', 6, 'right hip', 56, 1, 'NA', 25, 24, 15, 20, 26),
	(1,	'2013-08-01', 2, 'right hip', 45, 3, 'NA', 12, 14, 11, 12, 12),
	(2,	'2013-02-01', 4, 'upper and lower back', 66, 2, 'NA', 18, 19, 14, 20, 21),
	(2,	'2013-05-01', 4, 'lower back', 49, 2, 'NA', 17, 16, 10, 14, 22),
	(2,	'2013-08-01', 2, 'lower back', 12, 2, 'NA', 5, 15, 9, 11, 11),
	(3,	'2013-02-01', 7, 'both thighs', 80, 0, 'NA', 43, 28, 19, 22, 34),
	(3,	'2013-05-01', 3, 'both thighs', 33, 2, 'NA', 6, 15, 10, 13, 18),
    (3,	'2013-08-01', 0, 'NA', 0, 4, 'NA', 0, 9, 7, 10, 10),
    (4,	'2013-02-01', 7, 'lower back', 72, 0, 'morphine', 41, 27, 19, 23, 29),
    (4,	'2013-05-01', 5, 'lower back', 70, 1, 'morphine', 19, 18, 15, 20, 22),
    (4,	'2013-08-01', 4, 'lower back', 58, 2, 'NA', 14, 14, 13, 15, 11),
    (5,	'2013-02-01', 5, 'lower back', 36, 1, 'NA', 26, 19, 15, 18, 16),
    (5,	'2013-05-01', 3, 'lower back', 23, 1, 'NA', 11, 14, 12, 16, 12),
    (5,	'2013-08-01', 1, 'lower back', 7, 1, 'NA', 2, 10, 8, 11, 9),
    (6,	'2013-02-01', 7, 'lower back', 67, 1, 'NA', 45, 31, 19, 28, 32),
    (6,	'2013-05-01', 5, 'lower back', 56, 1, 'NA', 37, 25, 19, 23, 26),
    (6,	'2013-08-01', 8, 'lower back', 72, 1, 'NA', 52, 35, 22, 30, 33),
    (7,	'2013-02-01', 6, 'lower back', 45, 1, 'NA', 39, 22, 17, 20, 24),
    (7,	'2013-05-01', 5, 'lower back', 42, 2, 'NA', 37, 21, 17, 20, 23),
    (7,	'2013-08-01', 5, 'lower back', 56, 1, 'NA', 38, 22, 19, 21, 18),
    (8,	'2013-02-01', 8, 'upper back and shoulder', 79, 0, 'hydrocodone', 62, 35, 22, 31, 30),
    (8,	'2013-05-01', 8, 'upper back', 76, 0, 'hydrocodone', 66, 30, 21, 31, 32),
    (8,	'2013-08-01', 7, 'upper back', 81, 0, 'hydrocodone', 58, 29, 22, 30, 34);

# Import lookup table brain_locations from csv
SET GLOBAL local_infile=1;

LOAD DATA LOCAL INFILE '/Users/huajialiang/Library/CloudStorage/OneDrive-cumc.columbia.edu/SQL/Final Project/jh4323_lookup_data.csv'
INTO TABLE brain_locations
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(brain_loc_id, location);

# Enter data into fmris table
INSERT INTO fmris (participant_id, fmri_date, brain_loc_id, activation_vol)
VALUES
	(1, '2013-01-20', 1, 3020.5),
    (1, '2013-01-20', 2, 2415.2),
    (1, '2013-01-20', 3, 5780.7),
    (1, '2013-08-20', 1, 1723.6),
    (1, '2013-08-20', 2, 623.8),
    (1, '2013-08-20', 3, 2693.4),
    (2, '2013-01-20', 1, 2198.7),
    (2, '2013-01-20', 2, 2975.2),
    (2, '2013-01-20', 3, 9790.6),
    (2, '2013-08-20', 1, 1624.5),
    (2, '2013-08-20', 2, 1673.8),
    (2, '2013-08-20', 3, 1993.9),
    (3, '2013-01-20', 1, 6734.5),
    (3, '2013-01-20', 2, 3495.8),
    (3, '2013-01-20', 3, 1882.2),
    (3, '2013-08-20', 1, 456.7),
    (3, '2013-08-20', 2, 142.2),
    (3, '2013-08-20', 3, 98.5),
    (4, '2013-01-20', 1, 4129.3),
    (4, '2013-01-20', 2, 2165.7),
    (4, '2013-01-20', 3, 2123.0),
    (4, '2013-08-20', 1, 1193.9),
    (4, '2013-08-20', 2, 1423.8),
    (4, '2013-08-20', 3, 493.4),
    (5, '2013-01-20', 1, 4129.5),
    (5, '2013-01-20', 2, 1425.2),
    (5, '2013-01-20', 3, 3850.9),
    (5, '2013-08-20', 1, 2732.6),
    (5, '2013-08-20', 2, 438.0),
    (5, '2013-08-20', 3, 963.4),
    (6, '2013-01-20', 1, 3929.9),
    (6, '2013-01-20', 2, 4135.7),
    (6, '2013-01-20', 3, 2777.7),
    (6, '2013-08-20', 1, 3826.6),
    (6, '2013-08-20', 2, 4299.2),
    (6, '2013-08-20', 3, 2893.0),
    (7, '2013-01-20', 1, 6013.1),
    (7, '2013-01-20', 2, 2867.3),
    (7, '2013-01-20', 3, 4248.9),
    (7, '2013-08-20', 1, 7723.6),
    (7, '2013-08-20', 2, 1679.2),
    (7, '2013-08-20', 3, 4693.4),
    (8, '2013-01-20', 1, 8847.7),
    (8, '2013-01-20', 2, 7843.1),
    (8, '2013-01-20', 3, 2287.9),
    (8, '2013-08-20', 1, 8952.0),
    (8, '2013-08-20', 2, 6843.1),
    (8, '2013-08-20', 3, 2341.8);


#####################################
#             QUERIES               #
#####################################

-- 1. Query that creates a view and incorporates at least one join.

CREATE VIEW gender_intensity AS
	SELECT p.gender, p.tx_group, AVG(v.depress_score) AS avg_depress_score 
    FROM participants AS p
		INNER JOIN visits AS v
        USING (participant_id)
	GROUP BY p.gender, p.tx_group
    ORDER BY p.gender;

/* I want to display average depression score by gender and treatmet group across all visits. 
Because I want to keep monitoring the depression score by gender and treatment group across all visits
as the trial goes, saving this result as a view would make the desired results stored within the schema as 
an object and be dynamically updated as the data is updated in the tables. So as new data updates
during the course of the trial, I just need to check the view instead of running the same query over and over 
again when I want to check this desired result. */

-- 2. Query that creates a temporary table and incorporates at least one join and then queries it (must be different from view).
CREATE TEMPORARY TABLE avg_days_per_patient AS
(
	SELECT p.participant_id, ROUND(AVG(v.days_in_pain)) AS avg_days
    FROM participants AS p
		INNER JOIN visits AS v
        USING (participant_id)
	GROUP BY p.participant_id
);

SELECT MAX(avg_days) AS max_avg_days
FROM avg_days_per_patient;

SELECT MIN(avg_days) AS min_avg_days
FROM avg_days_per_patient;

/* I want to display the results showing the maximum and minimum of average number of days in pain (every 3 months) per patient. */

-- 3. Query that creates a CTE and incorporates at least one join and then queries it (must be different from view/temporary table).
WITH brain_loc_lookup AS
(
	SELECT b.brain_loc_id, f.fmri_id
    FROM brain_locations AS b
		LEFT JOIN fmris AS f
        USING (brain_loc_id)
	WHERE f.fmri_id IS NULL
)

SELECT COUNT(brain_loc_id) AS num_loc
FROM brain_loc_lookup;

/* I am trying to display the number of brain locations in the brain_locations lookup table that don't 
have any corresponding record in the fmris table */

-- 4. Create a new table that pivots one of your tables from long to wide or wide to long.
CREATE TABLE visits_wide AS
SELECT participant_id,
	MAX(CASE WHEN visit_date = '2013-02-01' THEN pain_intensity END) AS intensity_month0,
	MAX(CASE WHEN visit_date = '2013-05-01' THEN pain_intensity END) AS intensity_month3,
    MAX(CASE WHEN visit_date = '2013-08-01' THEN pain_intensity END) AS intensity_month6
FROM visits
GROUP BY participant_id;
    
/* I would like to use a mixed-effects model to test the effect of treatment on primary outcome (pain_intensity) */

-- 5. Query that incorporates a self-join.
SELECT a.participant_id, 
	a.pain_intensity AS intensity_month0, 
    b.pain_intensity AS intensity_month6, 
    CAST(b.pain_intensity AS SIGNED) - CAST(a.pain_intensity AS SIGNED) AS diff_intensity
FROM visits AS a
	INNER JOIN visits AS b
    USING (participant_id)
WHERE a.visit_date = '2013-02-01' AND b.visit_date = '2013-08-01';

/* I am trying to display the pain intensity of the first visit and the last visit, and the overall 
change in pain intensity between the first visit and the last visit for every participant */

-- 6. Query that incorporates a subquery to account for possible ties.
SELECT participant_id, visit_date, depress_score
FROM visits
WHERE depress_score = 
	(SELECT MAX(depress_score) AS max_score 
    FROM visits);

/* I am trying to display the the visits (participant_id, visit_date) with the highest depression scores, 
accounting for possible ties */

-- 7. Query that incorporates a UNION.
SELECT f.participant_id, f.activation_vol, v.visit_date
FROM fmris AS f
	LEFT JOIN visits AS v
    USING (participant_id)
    
UNION

SELECT v.participant_id, f.activation_vol, v.visit_date
FROM fmris AS f
	RIGHT JOIN visits AS v
    USING (participant_id);

/* I want to display the result of a full join joining fmri table and visits table in order to check
if there are inconsistencies between these 2 tables. I chose UNION because I need the duplicate rows 
to be removed. To check inconsistencies, we only need to look at if there is any NULL value in the 
activation_vol and visit_date columns. */


-- 8. Query that adds an aggregated value with OVER() or OVER(PARTITION BY) and CASE WHEN() to compare the 
-- aggregated value to the value in each row.
SELECT p.participant_id, p.tx_group, v.visit_date, v.anxiety_score, ROUND(AVG(v.anxiety_score) OVER(), 1) AS avg_anxiety,
	CASE 
		WHEN v.anxiety_score < ROUND(AVG(v.anxiety_score) OVER(), 1) THEN 'Below Average'
        WHEN v.anxiety_score > ROUND(AVG(v.anxiety_score) OVER(), 2) THEN 'Above Average'
	END AS `status`
FROM participants AS p
	INNER JOIN visits AS v
    USING (participant_id)
ORDER BY p.tx_group;

/* I am trying to display the treatment group, anxiety score, the average treatment score over all visits,
and the indicator indicating whether the anxiety score is above or below average for each visit. I chose to
use OVER() here because I want to compare the anxiety score of each visit to the overall anxiety score. This
comparison, combing with the treatment group variable, can help me get a sense of the effect of the treatment 
on anxiety. */

-- 9. Query that ranks your data in some way.
SELECT *, DENSE_RANK() OVER(ORDER BY sleep_score) AS sleep_rank
FROM visits;

/* I am trying to display a ranked visits table based on sleep_score. I chose DENSE_RANK() 
because DENSE_RANK() will assign consecutive ranks to the values in a set in the case of tie, 
which can help me get a better sense of the real location of a particular sleep score in the
whole dataset. Furthermore, it can be helpful if I want to do the analyses that treats the sleep 
score as a categorical variable. */

-- 10. Query that answers a question of your choosing about your database – should incorporate at 
-- least one additional feature like a join, aggregate/non-aggregate/CASE function, window function, 
-- view/temporary table/CTE etc.

/* Question: According to all the fMRI records, which brain location has the largest activation volume in total?
Answer: Amygdala has the largest activation volume in total, which is 67236.7 */

SELECT b.location, ROUND(SUM(f.activation_vol), 1) AS total_vol
FROM brain_locations AS b
	INNER JOIN fmris AS f
    USING (brain_loc_id)
GROUP BY b.location
ORDER BY total_vol DESC
LIMIT 1;
	