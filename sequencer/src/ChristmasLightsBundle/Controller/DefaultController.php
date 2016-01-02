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
use Symfony\Component\HttpFoundation\Response;

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
     * @Route("/song/{song_id}/keyframesInit.json", name="song_keyframes_init")
     */
    public function keyframesInitAction(Request $request, $song_id)
    {
        $duration = 76.564896;

        $keyframes = [];

        // milliseconds in 40ms increments
        for ($i = 0; $i < $duration * 1000; $i += 46) {
            $frame = KeyframeQuery::create()
                ->filterBySongId($song_id)
                ->filterByTimestamp($i)
                ->findOneOrCreate();
            $frame
                ->save();
            $keyframes[] = $frame
                ->toArray();
        }

        return new JsonResponse($keyframes);
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
     * @Route("/song/{song_id}/leds.json", name="song_led_keyframes")
     */
    public function ledKeyframesAction(Request $request, $song_id)
    {
        $leds = LedQuery::create()
            ->find();

        $data = [];

        foreach ($leds as $led) {
            $data[$led->getId()] = $led->getKeyframes($song_id);
        }

        return new JsonResponse($data);
    }

    /**
     * @Route("/song/{song_id}/led/{led_id}.json", name="song_single_led_keyframes")
     */
    public function singleLedKeyframesAction(Request $request, $song_id, $led_id)
    {
        $led = LedQuery::create()
            ->filterById($led_id)
            ->findOne();

        $data = $led->getKeyframes($song_id);

        return new JsonResponse($data);
    }

    /**
     * @Route("/song/{song_id}/{timestamp}/{led_id}/toggleLed", name="toggle_led")
     */
    public function toggleLedAction(Request $request, $song_id, $timestamp, $led_id)
    {
        $keyframe = KeyframeQuery::create()
            ->filterBySongId($song_id)
            ->filterByTimestamp($timestamp)
            ->findOneOrCreate();
        $keyframe->save();

        $frameLed = KeyframeLedQuery::create()
            ->filterByKeyframe($keyframe)
            ->filterByLedIndex($led_id)
            ->findOneOrCreate();

        $frameLed->toggle();

        return new Response("");
    }


    /**
     * @Route("/song/{song_id}/processing.txt", name="song_keyframes")
     */
    public function outputProcessing(Request $request, $song_id)
    {
        $arbitraryOffset = 4; // subtract 4 ms from each delay for some reason

        $frames = KeyframeQuery::create()
            ->filterBySongId($song_id)
            ->orderByTimestamp()
            ->find();

        $timestamp = 0 - $arbitraryOffset;
        $code = "";

        /** @var $frame Keyframe */
        foreach ($frames as $frame) {
            $ledData = array_fill(0, 10, 0);

            $leds = $frame->getKeyframeLeds();
            foreach ($leds as $l) {
                $ledData[$l->getLedIndex()-1] = $l->getValue();
            }

            $code .= sprintf("delay(%d);setColors(%s);\n", $frame->getTimestamp() - $timestamp - $arbitraryOffset, implode(", ", $ledData));

            $timestamp = $frame->getTimestamp();
        }

        // setColors(215,0,0,0,0);delay(230);
        return new Response($code);
    }
}
