<?php

namespace ChristmasLightsBundle\Model;

use ChristmasLightsBundle\Model\om\BaseKeyframe;

class Keyframe extends BaseKeyframe
{

    public function getJsonArray()
    {
        $leds = $this->getKeyframeLeds();


        return $leds->toArray();
    }
}
