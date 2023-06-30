INSERT INTO `addon_account` (name, label, shared) VALUES 
	('society_autoecole','Auto-école',1)
;

INSERT INTO `datastore` (name, label, shared) VALUES 
	('society_autoecole','Auto-école',1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES 
	('society_autoecole', 'Auto-école', 1)
;

INSERT INTO `jobs` (`name`, `label`) VALUES
('autoecole', 'Auto-école');

INSERT INTO `job_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
('autoecole', 0, 'secretaire','Secrétaire', 200, 'null', 'null'),
('autoecole', 1, 'boss','Moniteur', 400, 'null', 'null');

ALTER TABLE `user_licenses` ADD  `point` int(3) NOT NULL DEFAULT 12;