function [decodedMsg] = hova(encodedMsg,nInputBits,nOutputBits,numStates,nextState,outputs)
% hova decodes a convolutionally coded vector using the hard output viterbi algorithm.
    % codedMsg is the binary convolutionally encoded vector
    % numStates : the number of states of the encoder
    % nextStates : a matrix that describes how the encoder jumps from one
    % state to the other (detailed description of this matrix is found in
    % matlab's Documentation)
    % outputs is a matrix that describes the output of the encoder for each
    % state change (detailed description of this matrix is found in
    % matlab's Documentation)
    % it is supposed that the encoder always starts from state 1 which
    % corresponds to the shift registers being full with zeros
    r = nOutputBits/nInputBits;
    N = length(encodedMsg)/r;
    pathMetric = inf(numStates,N);
    pathHistory = zeros(numStates,N);
    outputNodes = [ 1 zeros(1,numStates-1) ];
    outputNodesTemp = outputNodes;
    %% FORWARD PASS
    for k = 1 : N
        msg=encodedMsg(k*r-1:k*r);
        for i = 1 : numStates 
            if outputNodes(i) == 1 
                for j = 1 : nInputBits
                    outputNodesTemp(nextState(i,j))=1;
                    hammingDis = hamming(outputs(i,j),bi2de(msg,'left-msb') );
                    pathCost = hammingDis;
                    if k ~= 1 
                        pathCost =  pathCost + pathMetric(i,k-1);
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
    oldState = pathHistory(newState,N);
    decodedMsg = zeros(1,N);
    for n = N :-1: 1 
        for j = 1 : nInputBits
            if nextState(oldState,j) == newState
                decodedMsg(n)=j-1;
            end
        end
        newState=oldState;
        if n == 1 
            oldState = 1;
        else
            oldState = pathHistory(newState,n-1);
        end
    end
    pathMetric;
    pathHistory;
    
    
end

