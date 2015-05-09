nColl=$1
nDocs=$2
nLoader=$3
nMins=$4
mongoDir=$5
javaBin=$6

shift 6
nthreads=( "$@" )
for num_thr in "${nthreads[@]}" ; do
  echo Will run for $num_thr threads
done

echo load
bash run.simple.bash yes no $nColl $nDocs 10 $nLoader $nThr 1 1 1 1 1 1 1 1 1 1

echo point query, v1
for nt in "${nthreads[@]}" ; do bash run.simple.bash no yes $nColl $nDocs 10 1 $nt $nMins 1 0 0 0 0 0 0 0 $mongoDir $javaBin; mkdir pq1.nt${nt}; mv r.* mongoSysbenchExecute-* pq1.nt${nt} ; done

for nt in "${nthreads[@])}" ; do grep "cum tps"  pq1.nt${nt}/mongoSysbenchExecute-${nColl}-${nDocs}-${nt}.txt | tail -1; done > pq1.res

echo range query, v1
for nt in "${nthreads[@]}" ; do bash run.simple.bash no yes $nColl $nDocs 10 1 $nt $nMins 0 1 0 0 0 0 0 0 $mongoDir $javaBin; mkdir rq1.nt${nt}; mv r.* mongoSysbenchExecute-* rq1.nt${nt} ; done

for nt in "${nthreads[@])}" ; do grep "cum tps"  rq1.nt${nt}/mongoSysbenchExecute-${nColl}-${nDocs}-${nt}.txt | tail -1; done > rq1.res

echo non-indexed update, v1
for nt in "${nthreads[@]}" ; do bash run.simple.bash no yes $nColl $nDocs 10 1 $nt $nMins 0 0 0 0 0 0 1 0 $mongoDir $javaBin; mkdir niu1.nt${nt}; mv r.* mongoSysbenchExecute-* niu1.nt${nt} ; done

for nt in "${nthreads[@])}" ; do grep "cum tps"  niu1.nt${nt}/mongoSysbenchExecute-${nColl}-${nDocs}-${nt}.txt | tail -1; done > niu1.res

echo point query, v2
for nt in "${nthreads[@]}" ; do bash run.simple.bash no yes $nColl $nDocs 10 1 $nt $nMins 1 0 0 0 0 0 0 0 $mongoDir $javaBin; mkdir pq2.nt${nt}; mv r.* mongoSysbenchExecute-* pq2.nt${nt} ; done

for nt in "${nthreads[@])}" ; do grep "cum tps"  pq2.nt${nt}/mongoSysbenchExecute-${nColl}-${nDocs}-${nt}.txt | tail -1; done > pq2.res

echo range query, v2
for nt in "${nthreads[@]}" ; do bash run.simple.bash no yes $nColl $nDocs 10 1 $nt $nMins 0 1 0 0 0 0 0 0 $mongoDir $javaBin; mkdir rq2.nt${nt}; mv r.* mongoSysbenchExecute-* rq2.nt${nt} ; done

for nt in "${nthreads[@])}" ; do grep "cum tps"  rq2.nt${nt}/mongoSysbenchExecute-${nColl}-${nDocs}-${nt}.txt | tail -1; done > rq2.res

echo indexed update, v1
for nt in "${nthreads[@]}" ; do bash run.simple.bash no yes $nColl $nDocs 10 1 $nt $nMins 0 0 0 0 0 1 0 0 $mongoDir $javaBin; mkdir iu1.nt${nt}; mv r.* mongoSysbenchExecute-* iu1.nt${nt} ; done

for nt in "${nthreads[@])}" ; do grep "cum tps"  iu1.nt${nt}/mongoSysbenchExecute-${nColl}-${nDocs}-${nt}.txt | tail -1; done > iu1.res

for tn in pq1 rq1 niu1 pq2 rq2 iu1 ; do
  echo $tn
  cat $tn.res
  echo
done

