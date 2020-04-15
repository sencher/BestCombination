package {

import flash.display.Sprite;
import flash.events.Event;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.utils.getTimer;

import mx.utils.ObjectUtil;

[SWF(height=900, width=1200)]
public class Main extends Sprite {
    private const ACCOUNTS:int = 11;
    private const CLASSES:int = 10;
    private const MAXIMUM_DUST:int = int.MAX_VALUE;
    private var data:Array = [
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

    private const NAMES:Array = ["БрызгиПоноса", "AnaISurprise", "ЖидкийГаз", "Berlinetta", "Dominating", "RageQuit",
        "FukinAwesome", "MegaBoobs", "YoungInWound", "MissedLethal", "KissMyAxe"];
    private const CLASS_NAMES:Array = ["Demon", "Druid", "Hunter", "Mage", "Paladin", "Priest", "Rogue", "Shaman", "Warlock", "Warrior"];
    private const LEFT:int = 0;
    private const RIGHT:int = 1;
    private var matrix:Array = [];
    private var working:Boolean;

    private var minimumTotalScore:Number = Number.MAX_VALUE;
    private var minimumTotalMatrix:Array = [];
    private var maximumClassScore:Number = Number.MAX_VALUE;
    private var maximumClassMatrix:Array = [];
    private var finished:Boolean;
    private var startTime:int;
    private var textFieldLeft:TextField;
    private var textFieldRight:TextField;

    public function Main() {
        startTime = getTimer();
        var textFormat:TextFormat = new TextFormat();
        textFormat.size = 20;
        textFieldLeft = new TextField();
        textFieldLeft.setTextFormat(textFormat);
        textFieldLeft.defaultTextFormat = textFormat;
        textFieldLeft.wordWrap = true;
        textFieldLeft.width = stage.stageWidth/2;
        textFieldLeft.height = stage.stageHeight;
        addChild(textFieldLeft);
        stage.focus = textFieldLeft;

        textFieldRight = new TextField();
        textFieldRight.setTextFormat(textFormat);
        textFieldRight.defaultTextFormat = textFormat;
        textFieldRight.wordWrap = true;
        textFieldRight.width = stage.stageWidth/2;
        textFieldRight.height = stage.stageHeight;
        textFieldRight.x = stage.stageWidth/2;
        addChild(textFieldRight);

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
        writeMatrix(matrix);
        //traceTf(minimumMatrix);
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    private function traceTf(value:*, position:int = LEFT):void {
        if(position == LEFT) {
            textFieldLeft.appendText(value + "\n");
            textFieldLeft.scrollV = textFieldLeft.maxScrollV;
        }else{
            textFieldRight.appendText(value + "\n");
            textFieldRight.scrollV = textFieldRight.maxScrollV;
        }
    }

    private function fullTrace(value:*, index:int = 0, arr:Array = null):void {
        var s:String = value[0] + "/" + value[2] + " - " + value[1] + "/" + value[3] + "\n";
        for (var i:int = 0; i < value[1].length; i++) {
            s += CLASS_NAMES[i] + " - " + NAMES[value[1][i]] + " " + data[value[1][i]][i] + "\n";
        }
        traceTf(s);
    }

    private function onEnterFrame(event:Event):void {
        if (finished) {
            removeEventListener(Event.ENTER_FRAME, onEnterFrame);
            traceTf(">>>Minimum Total Score: " + minimumTotalScore);
            minimumTotalMatrix = minimumTotalMatrix.splice(minimumTotalMatrix.length - 10, 10);
            minimumTotalMatrix.reverse();
            minimumTotalMatrix.forEach(fullTrace);
            traceTf(">>>Maximum Class Score: " + maximumClassScore);
            maximumClassMatrix = maximumClassMatrix.splice(maximumClassMatrix.length - 10, 10);
            maximumClassMatrix.reverse();
            maximumClassMatrix.forEach(fullTrace);
            traceTf("Time: " + (getTimer() - startTime) * 0.001);
        } else if (!working) {
            working = true;
            for (var i:int = 0; i < 1000000; i++) {
                if (finished) break;
                matrix = tick(matrix);
//                if(ObjectUtil.compare(matrix,[9,5,6,2,7,4,8,1,0,3,10])==0){//10,5,6,2,7,4,8,1,0,3/9
//                    trace("dfsdfsdsfds");
//                }
                if(i<20) traceTf(matrix);
                writeMatrix(matrix);
            }
            traceTf(matrix.slice(0, CLASSES));
            working = false;
        }
    }

    private function writeMatrix(value:Array):void {
        if (!value.length) return;

        var totalDust:Number = 0;
        var maxDustInMatrix:Number = 0;

        for (var i:int = 0; i < CLASSES; i++) {
            if (data[value[i]][i] < MAXIMUM_DUST) {
                totalDust += data[value[i]][i];
                if (maxDustInMatrix < data[value[i]][i]) {
                    maxDustInMatrix = data[value[i]][i];
                }
            } else {
                //more than maximum = ignore
                return;
            }
        }

        if (totalDust < minimumTotalScore) {
            minimumTotalScore = totalDust;
            minimumTotalMatrix.push([totalDust, value.slice(0, CLASSES), maxDustInMatrix, value.slice(CLASSES)]);
        }
        if (maxDustInMatrix < maximumClassScore) {
            maximumClassScore = maxDustInMatrix;
            maximumClassMatrix.push([totalDust, value.slice(0, CLASSES), maxDustInMatrix, value.slice(CLASSES)]);
        }
        //traceTf(result + " \ " + value.slice(0, VALUES) + " \ " + value);
    }

    private function tick(array:Array, depth:int = 3):Array {
        //last with previous
        if (array[array.length - 1] > array[array.length - 2]) {
            var temp:int = array[array.length - 2];
            array[array.length - 2] = array[array.length - 1];
            array[array.length - 1] = temp;
        } else {
            var tmpArr:Array = array.splice(array.length - depth, depth);
            var sortedArr:Array = tmpArr.concat().sort(Array.NUMERIC);
            var result:Array = sortedArr.splice(sortedArr.indexOf(tmpArr[0]) + 1, 1);
            if (!result.length) {
                if (!array.length) {
                    finished = true;
                    return array;//???
                } else {
                    return tick(array.concat(tmpArr), ++depth);
                }
            }
            return array.concat(result, sortedArr);
        }
        return array;//???
    }

    private function factorial(n:int):int {
        var result:int = 1;
        while (n) {
            result *= n--;
        }
        return result;
    }
}
}
