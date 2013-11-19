public class Pad{
    Sampler sampler;
    int noteNum;
    
    //Functions                 gridPos in push.grid[x][y]
    fun void init(string sample, int gPos){
        sampler.init(sample);
        <<<sampler.numSounds>>>;
        gPos => noteNum;
    }
}