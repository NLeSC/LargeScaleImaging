function fh = format_figure(square_data, batch_size, cmap, ...
    colorbar_ticks, colorbar_labels, title_str, full_axis_labels, tick_step)

if isempty(tick_step)
    tick_step = 1;
end

fh = figure('units','normalized','outerposition',[0 0 1 1]);

figure(fh);
hold on;
imagesc(square_data);
data_size = size(square_data,1);

ax = gca;
ax.XTick = 1:tick_step:data_size;
ax.XTickLabels = 1:tick_step:data_size;
ax.XTickLabelRotation = 45;
ax.YTick = 1:tick_step:data_size;
ax.YTickLabel = full_axis_labels(1:tick_step:end);
% ax.YTickLabelRotation = 30;
ax.TickLabelInterpreter = 'None';
axis square; axis on, grid on
%load MyColormaps; colormap(mycmap);
colormap(cmap);
if isempty(colorbar_ticks) && isempty(colorbar_labels)
    colorbar;
else
    colorbar('Ticks',colorbar_ticks, 'TickLabels',colorbar_labels);
end
title(title_str, 'Interpreter', 'none');

hold on;

for l = 0.5:batch_size:data_size + 0.5
    x = [0.5 data_size + 0.5];
    y = [l l];
    plot(x,y,'Color','w','LineStyle','-');
    plot(x,y,'Color','r','LineStyle',':');
end
for l = 0.5:batch_size:data_size+0.5
    x = [l l];
    y = [0.5 data_size + 0.5];
    plot(x,y,'Color','w','LineStyle','-');
    plot(x,y,'Color','r','LineStyle',':');
end

hold off;
end
