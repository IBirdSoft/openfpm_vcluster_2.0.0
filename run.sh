#! /bin/bash

# Make a directory in /tmp/openfpm_data

workspace=$1
hostname=$2
nproc=$3
branch=$4

echo "Directory: $workspace"
echo "Machine: $hostname"
echo "Nproc: $nproc"
echo "Branch: $branch"


if [ "$hostname" == "wetcluster" ]; then

export MODULEPATH="/sw/apps/modules/modulefiles:$MODULEPATH"

 ## Run on the cluster
 bsub -o output_run2.%J -K -n 2 -R "span[hosts=1]" "module load openmpi/1.8.1 ; module load gcc/4.9.2;  mpirun -np $nproc ./src/vcluster_test"
 if [ $? -ne 0 ]; then exit 1 ; fi

elif [ "$hostname" == "taurus" ]; then
 echo "Running on taurus"

 echo "$PATH"
 module load gcc/5.3.0
 module load boost/1.60.0
 module load openmpi/1.10.2-gnu
 module unload bullxmpi

### to exclude --exclude=taurusi[6300-6400],taurusi[5400-5500]

 salloc --nodes=1 --ntasks-per-node=$nproc --time=00:05:00 --mem-per-cpu=1800 --partition=haswell bash -c "ulimit -s unlimited && mpirun -np $nproc src/vcluster_test --report_level=no"
 if [ $? -ne 0 ]; then exit 1 ; fi
 sleep 5
# salloc --nodes=2 --ntasks-per-node=24 --time=00:05:00 --mem-per-cpu=1800 --partition=haswell bash -c "ulimit -s unlimited && mpirun -np 48 src/vcluster_test --report_level=no"
# if [ $? -ne 0 ]; then exit 1 ; fi
# sleep 5
# salloc --nodes=4 --ntasks-per-node=24 --time=00:05:00 --mem-per-cpu=1800 --partition=haswell bash -c "ulimit -s unlimited && mpirun -np 96 src/vcluster_test --report_level=no"
# if [ $? -ne 0 ]; then exit 1 ; fi
# sleep 5
# salloc --nodes=8 --ntasks-per-node=24 --time=00:05:00 --mem-per-cpu=1800 --partition=haswell bash -c "ulimit -s unlimited && mpirun -np 192 src/vcluster_test --report_level=no"
# if [ $? -ne 0 ]; then exit 1 ; fi
# sleep 5
# salloc --nodes=10 --ntasks-per-node=24 --time=00:5:00 --mem-per-cpu=1800 --partition=haswell bash -c "ulimit -s unlimited && mpirun -np 240 src/vcluster_test --report_level=no"
# if [ $? -ne 0 ]; then exit 1 ; fi

else

 export PATH="$PATH:$HOME/openfpm_dependencies/openfpm_vcluster/MPI/bin"
 export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$HOME/openfpm_dependencies/openfpm_vcluster/BOOST/lib"
 export DYLD_LIBRARY_PATH="$DYLD_LIBRARY_PATH:$HOME/openfpm_dependencies/openfpm_vcluster/BOOST/lib"


 cd openfpm_vcluster
 mpirun --oversubscribe -np $nproc ./build/src/vcluster_test
 if [ $? -ne 0 ]; then exit 1 ; fi
fi


