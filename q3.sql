SET SEARCH_PATH TO a3;

--Compute the grade and total score on quiz Pr1-220310 for every student in the grade 8 class in room 120 with Mr Higgins. Report the student number, last name, and total grade.

-- we want the weighted total
DROP TABLE IF EXISTS q3 CASCADE;
CREATE TABLE q3(
	StudentNumber BIGINT  PRIMARY KEY,
	LastName VARCHAR(1000),
	total_grade BIGINT
);


DROP VIEW IF EXISTS find_classID CASCADE;

-- find the id of class using the room, teacher, grade attributes
CREATE VIEW find_classID AS -- A
	SELECT cid
	FROM class
	WHERE room = 120 AND teacher = 'Mr Higgins' AND grade = 8;

DROP VIEW IF EXISTS class_students CASCADE;

-- find all students enrolled in class mentioned above
CREATE VIEW class_students AS -- B
	SELECT enrolled.sid AS sid, enrolled.cid AS cid 
	FROM enrolled 
	WHERE cid = (SELECT find_classID.cid 	
			FROM find_classID);

DROP VIEW IF EXISTS class_quiz CASCADE;

-- give the quiz details including weights and quiz content 
CREATE VIEW class_quiz AS -- C
	SELECT quiz.id as quiz_id, quiz.cid AS cid, quiz_content.id AS quiz_content_id, 
		quiz_content.question_id AS question_id, quiz_content.weight AS weight 
	FROM quiz INNER JOIN quiz_content ON quiz.id = quiz_content.quiz_id
	WHERE quiz.id = 'Pr1-220310'; 

DROP VIEW IF EXISTS quiz_answers CASCADE;

-- give weights and answers per questino on quiz
CREATE VIEW quiz_answers AS  -- D
	SELECT class_quiz.quiz_id, class_quiz.cid, class_quiz.quiz_content_id, 
		class_quiz.question_id, class_quiz.weight, question.answer 
	FROM question INNER JOIN class_quiz ON question.id = class_quiz.question_id;
	
DROP VIEW IF EXISTS all_took CASCADE;
  
-- join quiz_answers with class_students to get the "ideal" situation of
-- all students in the class taking the quiz and answering all questions
CREATE VIEW all_took AS -- E
	SELECT class_students.sid, quiz_answers.*
	FROM quiz_answers CROSS JOIN class_students;
	
DROP VIEW IF EXISTS quiz_responses CASCADE;

-- find students in the said class who actually responded to any question on the 
-- quiz
CREATE VIEW quiz_responses AS -- F
	SELECT response.sid, class_students.*  
	FROM response INNER JOIN class_students ON response.sid = class_students.sid AND
		response.cid = class_students.cid;

DROP VIEW IF EXISTS weighted_responses CASCADE;

-- include the weights to each answered question on the quiz, 
-- as well as correct answers 
CREATE VIEW weighted_responses AS -- G
	SELECT quiz_responses.sid, quiz_answers.* 
	FROM quiz_responses INNER JOIN quiz_answers ON 
		quiz_responses.quiz_content_id = quiz_answers.quiz_content_id; 

DROP VIEW IF EXISTS no_response CASCADE;

-- find those who did not give a response to at least one quiz content
CREATE VIEW no_response AS  -- I
	(SELECT * 
	FROM all_took)
	
	EXCEPT
	
	(SELECT *
	FROM weighted_responses);
		 
DROP VIEW IF EXISTS correct_response CASCADE;

-- find those who correctly responded to at least one question on the quiz
CREATE VIEW correct_response AS
	SELECT *
	FROM weighted_responses 
	WHERE response = answer;

--INSERT INTO q3


--;
