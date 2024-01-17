CREATE TABLE `mms_boats` (
	`identifier` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8_general_ci',
	`name` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8_general_ci',
	`model` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8_general_ci',
	`sellprice` INT(11) NULL DEFAULT NULL,
	`maxboats` INT(11) NULL DEFAULT NULL
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB
;
