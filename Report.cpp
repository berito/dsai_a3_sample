//
// Performs various reporting functions
//
// Do not change the code in this file, as doing so
// could cause your submission to be graded incorrectly
#include <filesystem> // For directory creation
#include <iostream>
#include <fstream>
#include <iomanip>
#include <stdlib.h>
#include <math.h>
#include "cblock.h"
#ifdef _MPI_
#include "mpi.h"
#endif
#ifdef _OPENMP
#include <omp.h>
#endif
using namespace std;

extern control_block cb;
// Reports statistics about the computation
// These values should not vary (except to within roundoff)
// when we use different numbers of  processes to solve the problem

void ABEND()
{
    cout.flush();
    cerr.flush();
#ifdef _MPI_
    MPI_Abort(MPI_COMM_WORLD, -1);
#else
    exit(-1);
#endif
}

void Stop()
{
    cout.flush();
    cerr.flush();
#ifdef _MPI_
    MPI_Barrier(MPI_COMM_WORLD);
    MPI_Finalize();
#endif
    exit(-1);
}

// Report statistics periodically
void repNorms(double l2norm, double mx, double dt, int m, int n, int niter, int stats_freq)
{

    int myrank;
#ifdef _MPI_
    MPI_Comm_rank(MPI_COMM_WORLD, &myrank);
#else
    myrank = 0;
#endif
    if (!myrank)
    {
        cout << setw(6);
        cout.setf(ios::fixed);
        cout << "iteration = " << niter << ", ";
        cout.unsetf(ios::fixed);
        cout.setf(ios::scientific);
        cout.precision(6);
        cout << "Max norm: " << mx << ", L2norm: " << l2norm << endl;
    }
#ifdef _MPI_
    MPI_Barrier(MPI_COMM_WORLD);
#endif
}
void printTOD(string mesg)
{
    time_t tim = time(NULL);
    string s = ctime(&tim);
    int myrank;
#ifdef _MPI_
    MPI_Comm_rank(MPI_COMM_WORLD, &myrank);
#else
    myrank = 0;
#endif
    if (!myrank)
    {
        cout << endl;
        if (mesg.length() == 0)
        {
            cout << "Time of day: " << s.substr(0, s.length() - 1) << endl;
        }
        else
        {
            cout << "[" << mesg << "] ";
            cout << s.substr(0, s.length() - 1) << endl;
        }
        cout << endl;
    }
#ifdef _MPI_
    MPI_Barrier(MPI_COMM_WORLD);
#endif
}

// Computes the gigaflops rate

double gflops(int n, int niter, double time)
{
    int n2 = n * n;
    int64_t updates = (int64_t)n2 * (int64_t)niter;
    int64_t flops = 28 * updates;
    double flop_rate = (double)flops / time;
    return (flop_rate / 1.0e9);
}

