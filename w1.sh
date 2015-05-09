nColl=$1
nDocs=$2
nLoader=$3
nMins=$4

shift 4
nthreads=( "$@" )
for num_thr in "${nthreads[@]}" ; do
  echo Will run for $num_thr threads
done

echo load
bash run.simple.bash yes no $nColl $nDocs 10 $nLoader $nThr 1 1 1 1 1 1 1 1 1 1

echo point query, v1
for nt in "${nthreads[@]}" ; do bash run.simple.bash no yes $nColl $nDocs 10 1 $nt $nMins 1 0 0 0 0 0 0 0; mkdir pq.nt${nt}; mv r.* mongoSysbenchExecute-* pq.nt${nt} ; done

echo range query, v1
for nt in "${nthreads[@]}" ; do bash run.simple.bash no yes $nColl $nDocs 10 1 $nt $nMins 0 1 0 0 0 0 0 0; mkdir rq1.nt${nt}; mv r.* mongoSysbenchExecute-* rq1.nt${nt} ; done

echo non-indexed update, v1
for nt in "${nthreads[@]}" ; do bash run.simple.bash no yes $nColl $nDocs 10 1 $nt $nMins 0 0 0 0 0 0 1 0; mkdir niu1.nt${nt}; mv r.* mongoSysbenchExecute-* niu1.nt${nt} ; done

echo point query, v2
for nt in "${nthreads[@]}" ; do bash run.simple.bash no yes $nColl $nDocs 10 1 $nt $nMins 1 0 0 0 0 0 0 0; mkdir pq2.nt${nt}; mv r.* mongoSysbenchExecute-* pq2.nt${nt} ; done

echo range query, v2
for nt in "${nthreads[@]}" ; do bash run.simple.bash no yes $nColl $nDocs 10 1 $nt $nMins 0 1 0 0 0 0 0 0; mkdir rq2.nt${nt}; mv r.* mongoSysbenchExecute-* rq2.nt${nt} ; done

echo indexed update, v1
for nt in "${nthreads[@]}" ; do bash run.simple.bash no yes $nColl $nDocs 10 1 $nt $nMins 0 0 0 0 0 1 0 0; mkdir iu1.nt${nt}; mv r.* mongoSysbenchExecute-* iu1.nt${nt} ; done
