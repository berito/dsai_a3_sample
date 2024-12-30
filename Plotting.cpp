// // #include <iostream>
// // #include "cblock.h"
// // #include "Plotting.h"
// // using namespace std;

// // extern control_block cb;

// // Plotter::Plotter() {
// //     gnu_pipe = popen("gnuplot","w");
// // }

// // void Plotter::updatePlot(double *U,  int niter, int m, int n){
// //     double mx= -1.0e10, mn = 1.0e10;

// //     for (int i=0; i<(m+2)*(n+2); i++){
// //        if (U[i] > mx)
// //            mx = U[i];
// //        if (U[i] < mn)
// //            mn = U[i];
// //        }
// // //    fprintf(gnu_pipe, "\n\nunset key\n");
// //     fprintf(gnu_pipe, "set title \"niter = %d\n",niter);
// //     fprintf(gnu_pipe, "set xrange [0:%d]\n", m);
// //     fprintf(gnu_pipe, "set yrange [0:%d]\n", n);
// //     fprintf(gnu_pipe, "set size square\n");
// //     fprintf(gnu_pipe, "set key off\n");
// //     fprintf(gnu_pipe, "set pm3d map\n");
// //     fprintf(gnu_pipe, "set palette defined (-3 \"blue\", 0 \"white\", 1 \"red\")\n");

// // //    fprintf(gnu_pipe, "plot \"-\" with points lt 1 pt 10 ps 1\n");
// // // Various color schemes
// // // fprintf(gnu,"set palette rgbformulae 22, 13, 31\n");
// // // fprintf(gnu,"set palette rgbformulae 30, 31, 32\n");

// //     // Write out the coordinates of the particles
// //     fprintf(gnu_pipe,"splot [0:%d] [0:%d][%f:%f] \"-\"\n",m-2,n-2,mn,mx);
// // for (int i=0; i<(m+2)*(n+2); i++) {
// //             int I = i / (n+2);
// //             int J = i % (n+2);
// //             fprintf(gnu_pipe,"%d %d %f\n", I, J, U[i]);
// //             if (J == n+1)
// //                 fprintf(gnu_pipe,"\n");
// //     }
// //     fprintf(gnu_pipe, "e\n");

// //     fflush(gnu_pipe);

// //   if (cb.wait){
// //       cout << "Type any key to continue...\n";
// //       int dummy;
// //       cin >> dummy;
// //   }
// // }

// // Plotter::~Plotter() {
// //     pclose(gnu_pipe);
// // }
// #include "Plotting.h"
// #include <cstdio>  // For FILE and popen/pclose
// #include <cstdlib> // For exit
// #include <iostream>
// using namespace std;

// Plotter::Plotter() {
//     // Open Gnuplot pipe once
//     gnu_pipe = popen("gnuplot", "w");
//     if (!gnu_pipe) {
//         cerr << "Error: Could not open Gnuplot pipe.\n";
//         exit(1);
//     }

//     // Configure Gnuplot for a single persistent window
//     fprintf(gnu_pipe, "set terminal x11 persist\n"); // Use the same GUI window
//     fprintf(gnu_pipe, "set pm3d map\n");
//     fprintf(gnu_pipe, "set size square\n");
//     fprintf(gnu_pipe, "set key off\n");
//     fprintf(gnu_pipe, "set palette defined (-3 \"blue\", 0 \"white\", 1 \"red\")\n");
//     fflush(gnu_pipe);
// }

// void Plotter::updatePlot(double *U, int niter, int m, int n) {
//     double mx = -1.0e10, mn = 1.0e10;

//     // Find the min and max values for scaling
//     for (int i = 0; i < (m + 2) * (n + 2); i++) {
//         if (U[i] > mx) mx = U[i];
//         if (U[i] < mn) mn = U[i];
//     }

//     // Update the plot title and axis ranges
//     fprintf(gnu_pipe, "set title \"Iteration = %d\"\n", niter);
//     fprintf(gnu_pipe, "set xrange [0:%d]\n", m - 1);
//     fprintf(gnu_pipe, "set yrange [0:%d]\n", n - 1);
//     fprintf(gnu_pipe, "set zrange [%f:%f]\n", mn, mx);

//     // Send data to Gnuplot
//     fprintf(gnu_pipe, "splot '-' using 1:2:3 with pm3d\n");
//     for (int i = 0; i < (m + 2) * (n + 2); i++) {
//         int I = i / (n + 2);
//         int J = i % (n + 2);
//         fprintf(gnu_pipe, "%d %d %f\n", I, J, U[i]);
//         if (J == n + 1) fprintf(gnu_pipe, "\n");
//     }
//     fprintf(gnu_pipe, "e\n");
//     fflush(gnu_pipe);
// }

// Plotter::~Plotter() {
//     if (gnu_pipe) {
//         pclose(gnu_pipe); // Close Gnuplot pipe
//         gnu_pipe = NULL;
//     }
// }
#include "Plotting.h"
#include <cstdlib>
#include <iostream>
using namespace std;

Plotter::Plotter() {
    cout << "Opening Gnuplot pipe...\n";
    gnu_pipe = popen("gnuplot", "w");
    if (!gnu_pipe) {
        cerr << "Error: Could not open Gnuplot pipe.\n";
        exit(1);
    }

    // Configure Gnuplot settings once
    fprintf(gnu_pipe, "set terminal x11 persist\n");
    fprintf(gnu_pipe, "set pm3d map\n");
    fprintf(gnu_pipe, "set size square\n");
    fprintf(gnu_pipe, "set key off\n");
    fprintf(gnu_pipe, "set palette defined (-3 \"blue\", 0 \"white\", 1 \"red\")\n");
    fflush(gnu_pipe);
}

void Plotter::updatePlot(double *U, int niter, int m, int n) {
    double mx = -1.0e10, mn = 1.0e10;

    // Find the min and max values for scaling
    for (int i = 0; i < (m + 2) * (n + 2); i++) {
        if (U[i] > mx) mx = U[i];
        if (U[i] < mn) mn = U[i];
    }

    // Update title and axis ranges
    fprintf(gnu_pipe, "set title 'Iteration = %d'\n", niter);
    fprintf(gnu_pipe, "set xrange [0:%d]\n", m - 1);
    fprintf(gnu_pipe, "set yrange [0:%d]\n", n - 1);
    fprintf(gnu_pipe, "set zrange [%f:%f]\n", mn, mx);

    // Send data to Gnuplot dynamically
    fprintf(gnu_pipe, "splot '-' using 1:2:3 with pm3d\n");
    for (int i = 0; i < (m + 2) * (n + 2); i++) {
        int I = i / (n + 2);
        int J = i % (n + 2);
        fprintf(gnu_pipe, "%d %d %f\n", I, J, U[i]);
        if (J == n + 1) fprintf(gnu_pipe, "\n");
    }
    fprintf(gnu_pipe, "e\n");
    fflush(gnu_pipe);
}

Plotter::~Plotter() {
    if (gnu_pipe) {
        cout << "Closing Gnuplot pipe...\n";
        pclose(gnu_pipe); // Close Gnuplot pipe
    }
}

