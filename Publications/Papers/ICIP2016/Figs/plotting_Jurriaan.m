function y = makeRootDensityContourPlot()


    x = 0 : 0.01 : 3.4;
    d = 0 : 0.01 : 4.5;

    [D,X] = ndgrid(d,x);

    sigm         = 0.50;
    growFact     = 0.05;
    rCanopy      = 2.00;
    maxRootDepth = 4.00;

    [Y,domainVec] = testLogNormalRootDensity(sigm, growFact, rCanopy, maxRootDepth, X(:), D(:));

    subplotScreen(2,3,1)

    cLevels = [0.1:0.1:0.9];
    C = contourc(x,d,reshape(Y,[numel(d),numel(x)]),cLevels);
    cLimLow = 0.0;
    cLimHigh = 0.9;

    nLevels = numel(cLevels);
    pos = [0.12, 0.1, 0.55, 0.8];
    L = pos(1) + pos(3);
    B = pos(2);
    H = 0.045;

    clf

    for iLevel = -1:nLevels

        axes('Position',[L + 0.05,B + iLevel * (H + 0.02), 0.05, H])
        set(gca,'XTick',[])
        set(gca,'YTick',0.0)
        set(gca,'TickLength',[0,0])
        set(gca,'box','on')
        set(gca,'YAxisLocation','right')
        set(gca,'FontSize',12)
        set(gca,'FontName','Arial')
        set(gca,'FontWeight','demi')


        if iLevel == -1
            plot([-0.5,0.5],[0,0],'-.k','LineWidth',2)
            axis tight
            axis off
            text(0.6,0.5,[char(10),'valid domain'],....
                'FontSize',12,...
                'FontName','Arial',...
                'FontWeight','demi',...
                'verticalalign','middle')
        elseif iLevel == 0
            patch(0.5*[-1,1,1,-1,-1],0.5*[1,1,-1,-1,1],'k',...
                'FaceColor',0.8*[1,1,1])
            set(gca,'YTickLabel','0.0 - 0.1')
        else
            cLevel = cLevels(iLevel);
            f = (cLevel - cLimLow) / (cLimHigh - cLimLow);
            patch(0.5*[-1,1,1,-1,-1],0.5*[1,1,-1,-1,1],'k','FaceColor',(0.8-f*0.8) * [1,1,1])
            axis tight
            if iLevel == nLevels
                set(gca,'YTickLabel',sprintf('%.1f - 1.0',cLevels(iLevel)))
            else
                set(gca,'YTickLabel',sprintf('%.1f - %.1f',cLevels(iLevel),cLevels(iLevel+1)))
            end
        end
        if iLevel == nLevels
            title(['relative',char(10),'root density'],'horizontalalign','center')
        end


    end

    axes('Position',pos)

    set(gca,'LineWidth',2)
    hold on
    patch(domainVec.x,domainVec.y,'k','FaceColor',0.8 * [1,1,1],'EdgeColor','none')
    plot(domainVec.x,domainVec.y,'-.k','linewidth',2)

    iElem = 1;
    iPath = 2987;
    while iElem < size(C,2)

        cLevel = cLevels(C(1,iElem) == cLevels);
        nElems = C(2,iElem);

        f = (cLevel - cLimLow) / (cLimHigh - cLimLow);
        % read x and y
        xv = C(1,iElem+(1:nElems));
        yv = C(2,iElem+(1:nElems));

        [xv,yv] = getPatch(xv,yv);
        patch(xv,yv,'k','FaceColor',(0.8-f*0.8) * [1,1,1])


        iElem = iElem + nElems + 1;
        iPath = iPath + 1;

    end

    plot([1,1]*rCanopy,[d(1),d(end)],'--','LineWidth',2,'Color',[1,1,1]*0.5)
    plot([1,1]*rCanopy + exp(-sigm^2),[d(1),d(end)],'--','LineWidth',2,'Color',[1,1,1]*0.5)
    axis image
    colormap('gray')
    set(gca,'FontSize',12)
    set(gca,'FontName','Arial')
    set(gca,'FontWeight','demi')
    set(gca,'LineWidth',2)
    set(gca,'YDir','reverse')
    set(gca,'Color','none')
    set(gca,'XLim',[0, 3.2])
    set(gca,'YLim',[0, 4.5])
    set(gca,'XTick',[rCanopy, rCanopy + exp(-sigm^2)])
    set(gca,'XTickLabel',[])
    set(gca,'YTick',[1,2,3,4,5])
    set(gca,'YTickLabel',num2str(get(gca,'YTick')','%.1f'))
    set(gca,'TickDir','out')
    set(gca,'layer','top')
    set(gca,'box','on')
    set(gca,'XAxisLocation','top')

    text(rCanopy,4.9,'r_c','Interpreter','tex',...
        'FontSize',12,...
        'FontName','Arial',...
        'FontWeight','demi')
    text(rCanopy +  exp(-sigm^2),4.9,'r_{r}(d=0)','Interpreter','tex',...
        'FontSize',12,...
        'FontName','Arial',...
        'FontWeight','demi')

    xlabel(['distance from tree trunk \rightarrow'])
    ylabel(['\leftarrow depth [m]',char(10)])


    set(gcf,'Color',[1,0,0])
    set(gcf,'PaperSize',[5.6,4.6])
    set(gcf,'PaperPositionMode','auto')
%     set(gcf,'InvertHardCopy','off')
%     print(gcf,'-dpng','-r300','contourf-root-density-distribution.png')

    print(gcf,'-dpdf','-loose','contourf-root-density-distribution.pdf')


end


function [x,y] = getPatch(x,y)

        % close path:
        x = [x,x(1)];
        y = [y,y(1)];
        % remove NaNs
        io = isnan(x) | isnan(y);
        x = x(~io);
        y = y(~io);
end

