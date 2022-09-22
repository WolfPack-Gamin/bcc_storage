DROP TABLE IF EXISTS `storage`;
CREATE TABLE `storage` (
	`id` INT(20) NOT NULL AUTO_INCREMENT,
	`identifier` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`charidentifier` INT(30) NOT NULL DEFAULT '0',
	`inventory` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`x` DOUBLE NOT NULL DEFAULT '0.0',
	`y` DOUBLE NOT NULL DEFAULT '0.0',
	`z` DOUBLE NOT NULL DEFAULT '0.0',
	`h` DOUBLE NOT NULL DEFAULT '0.0',
	PRIMARY KEY (`id`),
	INDEX `identifier` (`identifier`)
)
COLLATE='utf8_general_ci';