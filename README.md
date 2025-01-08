

## About the Project
This assignment 4 was executed as a part of the **distributed for AI and parallel programming** course at **AAIT** in **2024**.

---
## Compilation Instructions
- Compile without MPI:
  ```bash
  make
  ```
- Compile with MPI:
  ```bash
  make mpi=1
  ```
- Compile with MPI,openmp,and Fused Directive (for optimized performance):
  ```bash
  make mpi=1 fused=1 openmp=1
  ```
- Clean the build:
  ```bash
  make clean
  ```

---

## Running the Code
- **Run Serial Code**:
  ```bash
  ./apf -n 800 -i 2000 -p 100
  ```
- **Run MPI Code**:
  ```bash
  mpirun ./apf -n 800 -i 2000 -p 100
  ```
- **Run MPI and openmp Code**:
  ```bash
  export OMP_NUM_THREADS=4 && mpirun -np 2 ./apf
- **Run MPI and openmp Code**:
  - Disable OpenMP by setting the number of threads to 1
  ```bash
    export OMP_NUM_THREADS=1 && mpirun -np 2 ./apf
  ```
---




