%{
triangle threshold algorithm
takes arbitrary EMG input data
outputs positive and negative thresholds
along with 'Williams Index of Spiking' (WIS)
%}
function [thrPos,thrNeg,WIS] = FPT_triangleThreshold(inputData,plotFlag)


%% triangle threshold on positive side
%histogram to get counts (positive side only)
[countsPos] = histcounts(inputData.*(inputData>=0),0:1:round(max(inputData)));
%cut off histogram at first zero
edgePos = find(countsPos<1,1);
if isempty(edgePos)
    edgePos = length(countsPos);
end
edgesPos = 1:1:edgePos;
%remake histogram capped at that first zero
[countsPos] = histcounts(inputData.*(inputData>=0),edgesPos);
%rescale counts to make math easier
XPos = rescale(edgesPos(1:end-1));
YPos = rescale(cumsum(countsPos));
%perpendicular line is maximized when X-Y is maximized (rescaled data)
[MPos,IPos] = max(abs(YPos-XPos));
maxXPos = XPos(IPos);
maxYPos = YPos(IPos);
%get actual threshold
thrPos = edgesPos(IPos);
inputPos = inputData.*(inputData>=thrPos);
inputPos(inputPos==0) = NaN;

%% triangle threshold on negative side
%histogram to get counts (use both positive and negative separately)
[countsNeg] = histcounts(-1*inputData.*(inputData<=0),-1*(0:-1:round(min(inputData))));
%cut off histogram at first zero
edgeNeg = find(countsNeg<1,1);
if isempty(edgeNeg)
    edgeNeg = length(countsNeg);
end
edgesNeg = 1:1:edgeNeg;
%remake histogram capped at that first zero
[countsNeg] = histcounts(-1*inputData.*(inputData<=0),edgesNeg);
%rescale counts to make math easier
XNeg = (rescale(edgesNeg(1:end-1)));
YNeg = (rescale(cumsum(countsNeg)));
%perpendicular line is maximized when X-Y is maximized (rescaled data)
[MNeg,INeg] = max(abs(YNeg-XNeg));
maxXNeg = XNeg(INeg);
maxYNeg = YNeg(INeg);
%get actual threshold
thrNeg = -1*edgesNeg(INeg);
inputNeg = inputData.*(inputData<=thrNeg);
inputNeg(inputNeg==0) = NaN;

%% calculate 'Williams Index of Spiking (WIS)' from x-value of max point
WIS = 1 - (maxXPos + maxXNeg)/2;

%% Plot triangle thresholds
if plotFlag == 1
    figure('NumberTitle','off','Name','Triangle Threshold');
    tiledlayout(1,3);
    nexttile;
    plot((1:30000)/30000,inputData(1:30000));
    title('First second of data');
    ylabel('Voltage');
    xlabel('Time (s)');
    axis square
    
    nexttile;
    plot(edgesPos(1:end-1),countsPos,'k');
    title('Histogram');
    ylabel('histogram counts');
    xlabel('voltage level');
    axis square

    % figure('NumberTitle','off','Name','Triangle Threshold'); tiledlayout(1,2);
    %positive side
    nexttile; hold on;
    plot(XPos,YPos,'k-*');
    plot([maxXPos,(maxXPos+maxYPos)/2],[maxYPos,(maxXPos+maxYPos)/2],'g-*');
    plot([XPos(1),XPos(end)],[YPos(1),YPos(end)],'r--');
    title(['Positive Thr = ',num2str(thrPos),', WIS = ',num2str(1-maxXPos,2)]);
    ylabel('CDF');
    xlabel('voltage level (rescaled)');
    legend('histcounts','knee');
    axis square
    % %negative side
    % nexttile; hold on;
    % plot(XNeg,YNeg,'k-*');
    % plot([XNeg(1),XNeg(end)],[YNeg(1),YNeg(end)],'r--');
    % plot([maxXNeg,(maxXNeg+maxYNeg)/2],[maxYNeg,(maxXNeg+maxYNeg)/2],'g-*');
    % title(['Negative Thr = ',num2str(thrNeg),', WIS = ',num2str(1-maxXNeg,2)]);
    % xlabel('histogram counts (rescaled)');
    % ylabel('voltage level (rescaled)');
    % legend('histcounts','connection');
    % axis square

    figure('NumberTitle','off','Name',['Thr = (',num2str(thrPos),', ',num2str(thrNeg),'), WIS = ',num2str(WIS)]); hold on;
    plot((1:length(inputData))/30000,inputData,'k');
    plot([0,length(inputData)/30000],[thrPos,thrPos],'g--');
    plot([0,length(inputData)/30000],[thrNeg,thrNeg],'g--');
    plot((1:length(inputData))/30000,inputPos,'c');
    plot((1:length(inputData))/30000,inputNeg,'m');
    title(['WIS = ',num2str(WIS,2)]);
    xlabel('time (s)');
    ylabel('voltage (AU)');
end





end