void writeFinalMetricsToFile(double l2norm, double linf, double execTime, int gridRows, int gridCols, int px, int py, int niter, double gflops, int mpiProcs, int ompThreads)
{
    std::string directory = "data";
    std::string separator = "/";
    std::string fullPath = directory + separator + cb.outputFileName;
    std::ofstream outFile(fullPath, std::ios::app); // Use the file name from cb

    if (!outFile.is_open())
    {
        std::cerr << "Error: Unable to open " << cb.outputFileName << " for writing." << std::endl;
        return;
    }

    // // Write the header if the file is empty
    // static bool headerWritten = false;
    // if (!headerWritten) {
    //     outFile << "process,geometry,iterations,gflops,time,grid_size,l2_norm,linf_norm,threads\n";
    //     headerWritten = true;
    // }
    // Write the header if the file is empty
    // Check if the file is empty using std::ifstream
    std::ifstream checkFile(fullPath);
    bool isEmpty = checkFile.peek() == std::ifstream::traits_type::eof();
    checkFile.close();

    // Write the header if the file is empty
    if (isEmpty)
    {
        outFile << "process,geometry,iterations,gflops,time,grid_size,l2_norm,linf_norm,threads\n";
    }

    // Write the metrics
    outFile << mpiProcs << ","                    // Processes
            << px << "x" << py << ","             // Geometry
            << niter << ","                       // Iterations
            << gflops << ","                      // GFlops
            << execTime << ","                    // Execution Time
            << gridRows << "x" << gridCols << "," // Grid Size
            << l2norm << ","                      // L2 Norm
            << linf << ","                        // Linf Norm
            << ompThreads << "\n";                // Threads

    outFile.close();
}
void ReportEnd(double l2norm, double mx, double t0)
{
    printTOD("Simulation completes");
    int myrank, nprocs = 1, threads = 1;

#ifdef _MPI_
    MPI_Comm_size(MPI_COMM_WORLD, &nprocs);
    MPI_Comm_rank(MPI_COMM_WORLD, &myrank);
#else
    myrank = 0;
#endif
#ifdef _OPENMP
    threads = omp_get_max_threads();
#endif
    if (!myrank)
    {
        double gf = gflops(cb.n, cb.niters, t0);
        cout << "End at";
        cout << setw(6);
        cout.setf(ios::fixed);
        cout << " iteration " << cb.niters - 1 << endl;
        cout.unsetf(ios::fixed);
        cout.setf(ios::scientific);
        cout.precision(5);
        cout << "Max norm: " << mx << ", L2norm: " << l2norm << endl;
        cout.unsetf(ios::scientific);
        cout.unsetf(ios::fixed);
        cout.precision(6);
        cout << "Running Time: " << t0 << " sec.";
        cout.precision(3);
        cout << " [" << gf << " GFlop/sec]" << endl
             << endl;

        cout << "   M x N   px x py Comm?   #iter  T_p, Gflops        Linf, L2" << endl;
        cout << "@ " << cb.m << " " << cb.n << " ";
        cout.precision(3);
        cout << "   " << cb.px << " " << cb.py << "  ";
        cout << "    ";
        if (!cb.noComm)
            cout << "Y";
        else
            cout << "N";
        cout.precision(6);
        cout << "     " << cb.niters << " ";
        cout.precision(4);
        cout << " " << t0 << " " << gf << "  ";

        cout.unsetf(ios::fixed);
        cout.setf(ios::scientific);
        cout.precision(5);
        cout << "  " << mx << " " << l2norm << endl;
        // new added
        cout << "MPI Processes: " << nprocs << endl;
        cout << "OpenMP Threads: " << threads << endl;
        cout << "  -----" << endl;
        // Write metrics to the file
        // Call the CSV writer function
        writeFinalMetricsToFile(l2norm, mx, t0, cb.m, cb.n, cb.px, cb.py, cb.niters, gf, nprocs, threads);
    }

#ifdef _MPI_
    MPI_Barrier(MPI_COMM_WORLD);
#endif
}

void ReportStart(double dt)
{
    int myrank;
#ifdef _MPI_
    MPI_Comm_rank(MPI_COMM_WORLD, &myrank);
#else
    myrank = 0;
#endif
    printTOD("Simulation begins");
    if (!myrank)
    {
        cout << "dt= " << dt << ", ";
        cout << "# iters = " << cb.niters << endl;
        cout << "m x n = " << cb.m << " x " << cb.n << endl;
        cout << "processor geometry: " << cb.px << " x " << cb.py << endl;
        cout << endl;

#ifdef SSE_VEC
        cout << "Using SSE Intrinsics\n";
#endif

#ifdef _MPI_
        cout << "Compiled with MPI ENABLED\n";
        if (cb.noComm)
        {
            cout << "Communication shut off" << endl;
        }
#else
        cout << "Compiled with MPI DISABLED\n";
#endif
    }
#ifdef _MPI_
    MPI_Barrier(MPI_COMM_WORLD);
#endif
#ifdef _OPENMP
    cout << "Compiled with OpenMP ENABLED\n";
    cout << "Using " << omp_get_max_threads() << " threads\n";
#else
    cout << "Compiled with OpenMP DISABLED\n";
#endif

#ifdef FUSED
    cout << "Fused computation mode ENABLED\n";
#else
    cout << "Fused computation mode DISABLED\n";
#endif
}
