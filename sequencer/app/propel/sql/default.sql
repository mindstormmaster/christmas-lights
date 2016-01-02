
# This is a fix for InnoDB in MySQL >= 4.1.x
# It "suspends judgement" for fkey relationships until are tables are set.
SET FOREIGN_KEY_CHECKS = 0;

-- ---------------------------------------------------------------------
-- songs
-- ---------------------------------------------------------------------

DROP TABLE IF EXISTS `songs`;

CREATE TABLE `songs`
(
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(255) NOT NULL,
    `delay` INTEGER DEFAULT 0 NOT NULL,
    `offset` INTEGER DEFAULT 0 NOT NULL,
    `waveform_data` TEXT,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- leds
-- ---------------------------------------------------------------------

DROP TABLE IF EXISTS `leds`;

CREATE TABLE `leds`
(
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(255) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- keyframes
-- ---------------------------------------------------------------------

DROP TABLE IF EXISTS `keyframes`;

CREATE TABLE `keyframes`
(
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `song_id` INTEGER NOT NULL,
    `timestamp` INTEGER NOT NULL,
    PRIMARY KEY (`id`),
    INDEX `FK_keyframe_song` (`song_id`),
    CONSTRAINT `FK_keyframe_song`
        FOREIGN KEY (`song_id`)
        REFERENCES `songs` (`id`)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- keyframe_leds
-- ---------------------------------------------------------------------

DROP TABLE IF EXISTS `keyframe_leds`;

CREATE TABLE `keyframe_leds`
(
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `keyframe_id` INTEGER NOT NULL,
    `led_index` INTEGER NOT NULL,
    `value` INTEGER NOT NULL,
    PRIMARY KEY (`id`),
    INDEX `FK_keyframeLed_keyframe` (`keyframe_id`),
    INDEX `FK_keyframeLed_led` (`led_index`),
    CONSTRAINT `FK_keyframeLed_keyframe`
        FOREIGN KEY (`keyframe_id`)
        REFERENCES `keyframes` (`id`),
    CONSTRAINT `FK_keyframeLed_led`
        FOREIGN KEY (`led_index`)
        REFERENCES `leds` (`id`)
) ENGINE=InnoDB;

# This restores the fkey checks, after having unset them earlier
SET FOREIGN_KEY_CHECKS = 1;
