Note: This project was executed as a part of the CSE 260 Parallel Computation course by Bryan Chin at UC San Diego in Fall 2022.
-  ./apf -n 800 -i 2000 -p 100        // run serial code 
- mpirun ./apf -n 800 -i 2000 -p 100  // run mpi code 
# compile (is compiled with both openmp and openmpi)
  - make         // compile without mpi 
  - make mpi=1   // compile with mpi 
  - make mpi=1 fused=1 // compile with mpi and fused directive enabled (performance) 
  - make clean   // clen build 
## run 
 - With OpenMP (single process, multiple threads):
    - export OMP_NUM_THREADS=4 && ./apf  
 - With MPI and OpenMP
   - export OMP_NUM_THREADS=4 && mpirun -np 2 ./apf
 - with MPI only 
   (If your program has been compiled with OpenMP support   
   (-fopenmp), you can effectively disable OpenMP by setting the number of threads to 1 using the OMP_NUM_THREADS environment variable. )
   
   - export OMP_NUM_THREADS=1 && mpirun -np 2 ./apf
 - With No openMpi or openMP 
   If the program was compiled with OpenMP support but you want to enforce a single thread at runtime, set the following environment variable:
   
    - export OMP_NUM_THREADS=1 &&  ./apf
 - inorder to run with fused (opimized ODE) you need to compile the code using fused=1,if not it will run with less optimized code but the openmp is enabled to run with out openmp just prvide the OMP_NUM_THREADS=1 
