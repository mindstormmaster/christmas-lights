<?php

namespace ChristmasLightsBundle\Model;

use ChristmasLightsBundle\Model\om\BaseLed;

class Led extends BaseLed
{

    public function getKeyframes($song_id)
    {
        $frames = KeyframeLedQuery::create()
            ->filterByLedIndex($this->getId())
            ->useKeyframeQuery()
            ->filterBySongId($song_id)
            ->orderByTimestamp()
            ->endUse()
            ->find();

        $data = [];
        foreach ($frames as $frame) {
            $data[] = $frame->getJsonArray();
        }

        return $data;
    }
}
