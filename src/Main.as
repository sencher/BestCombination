package {

import flash.display.Sprite;
import flash.events.Event;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.utils.getTimer;

[SWF (height=900, width=900)]
public class Main extends Sprite {
    private const MAXIMUM_DUST:int = 75000;
    private const ACCOUNTS:int = 11;
    private const CLASSES:int = 9;
    private const DATA:Array = [
        [20220, 33200, 29140, 33200, 55000, 73020, 46700, 26140, 38100],
        [41580, 53520, 33960, 53820, 54220, 74420, 41040, 31280, 55560],
        [35820, 55460, 28380, 43080, 54100, 58020, 49100, 27360, 42880],
        [46600, 69120, 35820, 58760, 69820, 90420, 55560, 38820, 63120],
        [42160, 63700, 35880, 56940, 60320, 75580, 51840, 36620, 60680],
        [44940, 63980, 34420, 56740, 63840, 82680, 49700, 40120, 60540],
        [46000, 60280, 33840, 59220, 61880, 88280, 55320, 38840, 63420],
        [41580, 52200, 38300, 53960, 58180, 83940, 53120, 35000, 55640],
        [48100, 66540, 40100, 60720, 67320, 73760, 49860, 38420, 62640],
        [49980, 64600, 39940, 63340, 67500, 92160, 57400, 37860, 67680],
        [47060, 65960, 39380, 57700, 59780, 83500, 56380, 39160, 64600]
    ];

    private const NAMES:Array = ["БрызгиПоноса", "AnaISurprise", "ЖидкийГаз", "Berlinetta", "Dominating", "RageQuit",
        "FukinAwesome", "MegaBoobs", "YoungInWound", "MissedLethal", "KissMyAxe"];
    private const CLASS_NAMES:Array = ["Druid","Hunter","Mage","Paladin","Priest","Rogue","Shaman","Warlock","Warrior"];
    private var matrix:Array = [];
    private var substitutions:Array = [];
    private var working:Boolean;

    private var minimumTotalScore:Number = Number.MAX_VALUE;
    private var minimumTotalMatrix:Array = [];
    private var maximumClassScore:Number = Number.MAX_VALUE;
    private var maximumClassMatrix:Array = [];
    private var finished:Boolean;
    private var startTime:int;
    private var textField:TextField;

    public function Main() {
        startTime = getTimer();
        var textFormat:TextFormat = new TextFormat();
        textFormat.size = 20;
        textField = new TextField();
        textField.setTextFormat(textFormat);
        textField.defaultTextFormat = textFormat;
        textField.wordWrap = true;
        textField.width = stage.stageWidth;
        textField.height = stage.stageHeight;
        addChild(textField);

        if(ACCOUNTS < CLASSES){
            traceTF("not enough accounts");
            return;
        }

        for (var i:int = 0; i < ACCOUNTS; i++) {
            matrix.push(i);
        }
        writeMatrix(matrix);
        //traceTF(minimumMatrix);
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    private function traceTF(value:*, index:int = 0, arr:Array = null):void {
        textField.appendText(value + "\n");
        textField.scrollV = textField.maxScrollV;
    }

    private function fullTrace(value:*, index:int = 0, arr:Array = null):void{
        var s:String = value[0] + "/" + value[2] + " - " + value[1] + "/" + value[3] + "\n";
        for (var i:int = 0;i<value[1].length;i++){
            s += CLASS_NAMES[i] + " - " + NAMES[value[1][i]] + " " + DATA[value[1][i]][i] + "\n";
        }
        textField.appendText(s + "\n");
        textField.scrollV = textField.maxScrollV;
    }

    private function onEnterFrame(event:Event):void {
        if (finished) {
            removeEventListener(Event.ENTER_FRAME, onEnterFrame);
            traceTF(">>>Minimum Total Score: " + minimumTotalScore);
            minimumTotalMatrix = minimumTotalMatrix.splice(minimumTotalMatrix.length - 10, 10);
            minimumTotalMatrix.reverse();
            minimumTotalMatrix.forEach(fullTrace);
            traceTF(">>>Maximum Class Score: " + maximumClassScore);
            maximumClassMatrix = maximumClassMatrix.splice(maximumClassMatrix.length - 10, 10);
            maximumClassMatrix.reverse();
            maximumClassMatrix.forEach(fullTrace);
            var currentTime:int = getTimer();
            traceTF("Time: " + (currentTime - startTime) * 0.001);
        } else if (!working) {
            working = true;
            for (var i:int = 0; i < 100000; i++) {
                if (finished) break;
                matrix = tick2(matrix);
                //traceTF(matrix.slice(0, VALUES));
                writeMatrix(matrix);
            }
            traceTF(matrix.slice(0, CLASSES));
            working = false;
        }
    }

    private function writeMatrix(value:Array):void {
        if (!value.length) return;

        var totalDust:Number = 0;
        var maxDustInMatrix:Number = 0;

        for (var i:int = 0; i < CLASSES; i++) {
            if(DATA[value[i]][i] < MAXIMUM_DUST){
                totalDust += DATA[value[i]][i];
                if (maxDustInMatrix < DATA[value[i]][i]){
                    maxDustInMatrix = DATA[value[i]][i];
                }
            }else{
                //more than maximum = ignore
                return;
            }
        }

        if (totalDust < minimumTotalScore) {
            minimumTotalScore = totalDust;
            minimumTotalMatrix.push([totalDust, value.slice(0, CLASSES), maxDustInMatrix, value.slice(CLASSES)]);
        }
        if(maxDustInMatrix < maximumClassScore){
            maximumClassScore = maxDustInMatrix;
            maximumClassMatrix.push([totalDust, value.slice(0, CLASSES), maxDustInMatrix, value.slice(CLASSES)]);
        }
        //traceTF(result + " \ " + value.slice(0, VALUES) + " \ " + value);
        return;
    }

    private function tick2(array:Array, depth:int = 3):Array {
        //last with previous
        if (array[array.length - 1] > array[array.length - 2]) {
            var temp:int = array[array.length - 2];
            array[array.length - 2] = array[array.length - 1];
            array[array.length - 1] = temp;
        } else {
            var tmpArr:Array = array.splice(array.length - depth, depth);
            var sortedArr:Array = tmpArr.concat().sort();
            var result:Array = sortedArr.splice(sortedArr.indexOf(tmpArr[0]) + 1, 1);
            if (!result.length) {
                if (!array.length) {
                    finished = true;
                    return array;//???
                } else {
                    return tick2(array.concat(tmpArr), ++depth);
                }
            }
            return array.concat(result, sortedArr);
        }
        return array;//???
    }

    function factorial(n) {
        var result = 1;
        while (n) {
            result *= n--;
        }
        return result;
    }
}
}
