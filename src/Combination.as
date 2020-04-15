package {
public class Combination {

    public var totalDust:int;
    public var maxClassDust:int;
    public var matrix:Array;
//    public var matrixBanch:Array;

    public function Combination(totalDust:int, maxClassDust:int, matrix:Array/*, matrixBanch:Array*/) {
        this.totalDust = totalDust;
        this.maxClassDust = maxClassDust;
        this.matrix = matrix;
//        this.matrixBanch = matrixBanch;
    }

    public function toString():String {
        var shortMatrix:Array = matrix.slice(0, Main.CLASSES);
        var s:String = totalDust + "/" + maxClassDust + " - " + shortMatrix + "/" + matrix.slice(Main.CLASSES) + "\n";
        for (var i:int = 0; i < shortMatrix.length; i++) {
            s += Main.CLASS_NAMES[i] + " - " + Main.NAMES[shortMatrix[i]] + " " + Main.data[shortMatrix[i]][i] + "\n";
        }
        return s;
    }
}
}
