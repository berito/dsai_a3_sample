typedef struct _control_block {
    
    int m,n;
    int stats_freq;
    int plot_freq;
    int px, py;
    bool noComm;
    int niters;
    bool debug;
    bool wait;
    int simTime;   // Simulation time (passed via -t)
    std::string outputFileName = "strong_scaling.csv"; // Default output file
} control_block;
