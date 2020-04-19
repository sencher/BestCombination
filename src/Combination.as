package {
public class Combination {

    public var totalDust:int;
    public var maxClassDust:int;
    public var lootLeft:int;
    public var matrix:Array;
    public var shortMatrix:Array;

    public function Combination(totalDust:int, maxClassDust:int, lootLeft:int, matrix:Array) {
        this.totalDust = totalDust;
        this.maxClassDust = maxClassDust;
        this.lootLeft = lootLeft;
        this.matrix = matrix;
        shortMatrix = matrix.slice(0, Main.CLASSES);
    }

    public function toString():String {
        var s:String = totalDust + "/" + maxClassDust + "/" + lootLeft + " - " + shortMatrix + "/" + matrix.slice(Main.CLASSES) + "\n";
        for (var i:int = 0; i < shortMatrix.length; i++) {
            s += Main.CLASS_NAMES[i] + " - " + Main.NAMES[shortMatrix[i]] + " " + Main.data[shortMatrix[i]][i] + " lootleft:" + Main.lootLeft[shortMatrix[i]][i] + "\n";
        }
        return s;
    }
}
}
