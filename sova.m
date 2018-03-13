function [decodedMsg] = sova(encodedMsg,nInputBits,nOutputBits,numStates,nextState,outputs)
    r = nOutputBits/nInputBits;
    N = length(encodedMsg)/r;
    pathMetric = inf(numStates,N);
    pathHistory = zeros(numStates,N);
    outputNodes = [ 1 zeros(1,numStates-1) ];
    diffMetric = inf(numStates,N);
    reliability = inf(numStates,N); 
    outputNodesTemp = outputNodes;
    metricDiff=0;
    Kd=2;
    %% FORWARD PASS
    for k = 1 : N
        msg=encodedMsg(k*r-1:k*r);
        for i = 1 : numStates 
            if outputNodes(i) == 1 
                for j = 1 : nInputBits
                    outputNodesTemp(nextState(i,j))=1;
                    pathCost =hamming(outputs(i,j),bi2de(msg,'left-msb') );
                    if k ~= 1 
                        pathCost =  pathCost + pathMetric(i,k-1);
                    end
                    pathHistoryTemp = pathHistory;
                    if  pathMetric(nextState(i,j),k) ~= inf
                        metricDiff=abs(pathMetric(nextState(i,j),k)-pathCost);
                        diffMetric(nextState(i,j),k)=metricDiff;
                        seq1 = traceback(nextState(i,j),pathHistoryTemp,nextState,k,nInputBits,Kd);
                        pathHistoryTemp(nextState(i,j),k)=i;
                        seq2 = traceback(nextState(i,j),pathHistoryTemp,nextState,k,nInputBits,Kd);
                        if pathCost > pathMetric(nextState(i,j),k)
                            pathHistoryTemp=pathHistory;
                        end
                        newState=nextState(i,j);
                        oldState = pathHistoryTemp(newState,k);
                        e=k-Kd;
                        if e < 1
                            e=1;
                        end
                        for l = k:-1:e
                            if l ==k
                                reliability(newState,l)=metricDiff;
                            else
                                if seq2(l) ~= seq1(l) 
                                    reliability(newState,l)=min(metricDiff,reliability(newState,l));
                                end
                            end
                        newState=oldState;
                        if l == 1
                            oldState=1;
                        else
                            oldState = pathHistoryTemp(newState,l-1);
                        end
                        end
                        end
                        if pathCost < pathMetric(nextState(i,j),k)
                        pathMetric(nextState(i,j),k)=pathCost;
                        pathHistory(nextState(i,j),k)=i;
                    end
                end
            end
        end
        outputNodes = outputNodesTemp;
    end
    %% TRACEBACK
    [metric,newState] = min(pathMetric(:,N));
    decodedMsg = traceback(newState,pathHistory,nextState,N,nInputBits,N-1);
        reliabilityVect = zeros(1,N);
    oldState = pathHistory(newState,N);
    for n = N :-1: 1 
        reliabilityVect(n)=reliability(newState,n);
        newState=oldState;
        if n == 1 
            oldState = 1;
        else
            oldState = pathHistory(newState,n-1);
        end
    end
    reliabilityVect
end
