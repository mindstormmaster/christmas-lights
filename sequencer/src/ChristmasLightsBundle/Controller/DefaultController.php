<?php

namespace ChristmasLightsBundle\Controller;

use ChristmasLightsBundle\Model\KeyframeLedQuery;
use ChristmasLightsBundle\Model\KeyframeQuery;
use ChristmasLightsBundle\Model\LedQuery;
use ChristmasLightsBundle\Model\SongQuery;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;

class DefaultController extends Controller
{
    /**
     * @Route("/", name="homepage")
     */
    public function indexAction(Request $request)
    {
        // replace this example code with whatever you need
        return $this->render('default/index.html.twig', array(
            'base_dir' => realpath($this->container->getParameter('kernel.root_dir').'/..'),
        ));
    }

    /**
     * @Route("/songs.json", name="songs")
     */
    public function songsAction(Request $request)
    {
        $data = SongQuery::create()
            ->find()
            ->toArray();

        return new JsonResponse($data);
    }

    /**
     * @Route("/leds.json", name="leds")
     */
    public function ledsAction(Request $request)
    {
        $data = LedQuery::create()
            ->find()
            ->toArray();

        return new JsonResponse($data);
    }

    /**
     * @Route("/song/{song_id}/keyframes.json", name="song_keyframes")
     */
    public function keyframesAction(Request $request, $song_id)
    {
        $data = KeyframeQuery::create()
            ->filterBySongId($song_id)
            ->orderByTimestamp()
            ->find()
            ->toArray();

        return new JsonResponse($data);
    }

    /**
     * @Route("/song/keyframe/{keyframe_id}/leds.json", name="keyframe_leds")
     */
    public function keyframeLedsAction(Request $request, $keyframe_id)
    {
        $data = KeyframeLedQuery::create()
            ->filterByKeyframeId($keyframe_id)
            ->find()
            ->toArray();

        return new JsonResponse($data);
    }
}
