
OscRecv orec;
12001 => orec.port;
orec.listen();
orec.event("/mgain, f") @=> OscEvent mg;

spork ~ loop();
while(samp=>now);

//Functions
fun void loop(){
    while(mg=>now){ 
        while(mg.nextMsg() != 0){
            <<<mg.getFloat()>>>;
        }
    }
}