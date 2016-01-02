<?php

namespace ChristmasLightsBundle\Model;

use ChristmasLightsBundle\Model\om\BaseKeyframeLed;

class KeyframeLed extends BaseKeyframeLed
{

    public function getJsonArray()
    {
        $data = $this->toArray();
        $data['Timestamp'] = $this->getKeyframe()->getTimestamp();

        return $data;
    }

    public function toggle()
    {
        if ($this->getValue() == 0) {
            $this->setValue(215);
        } else {
            $this->setValue(0);
        }

        $this->save();
    }
}
