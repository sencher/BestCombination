package {

import flash.display.Sprite;
import flash.events.Event;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.utils.getTimer;

import utils.Utils;

[SWF(height=900, width=1200)]
public class Main extends Sprite {
    public static const NAMES:Array = ["БрызгиПоноса", "AnaISurprise", "ЖидкийГаз", "Berlinetta", "Dominating", "RageQuit",
        "FukinAwesome", "MegaBoobs", "YoungInWound", "MissedLethal", "KissMyAxe"];
    public static const CLASS_NAMES:Array = ["Demon", "Druid", "Hunter", "Mage", "Paladin", "Priest", "Rogue", "Shaman", "Warlock", "Warrior"];

    public static const CLASSES:int = 10;

    private const ACCOUNTS:int = 11;
    private const VECTOR_LIMIT:uint = 7;
    private const ITERATIONS_PER_FRAME:uint = 10000;

    private const MAXIMUM_DUST:int = int.MAX_VALUE;
    private const LEFT:int = 0;
    private const CENTER:int = 1;
    private const RIGHT:int = 2;

    public static var data:Array = [
        [18.8, 27.44, 17.3, 38.8, 2.82, 39.74, 27.6, 7.76, 59.56, 10.68],
        [21.54, 31.82, 15.7, 39.88, 5.04, 37.36, 23.32, 5.66, 64.7, 15.26],
        [20, 30.46, 17.6, 37.66, 3.98, 44.24, 23.92, 5.06, 58.68, 12.96],
        [21.8, 33.68, 18.46, 44.42, 3.98, 51.32, 32.84, 11.3, 72.54, 14.6],
        [17.88, 32.48, 16.82, 48.06, 6.22, 34.92, 26.2, 11.7, 74.62, 16.76],
        [22.98, 26.58, 15.42, 42.8, 5.96, 44.52, 26.84, 9.72, 72.09, 17.84],
        [22.02, 38.52, 14.92, 47.94, 6.2, 51.16, 32.24, 11.68, 76.2, 17.06],
        [22.14, 36.56, 17.86, 50.08, 4.66, 48.74, 33.96, 13.58, 77.8, 16.16],
        [22.9, 37.84, 19.16, 52.56, 6.32, 46.4, 23.8, 10.98, 83.34, 18.72],
        [21.9, 38.42, 20.5, 54.06, 6.94, 52.12, 33.28, 13.48, 77.32, 19.34],
        [23.06, 36.8, 19.44, 56.58, 6.52, 48.5, 30.32, 13.86, 87.08, 19.5]
    ];

//    public static var data:Array = [
//        [4, 3, 2, 3, 4, 3, 4, 2],
//        [1, 3, 1, 5, 1, 2, 1, 4],
//        [0, 1, 9, 1, 2, 1, 7, 1],
//        [1, 0, 1, 4, 1, 0, 1, 0],
//        [0, 1, 2, 1, 2, 1, 2, 1],
//        [1, 4, 1, 0, 1, 2, 1, 3],
//        [6, 1, 0, 1, 7, 1, 4, 1],
//        [1, 2, 1, 7, 1, 0, 1, 3]
//    ];

    private var matrix:Array = [];
    private var working:Boolean;

    private var minimumTotalDustVector:Vector.<Combination> = new Vector.<Combination>();
    private var maximumClassDustVector:Vector.<Combination> = new Vector.<Combination>();
    private var finished:Boolean;
    private var startTime:int;
    private var textFieldLeft:TextField;
    private var textFieldCenter:TextField;
    private var textFieldRight:TextField;
    private var depth:int;

    public function Main() {
        startTime = getTimer();
        var textFormat:TextFormat = new TextFormat();
        textFormat.size = 20;
        textFieldLeft = new TextField();
        textFieldLeft.setTextFormat(textFormat);
        textFieldLeft.defaultTextFormat = textFormat;
        textFieldLeft.wordWrap = true;
        textFieldLeft.width = stage.stageWidth * 0.4;
        textFieldLeft.height = stage.stageHeight;
        addChild(textFieldLeft);
        stage.focus = textFieldLeft;

        textFieldCenter = new TextField();
        textFieldCenter.setTextFormat(textFormat);
        textFieldCenter.defaultTextFormat = textFormat;
        textFieldCenter.wordWrap = true;
        textFieldCenter.width = stage.stageWidth * 0.4;
        textFieldCenter.height = stage.stageHeight;
        textFieldCenter.x = stage.stageWidth * 0.4;
        addChild(textFieldCenter);

        textFieldRight = new TextField();
        textFieldRight.setTextFormat(textFormat);
        textFieldRight.defaultTextFormat = textFormat;
        textFieldRight.wordWrap = true;
        textFieldRight.width = stage.stageWidth * 0.2;
        textFieldRight.height = stage.stageHeight;
        textFieldRight.x = stage.stageWidth * 0.8;
        addChild(textFieldRight);

        depth = 1 + ACCOUNTS - CLASSES;
        if (depth < 2) depth = 2;

        for (var i:int = 0; i < data.length; i++) {
            for (var j:int = 0; j < data[i].length; j++) {
                data[i][j] = Math.round(data[i][j] * 1000);
            }
        }

        if (ACCOUNTS < CLASSES) {
            traceTf("not enough accounts");
            return;
        }

        for (i = 0; i < ACCOUNTS; i++) {
            matrix.push(i);
        }
        tryWriteMatrix(matrix);
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    private function traceTf(value:*, position:int = RIGHT):void {
        if (position == LEFT) {
            textFieldLeft.appendText(value + "\n");
        } else if (position == CENTER) {
            textFieldCenter.appendText(value + "\n");
        } else {
            textFieldRight.appendText(value + "\n");
            textFieldRight.scrollV = textFieldRight.maxScrollV;
        }
    }

    private function fullTraceLeft(value:*, index:int = 0, arr:* = null):void {
        traceTf(value, LEFT);
    }

    private function fullTraceCenter(value:*, index:int = 0, arr:* = null):void {
        traceTf(value, CENTER);
    }

    private function onEnterFrame(event:Event):void {
        if (finished) {
            removeEventListener(Event.ENTER_FRAME, onEnterFrame);

            traceTf(">>>Minimum Total Score: " + minimumTotalDustVector[0].totalDust + "\n", LEFT);
            minimumTotalDustVector.forEach(fullTraceLeft);

            traceTf(">>>Maximum Class Dust: " + maximumClassDustVector[0].maxClassDust + "\n", CENTER);
            maximumClassDustVector.forEach(fullTraceCenter);

            traceTf("Time: " + (getTimer() - startTime) * 0.001);
        } else if (!working) {
            working = true;
            try {
                for (var i:int = 0; i < ITERATIONS_PER_FRAME; i++) {
                    if (finished) break;
                    matrix = tick(matrix, depth);
//                    traceTf(matrix);
                    tryWriteMatrix(matrix);
                }
            } catch (e:Error) {
                traceTf("15>>>> " + matrix, CENTER);
            } finally {
                tryWriteMatrix(matrix);
                traceTf(matrix.slice(0, CLASSES));
                working = false;
            }
        }
    }

    private function tryWriteMatrix(value:Array):void {
        if (!value.length) return;

        var newCombTotalDust:int = 0;
        var newCombMaxClassDust:int = 0;

        for (var i:int = 0; i < CLASSES; i++) {
            if (data[value[i]][i] < MAXIMUM_DUST) {
                newCombTotalDust += data[value[i]][i];
                if (newCombMaxClassDust < data[value[i]][i]) {
                    newCombMaxClassDust = data[value[i]][i];
                }
            } else {
                //more than maximum = ignore
                return;
            }
        }

        if (
                !minimumTotalDustVector.length ||
                (newCombTotalDust < minimumTotalDustVector[0].totalDust) ||
                (newCombTotalDust == minimumTotalDustVector[0].totalDust && newCombMaxClassDust < minimumTotalDustVector[0].maxClassDust)
        ) {
            if (minimumTotalDustVector.length >= VECTOR_LIMIT) {
                minimumTotalDustVector.pop();
            }
            minimumTotalDustVector.unshift(new Combination(newCombTotalDust, newCombMaxClassDust, value.concat()));
        }

        if (
                !maximumClassDustVector.length ||
                (newCombMaxClassDust < maximumClassDustVector[0].maxClassDust) ||
                (newCombMaxClassDust == maximumClassDustVector[0].maxClassDust && newCombTotalDust < maximumClassDustVector[0].totalDust)
        ) {
            if (maximumClassDustVector.length >= VECTOR_LIMIT) {
                maximumClassDustVector.pop();
            }
            maximumClassDustVector.unshift(new Combination(newCombTotalDust, newCombMaxClassDust, value.concat()));
        }
    }

    private function pushIgnoreClones(vector:Vector.<Combination>, pretender:Combination):void {
        for each (var combination:Combination in vector) {
            if (Utils.areArraysEqual(combination.shortMatrix, pretender.shortMatrix)) {
                return;
            }
        }

        vector.push(pretender);
    }

    private function tick(array:Array, depth:int = 2):Array {
        var workArray:Array = array.splice(array.length - depth, depth);
        var sortedWork:Array = workArray.concat().sort(Array.NUMERIC);
        var result:Array = sortedWork.splice(sortedWork.indexOf(workArray[0]) + 1, 1);
        if (!result.length) {
            if (!array.length) {
                finished = true;
                return array;
            } else {
                return tick(array.concat(workArray), ++depth);
            }
        }
        return array.concat(result, sortedWork);
    }

//    private function minimumTotalDustSort(a:Combination, b:Combination):Number {
//        var totalDust:Number = a.totalDust - b.totalDust;
//        if( totalDust == 0 ){
//            return a.maxClassDust - b.maxClassDust;
//        }else{
//            return totalDust;
//        }
//    }
//
//    private function maximumClassDustSort(a:Combination, b:Combination):Number {
//        var totalDust:Number = a.maxClassDust - b.maxClassDust;
//        if( totalDust == 0 ){
//            return a.totalDust - b.totalDust;
//        }else{
//            return totalDust;
//        }
//    }

//    private function factorial(n:int):int {
//        var result:int = 1;
//        while (n) {
//            result *= n--;
//        }
//        return result;
//    }
}
}
