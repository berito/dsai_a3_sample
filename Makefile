# # Compiler and flags
# CXX = g++
# # CXXFLAGS = -O2 -std=c++11 -Wall
# CXXFLAGS = -O2 -std=c++11
# LDFLAGS = 
# LDLIBS = -lm

# # Application name
# APP = apf

# # Source files
# SOURCES = apf.cpp solve.cpp Plotting.cpp cmdLine.cpp Report.cpp utils.cpp helper.cpp Timer.cpp

# # Object files (inside build directory)
# BUILD_DIR = build
# OBJECTS = $(addprefix $(BUILD_DIR)/, $(SOURCES:.cpp=.o))

# # Default target
# all: $(BUILD_DIR) $(APP)

# # Create the build directory if it doesn't exist
# $(BUILD_DIR):
# 	mkdir -p $(BUILD_DIR)

# # Build the application
# $(APP): $(OBJECTS)
# 	$(CXX) $(LDFLAGS) -o $@ $(OBJECTS) $(LDLIBS)

# # Rule to build object files in the build directory
# $(BUILD_DIR)/%.o: %.cpp
# 	$(CXX) $(CXXFLAGS) -c $< -o $@

# # Clean up build artifacts
# .PHONY: clean
# clean:
# 	rm -rf $(BUILD_DIR) $(APP)
# Compiler and flags
# ifeq ($(mpi), 1)
# CXX = mpic++
# CXXFLAGS = -O2 -std=c++11 -fopenmp -DMPI_ENABLED  -D_MPI_
# LDLIBS = -lm -lmpi
# else
# CXX = g++
# CXXFLAGS = -O2 -std=c++11 -fopenmp
# LDLIBS = -lm
# endif

# # Add Fused Functionality Flag
# ifeq ($(fused), 1)
# CXXFLAGS += -DFUSED
# endif

# LDFLAGS = 

# # Application name
# APP = apf

# # Source files
# SOURCES = apf.cpp solve.cpp Plotting.cpp cmdLine.cpp Report.cpp utils.cpp helper.cpp Timer.cpp

# # Object files (inside build directory)
# BUILD_DIR = build
# OBJECTS = $(addprefix $(BUILD_DIR)/, $(SOURCES:.cpp=.o))

# # Default target
# all: $(BUILD_DIR) $(APP)

# # Create the build directory if it doesn't exist
# $(BUILD_DIR):
# 	mkdir -p $(BUILD_DIR)

# # Build the application
# $(APP): $(OBJECTS)
# 	$(CXX) $(LDFLAGS) -o $@ $(OBJECTS) $(LDLIBS)

# # Rule to build object files in the build directory
# $(BUILD_DIR)/%.o: %.cpp
# 	$(CXX) $(CXXFLAGS) -c $< -o $@

# # Clean up build artifacts
# .PHONY: clean
# clean:
# 	rm -rf $(BUILD_DIR) $(APP)

# Compiler and flags
ifeq ($(mpi), 1)
CXX = mpic++
CXXFLAGS = -O2 -std=c++11 -DMPI_ENABLED -D_MPI_
LDLIBS = -lm -lmpi
else
CXX = g++
CXXFLAGS = -O2 -std=c++11
LDLIBS = -lm
endif

# Enable OpenMP
ifeq ($(openmp), 1)
CXXFLAGS += -fopenmp
LDFLAGS += -fopenmp
endif

# Enable Fused Functionality
ifeq ($(fused), 1)
CXXFLAGS += -DFUSED
endif

# Application name
APP = apf

# Source files
SOURCES = apf.cpp solve.cpp Plotting.cpp cmdLine.cpp Report.cpp utils.cpp helper.cpp Timer.cpp

# Object files (inside build directory)
BUILD_DIR = build
OBJECTS = $(addprefix $(BUILD_DIR)/, $(SOURCES:.cpp=.o))

# Default target
all: $(BUILD_DIR) $(APP)

# Create the build directory if it doesn't exist
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Build the application
$(APP): $(OBJECTS)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) $(LDLIBS)

# Rule to build object files in the build directory
$(BUILD_DIR)/%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Clean up build artifacts
.PHONY: clean
clean:
	rm -rf $(BUILD_DIR) $(APP)
