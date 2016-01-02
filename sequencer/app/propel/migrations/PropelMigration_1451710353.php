<?php

/**
 * Data object containing the SQL and PHP code to migrate the database
 * up to version 1451710353.
 * Generated on 2016-01-02 04:52:33 by vagrant
 */
class PropelMigration_1451710353
{

    public function preUp($manager)
    {
        // add the pre-migration code here
    }

    public function postUp($manager)
    {
        // add the post-migration code here
    }

    public function preDown($manager)
    {
        // add the pre-migration code here
    }

    public function postDown($manager)
    {
        // add the post-migration code here
    }

    /**
     * Get the SQL statements for the Up migration
     *
     * @return array list of the SQL strings to execute for the Up migration
     *               the keys being the datasources
     */
    public function getUpSQL()
    {
        return array (
  'default' => '
# This is a fix for InnoDB in MySQL >= 4.1.x
# It "suspends judgement" for fkey relationships until are tables are set.
SET FOREIGN_KEY_CHECKS = 0;

CREATE INDEX `FK_keyframeLed_keyframe` ON `keyframe_leds` (`keyframe_id`);

CREATE INDEX `FK_keyframeLed_led` ON `keyframe_leds` (`led_index`);

ALTER TABLE `keyframe_leds` ADD CONSTRAINT `FK_keyframeLed_keyframe`
    FOREIGN KEY (`keyframe_id`)
    REFERENCES `keyframes` (`id`);

ALTER TABLE `keyframe_leds` ADD CONSTRAINT `FK_keyframeLed_led`
    FOREIGN KEY (`led_index`)
    REFERENCES `leds` (`id`);

CREATE INDEX `FK_keyframe_song` ON `keyframes` (`song_id`);

ALTER TABLE `keyframes` ADD CONSTRAINT `FK_keyframe_song`
    FOREIGN KEY (`song_id`)
    REFERENCES `songs` (`id`);

ALTER TABLE `songs` CHANGE `name` `name` VARCHAR(255) NOT NULL;

ALTER TABLE `songs` CHANGE `delay` `delay` INTEGER DEFAULT 0 NOT NULL;

CREATE TABLE `leds`
(
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(255) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB;

# This restores the fkey checks, after having unset them earlier
SET FOREIGN_KEY_CHECKS = 1;
',
);
    }

    /**
     * Get the SQL statements for the Down migration
     *
     * @return array list of the SQL strings to execute for the Down migration
     *               the keys being the datasources
     */
    public function getDownSQL()
    {
        return array (
  'default' => '
# This is a fix for InnoDB in MySQL >= 4.1.x
# It "suspends judgement" for fkey relationships until are tables are set.
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `leds`;

ALTER TABLE `keyframe_leds` DROP FOREIGN KEY `FK_keyframeLed_keyframe`;

ALTER TABLE `keyframe_leds` DROP FOREIGN KEY `FK_keyframeLed_led`;

DROP INDEX `FK_keyframeLed_keyframe` ON `keyframe_leds`;

DROP INDEX `FK_keyframeLed_led` ON `keyframe_leds`;

ALTER TABLE `keyframes` DROP FOREIGN KEY `FK_keyframe_song`;

DROP INDEX `FK_keyframe_song` ON `keyframes`;

ALTER TABLE `songs` CHANGE `name` `name` VARCHAR(45);

ALTER TABLE `songs` CHANGE `delay` `delay` INTEGER;

# This restores the fkey checks, after having unset them earlier
SET FOREIGN_KEY_CHECKS = 1;
',
);
    }

}